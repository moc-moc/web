import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';

/// カウントダウン終了イベント画面
class CountdownEndedEventScreen extends ConsumerStatefulWidget {
  final String? eventName;
  final String? countdownId;

  const CountdownEndedEventScreen({
    super.key,
    this.eventName,
    this.countdownId,
  });

  @override
  ConsumerState<CountdownEndedEventScreen> createState() => _CountdownEndedEventScreenState();
}

class _CountdownEndedEventScreenState extends ConsumerState<CountdownEndedEventScreen> {
  String? _eventName;
  String? _countdownId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteSettingsのargumentsからeventNameとcountdownIdを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _eventName = arguments['eventName'] as String?;
      _countdownId = arguments['countdownId'] as String?;
    } else {
      // 引数がない場合は、ウィジェットのプロパティを使用
      _eventName = widget.eventName;
      _countdownId = widget.countdownId;
    }
  }

  Future<void> _handleOkPressed() async {
    // カウントダウンを削除
    if (_countdownId != null) {
      await deleteCountdownHelper(
        context: context,
        ref: ref,
        countdownId: _countdownId!,
        mounted: mounted,
      );
    }

    // ホーム画面に遷移
    if (mounted) {
      NavigationHelper.pushAndRemoveUntil(
        context,
        AppRoutes.home,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEventName = _eventName ?? widget.eventName ?? 'Event';
    final completionDate = DateFormat('yyyy/MM/dd').format(DateTime.now());

    return EventScreenBase(
      gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.alarm,
            title: 'Countdown Ended!',
            message: 'The countdown has reached zero.',
            iconSize: 76,
            titleFontSize: 32,
          ),
          SizedBox(height: AppSpacing.sm),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 26,
            additionalContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.sm),
                EventContentBuilder.buildDetailRow(
                  'Completed on',
                  completionDate,
                ),
                EventContentBuilder.buildDetailRow(
                  'Status',
                  'Time to celebrate and review!',
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Actions',
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '• Record what you accomplished\n'
                  '• Set a fresh countdown to keep the momentum\n'
                  '• Share the milestone with friends',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: _handleOkPressed,
    );
  }
}
