import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// 目標達成イベント画面
class GoalAchievedEventScreen extends StatelessWidget {
  const GoalAchievedEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = goalAchievedEvent;
    final goalName = event.data?['goalName'] ?? 'Goal';
    final period = event.data?['period'] ?? 'Daily';
    final targetHours = event.data?['targetHours'] ?? 2.0;
    final achievedHours = event.data?['achievedHours'] ?? 2.5;

    return EventScreenBase(
      gradientColors: const [Color(0xFF9E66D5), Color(0xFF7C3AED)], // Purple
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 120, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            event.message,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            goalName,
            style: AppTextStyles.h1.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          AppChip(
            label: period,
            backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
            textColor: AppColors.textPrimary,
          ),
          SizedBox(height: AppSpacing.xl),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: AppColors.textPrimary),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      '${achievedHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Achieved ${((achievedHours / targetHours) * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      okButtonText: 'View Progress',
    );
  }
}
