import 'package:flutter/material.dart';
import 'dart:async';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/widgets/camera_preview_widget.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';
import 'package:test_flutter/feature/tracking/tracking_functions.dart';
import 'package:test_flutter/feature/tracking/detection/detection_controller.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/feature/tracking/tracking_session_data_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// トラッキング中画面（新デザインシステム版）
class TrackingScreenNew extends StatefulWidget {
  const TrackingScreenNew({super.key});

  @override
  State<TrackingScreenNew> createState() => _TrackingScreenNewState();
}

class _TrackingScreenNewState extends State<TrackingScreenNew> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isCameraOn = true;
  bool _isPowerSavingMode = false;

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
  final TrackingSessionDataManager _sessionManager = TrackingSessionDataManager();
  
  // 最後の検出結果の信頼度（セッション終了時に使用）
  double? _lastDetectionConfidence;

  // カテゴリのテーマカラー
  static const Color _studyColor = AppColors.green; // 緑
  static const Color _pcColor = AppColors.blue; // 青
  static const Color _smartphoneColor = AppColors.orange; // オレンジ
  static const Color _personColor = AppColors.purple; // パープル（灰色から変更）

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _initializeCamera();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // カメラリソースはStop Trackingボタンで解放するため、ここでは解放しない
    // ただし、画面が閉じられる場合（例：戻るボタン）は検出コントローラーのみ解放
    _detectionSubscription?.cancel();
    _detectionController?.dispose();
    super.dispose();
  }

  /// カメラの初期化
  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _cameraError = null;
    });

    try {
      final controller = await initializeDetection();
      
      if (controller == null) {
        setState(() {
          _isCameraInitializing = false;
          _cameraError = 'カメラの初期化に失敗しました';
        });
        return;
      }

      // カメラマネージャーを取得
      final cameraManager = controller.cameraManager;

      setState(() {
        _detectionController = controller;
        _cameraManager = cameraManager;
        _isCameraInitializing = false;
      });

      // 検出を開始
      await controller.start(powerSavingMode: _isPowerSavingMode);

      // 検出結果を直接処理
      _detectionSubscription = controller.resultStream.listen((result) {
        _handleDetectionResult(result);
      });
    } catch (e) {
      setState(() {
        _isCameraInitializing = false;
        _cameraError = 'カメラエラー: $e';
      });
    }
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
      setState(() {
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
      });
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });
    });
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
  
  /// 現在のカテゴリの経過時間を含めた秒数を取得
  int _getCurrentCategorySeconds(int baseSeconds) {
    if (_currentDetection != null && _categoryStartTime != null) {
      final now = DateTime.now();
      final duration = now.difference(_categoryStartTime!);
      return baseSeconds + duration.inSeconds;
    }
    return baseSeconds;
  }

  void _handleStop() async {
    _timer?.cancel();
    
    final sessionEndTime = DateTime.now();
    
    // 最後のカテゴリの期間を確定して時間を加算
    _finalizeCurrentPeriod(sessionEndTime);

    // セッションデータを作成
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
      
      // 次のセッションIDを取得
      final nextSessionId = await _sessionManager.getNextSessionId();
      
      var session = TrackingSession(
        id: nextSessionId,
        startTime: _sessionStartTime!,
        endTime: sessionEndTime,
        categorySeconds: {
          'study': _studySeconds,
          'pc': _pcSeconds,
          'smartphone': _smartphoneSeconds,
          'personOnly': _personOnlySeconds,
        },
        detectionPeriods: _detectionPeriods,
        lastModified: DateTime.now(),
      );

      // データ整合性チェックと自動修正
      final validation = session.validateData();
      if (!validation.$1) {
        LogMk.logWarning(
          '⚠️ データ整合性の問題を検出しました:',
          tag: 'TrackingScreen._handleStop',
        );
        for (final issue in validation.$2) {
          LogMk.logWarning('  - $issue', tag: 'TrackingScreen._handleStop');
        }
        
        // detectionPeriodsからcategorySecondsを再計算して修正
        final recalculated = session.recalculateCategorySeconds();
        session = session.copyWith(categorySeconds: recalculated);
        LogMk.logDebug(
          '✅ categorySecondsを再計算して修正しました',
          tag: 'TrackingScreen._handleStop',
        );
      }

      // ログに出力
      _logSessionData(session);

      // データベースに保存
      try {
        await _sessionManager.addSessionWithAuth(session);
        LogMk.logDebug(
          '✅ トラッキングセッションを保存しました: ${session.id}',
          tag: 'TrackingScreen._handleStop',
        );
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ トラッキングセッションの保存に失敗しました: $e',
          tag: 'TrackingScreen._handleStop',
          stackTrace: stackTrace,
        );
      }
    }

    // 検出を停止
    await _detectionController?.stop();
    
    // ストリーム購読を停止
    await _detectionSubscription?.cancel();
    _detectionSubscription = null;
    
    // カメラリソースを解放
    await _detectionController?.dispose();
    await _cameraManager?.dispose();
    
    // 状態をクリア
    setState(() {
      _detectionController = null;
      _cameraManager = null;
    });
    
    // 次の画面へ遷移
    if (mounted) {
      NavigationHelper.push(context, AppRoutes.trackingFinishedNew);
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
    return AppScaffold(
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
                    // 省電力モードを切り替え
                    await _detectionController?.setPowerSavingMode(_isPowerSavingMode);
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
    final displaySeconds = _getCurrentCategorySeconds(seconds);

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
    // 今日の目標を取得（study, pc, smartphoneのみ）
    final activeGoals = todaysGoals.where((goal) => 
      goal.category == 'study' || 
      goal.category == 'pc' || 
      goal.category == 'smartphone'
    ).toList();

    if (activeGoals.isEmpty) {
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
          ...activeGoals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            final color = _getGoalColor(goal.category);
            final currentHours = _getCurrentHours(goal.category);
            final progress = (currentHours / goal.targetHours).clamp(0.0, 1.0);
            final isDetected = _currentDetection == goal.category;
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < activeGoals.length - 1 ? AppSpacing.md : 0,
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
                            '${_formatTimeWithSeconds((currentHours * 3600).round())} / ${goal.targetHours.toStringAsFixed(1)}h',
                            style: AppTextStyles.body2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          '${(progress * 100).toInt()}%',
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

  double _getCurrentHours(String category) {
    int seconds;
    switch (category) {
      case 'study':
        seconds = _getCurrentCategorySeconds(_studySeconds);
        break;
      case 'pc':
        seconds = _getCurrentCategorySeconds(_pcSeconds);
        break;
      case 'smartphone':
        seconds = _getCurrentCategorySeconds(_smartphoneSeconds);
        break;
      default:
        return 0.0;
    }
    return seconds / 3600.0;
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
