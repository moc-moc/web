import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';

/// ホーム画面（新デザインシステム版）
class HomeScreenNew extends ConsumerWidget {
  const HomeScreenNew({super.key});

  static const double _statCardMinHeight = 160;
  
  // 目標フィルタリング結果のキャッシュ（パフォーマンス最適化）
  static List<Goal>? _cachedTodaysGoals;
  static DateTime? _cacheTimestamp;
  static const _cacheExpiry = Duration(minutes: 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: ScrollableContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 統計表示セクション
              _buildStatsSection(ref),

              SizedBox(height: AppSpacing.md),

              // 今日の目標表示セクション
              _buildTodaysGoalsSection(ref),

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
  Widget _buildStatsSection(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTotalFocusedTimeCard(ref)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStreakDaysCard(ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFocusedTimeCard(WidgetRef ref) {
    final totalData = ref.watch(totalDataProvider);
    final totalMinutes = totalData.totalWorkTimeMinutes;
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
              '$totalMinutes',
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

  Widget _buildStreakDaysCard(WidgetRef ref) {
    final streakData = ref.watch(streakDataProvider);
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
              '${streakData.currentStreak}',
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
  Widget _buildTodaysGoalsSection(WidgetRef ref) {
    final goals = ref.watch(goalsListProvider);
    
    // キャッシュから今日の目標を取得（パフォーマンス最適化）
    final now = DateTime.now();
    List<Goal> todaysGoals;
    
    if (_cachedTodaysGoals != null && 
        _cacheTimestamp != null && 
        now.difference(_cacheTimestamp!) < _cacheExpiry &&
        _cachedTodaysGoals!.isNotEmpty) {
      // キャッシュが有効な場合は使用
      todaysGoals = _cachedTodaysGoals!;
    } else {
      // 今日の目標をフィルタリング（期間が今日を含む目標）
      todaysGoals = goals.where((goal) {
        final endDate = goal.startDate.add(Duration(days: goal.durationDays));
        return now.isAfter(goal.startDate.subtract(const Duration(days: 1))) &&
            now.isBefore(endDate.add(const Duration(days: 1)));
      }).take(4).toList();
      
      // キャッシュを更新
      _cachedTodaysGoals = todaysGoals;
      _cacheTimestamp = now;
    }
    
    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
          ...todaysGoals.map((goal) => _buildGoalCard(goal)),
        ],
      ),
    );
  }
  
  /// 目標カードを構築（計算結果をキャッシュ）
  Widget _buildGoalCard(Goal goal) {
    final category = _getCategoryFromDetectionItem(goal.detectionItem);
    final color = _getGoalColor(category);
    
    // 時間を分に変換して表示（メモ化）
    final currentMinutes = (goal.achievedTime ?? 0) ~/ 60;
    final targetMinutes = goal.targetTime ~/ 60;
    
    // 時間フォーマット（メモ化関数を使用）
    final currentValue = _formatMinutes(currentMinutes);
    final targetValue = _formatMinutes(targetMinutes);
    
    // 進捗率の計算
    final percentage = targetMinutes > 0 
        ? (currentMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: GoalProgressCard(
        goalName: goal.title,
        percentage: percentage,
        currentValue: currentValue,
        targetValue: targetValue,
        progressColor: color,
        labelColor: color,
        borderColor: color.withValues(alpha: 0.4),
        backgroundColor: color.withValues(alpha: 0.1),
        barBackgroundColor: AppColors.disabledGray.withValues(alpha: 0.2),
      ),
    );
  }
  
  /// 分を時間フォーマットに変換（メモ化対応）
  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (m == 0) {
        return '${h}h';
      } else {
        return '${h}h ${m}m';
      }
    }
  }
  
  String _getCategoryFromDetectionItem(DetectionItem item) {
    switch (item) {
      case DetectionItem.book:
        return 'study';
      case DetectionItem.pc:
        return 'pc';
      case DetectionItem.smartphone:
        return 'smartphone';
    }
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
            NavigationHelper.push(context, AppRoutes.trackingSettingNew);
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
            NavigationHelper.push(context, AppRoutes.trackingNew);
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
        NavigationHelper.pushReplacement(context, AppRoutes.goal);
        break;
      case 2:
        NavigationHelper.pushReplacement(context, AppRoutes.report);
        break;
      case 3:
        NavigationHelper.pushReplacement(context, AppRoutes.settings);
        break;
    }
  }
}
