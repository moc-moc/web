import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';

/// 目標期間終了イベント画面
class GoalPeriodEndedEventScreen extends ConsumerStatefulWidget {
  final String? goalName;
  final double? targetHours;
  final double? achievedHours;
  final double? progress;
  final int? consecutiveDays;
  final String? period;
  final String? goalId;

  const GoalPeriodEndedEventScreen({
    super.key,
    this.goalName,
    this.targetHours,
    this.achievedHours,
    this.progress,
    this.consecutiveDays,
    this.period,
    this.goalId,
  });

  @override
  ConsumerState<GoalPeriodEndedEventScreen> createState() => _GoalPeriodEndedEventScreenState();
}

class _GoalPeriodEndedEventScreenState extends ConsumerState<GoalPeriodEndedEventScreen> {
  String? _goalName;
  double? _targetHours;
  double? _achievedHours;
  double? _progress;
  int? _consecutiveDays;
  String? _period;
  String? _goalId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteSettingsのargumentsからパラメータを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _goalName = arguments['goalName'] as String?;
      _targetHours = arguments['targetHours'] as double?;
      _achievedHours = arguments['achievedHours'] as double?;
      _progress = arguments['progress'] as double?;
      _consecutiveDays = arguments['consecutiveDays'] as int?;
      _period = arguments['period'] as String?;
      _goalId = arguments['goalId'] as String?;
    } else {
      // 引数がない場合は、ウィジェットのプロパティを使用
      _goalName = widget.goalName;
      _targetHours = widget.targetHours;
      _achievedHours = widget.achievedHours;
      _progress = widget.progress;
      _consecutiveDays = widget.consecutiveDays;
      _period = widget.period;
      _goalId = widget.goalId;
    }
  }

  Future<void> _handleOkPressed() async {
    // イベント発生の処理を先に実行（OKボタンが押されるまで待つ）
    // ゴールをリセット・更新
    if (_goalId != null) {
      await _resetAndUpdateGoal(_goalId!);
    }

    // 処理完了後、画面を閉じてホーム画面に遷移
    // pushAndRemoveUntilは既に画面を閉じる処理を含んでいる
    if (mounted) {
      NavigationHelper.pushAndRemoveUntil(
        context,
        AppRoutes.home,
      );
    }
  }

  /// ゴールをリセット・更新する処理
  /// 
  /// - 達成時間を0にリセット
  /// - 進捗率は自動的に0になる（achievedTime / targetTime）
  /// - 期間を更新（startDateを現在時刻に更新）
  /// - 連続日数を更新（目標達成していた場合は維持、達成していなかった場合は0にリセット）
  Future<void> _resetAndUpdateGoal(String goalId) async {
    try {
      final goals = ref.read(goalsListProvider);
      final goal = goals.firstWhere(
        (g) => g.id == goalId,
        orElse: () => throw Exception('Goal not found'),
      );

      // 目標達成していたかどうかを判定
      // achievedTimeがtargetTime以上の場合、達成とみなす
      final wasAchieved = (goal.achievedTime ?? 0) >= goal.targetTime;

      // 連続日数を更新
      // 達成していた場合は+1、達成していなかった場合は0にリセット
      final updatedConsecutiveDays = wasAchieved
          ? goal.consecutiveAchievements + 1
          : 0;

      // ゴールを更新
      final now = DateTime.now();
      final updatedGoal = goal.copyWith(
        achievedTime: 0, // 達成時間をリセット
        startDate: now, // 期間を更新（新しい期間の開始）
        periodEndDate: now.add(Duration(days: goal.durationDays)),
        consecutiveAchievements: updatedConsecutiveDays, // 連続日数を更新
        lastModified: now,
      );

      // 更新処理を実行
      await updateGoalHelper(
        context: context,
        ref: ref,
        goal: updatedGoal,
        mounted: mounted,
      );
    } catch (e) {
      debugPrint('❌ [GoalPeriodEndedEventScreen] ゴール更新エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ゴールの更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGoalName = _goalName ?? widget.goalName ?? 'Goal';
    final effectiveTargetHours = _targetHours ?? widget.targetHours ?? 10.0;
    final effectiveAchievedHours = _achievedHours ?? widget.achievedHours ?? 8.5;
    final effectiveProgress = _progress ?? widget.progress ?? 0.85;
    final effectiveConsecutiveDays = _consecutiveDays ?? widget.consecutiveDays ?? 0;
    final effectivePeriod = _period ?? widget.period ?? 'Weekly';

    return EventScreenBase(
      gradientColors: const [Color(0xFFEC4899), Color(0xFFC026D3)], // Pink
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Goal Period Ended',
            style: AppTextStyles.h1.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'The goal period has ended. Check your progress below.',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          CircularProgressBar(
            percentage: effectiveProgress,
            size: 160,
            strokeWidth: 16,
            progressColor: AppColors.textPrimary,
            backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
          ),
          SizedBox(height: AppSpacing.xl),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                EventContentBuilder.buildDetailRow('Goal', effectiveGoalName),
                EventContentBuilder.buildDetailRow(
                  'Hours',
                  '${effectiveAchievedHours.toStringAsFixed(1)}h / ${effectiveTargetHours.toStringAsFixed(1)}h',
                ),
                EventContentBuilder.buildDetailRow(
                  'Achievement',
                  '${(effectiveProgress * 100).toInt()}%',
                ),
                EventContentBuilder.buildDetailRow(
                  'Consecutive Days',
                  '$effectiveConsecutiveDays days',
                ),
                EventContentBuilder.buildDetailRow('Goal Period', effectivePeriod),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: _handleOkPressed,
    );
  }
}
