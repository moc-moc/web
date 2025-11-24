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
  State<GoalAchievedEventScreen> createState() =>
      _GoalAchievedEventScreenState();
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
    final effectiveAchievedHours =
        _achievedHours ?? widget.achievedHours ?? 2.5;
    final effectiveProgressPercent =
        _progressPercent ?? widget.progressPercent ?? 100.0;
    final effectiveConsecutiveDays =
        _consecutiveDays ?? widget.consecutiveDays ?? 0;
    final progressRatio = effectiveTargetHours > 0
        ? (effectiveAchievedHours / effectiveTargetHours).clamp(0.0, 1.0)
        : 1.0;

    return EventScreenBase(
      gradientColors: const [Color(0xFF9E66D5), Color(0xFF7C3AED)], // Purple
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 72, color: AppColors.textPrimary),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Goal Achieved',
            style: AppTextStyles.h1.copyWith(fontSize: 36),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Amazing work! Your dedication is paying off.',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          EventContentBuilder.buildProgressRing(
            percentage: progressRatio,
            value: '${effectiveProgressPercent.toStringAsFixed(0)}%',
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
                EventContentBuilder.buildDetailRow('Goal', effectiveGoalName),
                EventContentBuilder.buildDetailRow(
                  'Hours',
                  '${effectiveAchievedHours.toStringAsFixed(1)}h / ${effectiveTargetHours.toStringAsFixed(1)}h',
                ),
                EventContentBuilder.buildDetailRow(
                  'Consecutive Days',
                  '$effectiveConsecutiveDays days',
                ),
                EventContentBuilder.buildDetailRow(
                  'Goal Period',
                  effectivePeriod,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
