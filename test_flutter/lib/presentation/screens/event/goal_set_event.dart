import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';

/// 目標設定完了イベント画面
class GoalSetEventScreen extends ConsumerStatefulWidget {
  final String? goalTitle;
  final int? targetTime; // 目標時間（秒）
  final int? consecutiveDays; // 連続日数
  final int? durationDays; // 期間（日数）
  final int? consecutivePeriodAchievements; // 期間内に連続で目標を達成した回数
  final String? detectionItem; // 検出対象

  const GoalSetEventScreen({
    super.key,
    this.goalTitle,
    this.targetTime,
    this.consecutiveDays,
    this.durationDays,
    this.consecutivePeriodAchievements,
    this.detectionItem,
  });

  @override
  ConsumerState<GoalSetEventScreen> createState() =>
      _GoalSetEventScreenState();
}

class _GoalSetEventScreenState extends ConsumerState<GoalSetEventScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _persistGoalToProfile());
  }

  Future<void> _persistGoalToProfile() async {
    final targetTime = widget.targetTime;
    final user = ref.read(authControllerProvider).firebaseUser;
    if (targetTime == null || user == null) return;
    final minutes = (targetTime / 60).round();
    await ref
        .read(userRepositoryProvider)
        .updateProfileFields(user.uid, goalMinutes: minutes);
  }

  @override
  Widget build(BuildContext context) {
    final goalName = widget.goalTitle ?? 'New Goal';
    final targetHours = widget.targetTime != null ? widget.targetTime! / 3600.0 : null;
    final dailyTargetHours =
        (targetHours != null && widget.durationDays != null && widget.durationDays! > 0)
        ? targetHours / widget.durationDays!
        : null;
    final durationLabel = widget.durationDays != null
        ? '${widget.durationDays} days'
        : 'Flexible';
    final streakLabel = widget.consecutiveDays != null
        ? '${widget.consecutiveDays} days'
        : 'Start today';
    final detectionLabel = _detectLabel(widget.detectionItem);
    final targetHoursLabel = targetHours != null
        ? '${targetHours.toStringAsFixed(1)}h'
        : '--';
    final nickname =
        ref.watch(authControllerProvider).profile?.nickname ?? 'You';

    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)], // Blue
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 64, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Goal Set',
            style: AppTextStyles.h1.copyWith(fontSize: 38),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '$nickname, you\'ve taken the first step—keep going!',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildProgressRing(
            percentage: 0,
            value: '0%',
            label: 'Progress',
            size: 280,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                EventContentBuilder.buildDetailRow('Goal', goalName),
                if (targetHours != null)
                  EventContentBuilder.buildDetailRow(
                    'Hours',
                    '0.0h / $targetHoursLabel',
                  ),
                EventContentBuilder.buildDetailRow(
                  'Consecutive Days',
                  streakLabel,
                ),
                EventContentBuilder.buildDetailRow(
                  'Goal Period',
                  durationLabel,
                ),
                EventContentBuilder.buildDetailRow('Focus', detectionLabel),
                if (dailyTargetHours != null)
                  EventContentBuilder.buildDetailRow(
                    'Daily Target',
                    '${dailyTargetHours.toStringAsFixed(1)}h / day',
                  ),
                if (widget.consecutivePeriodAchievements != null)
                  EventContentBuilder.buildDetailRow(
                    'Period Achievements',
                    '${widget.consecutivePeriodAchievements}',
                  ),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: () {
        // ゴール画面に遷移（カウントダウン設定イベントと同様に、現在の画面を閉じてから遷移）
        NavigationHelper.popAndPush(context, AppRoutes.goal);
      },
    );
  }

  String _detectLabel(String? detection) {
    switch (detection) {
      case 'book':
        return 'Reading';
      case 'pc':
        return 'PC Work';
      case 'smartphone':
        return 'Smartphone Control';
      default:
        return 'General Focus';
    }
  }
}
