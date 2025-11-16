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
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_controller.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';

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
  bool _isCameraInitializing = false;
  String? _cameraError;

  // 現在検出されているカテゴリ（'study', 'pc', 'smartphone', 'personOnly', null）
  String? _currentDetection;

  // 計測時間（分単位）
  double _studyMinutes = 0;
  double _pcMinutes = 0;
  double _smartphoneMinutes = 0;
  double _personOnlyMinutes = 0;
  
  // 各カテゴリの開始時刻
  DateTime? _categoryStartTime;
  String? _lastCategory;

  // カテゴリのテーマカラー
  static const Color _studyColor = AppColors.green; // 緑
  static const Color _pcColor = AppColors.blue; // 青
  static const Color _smartphoneColor = AppColors.orange; // オレンジ
  static const Color _personColor = AppColors.purple; // パープル（灰色から変更）

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _detectionController?.dispose();
    _cameraManager?.dispose();
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

      // 検出結果を監視
      controller.resultStream.listen((result) {
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
  void _handleDetectionResult(DetectionResult result) {
    if (!mounted) return;

    final now = DateTime.now();
    final categoryString = result.categoryString;

    // カテゴリが変わった場合、前のカテゴリの時間を加算
    if (_lastCategory != null && _lastCategory != categoryString && _categoryStartTime != null) {
      final duration = now.difference(_categoryStartTime!);
      final minutes = duration.inSeconds / 60.0;

      setState(() {
        switch (_lastCategory) {
          case 'study':
            _studyMinutes += minutes;
            break;
          case 'pc':
            _pcMinutes += minutes;
            break;
          case 'smartphone':
            _smartphoneMinutes += minutes;
            break;
          case 'personOnly':
            _personOnlyMinutes += minutes;
            break;
        }
      });
    }

    // 新しいカテゴリの開始
    setState(() {
      _currentDetection = categoryString;
      _lastCategory = categoryString;
      _categoryStartTime = now;
    });
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

  String _formatTimeWithSeconds(double minutes) {
    final totalSeconds = (minutes * 60).round();
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins}m ${secs}s';
    } else if (mins > 0) {
      return '${mins}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  void _handleStop() async {
    _timer?.cancel();
    
    // 最後のカテゴリの時間を加算
    if (_categoryStartTime != null && _lastCategory != null) {
      final now = DateTime.now();
      final duration = now.difference(_categoryStartTime!);
      final minutes = duration.inSeconds / 60.0;

      switch (_lastCategory) {
        case 'study':
          _studyMinutes += minutes;
          break;
        case 'pc':
          _pcMinutes += minutes;
          break;
        case 'smartphone':
          _smartphoneMinutes += minutes;
          break;
        case 'personOnly':
          _personOnlyMinutes += minutes;
          break;
      }
    }

    // 検出を停止
    await _detectionController?.stop();
    
    // 次の画面へ遷移
    if (mounted) {
      NavigationHelper.push(context, AppRoutes.trackingFinishedNew);
    }
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
            CameraPreviewWidget(
              cameraManager: _cameraManager!,
              isVisible: _isCameraOn,
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
                minutes: _studyMinutes,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'pc',
                icon: Icons.computer,
                label: 'PC',
                color: _pcColor,
                minutes: _pcMinutes,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'smartphone',
                icon: Icons.smartphone,
                label: 'Phone',
                color: _smartphoneColor,
                minutes: _smartphoneMinutes,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCategoryButton(
                category: 'personOnly',
                icon: Icons.person,
                label: 'Person',
                color: _personColor,
                minutes: _personOnlyMinutes,
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
    required double minutes,
  }) {
    final isDetected = _currentDetection == category;
    
    // 現在のカテゴリの場合は、追加で経過時間を加算
    double displayMinutes = minutes;
    if (isDetected && _categoryStartTime != null) {
      final now = DateTime.now();
      final duration = now.difference(_categoryStartTime!);
      displayMinutes += duration.inSeconds / 60.0;
    }

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
              _formatTimeWithSeconds(displayMinutes),
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
                            '${_formatTimeWithSeconds(currentHours * 60)} / ${goal.targetHours.toStringAsFixed(1)}h',
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
    switch (category) {
      case 'study':
        return _studyMinutes / 60;
      case 'pc':
        return _pcMinutes / 60;
      case 'smartphone':
        return _smartphoneMinutes / 60;
      default:
        return 0.0;
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
