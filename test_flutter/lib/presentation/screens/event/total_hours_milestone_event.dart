import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
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
      gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)], // トーンを落とした専用の黄色
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 80, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildNumberContent(
            number: '$hours',
            label: 'Hours',
            title: event.title,
            message: event.message,
            numberFontSize: 100,
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildMilestoneCard(
            nextMilestoneText: 'Next target time is $nextMilestone hours',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
