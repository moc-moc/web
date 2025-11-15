import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/dummy_data/user_data.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';

/// ホーム画面（新デザインシステム版）
class HomeScreenNew extends StatelessWidget {
  const HomeScreenNew({super.key});

  static const double _statCardMinHeight = 160;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: ScrollableContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 統計表示セクション
              _buildStatsSection(),

              SizedBox(height: AppSpacing.md),

              // 今日の目標表示セクション
              _buildTodaysGoalsSection(),

              SizedBox(height: AppSpacing.md),

              // 設定ボタン
              _buildSettingsButton(context),

              SizedBox(height: AppSpacing.md),

              // スタートボタン
              _buildStartButton(context),

              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }


  /// 統計表示セクション
  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTotalFocusedTimeCard()),
                SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStreakDaysCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFocusedTimeCard() {
    const accentColor = AppColors.blue;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      constraints: const BoxConstraints(minHeight: _statCardMinHeight),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.blue.withValues(alpha: 0.9),
                size: 30,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Total Time',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              '${dummyUser.totalFocusedHours.toInt()}',
              style: AppTextStyles.h1.copyWith(
                fontSize: 48,
                color: accentColor,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Keep going!',
            style: AppTextStyles.caption.copyWith(
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDaysCard() {
    const accentColor = AppColors.orange;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      constraints: const BoxConstraints(minHeight: _statCardMinHeight),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.orange,
                size: 30,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Streak Days',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              '${dummyUser.streakDays}',
              style: AppTextStyles.h1.copyWith(
                fontSize: 48,
                color: accentColor,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Keep the flame alive!',
            style: AppTextStyles.caption.copyWith(
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 今日の目標表示セクション
  Widget _buildTodaysGoalsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.lightblackgray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Goals',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ...todaysGoals.map((goal) {
            final color = _getGoalColor(goal.category);
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: GoalProgressCard(
                goalName: goal.title,
                percentage: goal.progress,
                currentValue: '${goal.currentHours.toStringAsFixed(1)}h',
                targetValue: '${goal.targetHours.toStringAsFixed(1)}h',
                progressColor: color,
                labelColor: color,
                borderColor: color.withValues(alpha: 0.4),
                backgroundColor: color.withValues(alpha: 0.1),
                barBackgroundColor: AppColors.disabledGray.withValues(alpha: 0.2), // 透明度を追加
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 設定ボタン
  Widget _buildSettingsButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.large);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.trackingSettingNew);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightblackgray.withValues(alpha: 0.2),
              borderRadius: borderRadius,
              border: Border.all(
                color: AppColors.gray.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightblackgray,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Settings',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// スタートボタン
  Widget _buildStartButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.large);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.trackingNew);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: borderRadius,
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.blue,
                        AppColors.purple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Start Tracking',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      default:
        return AppColors.blue;
    }
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 0,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 0) return;
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.goal);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.report);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }
}
