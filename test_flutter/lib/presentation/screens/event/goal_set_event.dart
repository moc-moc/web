import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 目標設定完了イベント画面
class GoalSetEventScreen extends StatelessWidget {
  final String? goalTitle;
  final int? dayNumber;

  const GoalSetEventScreen({
    super.key,
    this.goalTitle,
    this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)], // Blue
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.flag,
            title: goalTitle ?? 'Goal Set!',
            message: 'Your new goal has been set successfully',
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildEventNameCard(
            eventName: 'Today is Day ${dayNumber ?? 0}',
            fontSize: 24,
          ),
        ],
      ),
    );
  }
}
