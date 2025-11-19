import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 目標達成イベント画面
class GoalAchievedEventScreen extends StatelessWidget {
  final String? goalName;
  final String? period;
  final double? targetHours;
  final double? achievedHours;

  const GoalAchievedEventScreen({
    super.key,
    this.goalName,
    this.period,
    this.targetHours,
    this.achievedHours,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGoalName = goalName ?? 'Goal';
    final effectivePeriod = period ?? 'Daily';
    final effectiveTargetHours = targetHours ?? 2.0;
    final effectiveAchievedHours = achievedHours ?? 2.5;

    return EventScreenBase(
      gradientColors: const [Color(0xFF9E66D5), Color(0xFF7C3AED)], // Purple
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.emoji_events,
            title: 'Goal Achieved!',
            message: 'Congratulations! You have achieved your goal.',
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            effectiveGoalName,
            style: AppTextStyles.h1.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildChip(label: effectivePeriod),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildAchievementCard(
            goalName: effectiveGoalName,
            achievedHours: effectiveAchievedHours,
            targetHours: effectiveTargetHours,
          ),
        ],
      ),
      okButtonText: 'View Progress',
    );
  }
}
