import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
            iconSize: 70,
            titleFontSize: 28,
          ),
          SizedBox(height: AppSpacing.sm),
          EventContentBuilder.buildEventNameCard(
            eventName: effectiveEventName,
            fontSize: 24,
          ),
        ],
      ),
      onOkPressed: _handleOkPressed,
    );
  }
}
