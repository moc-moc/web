import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/data/services/streak_milestone_service.dart';

/// 連続日数大台イベント画面
class StreakMilestoneEventScreen extends StatefulWidget {
  final int? days;
  final int? nextMilestone;

  const StreakMilestoneEventScreen({
    super.key,
    this.days,
    this.nextMilestone,
  });

  @override
  State<StreakMilestoneEventScreen> createState() => _StreakMilestoneEventScreenState();
}

class _StreakMilestoneEventScreenState extends State<StreakMilestoneEventScreen> {
  int? _days;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteSettingsのargumentsからdaysを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _days = arguments['days'] as int?;
    } else {
      // 引数がない場合は、ウィジェットのプロパティを使用
      _days = widget.days;
    }
  }

  Future<void> _handleOkPressed() async {
    // 達成したマイルストーンをFirestoreに記録
    final effectiveDays = _days ?? widget.days;
    if (effectiveDays != null) {
      await StreakMilestoneService.recordAchievedMilestone(effectiveDays);
    }

    // ホーム画面に遷移
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDays = _days ?? widget.days ?? 7;

    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E3A8A)], // Blue
      content: FutureBuilder<int?>(
        future: StreakMilestoneService.getNextMilestoneAfter(effectiveDays),
        builder: (context, snapshot) {
          final effectiveNextMilestone = snapshot.data;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ファイアアイコンを数値の上に表示
              Icon(
                Icons.local_fire_department,
                size: 60,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: AppSpacing.sm),
              // 数字を表示
              Text(
                '$effectiveDays',
                style: TextStyle(
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Days Streak',
                style: AppTextStyles.h2.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Streak Milestone!',
                style: AppTextStyles.h1.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Amazing! You have reached a new milestone.',
                style: AppTextStyles.body1.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              EventContentBuilder.buildMilestoneCard(
                nextMilestoneText: effectiveNextMilestone != null && effectiveNextMilestone > 0
                    ? 'Next Milestone: $effectiveNextMilestone Days'
                    : 'All Milestones Achieved!',
                icon: Icons.arrow_forward,
              ),
            ],
          );
        },
      ),
      onOkPressed: _handleOkPressed,
    );
  }
}
