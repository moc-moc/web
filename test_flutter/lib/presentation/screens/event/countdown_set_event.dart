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
    final estimatedEndDate =
        DateTime.now().add(Duration(days: effectiveRemainingDays.clamp(0, 3650)));
    final formattedEndDate = DateFormat('yyyy/MM/dd').format(estimatedEndDate);

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
            iconSize: 72,
            titleFontSize: 30,
          ),
          SizedBox(height: AppSpacing.xs),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 22,
            additionalContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.sm),
                EventContentBuilder.buildDetailRow(
                  'Days Remaining',
                  '$effectiveRemainingDays days',
                ),
                EventContentBuilder.buildDetailRow(
                  'Finish Date',
                  formattedEndDate,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Step',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Add reminders and plan checkpoints before $formattedEndDate.',
                  style: AppTextStyles.body2,
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
