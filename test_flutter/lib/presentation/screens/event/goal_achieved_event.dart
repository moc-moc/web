import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
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
          EventContentBuilder.buildIconContent(
            icon: Icons.emoji_events,
            title: event.title,
            message: event.message,
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            goalName,
            style: AppTextStyles.h1.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildChip(label: period),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildAchievementCard(
            goalName: goalName,
            achievedHours: achievedHours,
            targetHours: targetHours,
          ),
        ],
      ),
      okButtonText: 'View Progress',
    );
  }
}
