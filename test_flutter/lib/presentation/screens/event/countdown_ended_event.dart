import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// カウントダウン終了イベント画面
class CountdownEndedEventScreen extends StatelessWidget {
  const CountdownEndedEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = countdownEndedEvent;
    final eventName = event.data?['eventName'] ?? 'Event';

    return EventScreenBase(
      gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm,
            title: event.title,
            message: event.message,
          ),
          SizedBox(height: AppSpacing.xl),
          EventContentBuilder.buildEventNameCard(
            eventName: eventName,
            fontSize: 32,
          ),
        ],
      ),
    );
  }
}
