import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// 目標期間終了イベント画面
class GoalPeriodEndedEventScreen extends StatelessWidget {
  const GoalPeriodEndedEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = goalPeriodEndedEvent;
    final goalName = event.data?['goalName'] ?? 'Goal';
    final targetHours = event.data?['targetHours'] ?? 10.0;
    final achievedHours = event.data?['achievedHours'] ?? 8.5;
    final progress = event.data?['progress'] ?? 0.85;
    final consecutiveDays = event.data?['consecutiveDays'] ?? 0;
    final period = event.data?['period'] ?? 'Weekly';

    return EventScreenBase(
      gradientColors: const [Color(0xFFEC4899), Color(0xFFC026D3)], // Pink
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            event.message,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          CircularProgressBar(
            percentage: progress,
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
                EventContentBuilder.buildDetailRow('Goal', goalName),
                EventContentBuilder.buildDetailRow(
                  'Hours',
                  '${achievedHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(1)}h',
                ),
                EventContentBuilder.buildDetailRow(
                  'Achievement',
                  '${(progress * 100).toInt()}%',
                ),
                EventContentBuilder.buildDetailRow(
                  'Consecutive Days',
                  '$consecutiveDays days',
                ),
                EventContentBuilder.buildDetailRow('Goal Period', period),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
