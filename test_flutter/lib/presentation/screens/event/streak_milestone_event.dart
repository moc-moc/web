import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// 連続日数大台イベント画面
class StreakMilestoneEventScreen extends StatelessWidget {
  final DummyEvent? event;

  const StreakMilestoneEventScreen({super.key, this.event});

  @override
  Widget build(BuildContext context) {
    final eventData = event ?? streak7DaysEvent;
    final days = eventData.data?['days'] ?? 7;
    final nextMilestone = eventData.data?['nextMilestone'] ?? 10;

    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E3A8A)], // Blue
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 80,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: AppSpacing.xl),

          // 大きな数字
          Text(
            '$days',
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Days Streak',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xl),

          Text(
            eventData.title,
            style: AppTextStyles.h1.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            eventData.message,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xl),

          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, color: AppColors.textPrimary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Next Milestone: $nextMilestone Days',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
