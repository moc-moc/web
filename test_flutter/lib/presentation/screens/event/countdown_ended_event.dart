import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// カウントダウン終了イベント画面
class CountdownEndedEventScreen extends StatelessWidget {
  final String? eventName;

  const CountdownEndedEventScreen({
    super.key,
    this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEventName = eventName ?? 'Event';

    return EventScreenBase(
      gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm,
            title: 'Countdown Ended!',
            message: 'The countdown has reached zero.',
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 32,
          ),
        ],
      ),
    );
  }
}
