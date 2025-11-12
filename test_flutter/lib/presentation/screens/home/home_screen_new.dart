import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/dummy_data/user_data.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';

/// ホーム画面（新デザインシステム版）
class HomeScreenNew extends StatelessWidget {
  const HomeScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.xl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 上部セクション（プロフィール＋設定）
              _buildHeader(context),

              // 統計表示セクション
              _buildStatsSection(),

              // 今日の目標表示セクション
              _buildTodaysGoalsSection(),

              // スタートボタン
              _buildStartButton(context),

              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// 上部セクション（プロフィールアイコン＋設定ボタン）
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // プロフィールアイコン
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dummyUser.name[0], // 'A'
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // 設定ボタン
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            iconSize: 28,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }

  /// 統計表示セクション
  Widget _buildStatsSection() {
    return StandardCard(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // 総合計集中時間（大きく表示）
          Column(
            children: [
              Text(
                'Total Focused Time',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${dummyUser.totalFocusedHours.toInt()} Hours',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.blue,
                  fontSize: 42,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.backgroundSecondary),
          SizedBox(height: AppSpacing.lg),

          // 継続日数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                iconColor: AppColors.success,
                value: '${dummyUser.streakDays}',
                label: 'Streak Days',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.backgroundSecondary,
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                iconColor: AppColors.purple,
                value: '${dummyUser.totalLoginDays}',
                label: 'Total Days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  /// 今日の目標表示セクション
  Widget _buildTodaysGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Today\'s Goals', style: AppTextStyles.h2),
        ),
        SizedBox(height: AppSpacing.md),
        ...todaysGoals.map(
          (goal) => Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: GoalProgressCard(
              goalName: goal.title,
              percentage: goal.progress,
              currentValue: '${goal.currentHours.toStringAsFixed(1)}h',
              targetValue: '${goal.targetHours.toStringAsFixed(1)}h',
              progressColor: _getGoalColor(goal.category),
            ),
          ),
        ),
      ],
    );
  }

  /// スタートボタン
  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.blue, Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.trackingSettingNew);
            },
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: AppColors.textPrimary,
                    size: 32,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Start Tracking',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      default:
        return AppColors.blue;
    }
  }
}
