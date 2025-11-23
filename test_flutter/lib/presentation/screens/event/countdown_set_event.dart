import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm_add,
            title: 'Countdown Set!',
            message: 'Keep it up!',
            iconSize: 50,
            titleFontSize: 24,
          ),
          SizedBox(height: AppSpacing.xs),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 18,
            additionalContent: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: AppColors.textPrimary, size: 16),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '$effectiveRemainingDays days remaining',
                  style: AppTextStyles.body2.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: () {
        // ゴール画面に遷移（イベント画面を閉じてから遷移）
        NavigationHelper.popAndPush(
          context,
          AppRoutes.goal,
        );
      },
    );
  }
}
