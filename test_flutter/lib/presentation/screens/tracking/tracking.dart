import 'package:flutter/material.dart';
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
import 'package:test_flutter/feature/tracking/tracking_session_data_manager.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';
import 'package:test_flutter/feature/tracking/tracking_data_functions.dart';

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

class _TrackingScreenNewState extends ConsumerState<TrackingScreenNew> {
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
  final DailyStatisticsDataManager _dailyStatsManager = DailyStatisticsDataManager();
  final TrackingSessionDataManager _trackingSessionManager = TrackingSessionDataManager();
  
  // 最後の検出結果の信頼度（セッション終了時に使用）
  double? _lastDetectionConfidence;

  // 停止処理中フラグ
  bool _isStopping = false;

  // カテゴリのテーマカラー
  static const Color _studyColor = AppColors.green; // 緑
  static const Color _pcColor = AppColors.blue; // 青
  static const Color _smartphoneColor = AppColors.orange; // オレンジ
  static const Color _personColor = AppColors.purple; // パープル（灰色から変更）

  @override
  void initState() {
    super.initState();
    _loadTrackingSettings();
    _startAutoSaveTimer();
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
  /// **戻り値**: カメラ停止が完了した場合true
  Future<bool> _forceStopCamera({bool stopTimers = true}) async {
    LogMk.logDebug(
      '🛑 カメラ強制停止処理を開始',
      tag: 'TrackingScreen._forceStopCamera',
    );
    
    bool allSuccess = true;
    
    if (stopTimers) {
      try {
        _timer?.cancel();
        _timer = null;
        _autoSaveTimer?.cancel();
        _autoSaveTimer = null;
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
    
    // ストリーム購読を停止（最優先）
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
    
    // 検出を停止
    try {
      await _detectionController?.stop();
      LogMk.logDebug(
        '✅ 検出を停止しました',
        tag: 'TrackingScreen._forceStopCamera',
      );
    } catch (e) {
      LogMk.logError(
        '❌ 検出停止エラー: $e',
        tag: 'TrackingScreen._forceStopCamera',
      );
      allSuccess = false;
    }
    
    // 検出コントローラーを解放
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
    
    // カメラリソースを解放（最重要 - エラーが起きても必ず実行）
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
    
    super.dispose();
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
    });

    try {
      final controller = await initializeDetection();

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
            _setupErrorMessage = 'カメラとAIモデルの初期化に失敗しました。再試行してください。';
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
      });

      // 検出を開始
      await controller.start(powerSavingMode: _isPowerSavingMode);
      _ensureSessionTimingStarted();

      // 検出結果を直接処理
      await _detectionSubscription?.cancel();
      _detectionSubscription = controller.resultStream.listen((result) {
        _ensureSessionTimingStarted();
        _handleDetectionResult(result);
      });

      if (mounted && _setupStatus != _TrackingSetupStatus.ready) {
        setState(() {
          _setupStatus = _TrackingSetupStatus.ready;
        });
      }
    } catch (e) {
      LogMk.logError(
        '❌ カメラ/AI初期化エラー: $e',
        tag: 'TrackingScreen._initializeCamera',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitializing = false;
        _cameraError = 'カメラエラー: $e';
        if (_setupStatus != _TrackingSetupStatus.ready) {
          _setupStatus = _TrackingSetupStatus.error;
          _setupErrorMessage = 'カメラとAIモデルの初期化に失敗しました。再試行してください。';
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

  /// 検出結果の処理
  /// 
  /// 同じカテゴリが連続する場合は1つの期間にまとめ、空白期間を防ぐ
  void _handleDetectionResult(DetectionResult result) {
    if (!mounted) return;

    final now = DateTime.now(); // 現在時刻を使用（タイミング問題の解決）
    final categoryString = result.categoryString ?? 'nothingDetected';
    
    // 最後の検出結果の信頼度を保存
    _lastDetectionConfidence = result.confidence;

    // 最初の検出結果が来るまでの時間を記録
    if (_lastCategory == null && _sessionStartTime != null) {
      final initialDuration = now.difference(_sessionStartTime!);
      if (initialDuration.inSeconds > 0) {
        _detectionPeriods.add(DetectionPeriod(
          startTime: _sessionStartTime!,
          endTime: now,
          category: 'nothingDetected',
          confidence: 0.0,
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
      );
    } else {
      // 新しい期間を追加
      _detectionPeriods.add(DetectionPeriod(
        startTime: _categoryStartTime!,
        endTime: endTime,
        category: _lastCategory!,
        confidence: _lastDetectionConfidence ?? 0.0,
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
      ));
    }
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // セッション開始時の選択目標IDを取得
      final settings = ref.read(trackingSettingsProvider);
      final selectedGoalIds = {
        'study': settings.selectedStudyGoalId,
        'pc': settings.selectedPcGoalId,
        'smartphone': settings.selectedSmartphoneGoalId,
      };
      
      // 現在のセッション情報をSessionInfoに変換
      final sessionInfo = SessionInfo(
        id: '${_sessionStartTime!.millisecondsSinceEpoch}',
        startTime: _sessionStartTime!,
        endTime: now,
        categorySeconds: {
          'study': _studySeconds,
          'pc': _pcSeconds,
          'smartphone': _smartphoneSeconds,
          'personOnly': _personOnlySeconds,
        },
        detectionPeriods: List<DetectionPeriod>.from(_detectionPeriods),
        selectedGoalIds: selectedGoalIds,
        lastModified: now,
      );
      
      // 今日の日次統計を取得または作成（getByDateWithAuthを使用）
      final existingDailyStats = await _dailyStatsManager.getByDateWithAuth(today);
      
      DailyStatistics dailyStatsToSave;
      if (existingDailyStats != null) {
        // 既存のセッションリストを更新（同じIDのセッションがあれば置き換え、なければ追加）
        final updatedSessions = List<SessionInfo>.from(existingDailyStats.sessions);
        final existingIndex = updatedSessions.indexWhere((s) => s.id == sessionInfo.id);
        if (existingIndex >= 0) {
          updatedSessions[existingIndex] = sessionInfo;
        } else {
          updatedSessions.add(sessionInfo);
        }
        
        // 日次統計を更新（sessionsのみ更新、categorySeconds等はsaveOrUpdateWithAuth内で計算）
        dailyStatsToSave = existingDailyStats.copyWith(
          sessions: updatedSessions,
          lastModified: now,
        );
      } else {
        // 新規作成
        final year = today.year.toString();
        final month = today.month.toString().padLeft(2, '0');
        final day = today.day.toString().padLeft(2, '0');
        final id = '$year-$month-$day';
        
        dailyStatsToSave = DailyStatistics(
          id: id,
          date: today,
          categorySeconds: {},
          totalWorkTimeSeconds: 0,
          sessions: [sessionInfo],
          lastModified: now,
        );
      }
      
      // 保存（saveOrUpdateWithAuth内でupdateFromSessionsが呼ばれる）
      await _dailyStatsManager.saveOrUpdateWithAuth(dailyStatsToSave);
      
      LogMk.logDebug(
        '✅ セッション途中保存完了: ${sessionInfo.id}',
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
    if (_sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
    }
    if (_timer == null) {
      _startTimer();
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

      // SessionInfoを作成してDailyStatisticsに保存
      SessionInfo? sessionInfo;
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
        
        final sessionBuildStopwatch = Stopwatch()..start();

        // セッション開始時の選択目標IDを取得
        final settings = ref.read(trackingSettingsProvider);
        final selectedGoalIds = {
          'study': settings.selectedStudyGoalId,
          'pc': settings.selectedPcGoalId,
          'smartphone': settings.selectedSmartphoneGoalId,
        };
        
        // SessionInfoを作成
        final sessionId = '${_sessionStartTime!.millisecondsSinceEpoch}';
        final createdSessionInfo = SessionInfo(
          id: sessionId,
          startTime: _sessionStartTime!,
          endTime: sessionEndTime,
          categorySeconds: {
            'study': _studySeconds,
            'pc': _pcSeconds,
            'smartphone': _smartphoneSeconds,
            'personOnly': _personOnlySeconds,
          },
          detectionPeriods: List<DetectionPeriod>.from(_detectionPeriods),
          selectedGoalIds: selectedGoalIds,
          lastModified: DateTime.now(),
        );
        sessionInfo = createdSessionInfo;

        // TrackingSessionも作成（ログ出力用）
        final trackingSession = TrackingSession(
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

        // トラッキングセッションをローカル/Firestoreに保存し、Providerを更新
        try {
          final sessionSaveStopwatch = Stopwatch()..start();
          final saveSuccess = await _trackingSessionManager.addSessionWithAuth(
            trackingSession,
            awaitRemote: false,
          );
          sessionSaveStopwatch.stop();
          if (saveSuccess) {
            ref.read(trackingSessionsProvider.notifier).upsertSession(trackingSession);
            LogMk.logDebug(
              '✅ トラッキングセッション保存完了: ${trackingSession.id} (${sessionSaveStopwatch.elapsedMilliseconds}ms)',
              tag: 'TrackingScreen._handleStop',
            );
          } else {
            LogMk.logWarning(
              '⚠️ トラッキングセッションの保存に失敗しました: ${trackingSession.id}',
              tag: 'TrackingScreen._handleStop',
            );
          }
        } catch (e, stackTrace) {
          LogMk.logError(
            '❌ トラッキングセッション保存処理エラー: $e',
            tag: 'TrackingScreen._handleStop',
            stackTrace: stackTrace,
          );
        }

        // ログに出力
        _logSessionData(trackingSession);
      }
      
      // 次の画面へ遷移（SessionInfoを引数として渡す）
      if (mounted) {
        NavigationHelper.push(
          context,
          AppRoutes.trackingFinishedNew,
          arguments: sessionInfo,
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
          child: ScrollableContent(
            child: SpacedColumn(
              spacing: AppSpacing.lg,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 目標達成率（1番上）
                _buildGoalProgress(),

                // カメラ映像表示エリア
                _buildCameraArea(),

                // 検出状況（4つのカテゴリボタン）
                _buildDetectionStatus(),

                SizedBox(height: AppSpacing.md),

                // 終了ボタン
                _buildStopButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    return Container(
      height: 280,
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
                  Text(
                    'カメラを初期化中...',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textDisabled,
                    ),
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
            RepaintBoundary(
              child: CameraPreviewWidget(
                key: ValueKey('camera-preview-${_cameraManager.hashCode}'),
                cameraManager: _cameraManager!,
                isVisible: _isCameraOn,
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
                    setState(() {
                      _isCameraOn = !_isCameraOn;
                    });
                    // 設定を保存
                    _saveTrackingSettings();
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                _buildSmallControlButton(
                  icon: Icons.battery_saver,
                  isActive: _isPowerSavingMode,
                  isPowerSaving: true,
                  onTap: () async {
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isPowerSaving = false,
  }) {
    final activeColor = isPowerSaving ? AppColors.green : AppColors.blue;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.2)
                : AppColors.backgroundCard.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : AppColors.textSecondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? activeColor : AppColors.textSecondary,
            size: 20,
          ),
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
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: isDetected 
                    ? color.withValues(alpha: 1.0)
                    : color.withValues(alpha: 0.7),
                fontWeight: isDetected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _formatTimeWithSeconds(displaySeconds),
              style: AppTextStyles.caption.copyWith(
                color: isDetected 
                    ? color.withValues(alpha: 1.0)
                    : color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
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
    final now = DateTime.now();
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
      
      // 期間が今日を含むかチェック
      final endDate = studyGoal.periodEndDate ??
          studyGoal.startDate.add(Duration(days: studyGoal.durationDays));
      if (now.isAfter(studyGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
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
      
      // 期間が今日を含むかチェック
      final endDate = pcGoal.periodEndDate ??
          pcGoal.startDate.add(Duration(days: pcGoal.durationDays));
      if (now.isAfter(pcGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
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
      
      // 期間が今日を含むかチェック
      final endDate = smartphoneGoal.periodEndDate ??
          smartphoneGoal.startDate.add(Duration(days: smartphoneGoal.durationDays));
      if (now.isAfter(smartphoneGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
        todaysGoals.add(smartphoneGoal);
      }
    }

    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.4),
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
                    Text(
                      goal.title,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 1.0),
                      ),
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
                            style: AppTextStyles.body2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.body2.copyWith(
                            color: color.withValues(alpha: 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      ),
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
