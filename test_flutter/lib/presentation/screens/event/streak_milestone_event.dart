import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
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
          EventContentBuilder.buildNumberContent(
            number: '$days',
            label: 'Days Streak',
            title: eventData.title,
            message: eventData.message,
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildMilestoneCard(
            nextMilestoneText: 'Next Milestone: $nextMilestone Days',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
