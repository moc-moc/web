import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// 目標設定完了イベント画面
class GoalSetEventScreen extends StatelessWidget {
  const GoalSetEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = goalSetEvent;

    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)], // Blue
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, size: 120, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Text(
              'Today is Day 0',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            event.message,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
