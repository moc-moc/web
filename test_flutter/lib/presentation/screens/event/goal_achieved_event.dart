import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';

/// 目標達成イベント画面
class GoalAchievedEventScreen extends StatefulWidget {
  final String? goalName;
  final String? period;
  final double? targetHours;
  final double? achievedHours;
  final double? progressPercent;
  final int? consecutiveDays;

  const GoalAchievedEventScreen({
    super.key,
    this.goalName,
    this.period,
    this.targetHours,
    this.achievedHours,
    this.progressPercent,
    this.consecutiveDays,
  });

  @override
  State<GoalAchievedEventScreen> createState() => _GoalAchievedEventScreenState();
}

class _GoalAchievedEventScreenState extends State<GoalAchievedEventScreen> {
  String? _goalName;
  String? _period;
  double? _targetHours;
  double? _achievedHours;
  double? _progressPercent;
  int? _consecutiveDays;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteSettingsのargumentsからパラメータを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _goalName = arguments['goalName'] as String?;
      _period = arguments['period'] as String?;
      _targetHours = arguments['targetHours'] as double?;
      _achievedHours = arguments['achievedHours'] as double?;
      _progressPercent = arguments['progressPercent'] as double?;
      _consecutiveDays = arguments['consecutiveDays'] as int?;
    } else {
      // 引数がない場合は、ウィジェットのプロパティを使用
      _goalName = widget.goalName;
      _period = widget.period;
      _targetHours = widget.targetHours;
      _achievedHours = widget.achievedHours;
      _progressPercent = widget.progressPercent;
      _consecutiveDays = widget.consecutiveDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGoalName = _goalName ?? widget.goalName ?? 'Goal';
    final effectivePeriod = _period ?? widget.period ?? 'Daily';
    final effectiveTargetHours = _targetHours ?? widget.targetHours ?? 2.0;
    final effectiveAchievedHours = _achievedHours ?? widget.achievedHours ?? 2.5;
    final effectiveProgressPercent = _progressPercent ?? widget.progressPercent ?? 100.0;
    final effectiveConsecutiveDays = _consecutiveDays ?? widget.consecutiveDays ?? 0;

    return EventScreenBase(
      gradientColors: const [Color(0xFF9E66D5), Color(0xFF7C3AED)], // Purple
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          EventContentBuilder.buildIconContent(
            icon: Icons.emoji_events,
            title: 'Goal Achieved!',
            message: 'Congratulations! You have achieved your goal.',
            iconSize: 70,
            titleFontSize: 28,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            effectiveGoalName,
            style: AppTextStyles.h2.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          EventContentBuilder.buildChip(label: effectivePeriod),
          SizedBox(height: AppSpacing.sm),
          EventContentBuilder.buildAchievementCard(
            goalName: effectiveGoalName,
            achievedHours: effectiveAchievedHours,
            targetHours: effectiveTargetHours,
          ),
          SizedBox(height: AppSpacing.xs),
          // 進捗率を表示
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, color: AppColors.textPrimary, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Progress: ${effectiveProgressPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 連続日数を表示
          if (effectiveConsecutiveDays > 0) ...[
            SizedBox(height: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: AppColors.textPrimary, size: 18),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Consecutive Days: $effectiveConsecutiveDays',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      okButtonText: 'View Progress',
    );
  }
}
