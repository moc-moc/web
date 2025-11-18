import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// カウントダウン設定完了イベント画面
class CountdownSetEventScreen extends StatelessWidget {
  final String? eventName;
  final int? remainingDays;

  const CountdownSetEventScreen({
    super.key,
    this.eventName,
    this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEventName = eventName ?? 'Event';
    final effectiveRemainingDays = remainingDays ?? 15;

    return EventScreenBase(
      gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm_add,
            title: 'Countdown Set!',
            message: 'Your countdown has been set successfully',
            titleFontSize: 36,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 24,
            additionalContent: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: AppColors.textPrimary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '$effectiveRemainingDays days remaining',
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
