import 'package:flutter/material.dart';
import 'dart:async';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';

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

  // ダミー計測時間（秒単位でカウントアップ）
  double _studyMinutes = 0;
  double _pcMinutes = 0;
  double _smartphoneMinutes = 0;
  final double _personOnlyMinutes = 0;
  final double _nothingDetectedMinutes = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        // ダミー: ランダムに各カテゴリーの時間を増加
        if (_elapsedSeconds % 3 == 0) _studyMinutes += 0.05;
        if (_elapsedSeconds % 5 == 0) _pcMinutes += 0.033;
        if (_elapsedSeconds % 7 == 0) _smartphoneMinutes += 0.025;
      });
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleStop() {
    _timer?.cancel();
    Navigator.pushNamed(context, AppRoutes.trackingFinishedNew);
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
              // カメラ映像表示エリア
              _buildCameraArea(),

              // コントロールボタン
              _buildControls(),

              // 検出状況
              _buildDetectionStatus(),

              // カテゴリー別時間表示
              _buildCategoryTimes(),

              // 目標達成率
              _buildGoalProgress(),

              SizedBox(height: AppSpacing.md),

              // 終了ボタン
              SecondaryButton(
                text: 'Stop Tracking',
                icon: Icons.stop,
                size: ButtonSize.large,
                onPressed: _handleStop,
              ),
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
          // カメラプレースホルダー
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  size: 64,
                  color: AppColors.textDisabled,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  _isCameraOn ? 'Camera Active' : 'Camera Off',
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
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: _isCameraOn ? 'Camera On' : 'Camera Off',
            isActive: _isCameraOn,
            onTap: () {
              setState(() {
                _isCameraOn = !_isCameraOn;
              });
            },
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildControlButton(
            icon: Icons.battery_saver,
            label: 'Power Saving',
            isActive: _isPowerSavingMode,
            onTap: () {
              setState(() {
                _isPowerSavingMode = !_isPowerSavingMode;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InteractiveCard(
      onTap: onTap,
      backgroundColor: isActive
          ? AppColors.blue.withValues(alpha: 0.2)
          : AppColors.backgroundCard,
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.blue : AppColors.textSecondary,
            size: 32,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: isActive ? AppColors.blue : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionStatus() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Detection',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.menu_book, color: AppChartColors.study, size: 32),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Studying',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Focused',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTimes() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Breakdown',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.md),
          _buildTimeRow(
            'Study',
            Icons.menu_book,
            AppChartColors.study,
            _studyMinutes,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTimeRow(
            'Computer',
            Icons.computer,
            AppChartColors.pc,
            _pcMinutes,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTimeRow(
            'Smartphone',
            Icons.smartphone,
            AppChartColors.smartphone,
            _smartphoneMinutes,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTimeRow(
            'Person Only',
            Icons.person,
            AppChartColors.personOnly,
            _personOnlyMinutes,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTimeRow(
            'Nothing',
            Icons.remove_circle_outline,
            AppChartColors.nothingDetected,
            _nothingDetectedMinutes,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    String label,
    IconData icon,
    Color color,
    double minutes,
  ) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).toInt();

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          hours > 0 ? '${hours}h ${mins}m' : '${mins}m',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgress() {
    final totalMinutes = _studyMinutes + _pcMinutes;
    final goalMinutes = 120.0; // 2時間
    final progress = (totalMinutes / goalMinutes).clamp(0.0, 1.0);

    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Goal Progress',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.md),
          LinearProgressBar(
            percentage: progress,
            height: 12,
            progressColor: AppColors.success,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${(totalMinutes / 60).toStringAsFixed(1)}h / ${(goalMinutes / 60).toStringAsFixed(1)}h',
                  style: AppTextStyles.body2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
