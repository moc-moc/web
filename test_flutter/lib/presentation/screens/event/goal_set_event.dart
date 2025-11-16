import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
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
          EventContentBuilder.buildIconContent(
            icon: Icons.flag,
            title: event.title,
            message: event.message,
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildEventNameCard(
            eventName: 'Today is Day 0',
            fontSize: 24,
          ),
        ],
      ),
    );
  }
}
