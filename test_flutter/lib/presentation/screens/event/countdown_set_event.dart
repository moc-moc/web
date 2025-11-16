import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// カウントダウン設定完了イベント画面
class CountdownSetEventScreen extends StatelessWidget {
  const CountdownSetEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = countdownSetEvent;
    final eventName = event.data?['eventName'] ?? 'Event';
    final remainingDays = event.data?['remainingDays'] ?? 15;

    return EventScreenBase(
      gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm_add,
            title: event.title,
            message: event.message,
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildEventNameCard(
            eventName: eventName,
            fontSize: 24,
            additionalContent: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: AppColors.textPrimary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '$remainingDays days remaining',
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
