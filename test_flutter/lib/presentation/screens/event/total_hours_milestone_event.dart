import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 総時間大台イベント画面
class TotalHoursMilestoneEventScreen extends StatelessWidget {
  final int? hours;
  final int? nextMilestone;

  const TotalHoursMilestoneEventScreen({
    super.key,
    this.hours,
    this.nextMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHours = hours ?? 1000;
    final effectiveNextMilestone = nextMilestone ?? 2000;

    return EventScreenBase(
      gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)], // トーンを落とした専用の黄色
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 80, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildNumberContent(
            number: '$effectiveHours',
            label: 'Hours',
            title: 'Total Hours Milestone!',
            message: 'Congratulations! You have reached a new milestone.',
            numberFontSize: 100,
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildMilestoneCard(
            nextMilestoneText: 'Next target time is $effectiveNextMilestone hours',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
