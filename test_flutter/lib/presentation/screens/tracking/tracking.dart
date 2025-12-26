import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/widgets/camera_preview_widget.dart';
import 'package:test_flutter/presentation/widgets/loading/app_fullscreen_loader.dart';
import 'package:test_flutter/feature/tracking/tracking_functions.dart';
import 'package:test_flutter/feature/tracking/detection/detection_controller.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_performance_config.dart';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/tracking/tracking_data_functions.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/presentation/widgets/level_progress_card.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/presentation/widgets/entitlement_gate.dart';
import 'package:test_flutter/feature/tracking/tracking_limit_providers.dart';
import 'package:test_flutter/data/sources/date_utils.dart' as DateUtilsHelper;
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/data/services/audio_service.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/services/tracking_count_debug_service.dart';

enum _TrackingSetupStatus {
  loading,
  ready,
  error,
}

/// トラッキング中画面（新デザインシステム版）
class TrackingScreenNew extends ConsumerStatefulWidget {
  const TrackingScreenNew({super.key});

  @override
  ConsumerState<TrackingScreenNew> createState() => _TrackingScreenNewState();
}

class _TrackingScreenNewState extends ConsumerState<TrackingScreenNew> with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _autoSaveTimer; // 5分ごとの自動保存タイマー
  int _elapsedSeconds = 0;
  bool _isCameraOn = true;
  bool _isPowerSavingMode = false;
  _TrackingSetupStatus _setupStatus = _TrackingSetupStatus.loading;
  String? _setupErrorMessage;

  // カメラ関連
  DetectionController? _detectionController;
  CameraManager? _cameraManager;
  StreamSubscription<DetectionResult>? _detectionSubscription;
  bool _isCameraInitializing = false;
  String? _cameraError;
  final Map<DetectionInitStage, DetectionInitStatus> _initStageStatuses = {
    DetectionInitStage.camera: DetectionInitStatus.pending,
    DetectionInitStage.ai: DetectionInitStatus.pending,
  };

  // 現在検出されているカテゴリ（'study', 'pc', 'smartphone', 'personOnly', null）
  String? _currentDetection;

  // 計測時間（秒単位）
  int _studySeconds = 0;
  int _pcSeconds = 0;
  int _smartphoneSeconds = 0;
  int _personOnlySeconds = 0;
  
  // 各カテゴリの開始時刻
  DateTime? _categoryStartTime;
  String? _lastCategory;
  
  // セッション管理
  DateTime? _sessionStartTime;
  final List<DetectionPeriod> _detectionPeriods = [];
  
  // 最後の検出結果の信頼度（セッション終了時に使用）
  double? _lastDetectionConfidence;

  // 停止処理中フラグ
  bool _isStopping = false;

  // スマホアラート関連
  Timer? _alertCheckTimer;
  final AudioService _audioService = AudioService();
  
  // 連続検出時間管理（30秒以内の途切れは連続とみなす）
  static const int _smartphoneGapToleranceSeconds = 30; // 許容範囲（秒）
  int _continuousSmartphoneSeconds = 0; // 連続検出時間（秒）
  DateTime? _lastSmartphoneDetectionTime; // 最後にスマホが検出された時刻
  DateTime? _smartphoneGapStartTime; // スマホ検出が途切れた開始時刻（nullの場合は検出中）
  bool _isAlertShowing = false; // アラートダイアログが表示中かどうか
  BuildContext? _alertDialogContext; // アラートダイアログのコンテキスト（自動閉じるため）

  // カテゴリのテーマカラー
  static const Color _studyColor = AppColors.green; // 緑
  static const Color _pcColor = AppColors.blue; // 青
  static const Color _smartphoneColor = AppColors.orange; // オレンジ
  static const Color _personColor = AppColors.purple; // パープル（灰色から変更）

  // バックグラウンド検知関連
  String? _deviceType; // 現在のデバイスタイプ（'pc'または'smartphone'）
  bool _isAppInBackground = false; // アプリがバックグラウンドにあるかどうか
  Timer? _backgroundMonitoringTimer; // バックグラウンド時のPC計測用タイマー

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _deviceType = _getDeviceType();
    
    // 非同期処理を順次実行（SharedPreferencesの並列アクセスを回避）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 1. トラッキング制限をチェック
        await _checkTrackingLimitAsync();
        
        if (!mounted) return;
        
        // 2. トラッキング設定を読み込み（カメラ初期化含む）
        await _loadTrackingSettings();
        
        if (!mounted) return;
        
        // 3. タイマーを開始
        _startAutoSaveTimer();
        _startBackgroundMonitoring();
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ トラッキング画面初期化エラー: $e',
          tag: 'TrackingScreen.initState',
          stackTrace: stackTrace,
        );
        
        // エラー時もタイマーだけは開始（画面が使えなくなるのを防ぐ）
        if (mounted) {
          _startAutoSaveTimer();
          _startBackgroundMonitoring();
        }
      }
    });
  }

  /// トラッキング制限をチェック（非同期版）
  Future<void> _checkTrackingLimitAsync() async {
    if (!mounted) return;
    
    try {
      final subscriptionStatus = ref.read(subscriptionStatusProvider);
      // プレミアムユーザーは制限なし
      if (subscriptionStatus.hasPremiumAccess) {
        return;
      }
      
      // Providerを無効化して再読み込み
      ref.invalidate(dailyTrackingCountProvider);
      final canStart = ref.read(canStartTrackingProvider);
      
      if (!canStart && mounted) {
        // 制限超過の場合は課金画面に遷移
        Navigator.of(context).pop();
        NavigationHelper.push(context, AppRoutes.subscriptionNew);
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ トラッキング制限チェックエラー: $e',
        tag: 'TrackingScreen._checkTrackingLimitAsync',
        stackTrace: stackTrace,
      );
    }
  }

  /// トラッキング設定を読み込む
  Future<void> _loadTrackingSettings() async {
    try {
      // 設定をバックグラウンド更新で読み込む
      final settings = await loadTrackingSettingsWithBackgroundRefreshHelper(ref);
      
      // 設定を反映
      setState(() {
        _isCameraOn = settings.isCameraOn;
        _isPowerSavingMode = settings.isPowerSavingMode;
      });

      // アラート監視を開始
      _startAlertMonitoring(settings);

      CameraPerformanceConfig.configure(
        lowResolutionPreview: _isPowerSavingMode,
      );
      
      // カメラを初期化（設定を反映した後）
      _initializeCamera();
    } catch (e) {
      LogMk.logError(
        '❌ トラッキング設定の読み込みに失敗しました: $e',
        tag: 'TrackingScreen._loadTrackingSettings',
      );
      // エラー時はデフォルト値でカメラを初期化
      CameraPerformanceConfig.configure(
        lowResolutionPreview: _isPowerSavingMode,
      );
      _initializeCamera();
    }
  }

  /// トラッキング設定を保存する
  Future<void> _saveTrackingSettings() async {
    try {
      final currentSettings = ref.read(trackingSettingsProvider);
      final updatedSettings = currentSettings.copyWith(
        isCameraOn: _isCameraOn,
        isPowerSavingMode: _isPowerSavingMode,
      );
      
      await saveTrackingSettingsHelper(ref, updatedSettings);
    } catch (e) {
      LogMk.logError(
        '❌ トラッキング設定の保存に失敗しました: $e',
        tag: 'TrackingScreen._saveTrackingSettings',
      );
    }
  }

  /// カメラを強制的に停止する（エラーが起きても必ず停止）
  /// 
  /// この関数は、エラーが発生しても必ずカメラを停止します。
  /// 各停止処理は個別のtry-catchで囲まれているため、
  /// 一部の処理が失敗しても他の処理は実行されます。
  /// 
  /// **改善点**:
  /// 1. タイマーを先に停止（新規の検出処理を開始させない）
  /// 2. 検出を停止（実行中の検出処理の完了を待つ）
  /// 3. ストリーム購読を停止（検出結果の受信を停止）
  /// 4. 検出コントローラーを解放
  /// 5. カメラリソースを解放
  /// 
  /// **戻り値**: カメラ停止が完了した場合true
  Future<bool> _forceStopCamera({bool stopTimers = true}) async {
    LogMk.logDebug(
      '🛑 カメラ強制停止処理を開始',
      tag: 'TrackingScreen._forceStopCamera',
    );
    
    bool allSuccess = true;
    
    // 1. タイマーを停止（新規の検出処理を開始させない）
    if (stopTimers) {
      try {
        _timer?.cancel();
        _timer = null;
        _autoSaveTimer?.cancel();
        _autoSaveTimer = null;
        _alertCheckTimer?.cancel();
        _alertCheckTimer = null;
        LogMk.logDebug(
          '✅ タイマーを停止しました',
          tag: 'TrackingScreen._forceStopCamera',
        );
      } catch (e) {
        LogMk.logError(
          '❌ タイマー停止エラー: $e',
          tag: 'TrackingScreen._forceStopCamera',
        );
        allSuccess = false;
      }
    }
    
    // 2. 検出を停止（実行中の検出処理の完了を待つ）
    try {
      await _detectionController?.stop();
      LogMk.logDebug(
        '✅ 検出を停止しました（実行中の処理の完了を待機済み）',
        tag: 'TrackingScreen._forceStopCamera',
      );
    } catch (e) {
      LogMk.logError(
        '❌ 検出停止エラー: $e',
        tag: 'TrackingScreen._forceStopCamera',
      );
      allSuccess = false;
    }
    
    // 3. ストリーム購読を停止（検出結果の受信を停止）
    try {
      await _detectionSubscription?.cancel();
      _detectionSubscription = null;
      LogMk.logDebug(
        '✅ 検出ストリーム購読を停止しました',
        tag: 'TrackingScreen._forceStopCamera',
      );
    } catch (e) {
      LogMk.logError(
        '❌ ストリーム購読停止エラー: $e',
        tag: 'TrackingScreen._forceStopCamera',
      );
      allSuccess = false;
    }
    
    // 4. 検出コントローラーを解放
    try {
      await _detectionController?.dispose();
      _detectionController = null;
      LogMk.logDebug(
        '✅ 検出コントローラーを解放しました',
        tag: 'TrackingScreen._forceStopCamera',
      );
    } catch (e) {
      LogMk.logError(
        '❌ 検出コントローラー解放エラー: $e',
        tag: 'TrackingScreen._forceStopCamera',
      );
      allSuccess = false;
    }
    
    // 5. カメラリソースを解放（最重要 - エラーが起きても必ず実行）
    try {
      await _cameraManager?.dispose();
      _cameraManager = null;
      LogMk.logDebug(
        '✅ カメラリソースを解放しました',
        tag: 'TrackingScreen._forceStopCamera',
      );
    } catch (e) {
      LogMk.logError(
        '❌ カメラリソース解放エラー: $e',
        tag: 'TrackingScreen._forceStopCamera',
      );
      allSuccess = false;
      // カメラリソース解放は最重要なので、エラーでもnullに設定
      _cameraManager = null;
    }
    
    // 状態をクリア
    if (mounted) {
      setState(() {
        _currentDetection = null;
      });
    }
    
    LogMk.logDebug(
      allSuccess 
        ? '✅ カメラ強制停止処理が完了しました（すべて成功）'
        : '⚠️ カメラ強制停止処理が完了しました（一部エラーあり）',
      tag: 'TrackingScreen._forceStopCamera',
    );
    
    return allSuccess;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // カメラを確実に停止（非同期処理を待つ）
    // dispose()は同期的に実行される必要があるため、Futureを待たずに実行
    // ただし、カメラ停止処理は必ず実行される
    _forceStopCamera().catchError((e) {
      LogMk.logError(
        '❌ dispose()でのカメラ停止エラー: $e',
        tag: 'TrackingScreen.dispose',
      );
      return false;
    });
    
    // バックグラウンド監視関連のリソースを解放
    _backgroundMonitoringTimer?.cancel();
    _backgroundMonitoringTimer = null;
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // アプリがバックグラウンドにある場合（別アプリを使用している）
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInBackground = true;
      LogMk.logDebug(
        'アプリがバックグラウンドに移動しました（別アプリ使用中と判断、端末計測を開始）',
        tag: 'TrackingScreen.didChangeAppLifecycleState',
      );
      
      // バックグラウンド時は端末タイプに応じた計測を開始
      if (_deviceType == 'pc' && _currentDetection != 'smartphone') {
        _startBackgroundPcTracking();
      } else if (_deviceType == 'smartphone' && _currentDetection != 'pc') {
        _startBackgroundSmartphoneTracking();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      LogMk.logDebug(
        'アプリがフォアグラウンドに戻りました。端末計測を停止します。',
        tag: 'TrackingScreen.didChangeAppLifecycleState',
      );
      
      // フォアグラウンドに戻った時は、端末計測を停止
      final now = DateTime.now();
      if (_lastCategory == 'pc' && _deviceType == 'pc') {
        _finalizeCurrentPeriod(now);
        _lastCategory = null;
        _categoryStartTime = null;
        
        if (mounted) {
          setState(() {
            _currentDetection = null;
          });
        }
        
        LogMk.logDebug(
          'PC計測を停止しました（フォアグラウンド復帰）',
          tag: 'TrackingScreen.didChangeAppLifecycleState',
        );
      } else if (_lastCategory == 'smartphone' && _deviceType == 'smartphone') {
        _finalizeCurrentPeriod(now);
        _lastCategory = null;
        _categoryStartTime = null;
        
        if (mounted) {
          setState(() {
            _currentDetection = null;
          });
        }
        
        LogMk.logDebug(
          'スマホ計測を停止しました（フォアグラウンド復帰）',
          tag: 'TrackingScreen.didChangeAppLifecycleState',
        );
      }
    }
  }

  /// カメラの初期化
  Future<void> _initializeCamera() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isCameraInitializing = true;
      _cameraError = null;
      _setupErrorMessage = null;
      if (_setupStatus != _TrackingSetupStatus.ready) {
        _setupStatus = _TrackingSetupStatus.loading;
      }
      _initStageStatuses[DetectionInitStage.camera] = DetectionInitStatus.inProgress;
      _initStageStatuses[DetectionInitStage.ai] = DetectionInitStatus.pending;
    });

    try {
      final controller = await initializeDetection(
        options: DetectionInitOptions(
          powerSavingMode: _isPowerSavingMode,
          onStageStatusChanged: (stage, status) {
            if (!mounted) {
              return;
            }
            setState(() {
              _initStageStatuses[stage] = status;
            });
          },
        ),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          LogMk.logError(
            '❌ カメラ/AI初期化がタイムアウトしました（45秒）',
            tag: 'TrackingScreen._initializeCamera',
          );
          return null;
        },
      );

      if (!mounted) {
        await controller?.dispose();
        return;
      }

      if (controller == null) {
        setState(() {
          _isCameraInitializing = false;
          _cameraError = 'カメラの初期化に失敗しました';
          if (_setupStatus != _TrackingSetupStatus.ready) {
            _setupStatus = _TrackingSetupStatus.error;
            _setupErrorMessage = 'カメラとAIモデルの初期化に失敗しました。\n\n'
                '【対処方法】\n'
                '1. アプリを完全に終了して再起動\n'
                '2. 端末を再起動\n'
                '3. カメラ権限を確認';
          }
        });
        return;
      }

      // カメラマネージャーを取得
      final cameraManager = controller.cameraManager;

      setState(() {
        _detectionController = controller;
        _cameraManager = cameraManager;
        _isCameraInitializing = false;
        _cameraError = null;
        _initStageStatuses[DetectionInitStage.camera] = DetectionInitStatus.success;
        _initStageStatuses[DetectionInitStage.ai] = DetectionInitStatus.success;
      });

      // 検出を開始
      LogMk.logDebug(
        '🚀 検出を開始します（省電力モード: $_isPowerSavingMode）',
        tag: 'TrackingScreen._initializeCamera',
      );
      await controller.start(powerSavingMode: _isPowerSavingMode);
      _ensureSessionTimingStarted();

      // 検出結果を直接処理
      await _detectionSubscription?.cancel();
      LogMk.logDebug(
        '📡 検出結果ストリームを購読します',
        tag: 'TrackingScreen._initializeCamera',
      );
      _detectionSubscription = controller.resultStream.listen(
        (result) {
          LogMk.logDebug(
            '📥 検出結果を受信: ${result.categoryString}',
            tag: 'TrackingScreen',
          );
          _ensureSessionTimingStarted();
          _handleDetectionResult(result);
        },
        onError: (error, stackTrace) {
          LogMk.logError(
            '❌ 検出結果ストリームエラー: $error',
            tag: 'TrackingScreen',
            stackTrace: stackTrace,
          );
        },
        onDone: () {
          LogMk.logDebug(
            '🏁 検出結果ストリームが終了しました',
            tag: 'TrackingScreen',
          );
        },
      );

      if (mounted && _setupStatus != _TrackingSetupStatus.ready) {
        setState(() {
          _setupStatus = _TrackingSetupStatus.ready;
        });
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ カメラ/AI初期化エラー: $e',
        tag: 'TrackingScreen._initializeCamera',
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitializing = false;
        final errorString = e.toString();
        
        // エラーメッセージをユーザーフレンドリーに変換
        String userMessage;
        String detailedSteps;
        
        if (errorString.contains('カメラ権限') || errorString.contains('permission')) {
          userMessage = 'カメラへのアクセスが許可されていません';
          detailedSteps = '【対処方法】\n'
              '1. 設定アプリを開く\n'
              '2. このアプリを選択\n'
              '3. カメラへのアクセスを「許可」に変更\n'
              '4. アプリを再起動';
        } else if (errorString.contains('Binding has not yet been initialized')) {
          userMessage = 'AIモデルの読み込みに失敗しました';
          detailedSteps = '【対処方法】\n'
              '1. アプリを完全に終了\n'
              '2. アプリを再起動\n'
              '3. 問題が続く場合は端末を再起動';
        } else {
          userMessage = 'カメラとAIモデルの初期化に失敗しました';
          detailedSteps = '【対処方法】\n'
              '1. アプリを完全に終了して再起動\n'
              '2. 端末を再起動\n'
              '3. カメラ権限を確認\n\n'
              'エラー詳細: ${e.toString()}';
        }
        
        _cameraError = userMessage;
        _initStageStatuses[DetectionInitStage.camera] = DetectionInitStatus.failure;
        _initStageStatuses[DetectionInitStage.ai] = DetectionInitStatus.failure;
        if (_setupStatus != _TrackingSetupStatus.ready) {
          _setupStatus = _TrackingSetupStatus.error;
          _setupErrorMessage = '$userMessage\n\n$detailedSteps';
        }
      });
    }
  }

  void _retryInitialSetup() {
    if (!mounted || _isCameraInitializing) {
      return;
    }
    setState(() {
      _setupStatus = _TrackingSetupStatus.loading;
      _setupErrorMessage = null;
    });
    _initializeCamera();
  }

  Widget _buildSetupErrorView() {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.red,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                _setupErrorMessage ?? 'トラッキングの準備に失敗しました。',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retryInitialSetup,
                  child: const Text('再試行'),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// デバイスタイプを判定
  String? _getDeviceType() {
    if (kIsWeb) {
      // Web版の場合、デフォルトでPC
      return 'pc';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return 'pc';
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'smartphone';
      default:
        return null;
    }
  }

  /// バックグラウンド時のPC計測を開始
  void _startBackgroundPcTracking() {
    if (!mounted || _deviceType != 'pc') return;
    
    final now = DateTime.now();
    
    // カテゴリが変わった場合
    if (_lastCategory != 'pc') {
      // 前のカテゴリの期間を確定して時間を加算
      _finalizeCurrentPeriod(now);
      
      // PCカテゴリの開始
      _categoryStartTime = now;
      _lastCategory = 'pc';
      
      // UI更新
      setState(() {
        _currentDetection = 'pc';
      });
      
      LogMk.logDebug(
        'バックグラウンドでPC計測を開始しました',
        tag: 'TrackingScreen._startBackgroundPcTracking',
      );
    }
  }

  /// バックグラウンド時のスマホ計測を開始
  void _startBackgroundSmartphoneTracking() {
    if (!mounted || _deviceType != 'smartphone') return;
    
    final now = DateTime.now();
    
    // カテゴリが変わった場合
    if (_lastCategory != 'smartphone') {
      // 前のカテゴリの期間を確定して時間を加算
      _finalizeCurrentPeriod(now);
      
      // スマホカテゴリの開始
      _categoryStartTime = now;
      _lastCategory = 'smartphone';
      
      // UI更新
      setState(() {
        _currentDetection = 'smartphone';
      });
      
      LogMk.logDebug(
        'バックグラウンドでスマホ計測を開始しました',
        tag: 'TrackingScreen._startBackgroundSmartphoneTracking',
      );
    }
    
    // アラート監視のために、最後の検出時刻を更新
    // バックグラウンド時もアラート機能が動作するようにする
    if (_currentDetection == 'smartphone') {
      _lastSmartphoneDetectionTime = now;
      _smartphoneGapStartTime = null; // 検出中に戻す
      
      LogMk.logDebug(
        'バックグラウンド時のスマホ検出時刻を更新しました（アラート監視用）',
        tag: 'TrackingScreen._startBackgroundSmartphoneTracking',
      );
    }
  }

  /// バックグラウンド監視を開始
  void _startBackgroundMonitoring() {
    _backgroundMonitoringTimer?.cancel();
    
    _backgroundMonitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _backgroundMonitoringTimer = null;
        return;
      }
      
      final now = DateTime.now();
      
      // アプリがバックグラウンドにある場合（別アプリを使用している）
      if (_isAppInBackground && _deviceType != null) {
        // PCデバイスの場合
        if (_deviceType == 'pc') {
          // スマホが検出されている場合は、スマホを優先（PC計測より優先）
          if (_currentDetection == 'smartphone') {
            // スマホ検出中は、PC計測を停止
            if (_lastCategory == 'pc') {
              _finalizeCurrentPeriod(now);
              _lastCategory = null;
              _categoryStartTime = null;
              
              setState(() {
                _currentDetection = 'smartphone';
              });
            }
            // スマホの期間を更新（カメラ検出結果で更新される）
            return;
          }
          
          // スマホが検出されていない場合は、PC計測を継続
          if (_lastCategory != 'pc') {
            _startBackgroundPcTracking();
          }
          
          // PC計測の期間を更新
          if (_lastCategory == 'pc') {
            _updateCurrentPeriodEndTime(now, 'pc', 1.0);
          }
          return;
        }
        
        // スマホデバイスの場合
        if (_deviceType == 'smartphone') {
          // PCが検出されている場合は、PCを優先（スマホ計測より優先）
          if (_currentDetection == 'pc') {
            // PC検出中は、スマホ計測を停止
            if (_lastCategory == 'smartphone') {
              _finalizeCurrentPeriod(now);
              _lastCategory = null;
              _categoryStartTime = null;
              
              setState(() {
                _currentDetection = 'pc';
              });
            }
            // PCの期間を更新（カメラ検出結果で更新される）
            return;
          }
          
          // PCが検出されていない場合は、スマホ計測を継続
          if (_lastCategory != 'smartphone') {
            _startBackgroundSmartphoneTracking();
          }
          
          // スマホ計測の期間を更新
          if (_lastCategory == 'smartphone') {
            _updateCurrentPeriodEndTime(now, 'smartphone', 1.0);
            
            // アラート監視のために、最後の検出時刻を更新
            // バックグラウンド時もアラート機能が動作するようにする
            _lastSmartphoneDetectionTime = now;
            _smartphoneGapStartTime = null; // 検出中に戻す
          }
          return;
        }
      }
      
      // フォアグラウンド時は何もしない（カメラ検出のみ）
    });
  }

  /// 検出結果の処理
  /// 
  /// バックグラウンド時はカメラ検出を優先、それ以外はカメラ検出結果を使用
  void _handleDetectionResult(DetectionResult result) {
    if (!mounted) return;

    final now = DateTime.now(); // 現在時刻を使用（タイミング問題の解決）
    final categoryString = result.categoryString ?? 'nothingDetected';
    
    // バックグラウンド時の処理
    if (_isAppInBackground) {
      // PCデバイスの場合
      if (_deviceType == 'pc') {
        if (categoryString == 'smartphone') {
          // スマホが検出された場合は、PC計測を停止してスマホを優先
          if (_lastCategory == 'pc') {
            // PC計測がアクティブな場合は、カテゴリを切り替え
            _finalizeCurrentPeriod(now);
            _lastCategory = null;
            _categoryStartTime = null;
          }
          // カメラ検出結果の処理を続行（スマホカテゴリを計測）
        } else {
          // スマホが検出されていない場合は、PC計測を継続（カメラ検出結果は無視）
          if (_lastCategory == 'pc') {
            // PC計測中は、カメラ検出結果を無視
            return;
          }
          // PC計測が停止されている場合は、カメラ検出結果を処理
        }
      }
      // スマホデバイスの場合
      else if (_deviceType == 'smartphone') {
        if (categoryString == 'pc') {
          // PCが検出された場合は、スマホ計測を停止してPCを優先
          if (_lastCategory == 'smartphone') {
            // スマホ計測がアクティブな場合は、カテゴリを切り替え
            _finalizeCurrentPeriod(now);
            _lastCategory = null;
            _categoryStartTime = null;
          }
          // カメラ検出結果の処理を続行（PCカテゴリを計測）
        } else {
          // PCが検出されていない場合は、スマホ計測を継続（カメラ検出結果は無視）
          if (_lastCategory == 'smartphone') {
            // スマホ計測中は、カメラ検出結果を無視
            return;
          }
          // スマホ計測が停止されている場合は、カメラ検出結果を処理
        }
      }
    }
    // フォアグラウンド時は、カメラ検出結果をそのまま処理
    
    // 最後の検出結果の信頼度を保存
    _lastDetectionConfidence = result.confidence;

    // 最初の検出結果が来るまでの時間を記録
    if (_lastCategory == null && _sessionStartTime != null) {
      final initialDuration = now.difference(_sessionStartTime!);
      if (initialDuration.inSeconds > 0) {
        final settings = ref.read(trackingSettingsProvider);
        _detectionPeriods.add(DetectionPeriod(
          startTime: _sessionStartTime!,
          endTime: now,
          category: 'nothingDetected',
          confidence: 0.0,
          selectedGoalIds: {
            'study': settings.selectedStudyGoalId,
            'pc': settings.selectedPcGoalId,
            'smartphone': settings.selectedSmartphoneGoalId,
          },
        ));
        _categoryStartTime = now;
        _lastCategory = 'nothingDetected';
      }
    }

    // カテゴリが変わった場合
    if (_lastCategory != null && _lastCategory != categoryString) {
      // 前のカテゴリの期間を確定して時間を加算
      _finalizeCurrentPeriod(now);
      
      // 新しいカテゴリの開始
      _categoryStartTime = now;
      _lastCategory = categoryString;
    } else if (_lastCategory == null) {
      // 最初のカテゴリの開始
      _categoryStartTime = now;
      _lastCategory = categoryString;
    }
    
    // 現在の期間の終了時刻を更新（検出結果が来るたびに）
    _updateCurrentPeriodEndTime(now, categoryString, result.confidence);

    // スマホ検出時の連続検出時間管理
    if (categoryString == 'smartphone') {
      // スマホが検出された
      if (_smartphoneGapStartTime != null) {
        // 検出が途切れていた場合
        final gapDuration = now.difference(_smartphoneGapStartTime!);
        if (gapDuration.inSeconds <= _smartphoneGapToleranceSeconds) {
          // 30秒以内の途切れなら連続として扱う（連続検出時間は維持）
          LogMk.logDebug(
            'スマホ検出再開（${gapDuration.inSeconds}秒の途切れ、連続として扱う、連続検出時間: $_continuousSmartphoneSeconds秒）',
            tag: 'TrackingScreen._handleDetectionResult',
          );
          // 注意: アラート表示はタイマー処理で行う（次回のタイマー処理でチェックされる）
        } else {
          // 30秒超の途切れなら連続検出時間をリセット
          LogMk.logDebug(
            'スマホ検出再開（${gapDuration.inSeconds}秒の途切れ、連続検出時間をリセット）',
            tag: 'TrackingScreen._handleDetectionResult',
          );
          _continuousSmartphoneSeconds = 0;
        }
        _smartphoneGapStartTime = null; // 検出中に戻す
      }
      _lastSmartphoneDetectionTime = now;
    } else {
      // スマホ以外が検出された
      if (_lastSmartphoneDetectionTime != null && _smartphoneGapStartTime == null) {
        // 前回スマホが検出されていた場合、途切れ開始時刻を記録
        _smartphoneGapStartTime = now;
        LogMk.logDebug(
          'スマホ検出が途切れました',
          tag: 'TrackingScreen._handleDetectionResult',
        );
      }
      
      // スマホ以外が検出された場合、アラート音を停止
      // アラートダイアログが表示されている場合は自動で閉じる処理を呼ぶ
      if (_isAlertShowing) {
        _dismissAlertIfNeeded();
      } else {
        // アラートダイアログが表示されていない場合でも、音声が再生中の場合は停止
        try {
          _audioService.stop();
          LogMk.logDebug(
            'スマホ以外が検出されたため、アラート音を停止しました',
            tag: 'TrackingScreen._handleDetectionResult',
          );
        } catch (e) {
          LogMk.logWarning(
            'アラート音の停止エラー: $e',
            tag: 'TrackingScreen._handleDetectionResult',
          );
        }
      }
    }

    // UI更新
    setState(() {
      _currentDetection = categoryString;
    });
  }

  /// 現在の期間を確定して時間を加算
  void _finalizeCurrentPeriod(DateTime endTime) {
    if (_categoryStartTime == null || _lastCategory == null) return;
  
    final duration = endTime.difference(_categoryStartTime!);
    final seconds = duration.inSeconds;
  
    if (seconds <= 0) return;
  
    // 最後の期間を更新または追加
    final settings = ref.read(trackingSettingsProvider);
    final currentGoalIds = {
      'study': settings.selectedStudyGoalId,
      'pc': settings.selectedPcGoalId,
      'smartphone': settings.selectedSmartphoneGoalId,
    };
    
    if (_detectionPeriods.isNotEmpty && 
        _detectionPeriods.last.category == _lastCategory &&
        _detectionPeriods.last.startTime == _categoryStartTime) {
      // 既存の期間の終了時刻を更新
      final lastIndex = _detectionPeriods.length - 1;
      final lastPeriod = _detectionPeriods[lastIndex];
      _detectionPeriods[lastIndex] = DetectionPeriod(
        startTime: lastPeriod.startTime,
        endTime: endTime,
        category: lastPeriod.category,
        confidence: lastPeriod.confidence,
        selectedGoalIds: currentGoalIds,
      );
    } else {
      // 新しい期間を追加
      _detectionPeriods.add(DetectionPeriod(
        startTime: _categoryStartTime!,
        endTime: endTime,
        category: _lastCategory!,
        confidence: _lastDetectionConfidence ?? 0.0,
        selectedGoalIds: currentGoalIds,
      ));
    }
  
    // カテゴリ別の時間を加算（nothingDetectedは除外）
    if (_lastCategory != 'nothingDetected') {
      switch (_lastCategory) {
        case 'study':
          _studySeconds += seconds;
          break;
        case 'pc':
          _pcSeconds += seconds;
          break;
        case 'smartphone':
          _smartphoneSeconds += seconds;
          break;
        case 'personOnly':
          _personOnlySeconds += seconds;
          break;
      }
    }
  }

  /// 現在の期間の終了時刻を更新
  void _updateCurrentPeriodEndTime(DateTime endTime, String category, double confidence) {
    if (_categoryStartTime == null) return;
  
    final settings = ref.read(trackingSettingsProvider);
    final currentGoalIds = {
      'study': settings.selectedStudyGoalId,
      'pc': settings.selectedPcGoalId,
      'smartphone': settings.selectedSmartphoneGoalId,
    };
  
    if (_detectionPeriods.isNotEmpty) {
      final lastPeriod = _detectionPeriods.last;
      if (lastPeriod.category == category && 
          lastPeriod.startTime == _categoryStartTime) {
        // 期間の終了時刻を更新（同じカテゴリが続く場合）
        final lastIndex = _detectionPeriods.length - 1;
        _detectionPeriods[lastIndex] = DetectionPeriod(
          startTime: lastPeriod.startTime,
          endTime: endTime,
          category: lastPeriod.category,
          confidence: confidence,
          selectedGoalIds: currentGoalIds,
        );
        return;
      }
    }
  
    // 新しい期間を追加（最初の有効なカテゴリの場合）
    if (category != 'nothingDetected') {
      _detectionPeriods.add(DetectionPeriod(
        startTime: _categoryStartTime!,
        endTime: endTime,
        category: category,
        confidence: confidence,
        selectedGoalIds: currentGoalIds,
      ));
    }
  }

  /// アラート監視を開始
  void _startAlertMonitoring(TrackingSettings settings) {
    if (!settings.smartphoneAlertEnabled) {
      LogMk.logDebug('アラートが無効化されているため、監視を開始しません', tag: 'TrackingScreen._startAlertMonitoring');
      return;
    }

    _alertCheckTimer?.cancel();
    _continuousSmartphoneSeconds = 0;
    _isAlertShowing = false;

    final totalSeconds = settings.smartphoneAlertMinutes * 60 + settings.smartphoneAlertSeconds;
    LogMk.logDebug(
      'アラート監視を開始: ${settings.smartphoneAlertMinutes}分${settings.smartphoneAlertSeconds}秒（合計$totalSeconds秒、連続検出時間ベース）',
      tag: 'TrackingScreen._startAlertMonitoring',
    );

    _alertCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _alertCheckTimer = null;
        return;
      }

      final currentSettings = ref.read(trackingSettingsProvider);
      if (!currentSettings.smartphoneAlertEnabled) {
        timer.cancel();
        _alertCheckTimer = null;
        LogMk.logDebug('アラートが無効化されたため、監視を停止しました', tag: 'TrackingScreen._startAlertMonitoring');
        return;
      }

      final now = DateTime.now();
      final alertMinutes = currentSettings.smartphoneAlertMinutes;
      final alertSeconds = currentSettings.smartphoneAlertMinutes * 60 + currentSettings.smartphoneAlertSeconds;
      
      // 現在スマホが検出されているかどうか
      final isCurrentlyDetectingSmartphone = _currentDetection == 'smartphone';
      
      // バックグラウンド時にスマホが検出されているが、_lastSmartphoneDetectionTimeが未設定の場合
      // バックグラウンド監視のタイマーが更新する前にアラート監視のタイマーが実行される可能性があるため、
      // ここで更新する
      if (_isAppInBackground && isCurrentlyDetectingSmartphone && _lastSmartphoneDetectionTime == null) {
        _lastSmartphoneDetectionTime = now;
        _smartphoneGapStartTime = null;
        LogMk.logDebug(
          'アラート監視タイマーでバックグラウンド時のスマホ検出時刻を初期化しました',
          tag: 'TrackingScreen._startAlertMonitoring',
        );
      }
      
      // 連続検出時間の更新
      final timeSinceLastDetection = _lastSmartphoneDetectionTime != null
          ? now.difference(_lastSmartphoneDetectionTime!).inSeconds
          : 999;
      
      // 検出が途切れているかどうかを判定
      // 1. _smartphoneGapStartTimeが設定されている（検出が途切れている）
      // 2. _lastSmartphoneDetectionTimeが設定されていて、現在の検出がスマホでない
      // 3. _lastSmartphoneDetectionTimeが設定されていて、最後の検出から時間が経過している（検出結果が来ていない）
      final isDetectionGapped = _smartphoneGapStartTime != null || 
                                 (_lastSmartphoneDetectionTime != null && 
                                  !isCurrentlyDetectingSmartphone &&
                                  timeSinceLastDetection > 1); // 1秒以上経過していれば検出が途切れている

      // アラート表示中に検出が途切れたら、すぐにアラートを解除
      bool wasDismissed = false;
      if (_isAlertShowing && isDetectionGapped) {
        LogMk.logDebug(
          'アラート表示中にスマホ検出が途切れました（現在の検出: $_currentDetection, gapStartTime: $_smartphoneGapStartTime, timeSinceLastDetection: $timeSinceLastDetection秒）。アラートを解除します。',
          tag: 'TrackingScreen._startAlertMonitoring',
        );
        _dismissAlertIfNeeded();
        wasDismissed = true;
      }

      // 最後の検出から30秒以内：連続として扱う
      if (timeSinceLastDetection <= _smartphoneGapToleranceSeconds) {
        // 現在検出中の場合のみ連続検出時間を増やす
        if (_lastSmartphoneDetectionTime != null && isCurrentlyDetectingSmartphone) {
          _continuousSmartphoneSeconds++;
          
          // デバッグログ（10秒ごと）
          if (_continuousSmartphoneSeconds % 10 == 0 && _continuousSmartphoneSeconds > 0) {
            LogMk.logDebug(
              '連続検出時間: $_continuousSmartphoneSeconds秒 / $alertSeconds秒 (${(_continuousSmartphoneSeconds / alertSeconds * 100).toStringAsFixed(1)}%)',
              tag: 'TrackingScreen._startAlertMonitoring',
            );
          }
          
          // アラート表示条件をチェック
          // アラート解除後、30秒以内に再検出された場合も含む
          // wasDismissedがtrueの場合でも、30秒以内に再検出されていればアラートを再表示
          if (_continuousSmartphoneSeconds >= alertSeconds && !_isAlertShowing) {
            LogMk.logDebug(
              'アラート条件を満たしました: $_continuousSmartphoneSeconds秒 >= $alertSeconds秒（wasDismissed: $wasDismissed）',
              tag: 'TrackingScreen._startAlertMonitoring',
            );
            // 非同期実行前に再度チェック（_dismissAlertIfNeededが実行された可能性があるため）
            if (!_isAlertShowing) {
              _showSmartphoneAlert(alertMinutes);
            }
          }
        }
      } else {
        // 30秒以上経過：アラート表示中なら自動で閉じる（連続検出時間は維持）
        if (_isAlertShowing) {
          LogMk.logDebug(
            'スマホ検出が途切れました（$timeSinceLastDetection秒経過、現在の検出: $_currentDetection）。アラートを解除します。',
            tag: 'TrackingScreen._startAlertMonitoring',
          );
          _dismissAlertIfNeeded();
        }
        
        // 連続検出時間をリセットする条件：
        // 1. アラートが表示されていない
        // 2. 連続検出時間が0より大きい
        // 3. _smartphoneGapStartTimeが設定されている（検出が途切れている状態）
        //    （_smartphoneGapStartTimeがnullの場合は、「連続として扱う」と判断された状態なのでリセットしない）
        if (!_isAlertShowing && 
            _continuousSmartphoneSeconds > 0 && 
            _smartphoneGapStartTime != null) {
          LogMk.logDebug(
            '連続検出時間をリセット（$timeSinceLastDetection秒経過、アラート未表示、gapStartTime: $_smartphoneGapStartTime）',
            tag: 'TrackingScreen._startAlertMonitoring',
          );
          _continuousSmartphoneSeconds = 0;
        } else if (!_isAlertShowing && 
                   _continuousSmartphoneSeconds > 0 && 
                   _smartphoneGapStartTime == null) {
          // 「連続として扱う」と判断された状態なので、リセットしない
          LogMk.logDebug(
            '連続検出時間を維持（$timeSinceLastDetection秒経過、gapStartTime: null、連続として扱う）',
            tag: 'TrackingScreen._startAlertMonitoring',
          );
        }
      }
    });
  }

  /// スマホアラートを表示
  Future<void> _showSmartphoneAlert(int alertMinutes) async {
    if (!mounted) return;

    // 現在の設定から秒数を取得
    final currentSettings = ref.read(trackingSettingsProvider);
    final alertSeconds = currentSettings.smartphoneAlertSeconds;
    final totalSeconds = alertMinutes * 60 + alertSeconds;
    
    // 表示用の時間文字列を生成
    String timeDisplay;
    if (alertMinutes > 0 && alertSeconds > 0) {
      timeDisplay = '$alertMinutes分$alertSeconds秒';
    } else if (alertMinutes > 0) {
      timeDisplay = '$alertMinutes分';
    } else if (alertSeconds > 0) {
      timeDisplay = '$alertSeconds秒';
    } else {
      timeDisplay = '$totalSeconds秒';
    }

    LogMk.logDebug(
      'スマホアラートを表示します: $timeDisplay（合計$totalSeconds秒）',
      tag: 'TrackingScreen._showSmartphoneAlert',
    );

    // 音声アラートをループ再生
    try {
      await _audioService.playAlertSoundLoop();
      LogMk.logDebug('音声アラートをループ再生しました', tag: 'TrackingScreen._showSmartphoneAlert');
    } catch (e) {
      LogMk.logError(
        '音声アラートの再生エラー: $e',
        tag: 'TrackingScreen._showSmartphoneAlert',
        error: e,
      );
    }

    // ダイアログを表示
    if (!mounted) return;
    
    // 既にアラートが表示されている場合はスキップ
    if (_isAlertShowing) {
      LogMk.logDebug(
        'アラートは既に表示中のため、スキップします',
        tag: 'TrackingScreen._showSmartphoneAlert',
      );
      return;
    }
    
    try {
      _isAlertShowing = true;
      LogMk.logDebug(
        'アラートダイアログを表示しました（_isAlertShowing: true）',
        tag: 'TrackingScreen._showSmartphoneAlert',
      );
      
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        // バリアを透明にして、カメラプレビューが見えるようにする
        // これにより、ブラウザがカメラストリームを継続して処理し続ける
        barrierColor: Colors.black.withValues(alpha: 0.3),
        builder: (dialogContext) {
          // ダイアログコンテキストを保存（自動閉じるため）
          _alertDialogContext = dialogContext;
          return BlinkingAlertDialog(
            message: 'スマホを$timeDisplay以上使用しています。\n休憩を取ることをお勧めします。',
            onDismiss: () {
              // ユーザーが手動で閉じた場合のみここが呼ばれる
              // (_dismissAlertIfNeededで自動で閉じた場合は、既に状態がリセットされている)
              if (_isAlertShowing) {
                _isAlertShowing = false;
                _alertDialogContext = null;
                LogMk.logDebug(
                  'アラートダイアログをユーザーが手動で閉じました',
                  tag: 'TrackingScreen._showSmartphoneAlert',
                );
              }
            },
          );
        },
      );
      
      // await完了後の処理は削除（状態はonDismissまたは_dismissAlertIfNeededで管理される）
      LogMk.logDebug(
        'showDialog完了（状態: _isAlertShowing=$_isAlertShowing）',
        tag: 'TrackingScreen._showSmartphoneAlert',
      );
    } catch (e) {
      LogMk.logError(
        'アラートダイアログの表示エラー: $e',
        tag: 'TrackingScreen._showSmartphoneAlert',
        error: e,
      );
      _isAlertShowing = false;
      _alertDialogContext = null;
    }
  }

  /// アラート表示中にスマホが検出されなくなった場合に自動で閉じる
  /// 
  /// 注意: 連続検出時間はリセットしない（30秒以内に再検出された場合は
  /// 連続として扱い、設定時間を超えていたらすぐにアラートを再表示するため）
  void _dismissAlertIfNeeded() {
    if (!_isAlertShowing || _alertDialogContext == null) {
      LogMk.logDebug(
        'アラート解除をスキップ（_isAlertShowing: $_isAlertShowing, _alertDialogContext: $_alertDialogContext）',
        tag: 'TrackingScreen._dismissAlertIfNeeded',
      );
      return;
    }

    try {
      LogMk.logDebug(
        'スマホ検出が途切れたため、アラートを自動で閉じます（連続検出時間は維持: $_continuousSmartphoneSeconds秒）',
        tag: 'TrackingScreen._dismissAlertIfNeeded',
      );
      
      // 状態を先にリセット（Navigator.pop()の前に、重複実行を防ぐ）
      final dialogContext = _alertDialogContext;
      _isAlertShowing = false;
      _alertDialogContext = null;
      
      // ダイアログを閉じる
      if (dialogContext != null && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }
      
      // 音声アラートも停止
      _audioService.stop();
      
      LogMk.logDebug(
        'アラートを自動で閉じました（連続検出時間: $_continuousSmartphoneSeconds秒）',
        tag: 'TrackingScreen._dismissAlertIfNeeded',
      );
    } catch (e) {
      LogMk.logError(
        'アラート自動閉じ処理エラー: $e',
        tag: 'TrackingScreen._dismissAlertIfNeeded',
        error: e,
      );
      // エラーが発生しても状態はリセット（連続検出時間は維持）
      _isAlertShowing = false;
      _alertDialogContext = null;
    }
  }

  /// スマホアラート設定ダイアログを表示
  Future<void> _showSmartphoneAlertSettingsDialog() async {
    if (!mounted) return;

    final currentSettings = ref.read(trackingSettingsProvider);
    bool alertEnabled = currentSettings.smartphoneAlertEnabled;
    int alertMinutes = currentSettings.smartphoneAlertMinutes;
    int alertSeconds = currentSettings.smartphoneAlertSeconds;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AppDialogBase(
          title: 'スマホ使用時間アラート設定',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'アラートを有効にする',
                    style: AppTextStyles.body1,
                  ),
                  AppToggleSwitch(
                    value: alertEnabled,
                    onChanged: (value) {
                      setDialogState(() {
                        alertEnabled = value;
                      });
                    },
                    activeColor: AppColors.orange,
                  ),
                ],
              ),
              if (alertEnabled) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  'アラート時間',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                // 分の設定
                Text(
                  '分',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: alertMinutes.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 60,
                        label: '$alertMinutes分',
                        activeColor: AppColors.orange,
                        inactiveColor: AppColors.gray.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setDialogState(() {
                            alertMinutes = value.round();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Container(
                      width: 60,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Text(
                        '$alertMinutes分',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // 秒の設定
                Text(
                  '秒',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: alertSeconds.toDouble(),
                        min: 0,
                        max: 59,
                        divisions: 59,
                        label: '$alertSeconds秒',
                        activeColor: AppColors.orange,
                        inactiveColor: AppColors.gray.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setDialogState(() {
                            alertSeconds = value.round();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Container(
                      width: 60,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Text(
                        '$alertSeconds秒',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                // 合計時間の表示
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '合計: ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        alertMinutes > 0 || alertSeconds > 0
                            ? '${alertMinutes * 60 + alertSeconds}秒'
                            : '0秒',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            SecondaryButton(
              text: 'キャンセル',
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              size: ButtonSize.small,
              borderRadius: 30,
            ),
            SizedBox(width: AppSpacing.sm),
            PrimaryButton(
              text: '保存',
              onPressed: () async {
                final updatedSettings = currentSettings.copyWith(
                  smartphoneAlertEnabled: alertEnabled,
                  smartphoneAlertMinutes: alertMinutes,
                  smartphoneAlertSeconds: alertSeconds,
                );
                await saveTrackingSettingsHelper(ref, updatedSettings);
                
                // アラート監視を再開
                _startAlertMonitoring(updatedSettings);
                
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              size: ButtonSize.small,
              borderRadius: 30,
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _timer = null;
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });
    });
  }
  
  /// 5分ごとの自動保存タイマーを開始
  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!mounted || _isStopping) {
        timer.cancel();
        return;
      }
      
      await _saveSessionProgress();
    });
  }
  
  /// セッションの途中保存（5分ごと）
  Future<void> _saveSessionProgress() async {
    if (_sessionStartTime == null) return;
    
    try {
      // セッション情報は削除されたため、途中保存は行わない
      // 統計データはトラッキング終了時にStatisticsAggregationServiceで集計される
      LogMk.logDebug(
        'ℹ️ セッション途中保存はスキップ（統計データはトラッキング終了時に集計）',
        tag: 'TrackingScreen._saveSessionProgress',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ セッション途中保存エラー: $e',
        tag: 'TrackingScreen._saveSessionProgress',
        stackTrace: stackTrace,
      );
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTimeWithSeconds(int seconds) {
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins}m ${secs}s';
    } else if (mins > 0) {
      return '${mins}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  void _ensureSessionTimingStarted() {
    final wasNotStarted = _sessionStartTime == null;
    _sessionStartTime ??= DateTime.now();
    if (_timer == null) {
      _startTimer();
    }
    // セッション開始時に回数をカウント（初回のみ）
    if (wasNotStarted) {
      // トラッキング開始時にカテゴリ別の秒数をリセット
      _studySeconds = 0;
      _pcSeconds = 0;
      _smartphoneSeconds = 0;
      _personOnlySeconds = 0;
      
      // 連続検出時間関連の変数をリセット
      _continuousSmartphoneSeconds = 0;
      _lastSmartphoneDetectionTime = null;
      _smartphoneGapStartTime = null;
      _isAlertShowing = false;
      _alertDialogContext = null;
      
      // バックグラウンド監視関連の変数をリセット
      
      final subscriptionStatus = ref.read(subscriptionStatusProvider);
      // 無料プランの場合のみカウント
      if (!subscriptionStatus.hasPremiumAccess) {
        LogMk.logDebug('トラッキング回数をインクリメントします', tag: 'TrackingScreen._startTracking');
        
        DailyTrackingCountHelper.increment(ref).then((newCount) async {
          LogMk.logDebug('トラッキング回数をインクリメントしました: $newCount', tag: 'TrackingScreen._startTracking');
          
          // デバッグ: Firestore保存状態を確認
          await TrackingCountDebugService.checkTrackingCountStatus();
          
          if (mounted) {
            // Providerを無効化して再読み込み
            ref.invalidate(dailyTrackingCountProvider);
          }
        }).catchError((e, stackTrace) {
          LogMk.logError('トラッキング回数のインクリメントエラー', tag: 'TrackingScreen._startTracking', error: e, stackTrace: stackTrace);
        });
      }
    }
  }
  
  /// 現在のカテゴリの経過時間を含めた秒数を取得
  /// 
  /// [category]が現在検出されているカテゴリと一致する場合のみ、経過時間を加算します。
  int _getCurrentCategorySeconds(int baseSeconds, String category) {
    // 現在検出されているカテゴリと一致する場合のみ、経過時間を加算
    if (_currentDetection == category && _categoryStartTime != null) {
      final now = DateTime.now();
      final duration = now.difference(_categoryStartTime!);
      return baseSeconds + duration.inSeconds;
    }
    return baseSeconds;
  }

  void _handleStop() async {
    // 既に処理中の場合は何もしない
    if (_isStopping) return;
    final totalStopwatch = Stopwatch()..start();
    
    // 処理中フラグを設定（全画面ローディング画面を表示）
    setState(() {
      _isStopping = true;
    });
    
    try {
      // ===== 最優先: カメラ機能とモデルの検出を終了 =====
      LogMk.logDebug(
        '🛑 カメラ停止処理を開始',
        tag: 'TrackingScreen._handleStop',
      );
      
      // 共通のカメラ停止処理を使用（完全に停止するまで待つ）
      final cameraStopwatch = Stopwatch()..start();
      await _forceStopCamera();
      cameraStopwatch.stop();
      
      // 状態をクリア
      if (mounted) {
        setState(() {
          _detectionController = null;
          _cameraManager = null;
        });
      }
      
      LogMk.logDebug(
        '✅ カメラ停止処理が完了しました (${cameraStopwatch.elapsedMilliseconds}ms)',
        tag: 'TrackingScreen._handleStop',
      );
      
      // ===== その後: セッションデータの処理 =====
      final sessionEndTime = DateTime.now();
      
      // 最後のカテゴリの期間を確定して時間を加算
      _finalizeCurrentPeriod(sessionEndTime);

      // TrackingSessionを作成
      TrackingSession? trackingSession;
      if (_sessionStartTime != null) {
        // デバッグ: カテゴリ別時間をログに出力
        LogMk.logDebug(
          '📊 カテゴリ別時間（セッション作成前）',
          tag: 'TrackingScreen._handleStop',
        );
        LogMk.logDebug(
          '  study: $_studySeconds秒',
          tag: 'TrackingScreen._handleStop',
        );
        LogMk.logDebug(
          '  pc: $_pcSeconds秒',
          tag: 'TrackingScreen._handleStop',
        );
        LogMk.logDebug(
          '  smartphone: $_smartphoneSeconds秒',
          tag: 'TrackingScreen._handleStop',
        );
        LogMk.logDebug(
          '  personOnly: $_personOnlySeconds秒',
          tag: 'TrackingScreen._handleStop',
        );
        LogMk.logDebug(
          '📊 検出期間数: ${_detectionPeriods.length}件',
          tag: 'TrackingScreen._handleStop',
        );
        
        final sessionBuildStopwatch = Stopwatch()..start();

        // セッション開始時の選択目標IDを取得
        final settings = ref.read(trackingSettingsProvider);
        final selectedGoalIds = {
          'study': settings.selectedStudyGoalId,
          'pc': settings.selectedPcGoalId,
          'smartphone': settings.selectedSmartphoneGoalId,
        };
        
        // TrackingSessionを作成
        final sessionId = '${_sessionStartTime!.millisecondsSinceEpoch}';
        trackingSession = TrackingSession(
          id: sessionId,
          startTime: _sessionStartTime!,
          endTime: sessionEndTime,
          categorySeconds: {
            'study': _studySeconds,
            'pc': _pcSeconds,
            'smartphone': _smartphoneSeconds,
            'personOnly': _personOnlySeconds,
          },
          detectionPeriods: _detectionPeriods,
          selectedGoalIds: selectedGoalIds,
          lastModified: DateTime.now(),
        );
        sessionBuildStopwatch.stop();
        LogMk.logDebug(
          '⏱️ セッション生成完了: ${sessionBuildStopwatch.elapsedMilliseconds}ms',
          tag: 'TrackingScreen._handleStop',
        );

        // トラッキングセッションのローカル保存を削除
        // 統計データはdaily statisticsに集計済みのため、tracking sessionsは保存不要
        // Providerのみ更新（画面表示用）
        try {
          ref.read(trackingSessionsProvider.notifier).upsertSession(trackingSession);
          LogMk.logDebug(
            '✅ トラッキングセッションをProviderに反映: ${trackingSession.id}',
            tag: 'TrackingScreen._handleStop',
          );
        } catch (e, stackTrace) {
          LogMk.logError(
            '❌ トラッキングセッションProvider更新エラー: $e',
            tag: 'TrackingScreen._handleStop',
            stackTrace: stackTrace,
          );
        }

        // ログに出力
        _logSessionData(trackingSession);
      }
      
      // 次の画面へ遷移（TrackingSessionを引数として渡す）
      if (mounted) {
        NavigationHelper.push(
          context,
          AppRoutes.trackingFinishedNew,
          arguments: trackingSession,
        );
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 停止処理中にエラーが発生しました: $e',
        tag: 'TrackingScreen._handleStop',
        stackTrace: stackTrace,
      );
      
      // エラーが発生しても次の画面へ遷移
      if (mounted) {
        NavigationHelper.push(context, AppRoutes.trackingFinishedNew);
      }
    } finally {
      totalStopwatch.stop();
      LogMk.logDebug(
        '⏱️ 停止処理全体の所要時間: ${totalStopwatch.elapsedMilliseconds}ms',
        tag: 'TrackingScreen._handleStop',
      );
      // 処理中フラグをリセット
      if (mounted) {
        setState(() {
          _isStopping = false;
        });
      }
    }
  }

  /// セッションデータをログに出力
  void _logSessionData(TrackingSession session) {
    LogMk.logDebug(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '📊 トラッキングセッション完了',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      'セッションID: ${session.id}',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '開始時刻: ${_formatDateTime(session.startTime)}',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '終了時刻: ${_formatDateTime(session.endTime)}',
      tag: 'TrackingSession',
    );
    final totalSeconds = session.duration.inSeconds;
    LogMk.logDebug(
      '合計時間: $totalSeconds秒',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '検出期間数: ${session.detectionPeriods.length}件',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '📈 カテゴリ別時間',
      tag: 'TrackingSession',
    );
    final studySeconds = session.categorySeconds['study'] ?? 0;
    final pcSeconds = session.categorySeconds['pc'] ?? 0;
    final smartphoneSeconds = session.categorySeconds['smartphone'] ?? 0;
    final personOnlySeconds = session.categorySeconds['personOnly'] ?? 0;
    
    LogMk.logDebug(
      '  Study: $studySeconds秒',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '  PC: $pcSeconds秒',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '  Smartphone: $smartphoneSeconds秒',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '  PersonOnly: $personOnlySeconds秒',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'TrackingSession',
    );
    LogMk.logDebug(
      '⏱️ 検出期間リスト（時系列・連続）',
      tag: 'TrackingSession',
    );
    if (session.detectionPeriods.isEmpty) {
      LogMk.logDebug(
        '  検出期間なし',
        tag: 'TrackingSession',
      );
    } else {
      // 時系列を確認して、空白がないことを検証
      DateTime? lastEndTime;
      for (var i = 0; i < session.detectionPeriods.length; i++) {
        final period = session.detectionPeriods[i];
        
        // 空白期間のチェック
        if (lastEndTime != null && period.startTime != lastEndTime) {
          final gapSeconds = period.startTime.difference(lastEndTime).inSeconds;
          LogMk.logWarning(
            '  ⚠️ 空白期間検出: ${lastEndTime.toString()} → ${period.startTime.toString()} ($gapSeconds秒)',
            tag: 'TrackingSession',
          );
        }
        
        final durationSeconds = period.endTime.difference(period.startTime).inSeconds;
        LogMk.logDebug(
          '  [${i + 1}] ${period.category}',
          tag: 'TrackingSession',
        );
        LogMk.logDebug(
          '      開始: ${_formatDateTime(period.startTime)}',
          tag: 'TrackingSession',
        );
        LogMk.logDebug(
          '      終了: ${_formatDateTime(period.endTime)}',
          tag: 'TrackingSession',
        );
        LogMk.logDebug(
          '      継続時間: $durationSeconds秒',
          tag: 'TrackingSession',
        );
        LogMk.logDebug(
          '      信頼度: ${period.confidence.toStringAsFixed(2)}',
          tag: 'TrackingSession',
        );
        
        lastEndTime = period.endTime;
      }
      
      // セッション終了時刻との整合性チェック
      if (lastEndTime != null && lastEndTime != session.endTime) {
        final gapSeconds = session.endTime.difference(lastEndTime).inSeconds;
        LogMk.logWarning(
          '  ⚠️ 最後の検出期間とセッション終了時刻に差があります: $gapSeconds秒',
          tag: 'TrackingSession',
        );
      }
    }
    LogMk.logDebug(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'TrackingSession',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    // 停止処理中の場合は全画面ローディングを表示
    if (_isStopping) {
      return const AppFullScreenLoader(
        message: '処理中...',
      );
    }

    if (_setupStatus == _TrackingSetupStatus.loading) {
      return const AppFullScreenLoader(
        message: 'カメラとAIモデルを初期化しています...',
      );
    }

    if (_setupStatus == _TrackingSetupStatus.error) {
      return _buildSetupErrorView();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        // 戻るボタンが押された場合、カメラを停止してから画面を閉じる
        LogMk.logDebug(
          '🔙 戻るボタンが押されました。カメラを停止します。',
          tag: 'TrackingScreen.build',
        );
        
        // カメラを完全に停止
        await _forceStopCamera();
        
        // カメラ停止が完了したら画面を閉じる
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      child: AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      height: screenHeight * 0.10,
                      child: _buildLevelStatus(),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // カメラ映像表示エリア
                    SizedBox(
                      height: screenHeight * 0.20,
                      child: _buildCameraArea(),
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // 目標達成率
                    Expanded(
                      child: _buildGoalProgress(),
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // 検出状況（4つのカテゴリボタン）
                    SizedBox(
                      height: screenHeight * 0.25,
                      child: _buildDetectionStatus(),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // 終了ボタン
                    SizedBox(
                      height: screenHeight * 0.08,
                      child: _buildStopButton(),
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLevelStatus() {
    final levelState = ref.watch(levelingStateProvider);
    return LevelProgressCard(
      state: levelState,
      additionalPersonSeconds: _personOnlySeconds,
      showCountdown: false,
    );
  }

  Widget _buildCameraArea() {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final powerSavingUnlocked = EntitlementRules.canUse(
      subscriptionStatus,
      PremiumFeature.powerSavingMode,
    );

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Stack(
        children: [
          // カメラプレビューまたはエラー表示
          if (_isCameraInitializing)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              _buildInitStageStatusRow(
                label: 'カメラ準備中',
                stage: DetectionInitStage.camera,
              ),
              SizedBox(height: AppSpacing.xs),
              _buildInitStageStatusRow(
                label: 'AIモデル準備中',
                stage: DetectionInitStage.ai,
              ),
                ],
              ),
            )
          else if (_cameraError != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.red,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    _cameraError!,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _initializeCamera,
                    child: const Text('再試行'),
                  ),
                ],
              ),
            )
          else if (_cameraManager != null)
            Center(
              child: RepaintBoundary(
                child: CameraPreviewWidget(
                  key: ValueKey('camera-preview-${_cameraManager.hashCode}'),
                  cameraManager: _cameraManager!,
                  isVisible: _isCameraOn,
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'カメラが利用できません',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          // タイマー表示（左上）
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                _formatDuration(_elapsedSeconds),
                style: AppTextStyles.h3.copyWith(
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          // カメラオン/省電力ボタン（右上）
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: Column(
              children: [
                _buildSmallControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  isActive: _isCameraOn,
                  onTap: () {
                    final nextState = !_isCameraOn;
                    setState(() {
                      _isCameraOn = nextState;
                    });
                    if (nextState) {
                      final resumeFuture = _cameraManager?.resume();
                      if (resumeFuture != null) {
                        unawaited(resumeFuture);
                      }
                    } else {
                      final pauseFuture = _cameraManager?.pause();
                      if (pauseFuture != null) {
                        unawaited(pauseFuture);
                      }
                    }
                    // 設定を保存
                    _saveTrackingSettings();
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                _buildSmallControlButton(
                  icon: Icons.battery_saver,
                  isActive: _isPowerSavingMode,
                  isPowerSaving: true,
                  isLocked: !powerSavingUnlocked,
                  onTap: () async {
                    if (!powerSavingUnlocked) {
                      Navigator.of(context).pushNamed(AppRoutes.subscriptionNew);
                      return;
                    }
                    setState(() {
                      _isPowerSavingMode = !_isPowerSavingMode;
                    });
                    CameraPerformanceConfig.configure(
                      lowResolutionPreview: _isPowerSavingMode,
                    );
                    // 省電力モードを切り替え
                    await _detectionController?.setPowerSavingMode(_isPowerSavingMode);
                    await _forceStopCamera(stopTimers: false);
                    await _initializeCamera();
                    // 設定を保存
                    _saveTrackingSettings();
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(trackingSettingsProvider);
                    return _buildSmallControlButton(
                      icon: Icons.notifications_active,
                      isActive: settings.smartphoneAlertEnabled,
                      isPowerSaving: false,
                      isLocked: false,
                      onTap: () async {
                        await _showSmartphoneAlertSettingsDialog();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitStageStatusRow({
    required String label,
    required DetectionInitStage stage,
  }) {
    final status = _initStageStatuses[stage] ?? DetectionInitStatus.pending;
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case DetectionInitStatus.inProgress:
        icon = Icons.sync;
        color = AppColors.textDisabled;
        statusText = '処理中';
        break;
      case DetectionInitStatus.success:
        icon = Icons.check_circle;
        color = AppColors.green;
        statusText = '完了';
        break;
      case DetectionInitStatus.failure:
        icon = Icons.error;
        color = AppColors.red;
        statusText = 'エラー';
        break;
      case DetectionInitStatus.pending:
        icon = Icons.pause_circle;
        color = AppColors.textSecondary;
        statusText = '待機中';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: AppSpacing.xs),
        Text(
          '$label - $statusText',
          style: AppTextStyles.body2.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isPowerSaving = false,
    bool isLocked = false,
  }) {
    final activeColor = isPowerSaving ? AppColors.green : AppColors.blue;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.backgroundCard.withValues(alpha: 0.5)
                    : isActive
                        ? activeColor.withValues(alpha: 0.2)
                        : AppColors.backgroundCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: isLocked
                      ? AppColors.textSecondary.withValues(alpha: 0.3)
                      : isActive
                          ? activeColor
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isLocked
                    ? AppColors.textSecondary
                    : isActive
                        ? activeColor
                        : AppColors.textSecondary,
                size: 20,
              ),
            ),
            if (isLocked)
              const Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.lock,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildDetectionStatus() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryButton(
                category: 'study',
                icon: Icons.menu_book,
                label: 'Study',
                color: _studyColor,
                seconds: _studySeconds,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'pc',
                icon: Icons.computer,
                label: 'PC',
                color: _pcColor,
                seconds: _pcSeconds,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'smartphone',
                icon: Icons.smartphone,
                label: 'Phone',
                color: _smartphoneColor,
                seconds: _smartphoneSeconds,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'personOnly',
                icon: Icons.person,
                label: 'Person',
                color: _personColor,
                seconds: _personOnlySeconds,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryButton({
    required String category,
    required IconData icon,
    required String label,
    required Color color,
    required int seconds,
  }) {
    final isDetected = _currentDetection == category;
    
    // 現在のカテゴリの場合は、追加で経過時間を加算
    final displaySeconds = _getCurrentCategorySeconds(seconds, category);

    return Container(
      decoration: BoxDecoration(
        color: isDetected
            ? color.withValues(alpha: 0.2)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isDetected
              ? color.withValues(alpha: 0.6)
              : AppColors.blackgray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDetected ? 0.3 : 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color.withValues(alpha: isDetected ? 1.0 : 0.8),
                size: 24,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: isDetected 
                    ? color.withValues(alpha: 1.0)
                    : color.withValues(alpha: 0.7),
                fontWeight: isDetected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimeWithSeconds(displaySeconds),
              style: AppTextStyles.body2.copyWith(
                color: isDetected 
                    ? color.withValues(alpha: 1.0)
                    : color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildGoalProgress() {
    final goals = ref.watch(goalsListProvider);
    final settings = ref.watch(trackingSettingsProvider);
    
    // 選択された目標IDを取得
    final selectedStudyGoalId = settings.selectedStudyGoalId;
    final selectedPcGoalId = settings.selectedPcGoalId;
    final selectedSmartphoneGoalId = settings.selectedSmartphoneGoalId;
    
    // 各カテゴリーの目標を取得
    final studyGoals = goals.where((g) => g.detectionItem == DetectionItem.book).toList();
    final pcGoals = goals.where((g) => g.detectionItem == DetectionItem.pc).toList();
    final smartphoneGoals = goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList();
    
    // 選択された目標を取得（存在しない場合は最初の目標を自動選択）
    final todayDate = DateUtilsHelper.DateUtils.getTodayDate(ref);
    final todaysGoals = <Goal>[];
    
    // Study目標
    if (studyGoals.isNotEmpty) {
      Goal? studyGoal;
      if (selectedStudyGoalId != null) {
        studyGoal = studyGoals.firstWhere(
          (g) => g.id == selectedStudyGoalId,
          orElse: () => studyGoals[0],
        );
      } else {
        studyGoal = studyGoals[0];
      }
      
      // 期間が今日を含むかチェック（reset time settingを考慮）
      final endDate = studyGoal.periodEndDate ??
          studyGoal.startDate.add(Duration(days: studyGoal.durationDays));
      final startDateOnly = DateTime(studyGoal.startDate.year, studyGoal.startDate.month, studyGoal.startDate.day);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      if (todayDate.isAfter(startDateOnly.subtract(const Duration(days: 1))) &&
          todayDate.isBefore(endDateOnly.add(const Duration(days: 1)))) {
        todaysGoals.add(studyGoal);
      }
    }
    
    // PC目標
    if (pcGoals.isNotEmpty) {
      Goal? pcGoal;
      if (selectedPcGoalId != null) {
        pcGoal = pcGoals.firstWhere(
          (g) => g.id == selectedPcGoalId,
          orElse: () => pcGoals[0],
        );
      } else {
        pcGoal = pcGoals[0];
      }
      
      // 期間が今日を含むかチェック（reset time settingを考慮）
      final endDate = pcGoal.periodEndDate ??
          pcGoal.startDate.add(Duration(days: pcGoal.durationDays));
      final startDateOnly = DateTime(pcGoal.startDate.year, pcGoal.startDate.month, pcGoal.startDate.day);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      if (todayDate.isAfter(startDateOnly.subtract(const Duration(days: 1))) &&
          todayDate.isBefore(endDateOnly.add(const Duration(days: 1)))) {
        todaysGoals.add(pcGoal);
      }
    }
    
    // Smartphone目標
    if (smartphoneGoals.isNotEmpty) {
      Goal? smartphoneGoal;
      if (selectedSmartphoneGoalId != null) {
        smartphoneGoal = smartphoneGoals.firstWhere(
          (g) => g.id == selectedSmartphoneGoalId,
          orElse: () => smartphoneGoals[0],
        );
      } else {
        smartphoneGoal = smartphoneGoals[0];
      }
      
      // 期間が今日を含むかチェック（reset time settingを考慮）
      final endDate = smartphoneGoal.periodEndDate ??
          smartphoneGoal.startDate.add(Duration(days: smartphoneGoal.durationDays));
      final startDateOnly = DateTime(smartphoneGoal.startDate.year, smartphoneGoal.startDate.month, smartphoneGoal.startDate.day);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      if (todayDate.isAfter(startDateOnly.subtract(const Duration(days: 1))) &&
          todayDate.isBefore(endDateOnly.add(const Duration(days: 1)))) {
        todaysGoals.add(smartphoneGoal);
      }
    }

    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          ...todaysGoals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            final category = _getCategoryFromDetectionItem(goal.detectionItem);
            final color = _getGoalColor(category);
            
            // 今日の達成時間（目標に保存されている値）を取得
            final todayAchievedSeconds = goal.todayAchievedTime ?? 0;
            
            // セッション中の増分を取得
            int sessionSeconds;
            switch (category) {
              case 'study':
                sessionSeconds = _getCurrentCategorySeconds(_studySeconds, category);
                break;
              case 'pc':
                sessionSeconds = _getCurrentCategorySeconds(_pcSeconds, category);
                break;
              case 'smartphone':
                sessionSeconds = _getCurrentCategorySeconds(_smartphoneSeconds, category);
                break;
              default:
                sessionSeconds = 0;
            }
            
            // 今日の達成時間 + セッション中の増分
            final currentSeconds = todayAchievedSeconds + sessionSeconds;
            
            // 1日あたりの目標秒数（保存済みの値を優先し、無ければ期間から算出）
            final computedPerDay = goal.durationDays > 0
                ? (goal.targetTime / goal.durationDays).ceil()
                : goal.targetTime;
            final targetSecondsPerDay = goal.targetSecondsPerDay > 0
                ? goal.targetSecondsPerDay
                : computedPerDay;
            // 進捗率の計算（秒単位で計算）
            final progress = targetSecondsPerDay > 0
                ? (currentSeconds / targetSecondsPerDay).clamp(0.0, 1.0)
                : 0.0;
            final isDetected = _currentDetection == category;
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < todaysGoals.length - 1 ? AppSpacing.md : 0,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  onTap: () => _showGoalSelectionDialog(context, category, goal.detectionItem, color),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDetected
                          ? color.withValues(alpha: 0.2)
                          : AppColors.black,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: isDetected
                            ? color.withValues(alpha: 0.6)
                            : AppColors.gray.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: color.withValues(alpha: 1.0),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        LinearProgressBar(
                          percentage: progress,
                          height: 12,
                          progressColor: color,
                          backgroundColor: AppColors.blackgray,
                          barBackgroundColor: AppColors.gray.withValues(alpha: 0.4),
                          showFlowAnimation: isDetected,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${_formatTimeWithSeconds(currentSeconds)} / ${_formatTimeWithSeconds(targetSecondsPerDay)}',
                                style: AppTextStyles.body2.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.body2.copyWith(
                                color: color.withValues(alpha: 1.0),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _getCategoryFromDetectionItem(DetectionItem item) {
    switch (item) {
      case DetectionItem.book:
        return 'study';
      case DetectionItem.pc:
        return 'pc';
      case DetectionItem.smartphone:
        return 'smartphone';
    }
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return _studyColor;
      case 'pc':
        return _pcColor;
      case 'smartphone':
        return _smartphoneColor;
      default:
        return AppColors.blue;
    }
  }

  /// 目標選択ダイアログを表示
  Future<void> _showGoalSelectionDialog(
    BuildContext context,
    String category,
    DetectionItem detectionItem,
    Color color,
  ) async {
    final goals = ref.read(goalsListProvider);
    final settings = ref.read(trackingSettingsProvider);
    
    // 該当カテゴリーの目標を取得
    final categoryGoals = goals.where((g) => g.detectionItem == detectionItem).toList();
    
    if (categoryGoals.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No goals available for $category'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    
    // 現在選択されている目標IDを取得
    String? currentSelectedId;
    switch (category) {
      case 'study':
        currentSelectedId = settings.selectedStudyGoalId;
        break;
      case 'pc':
        currentSelectedId = settings.selectedPcGoalId;
        break;
      case 'smartphone':
        currentSelectedId = settings.selectedSmartphoneGoalId;
        break;
    }
    
    if (!context.mounted) return;
    
    final selectedGoalId = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackgray,
        title: Text(
          'Select Goal',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categoryGoals.map((goal) {
                final isSelected = currentSelectedId == goal.id;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    onTap: () => Navigator.of(context).pop(goal.id),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      margin: EdgeInsets.only(bottom: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : AppColors.gray.withValues(alpha: 0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? color : AppColors.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: AppTextStyles.body1.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${(goal.targetTime / 60).toStringAsFixed(1)}h / ${goal.durationDays} days',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
    
    if (selectedGoalId != null && selectedGoalId != currentSelectedId) {
      // 設定を更新
      final updatedSettings = settings.copyWith(
        selectedStudyGoalId: category == 'study' ? selectedGoalId : settings.selectedStudyGoalId,
        selectedPcGoalId: category == 'pc' ? selectedGoalId : settings.selectedPcGoalId,
        selectedSmartphoneGoalId: category == 'smartphone' ? selectedGoalId : settings.selectedSmartphoneGoalId,
      );
      
      await saveTrackingSettingsHelper(ref, updatedSettings);
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal updated'),
          backgroundColor: color,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildStopButton() {
    final borderRadiusValue = BorderRadius.circular(30.0);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadiusValue,
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: AppColors.blackgray,
        borderRadius: borderRadiusValue,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: _handleStop,
          borderRadius: borderRadiusValue,
          child: Container(
            height: 56.0,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stop,
                    color: AppColors.gray,
                    size: 18.0,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Stop Tracking',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

