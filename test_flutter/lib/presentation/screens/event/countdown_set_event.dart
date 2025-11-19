import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
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
      gradientColors: [
        AppColors.blue.withValues(alpha: 0.8),
        Color.fromRGBO(25, 120, 240, 0.8), // 明るいblue（透明度を上げた）
      ],
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_add, size: 120, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.xl),
          Text(
            event.title,
            style: AppTextStyles.h1.copyWith(fontSize: 36),
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
            child: Column(
              children: [
                Text(
                  eventName,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                Row(
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
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xl),
          Text(
            event.message,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
