import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final estimatedEndDate = DateTime.now().add(
      Duration(days: effectiveRemainingDays.clamp(0, 3650)),
    );
    final formattedEndDate = DateFormat('yyyy/MM/dd').format(estimatedEndDate);

    return EventScreenBase(
      gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_add, size: 72, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Countdown Set',
            style: AppTextStyles.h1.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Stay focused and make every day count!',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            '$effectiveRemainingDays',
            style: AppTextStyles.h1.copyWith(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'days remaining',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildEventNameCard(
            eventName: 'Schedule Overview',
            fontSize: 22,
            additionalContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EventContentBuilder.buildDetailRow('Event', effectiveEventName),
                EventContentBuilder.buildDetailRow(
                  'Days Remaining',
                  '$effectiveRemainingDays',
                ),
                EventContentBuilder.buildDetailRow(
                  'Finish Date',
                  formattedEndDate,
                ),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: () {
        // ゴール画面に遷移（イベント画面を閉じてから遷移）
        NavigationHelper.popAndPush(context, AppRoutes.goal);
      },
    );
  }
}
