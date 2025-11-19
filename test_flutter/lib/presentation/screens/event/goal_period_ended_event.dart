import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 目標期間終了イベント画面
class GoalPeriodEndedEventScreen extends StatelessWidget {
  final String? goalName;
  final double? targetHours;
  final double? achievedHours;
  final double? progress;
  final int? consecutiveDays;
  final String? period;

  const GoalPeriodEndedEventScreen({
    super.key,
    this.goalName,
    this.targetHours,
    this.achievedHours,
    this.progress,
    this.consecutiveDays,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGoalName = goalName ?? 'Goal';
    final effectiveTargetHours = targetHours ?? 10.0;
    final effectiveAchievedHours = achievedHours ?? 8.5;
    final effectiveProgress = progress ?? 0.85;
    final effectiveConsecutiveDays = consecutiveDays ?? 0;
    final effectivePeriod = period ?? 'Weekly';

    return EventScreenBase(
      gradientColors: const [Color(0xFFEC4899), Color(0xFFC026D3)], // Pink
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Goal Period Ended',
            style: AppTextStyles.h1.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'The goal period has ended. Check your progress below.',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          CircularProgressBar(
            percentage: effectiveProgress,
            size: 160,
            strokeWidth: 16,
            progressColor: AppColors.textPrimary,
            backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
          ),
          SizedBox(height: AppSpacing.xl),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                EventContentBuilder.buildDetailRow('Goal', effectiveGoalName),
                EventContentBuilder.buildDetailRow(
                  'Hours',
                  '${effectiveAchievedHours.toStringAsFixed(1)}h / ${effectiveTargetHours.toStringAsFixed(1)}h',
                ),
                EventContentBuilder.buildDetailRow(
                  'Achievement',
                  '${(effectiveProgress * 100).toInt()}%',
                ),
                EventContentBuilder.buildDetailRow(
                  'Consecutive Days',
                  '$effectiveConsecutiveDays days',
                ),
                EventContentBuilder.buildDetailRow('Goal Period', effectivePeriod),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
