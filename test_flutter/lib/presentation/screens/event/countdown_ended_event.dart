import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
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
          Icon(Icons.alarm, size: 120, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),

          // イベント名
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Text(
              eventName,
              style: AppTextStyles.h1.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.xl),
          Text(
            event.message,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
