import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// 総時間大台イベント画面
class TotalHoursMilestoneEventScreen extends StatelessWidget {
  const TotalHoursMilestoneEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = totalHours1000Event;
    final hours = event.data?['hours'] ?? 1000;
    final nextMilestone = event.data?['nextMilestone'] ?? 2000;

    return EventScreenBase(
      gradientColors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)], // Yellow
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 80, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),

          // 大きな数字
          Text(
            '$hours',
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text('Hours', style: AppTextStyles.h2, textAlign: TextAlign.center),

          SizedBox(height: AppSpacing.xl),

          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            event.message,
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
                Flexible(
                  child: Text(
                    'Next target time is $nextMilestone hours',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
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
