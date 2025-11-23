import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/screens/event/event_screen_base.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';

/// 目標設定完了イベント画面
class GoalSetEventScreen extends StatelessWidget {
  final String? goalTitle;
  final int? targetTime; // 目標時間（秒）
  final int? consecutiveDays; // 連続日数
  final int? durationDays; // 期間（日数）
  final int? consecutivePeriodAchievements; // 期間内に連続で目標を達成した回数

  const GoalSetEventScreen({
    super.key,
    this.goalTitle,
    this.targetTime,
    this.consecutiveDays,
    this.durationDays,
    this.consecutivePeriodAchievements,
  });

  @override
  Widget build(BuildContext context) {
    // 目標時間を時間単位に変換
    final targetHours = targetTime != null ? targetTime! / 3600.0 : null;
    final dailyTargetHours = (targetHours != null && durationDays != null && durationDays! > 0)
        ? targetHours / durationDays!
        : null;
    
    return EventScreenBase(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)], // Blue
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // アイコンとタイトルを横並びに
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag,
                size: 56,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Goal Set!',
                style: AppTextStyles.h1.copyWith(fontSize: 34),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Your new goal has been set successfully',
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          EventContentBuilder.buildEventNameCard(
            eventName: goalTitle ?? 'New Goal',
            fontSize: 24,
            additionalContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSpacing.sm),
                if (targetHours != null)
                  EventContentBuilder.buildDetailRow(
                    'Target Time',
                    '${targetHours.toStringAsFixed(1)}h',
                  ),
                if (consecutiveDays != null)
                  EventContentBuilder.buildDetailRow(
                    'Current Streak',
                    '$consecutiveDays days',
                  ),
                if (durationDays != null)
                  EventContentBuilder.buildDetailRow(
                    'Duration',
                    '$durationDays days',
                  ),
                if (consecutivePeriodAchievements != null)
                  EventContentBuilder.buildDetailRow(
                    'Consecutive Achievements',
                    '$consecutivePeriodAchievements times',
                  ),
                if (dailyTargetHours != null)
                  EventContentBuilder.buildDetailRow(
                    'Daily Target',
                    '${dailyTargetHours.toStringAsFixed(1)}h / day',
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (consecutiveDays != null || durationDays != null)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (consecutiveDays != null)
                  EventContentBuilder.buildChip(label: 'Current Streak: $consecutiveDays'),
                if (durationDays != null)
                  EventContentBuilder.buildChip(label: 'Period: $durationDays days'),
              ],
            ),
          SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Momentum Tip',
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Block dedicated time for this goal today so the countdown to success starts immediately.',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
      onOkPressed: () {
        // ゴール画面に遷移（カウントダウン設定イベントと同様に、現在の画面を閉じてから遷移）
        NavigationHelper.popAndPush(
          context,
          AppRoutes.goal,
        );
      },
    );
  }
}
