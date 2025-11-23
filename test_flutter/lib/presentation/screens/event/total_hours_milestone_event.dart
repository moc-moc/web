import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/total/total_hours_milestone_manager.dart';

/// 総時間大台イベント画面
class TotalHoursMilestoneEventScreen extends StatefulWidget {
  final int? hours;
  final int? nextMilestone;

  const TotalHoursMilestoneEventScreen({
    super.key,
    this.hours,
    this.nextMilestone,
  });

  @override
  State<TotalHoursMilestoneEventScreen> createState() => _TotalHoursMilestoneEventScreenState();
}

class _TotalHoursMilestoneEventScreenState extends State<TotalHoursMilestoneEventScreen> {
  int? _hours;
  int? _nextMilestone;
  int? _achievedMilestone;
  final TotalHoursMilestoneManager _milestoneManager = TotalHoursMilestoneManager();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteSettingsのargumentsからhours、nextMilestone、achievedMilestoneを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _hours = arguments['hours'] as int?;
      _nextMilestone = arguments['nextMilestone'] as int?;
      _achievedMilestone = arguments['achievedMilestone'] as int?;
    } else {
      // 引数がない場合は、ウィジェットのプロパティを使用
      _hours = widget.hours;
      _nextMilestone = widget.nextMilestone;
    }
  }

  Future<void> _handleOkPressed() async {
    // 達成したマイルストーンをFirestoreに記録
    if (_achievedMilestone != null) {
      await _milestoneManager.recordAchievedMilestone(_achievedMilestone!);
    } else if (_hours != null) {
      // achievedMilestoneが渡されていない場合は、hoursから達成したマイルストーンを探す
      // 最大（最新）の達成マイルストーンを記録するため、逆順にループ
      final milestones = await _milestoneManager.getMilestones();
      int? maxAchievedMilestone;
      for (final milestone in milestones.reversed) {
        if (_hours! >= milestone) {
          maxAchievedMilestone = milestone;
          break;
        }
      }
      if (maxAchievedMilestone != null) {
        await _milestoneManager.recordAchievedMilestone(maxAchievedMilestone);
      }
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
    final effectiveHours = _hours ?? widget.hours ?? 1000;
    final effectiveNextMilestone = _nextMilestone ?? widget.nextMilestone ?? 2000;

    return EventScreenBase(
      gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)], // トーンを落とした専用の黄色
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 60, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.md),
          EventContentBuilder.buildNumberContent(
            number: '$effectiveHours',
            label: 'Hours',
            title: 'Total Hours Milestone!',
            message: 'Congratulations! You have reached a new milestone.',
            numberFontSize: 70,
            titleFontSize: 28,
          ),
          SizedBox(height: AppSpacing.md),
          EventContentBuilder.buildMilestoneCard(
            nextMilestoneText: 'Next target time is $effectiveNextMilestone hours',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
      onOkPressed: _handleOkPressed,
    );
  }
}
