import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/dummy_data/user_data.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';
import 'package:test_flutter/dummy_data/countdown_data.dart';

/// 目標画面（新デザインシステム版）
class GoalScreenNew extends StatelessWidget {
  const GoalScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ScrollableContent(
              child: SpacedColumn(
                spacing: AppSpacing.xl,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー（挨拶 + 継続日数）
                  _buildHeader(),

                  // やる気の出る名言
                  _buildQuoteSection(),

                  // カウントダウン表示
                  _buildCountdownSection(context),

                  // 目標一覧
                  _buildGoalsList(context),

                  SizedBox(height: AppSpacing.xxl * 2), // FABのスペース確保
                ],
              ),
            ),

            // 右下の＋ボタン
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: FloatingActionButton(
                backgroundColor: AppColors.blue,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const GoalSettingDialog(),
                  );
                },
                child: const Icon(Icons.add, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 18) {
      greeting = 'Good afternoon';
    } else if (hour >= 18) {
      greeting = 'Good evening';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text('${dummyUser.name.split(' ')[0]}!', style: AppTextStyles.h1),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${dummyUser.streakDays} Days',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    const quotes = [
      'The secret of getting ahead is getting started.',
      'Focus on being productive instead of busy.',
      'Success is the sum of small efforts repeated daily.',
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: AppColors.textPrimary,
              size: 32,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                quote,
                style: AppTextStyles.body1.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CountdownDisplay(
        eventName: activeCountdown.eventName,
        days: activeCountdown.remainingDays,
        hours: activeCountdown.remainingHours,
        minutes: activeCountdown.remainingMinutes,
        seconds: activeCountdown.remainingSeconds,
        accentColor: AppColors.purple,
        onEdit: () {
          showDialog(
            context: context,
            builder: (context) => CountdownSettingDialog(
              isEdit: true,
              initialEventName: activeCountdown.eventName,
              onDelete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Countdown deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Goals', style: AppTextStyles.h2),
          SizedBox(height: AppSpacing.md),
          ...dummyGoals.map(
            (goal) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildGoalCard(context, goal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, DummyGoal goal) {
    return InteractiveCard(
      onTap: () {
        // 目標編集ダイアログを表示
        showDialog(
          context: context,
          builder: (context) => GoalSettingDialog(
            isEdit: true,
            initialTitle: goal.title,
            initialCategory: goal.category,
            initialPeriod: goal.period,
            initialTargetHours: goal.targetHours,
            initialIsFocusedOnly: goal.isFocusedOnly,
            onDelete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal deleted successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        );
      },
      child: Row(
        children: [
          // 円形プログレスバー
          CircularProgressBar(
            percentage: goal.progress,
            progressColor: _getGoalColor(goal.category),
            size: 80,
            strokeWidth: 8,
          ),
          SizedBox(width: AppSpacing.md),

          // 目標情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${goal.currentHours.toStringAsFixed(1)}h / ${goal.targetHours.toStringAsFixed(1)}h',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    AppChip.gray(label: _getPeriodLabel(goal.period)),
                    if (goal.isFocusedOnly) AppChip.blue(label: 'Focused Only'),
                    if (goal.remainingDays > 0)
                      AppChip.gray(label: '${goal.remainingDays} days left'),
                  ],
                ),
                if (goal.consecutiveAchievements > 0) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: AppColors.yellow,
                        size: 16,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          '${goal.consecutiveAchievements} consecutive achievements',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.yellow,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return AppChartColors.study;
      case 'pc':
        return AppChartColors.pc;
      case 'smartphone':
        return AppChartColors.smartphone;
      case 'work':
        return AppColors.purple;
      default:
        return AppColors.blue;
    }
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return period;
    }
  }
}
