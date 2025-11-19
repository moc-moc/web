import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 連続日数大台イベント画面
class StreakMilestoneEventScreen extends StatelessWidget {
  final int? days;
  final int? nextMilestone;

  const StreakMilestoneEventScreen({
    super.key,
    this.days,
    this.nextMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDays = days ?? 7;
    final effectiveNextMilestone = nextMilestone ?? 10;

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
            number: '$effectiveDays',
            label: 'Days Streak',
            title: 'Streak Milestone!',
            message: 'Amazing! You have reached a new milestone.',
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildMilestoneCard(
            nextMilestoneText: 'Next Milestone: $effectiveNextMilestone Days',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
