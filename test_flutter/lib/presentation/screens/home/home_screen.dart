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
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';

/// ホーム画面（新デザインシステム版）
class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  static const double _statCardMinHeight = 160;

  // 今日の日次統計データ（ローカルから取得）
  Map<String, int> _todayCategorySeconds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// データを読み込む
  Future<void> _loadData() async {
    try {
      // 累計データ、ストリークデータ、トラッキング設定を並行して読み込む（バックグラウンド更新）
      await Future.wait([
        loadTotalDataWithBackgroundRefreshHelper(ref),
        loadStreakDataWithBackgroundRefreshHelper(ref),
        loadTrackingSettingsWithBackgroundRefreshHelper(ref),
        _loadTodayStatistics(),
      ]);
    } catch (e) {
      debugPrint('❌ [HomeScreen] データ読み込みエラー: $e');
    }
  }
  
  /// 今日の日次統計をローカルから読み込む
  Future<void> _loadTodayStatistics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final manager = DailyStatisticsDataManager();
      final dailyStats = await manager.getByDateLocal(today);
      
      if (mounted) {
        setState(() {
          if (dailyStats != null) {
            _todayCategorySeconds = Map<String, int>.from(dailyStats.categorySeconds);
          } else {
            _todayCategorySeconds = {};
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [HomeScreen] 日次統計の読み込みエラー: $e');
      if (mounted) {
        setState(() {
          _todayCategorySeconds = {};
        });
      }
    }
  }

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalMinutes',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 48,
                    color: accentColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'min',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 48 * 0.8,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${streakData.currentStreak}',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 48,
                    color: accentColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'days',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 48 * 0.8,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
    final goals = ref.watch(goalsListProvider);
    final settings = ref.watch(trackingSettingsProvider);
    
    // 選択された目標IDを取得
    final selectedStudyGoalId = settings.selectedStudyGoalId;
    final selectedPcGoalId = settings.selectedPcGoalId;
    final selectedSmartphoneGoalId = settings.selectedSmartphoneGoalId;
    
    // 各カテゴリーの目標を取得
    final studyGoals = goals.where((g) => g.detectionItem == DetectionItem.book).toList();
    final pcGoals = goals.where((g) => g.detectionItem == DetectionItem.pc).toList();
    final smartphoneGoals = goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList();
    
    // 選択された目標を取得（存在しない場合は最初の目標を自動選択）
    final now = DateTime.now();
    final todaysGoals = <Goal>[];
    
    // Study目標
    if (studyGoals.isNotEmpty) {
      Goal? studyGoal;
      if (selectedStudyGoalId != null) {
        studyGoal = studyGoals.firstWhere(
          (g) => g.id == selectedStudyGoalId,
          orElse: () => studyGoals[0],
        );
      } else {
        studyGoal = studyGoals[0];
      }
      
      // 期間が今日を含むかチェック
      final endDate = studyGoal.startDate.add(Duration(days: studyGoal.durationDays));
      if (now.isAfter(studyGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
        todaysGoals.add(studyGoal);
      }
    }
    
    // PC目標
    if (pcGoals.isNotEmpty) {
      Goal? pcGoal;
      if (selectedPcGoalId != null) {
        pcGoal = pcGoals.firstWhere(
          (g) => g.id == selectedPcGoalId,
          orElse: () => pcGoals[0],
        );
      } else {
        pcGoal = pcGoals[0];
      }
      
      // 期間が今日を含むかチェック
      final endDate = pcGoal.startDate.add(Duration(days: pcGoal.durationDays));
      if (now.isAfter(pcGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
        todaysGoals.add(pcGoal);
      }
    }
    
    // Smartphone目標
    if (smartphoneGoals.isNotEmpty) {
      Goal? smartphoneGoal;
      if (selectedSmartphoneGoalId != null) {
        smartphoneGoal = smartphoneGoals.firstWhere(
          (g) => g.id == selectedSmartphoneGoalId,
          orElse: () => smartphoneGoals[0],
        );
      } else {
        smartphoneGoal = smartphoneGoals[0];
      }
      
      // 期間が今日を含むかチェック
      final endDate = smartphoneGoal.startDate.add(Duration(days: smartphoneGoal.durationDays));
      if (now.isAfter(smartphoneGoal.startDate.subtract(const Duration(days: 1))) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
        todaysGoals.add(smartphoneGoal);
      }
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
  
  /// 目標カードを構築（その日の時間をローカルの日次統計から取得）
  Widget _buildGoalCard(Goal goal) {
    final category = _getCategoryFromDetectionItem(goal.detectionItem);
    final color = _getGoalColor(category);
    
    // その日の時間（秒単位）を状態変数から取得
    final todaySeconds = _getTodayCategorySeconds(category);
        
        // 目標時間は1日換算データを使用（goal.targetSecondsPerDay）
        final targetSecondsPerDay = goal.targetSecondsPerDay;
        
        // 時間フォーマット（表示時に変換）
        final currentMinutes = todaySeconds ~/ 60;
        final targetMinutes = targetSecondsPerDay ~/ 60;
        final currentValue = _formatMinutes(currentMinutes);
        final targetValue = _formatMinutes(targetMinutes);
        
        // 進捗率の計算（秒単位で計算）
        final percentage = targetSecondsPerDay > 0 
            ? (todaySeconds / targetSecondsPerDay).clamp(0.0, 1.0)
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
  
  /// その日のカテゴリ別時間を状態変数から取得（秒単位）
  int _getTodayCategorySeconds(String category) {
      switch (category) {
        case 'study':
        return _todayCategorySeconds['study'] ?? 0;
        case 'pc':
        return _todayCategorySeconds['pc'] ?? 0;
        case 'smartphone':
        return _todayCategorySeconds['smartphone'] ?? 0;
        default:
      return 0;
    }
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
