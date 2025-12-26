import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/charts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/category_data_point.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/presentation/widgets/entitlement_gate.dart';
import 'package:test_flutter/presentation/widgets/level_badge.dart';
import 'package:test_flutter/data/sources/date_utils.dart' as DateUtilsHelper;
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/data/sources/auth_source.dart';

/// レポート画面（新デザインシステム版）
class ReportScreenNew extends ConsumerStatefulWidget {
  const ReportScreenNew({super.key});

  @override
  ConsumerState<ReportScreenNew> createState() => _ReportScreenNewState();
}

class _ReportScreenNewState extends ConsumerState<ReportScreenNew> {
  int _selectedPeriodIndex = 0; // 0: Day, 1: Week, 2: Month, 3: Year
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    // Firestore取得はアプリ起動時のみ（画面を開くたびには取得しない）
    // reset time settingに基づいて「今日」の日付を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedDate = DateUtilsHelper.DateUtils.getTodayDate(ref);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final hasExtendedReports = EntitlementRules.canUse(
      subscriptionStatus,
      PremiumFeature.extendedReports,
    );
    final isLockedView = _selectedPeriodIndex >= 2 && !hasExtendedReports;

    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            bottom: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodTabs(hasExtendedReports),
              SizedBox(height: AppSpacing.xs),
              if (isLockedView) ...[
                const PremiumLockCard(feature: PremiumFeature.extendedReports),
              ] else ...[
                _buildDateSelector(),
                SizedBox(height: AppSpacing.xs),
                _buildStatHighlights(),
                if (_selectedPeriodIndex == 2) ...[
                  SizedBox(height: AppSpacing.xs),
                  _buildLevelSummaryCard(),
                ],
                SizedBox(height: AppSpacing.xs),
                Expanded(child: _buildActivityChartCard()),
                SizedBox(height: AppSpacing.xs),
                Expanded(child: _buildDistributionCard()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodTitle() {
    switch (_selectedPeriodIndex) {
      case 0:
        return '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}';
      case 1:
        final weekStart = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}';
      case 2:
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 3:
        return 'Year ${_selectedDate.year}';
      default:
        return '--';
    }
  }

  Widget _buildPeriodTabs(bool hasExtendedReports) {
    const periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = index == _selectedPeriodIndex;
          final isPremiumTab = index >= 2;
          final isLocked = isPremiumTab && !hasExtendedReports;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    if (isLocked) {
                      setState(() {
                        _selectedPeriodIndex = index;
                      });
                      Navigator.of(context)
                          .pushNamed(AppRoutes.subscriptionNew);
                      return;
                    }
                    setState(() {
                      _selectedPeriodIndex = index;
                      _selectedDate = DateTime.now();
                    });
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blue.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.blue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            periods[index],
                            style: AppTextStyles.body2.copyWith(
                              color: isLocked
                                  ? AppColors.textSecondary
                                  : isSelected
                                      ? AppColors.blue
                                      : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isLocked) ...[
                            SizedBox(width: AppSpacing.xs),
                            const Icon(
                              Icons.lock,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateSelector() {
    final label = _getPeriodTitle();
    final baseFontSize = AppTextStyles.body2.fontSize ?? 14.0;
    final labelStyle = AppTextStyles.body2.copyWith(
      fontSize: baseFontSize * 1.1,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        _buildDateArrow(
          icon: Icons.chevron_left,
          onTap: () {
            setState(() {
              _selectedDate = _getPreviousDate();
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _buildDateArrow(
          icon: Icons.chevron_right,
          onTap: () {
            setState(() {
              _selectedDate = _getNextDate();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
            color: AppColors.black,
          ),
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildStatHighlights() {
    return FutureBuilder<double>(
      future: _getSelectedTotalHours(),
      builder: (context, snapshot) {
        final totalFocused = snapshot.data ?? 0.0;
        return FutureBuilder<double>(
          future: _getPreviousPeriodTotalHours(),
          builder: (context, prevSnapshot) {
            final previousTotal = prevSnapshot.data ?? 0.0;
            final totalChange = _calculatePercentageChange(totalFocused, previousTotal);
            final periodDescriptor = _getPeriodDescriptor();

            return _buildHeroStatCard(
              icon: Icons.schedule,
              title: 'Total Time ($periodDescriptor)',
              value: _formatMinutes(totalFocused),
              subtitle: 'Tracked focus time',
              changeLabel: _formatChange(totalChange, isPercentage: true),
              accentColor: AppColors.blue,
              isPositive: totalChange >= 0,
            );
          },
        );
      },
    );
  }

  Widget _buildLevelSummaryCard() {
    final levelState = ref.watch(levelingStateProvider);
    final visuals = LevelRankVisuals.resolveForLevel(levelState.level);
    final hours = (levelState.personSeconds / 3600).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: visuals.badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          LevelBadge(
            tier: levelState.rank,
            level: levelState.level,
            showGlow: true,
            size: 56,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Level Summary',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${visuals.label} • Lv ${levelState.level}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$hours h human focus • Reset on ${_formatDate(levelState.nextResetAt)}',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
  
  /// 前期間の合計時間を取得（統計データのtotalWorkTimeSecondsを使用）
  Future<double> _getPreviousPeriodTotalHours() async {
    try {
      int? totalWorkTimeSeconds;
      DateTime previousDate;
      
      switch (_selectedPeriodIndex) {
        case 0: // Daily: 前日
          previousDate = _selectedDate.subtract(const Duration(days: 1));
          final dailyManager = DailyStatisticsDataManager();
          final dateOnly = DateTime(previousDate.year, previousDate.month, previousDate.day);
          final dailyStats = await dailyManager.getByDateWithAuth(dateOnly);
          if (dailyStats != null) {
            totalWorkTimeSeconds = dailyStats.totalWorkTimeSeconds;
          }
          break;
        case 1: // Weekly: 先週
          previousDate = _selectedDate.subtract(const Duration(days: 7));
          final weeklyManager = WeeklyStatisticsDataManager();
          final weeklyStats = await weeklyManager.getByWeekWithAuth(previousDate);
          if (weeklyStats != null) {
            totalWorkTimeSeconds = weeklyStats.totalWorkTimeSeconds;
          }
          break;
        case 2: // Monthly: 先月
          final previousMonth = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            _selectedDate.day,
          );
          final monthlyManager = MonthlyStatisticsDataManager();
          final monthlyStats = await monthlyManager.getByMonthWithAuth(
            previousMonth.year,
            previousMonth.month,
          );
          if (monthlyStats != null) {
            totalWorkTimeSeconds = monthlyStats.totalWorkTimeSeconds;
          }
          break;
        case 3: // Yearly: 前年
          final previousYear = DateTime(
            _selectedDate.year - 1,
            _selectedDate.month,
            _selectedDate.day,
          );
          final yearlyManager = YearlyStatisticsDataManager();
          final yearlyStats = await yearlyManager.getByYearWithAuth(previousYear.year);
          if (yearlyStats != null) {
            totalWorkTimeSeconds = yearlyStats.totalWorkTimeSeconds;
          }
          break;
      }
      
      // Firestoreから統計データを取得できた場合
      if (totalWorkTimeSeconds != null) {
        return totalWorkTimeSeconds / 3600.0; // 秒を時間に変換
      }
    } catch (e) {
      debugPrint('❌ [report.dart] 前期間Firestore統計データ取得エラー: $e');
    }
    
    // 統計データが取得できない場合は0を返す
    return 0.0;
  }
  
  /// 変化率を計算（パーセンテージ）
  double _calculatePercentageChange(double current, double previous) {
    if (previous == 0.0) {
      // 前期間が0の場合は、現在が0より大きければ100%、そうでなければ0%
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100.0;
  }

  Widget _buildHeroStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required String changeLabel,
    required Color accentColor,
    required bool isPositive,
  }) {
    final badgeColor = isPositive ? AppColors.green : AppColors.red;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 28,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildTrendBadge(changeLabel, badgeColor, isPositive),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(String text, Color color, bool isPositive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 14,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(double hours) {
    final minutes = (hours * 60).round();
    if (minutes < 60) {
      return '${minutes}m';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) {
      return '${h}h';
    }
    return '${h}h ${m}m';
  }

  String _formatChange(
    double value, {
    bool isPercentage = true,
    String unit = '',
  }) {
    final prefix = value > 0 ? '+' : '';
    final formatted = isPercentage
        ? '${value.toStringAsFixed(0)}%'
        : value.toStringAsFixed(0);
    return '$prefix$formatted$unit';
  }

  /// 選択期間の合計時間を取得（統計データのtotalWorkTimeSecondsを使用）
  Future<double> _getSelectedTotalHours() async {
    try {
      // Firestoreから統計データを取得
      int? totalWorkTimeSeconds;
      
      switch (_selectedPeriodIndex) {
        case 0: // Daily
          final dailyManager = DailyStatisticsDataManager();
          final dateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          final dailyStats = await dailyManager.getByDateWithAuth(dateOnly);
          if (dailyStats != null) {
            totalWorkTimeSeconds = dailyStats.totalWorkTimeSeconds;
          }
          break;
        case 1: // Weekly
          final weeklyManager = WeeklyStatisticsDataManager();
          final weeklyStats = await weeklyManager.getByWeekWithAuth(_selectedDate);
          if (weeklyStats != null) {
            totalWorkTimeSeconds = weeklyStats.totalWorkTimeSeconds;
          }
          break;
        case 2: // Monthly
          final monthlyManager = MonthlyStatisticsDataManager();
          final monthlyStats = await monthlyManager.getByMonthWithAuth(
            _selectedDate.year,
            _selectedDate.month,
          );
          if (monthlyStats != null) {
            totalWorkTimeSeconds = monthlyStats.totalWorkTimeSeconds;
          }
          break;
        case 3: // Yearly
          final yearlyManager = YearlyStatisticsDataManager();
          final yearlyStats = await yearlyManager.getByYearWithAuth(_selectedDate.year);
          if (yearlyStats != null) {
            totalWorkTimeSeconds = yearlyStats.totalWorkTimeSeconds;
          }
          break;
      }
      
      // Firestoreから統計データを取得できた場合
      if (totalWorkTimeSeconds != null) {
        return totalWorkTimeSeconds / 3600.0; // 秒を時間に変換
      }
    } catch (e) {
      debugPrint('❌ [report.dart] Firestore統計データ取得エラー: $e');
    }
    
    // 統計データが取得できない場合は0を返す
    return 0.0;
  }

  /// 現在の期間のデータポイントを取得（統計データベースから）
  Future<List<CategoryDataPoint>> _getDataPointsForCurrentPeriod() async {
    switch (_selectedPeriodIndex) {
      case 0:
        return await _getDataPointsFromDailyStatistics(_selectedDate);
      case 1:
        return await _getDataPointsFromWeeklyStatistics(_selectedDate);
      case 2:
        return await _getDataPointsFromMonthlyStatistics(_selectedDate);
      case 3:
        return await _getDataPointsFromYearlyStatistics(_selectedDate);
      default:
        return await _getDataPointsFromWeeklyStatistics(_selectedDate);
    }
  }

  /// 日次統計からグラフデータを生成（時間ごとの検出時間をもとに棒グラフを作成）
  /// 
  /// daily statisticsのhourlyCategorySecondsフィールドから時間ごとの検出時間を取得し、
  /// reset time基準で並び替えて棒グラフ用のデータポイントを生成します。
  Future<List<CategoryDataPoint>> _getDataPointsFromDailyStatistics(DateTime date) async {
    try {
      // 1. Firestoreから取得を試みる
      final dailyManager = DailyStatisticsDataManager();
      final dateOnly = DateTime(date.year, date.month, date.day);
      DailyStatistics? stats = await dailyManager.getByDateWithAuth(dateOnly);
      
      // 2. 取得できない場合はローカルから取得
      stats ??= await dailyManager.getByDateLocal(dateOnly);
      
      // 3. データがない場合は空のリストを返す
      if (stats == null) {
        return [];
      }
      
      // 4. hourlyCategorySecondsが空の場合は空のリストを返す
      if (stats.hourlyCategorySeconds.isEmpty) {
        debugPrint('⚠️ [report.dart] hourlyCategorySecondsが空です: date=$dateOnly');
        return [];
      }
      
      debugPrint('📊 [report.dart] hourlyCategorySeconds取得: ${stats.hourlyCategorySeconds.length}時間帯にデータあり');
      
      // 5. reset timeを取得
      int resetHour = 0;
      try {
        final currentUser = AuthMk.getCurrentUser();
        if (currentUser != null) {
          final userId = currentUser.uid;
          final timeSettingsManager = TimeSettingsDataManager();
          final timeSettings = await timeSettingsManager.getById(userId, 'time_settings');
          if (timeSettings != null) {
            final resetTimeParts = timeSettings.dayBoundaryTime.split(':');
            resetHour = int.tryParse(resetTimeParts[0]) ?? 0;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [report.dart] reset time取得エラー: $e');
        // エラー時はデフォルトで0時を使用
      }
      
      // 6. reset time基準で時間を並び替え（reset timeから始まる）
      // 例: reset timeが4時の場合 → 4, 5, 6, ..., 23, 0, 1, 2, 3
      // hourlyCategorySecondsから時間ごとの検出時間を取得して棒グラフ用のデータポイントを生成
      final dataPoints = <CategoryDataPoint>[];
      for (int i = 0; i < 24; i++) {
        final hour = (resetHour + i) % 24;
        final hourKey = hour.toString();
        final hourData = stats.hourlyCategorySeconds[hourKey] ?? {};
        
        // 時間ごとの検出時間（秒）を時間単位に変換
        final values = <String, double>{
          'study': (hourData['study'] ?? 0) / 3600.0,
          'pc': (hourData['pc'] ?? 0) / 3600.0,
          'smartphone': (hourData['smartphone'] ?? 0) / 3600.0,
          'personOnly': (hourData['personOnly'] ?? 0) / 3600.0,
          'nothingDetected': (hourData['nothingDetected'] ?? 0) / 3600.0,
        };
        
        dataPoints.add(CategoryDataPoint(
          label: '$hour:00',
          values: values,
        ));
      }
      return dataPoints;
    } catch (e, stackTrace) {
      debugPrint('❌ [report.dart] 日次統計データ取得エラー: $e');
      debugPrint('   スタックトレース: $stackTrace');
      return [];
    }
  }

  /// 週次統計からグラフデータを生成
  Future<List<CategoryDataPoint>> _getDataPointsFromWeeklyStatistics(DateTime date) async {
    try {
      final weeklyManager = WeeklyStatisticsDataManager();
      WeeklyStatistics? stats = await weeklyManager.getByWeekWithAuth(date);
      
      // Firestoreから取得できない場合はローカルから取得
      if (stats == null) {
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final allLocal = await weeklyManager.getLocalAll();
        stats = allLocal.where((w) => 
          w.weekStart.year == weekStart.year &&
          w.weekStart.month == weekStart.month &&
          w.weekStart.day == weekStart.day
        ).firstOrNull;
      }
      
      if (stats == null || stats.dailyCategorySeconds.isEmpty) {
        return [];
      }
      
      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dataPoints = <CategoryDataPoint>[];
      
      for (int day = 0; day < 7; day++) {
        final dayKey = day.toString();
        final dayData = stats.dailyCategorySeconds[dayKey] ?? {};
        final values = <String, double>{
          'study': (dayData['study'] ?? 0) / 3600.0,
          'pc': (dayData['pc'] ?? 0) / 3600.0,
          'smartphone': (dayData['smartphone'] ?? 0) / 3600.0,
          'personOnly': (dayData['personOnly'] ?? 0) / 3600.0,
          'nothingDetected': (dayData['nothingDetected'] ?? 0) / 3600.0,
        };
        dataPoints.add(CategoryDataPoint(
          label: weekDays[day],
          values: values,
        ));
      }
      return dataPoints;
    } catch (e) {
      debugPrint('❌ [report.dart] 週次統計データ取得エラー: $e');
      return [];
    }
  }

  /// 月次統計からグラフデータを生成
  Future<List<CategoryDataPoint>> _getDataPointsFromMonthlyStatistics(DateTime date) async {
    try {
      final monthlyManager = MonthlyStatisticsDataManager();
      MonthlyStatistics? stats = await monthlyManager.getByMonthWithAuth(
        date.year,
        date.month,
      );
      
      // Firestoreから取得できない場合はローカルから取得
      if (stats == null) {
        final allLocal = await monthlyManager.getLocalAll();
        stats = allLocal.where((m) => 
          m.year == date.year && m.month == date.month
        ).firstOrNull;
      }
      
      if (stats == null || stats.dailyCategorySeconds.isEmpty) {
        return [];
      }
      
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = DateTime(date.year, date.month + 1, 1);
      final daysInMonth = monthEnd.difference(monthStart).inDays;
      
      final dataPoints = <CategoryDataPoint>[];
      
      for (int day = 1; day <= daysInMonth; day++) {
        final dayKey = day.toString();
        final dayData = stats.dailyCategorySeconds[dayKey] ?? {};
        final values = <String, double>{
          'study': (dayData['study'] ?? 0) / 3600.0,
          'pc': (dayData['pc'] ?? 0) / 3600.0,
          'smartphone': (dayData['smartphone'] ?? 0) / 3600.0,
          'personOnly': 0.0, // 月次ではpersonOnlyとnothingDetectedは含まれない
          'nothingDetected': 0.0,
        };
        dataPoints.add(CategoryDataPoint(
          label: '$day',
          values: values,
        ));
      }
      return dataPoints;
    } catch (e) {
      debugPrint('❌ [report.dart] 月次統計データ取得エラー: $e');
      return [];
    }
  }

  /// 年次統計からグラフデータを生成
  Future<List<CategoryDataPoint>> _getDataPointsFromYearlyStatistics(DateTime date) async {
    try {
      final yearlyManager = YearlyStatisticsDataManager();
      YearlyStatistics? stats = await yearlyManager.getByYearWithAuth(date.year);
      
      // Firestoreから取得できない場合はローカルから取得
      if (stats == null) {
        final allLocal = await yearlyManager.getLocalAll();
        stats = allLocal.where((y) => y.year == date.year).firstOrNull;
      }
      
      if (stats == null || stats.monthlyCategorySeconds.isEmpty) {
        return [];
      }
      
      final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final dataPoints = <CategoryDataPoint>[];
      
      for (int month = 1; month <= 12; month++) {
        final monthKey = month.toString();
        final monthData = stats.monthlyCategorySeconds[monthKey] ?? {};
        final values = <String, double>{
          'study': (monthData['study'] ?? 0) / 3600.0,
          'pc': (monthData['pc'] ?? 0) / 3600.0,
          'smartphone': (monthData['smartphone'] ?? 0) / 3600.0,
          'personOnly': 0.0, // 年次ではpersonOnlyとnothingDetectedは含まれない
          'nothingDetected': 0.0,
        };
        dataPoints.add(CategoryDataPoint(
          label: monthLabels[month - 1],
          values: values,
        ));
      }
      return dataPoints;
    } catch (e) {
      debugPrint('❌ [report.dart] 年次統計データ取得エラー: $e');
      return [];
    }
  }



  String _getPeriodDescriptor() {
    switch (_selectedPeriodIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'This Week';
      case 2:
        return 'This Month';
      case 3:
        return 'This Year';
      default:
        return 'This Period';
    }
  }

  /// 前の日付を取得（期間タイプに応じて）
  DateTime _getPreviousDate() {
    switch (_selectedPeriodIndex) {
      case 0: // Daily: 1日前
        return _selectedDate.subtract(const Duration(days: 1));
      case 1: // Weekly: 1週間前
        return _selectedDate.subtract(const Duration(days: 7));
      case 2: // Monthly: 1ヶ月前
        return DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
      case 3: // Yearly: 1年前
        return DateTime(
          _selectedDate.year - 1,
          _selectedDate.month,
          _selectedDate.day,
        );
      default:
        return _selectedDate.subtract(const Duration(days: 7));
    }
  }

  /// 次の日付を取得（期間タイプに応じて）
  DateTime _getNextDate() {
    switch (_selectedPeriodIndex) {
      case 0: // Daily: 1日後
        return _selectedDate.add(const Duration(days: 1));
      case 1: // Weekly: 1週間後
        return _selectedDate.add(const Duration(days: 7));
      case 2: // Monthly: 1ヶ月後
        return DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
      case 3: // Yearly: 1年後
        return DateTime(
          _selectedDate.year + 1,
          _selectedDate.month,
          _selectedDate.day,
        );
      default:
        return _selectedDate.add(const Duration(days: 7));
    }
  }

  Widget _buildActivityChartCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _buildLegendPill('Study', AppColors.green),
                  _buildLegendPill('PC', const Color.fromRGBO(20, 120, 230, 1)),
                  _buildLegendPill('Phone', AppColors.orange),
                  if (_selectedPeriodIndex <= 1)
                    _buildLegendPill('People', AppColors.gray),
                  if (_selectedPeriodIndex <= 1)
                    _buildLegendPill('No Detection', AppColors.lightblackgray),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<CategoryDataPoint>>(
            future: _getDataPointsForCurrentPeriod(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      'データの読み込みに失敗しました',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              final dataPoints = snapshot.data ?? [];
              
              // デバッグログ: データポイント数を確認
              debugPrint('📊 [report.dart] FutureBuilder<List<CategoryDataPoint>>: dataPoints.length=${dataPoints.length}');
              
              if (dataPoints.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      'データがありません',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return FutureBuilder<List<BarChartGroupData>>(
                future: _getChartData(),
                builder: (context, chartSnapshot) {
                  if (chartSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blue,
                        ),
                      ),
                    );
                  }

                  final barGroups = chartSnapshot.data ?? [];
                  
                  // デバッグログ: barGroups数を確認
                  debugPrint('📊 [report.dart] FutureBuilder<List<BarChartGroupData>>: barGroups.length=${barGroups.length}');
                  
                  // barGroupsが空の場合もデータなしを表示
                  if (barGroups.isEmpty) {
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'グラフデータがありません',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return FutureBuilder<double>(
                    future: _getMaxY(),
                    builder: (context, maxYSnapshot) {
                      final maxY = maxYSnapshot.data ?? 10.0;
                      
                      // デバッグログ: maxYを確認
                      debugPrint('📊 [report.dart] maxY=$maxY');
                      
                      return AppBarChart(
                        height: 300,
                        barGroups: barGroups,
                        maxY: maxY,
                        getBottomTitles: (value, meta) {
                          final index = value.toInt();
                          if (_selectedPeriodIndex == 0 && index % 3 != 0) {
                            return const SizedBox.shrink();
                          }
                          if (index >= 0 && index < dataPoints.length) {
                            final label = dataPoints[index].label;
                            if (label.isEmpty) return const SizedBox.shrink();
                            final isDense =
                                _selectedPeriodIndex == 0 || _selectedPeriodIndex == 2;
                            final style = isDense
                                ? AppTextStyles.caption.copyWith(fontSize: 10)
                                : AppTextStyles.caption;
                            return Padding(
                              padding: EdgeInsets.only(top: AppSpacing.xs),
                              child: Text(label, style: style),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        getLeftTitles: (value, meta) {
                          if (value == 0 || value == maxY) {
                            final minutes = (value * 60).round();
                            String label;
                            if (minutes < 60) {
                              label = '${minutes}m';
                            } else {
                              final h = minutes ~/ 60;
                              final m = minutes % 60;
                              if (m == 0) {
                                label = '${h}h';
                              } else {
                                label = '${h}h ${m}m';
                              }
                            }
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: value == 0 ? AppSpacing.xs : 0,
                                top: value == maxY ? AppSpacing.sm : 0,
                              ),
                              child: Text(
                                label,
                                style: AppTextStyles.caption,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDistributionCard() {
    return FutureBuilder<Map<String, double>>(
      future: _getCategorySummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data ?? <String, double>{
          'study': 0.0,
          'pc': 0.0,
          'smartphone': 0.0,
          'personOnly': 0.0,
          'nothingDetected': 0.0,
        };
        
        final sections = _getPieChartSectionsFromSummary(summary);
        final isMonthOrYear = _selectedPeriodIndex == 2 || _selectedPeriodIndex == 3;
        // 月次と年次ではpeopleとno detectionを含めない
        final total = isMonthOrYear
            ? (summary['study'] ?? 0) + (summary['pc'] ?? 0) + (summary['smartphone'] ?? 0)
            : summary.values.reduce((a, b) => a + b);
        final titleStyle = AppTextStyles.body1.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        );

        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category Distribution', style: titleStyle),
              SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPieChart(
                    sections: sections,
                    centerText: _formatMinutesShort(total),
                    radius: 65,
                    strokeWidth: 18,
                    backgroundColor: AppColors.blackgray,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendRow(
                          'Study',
                          summary['study'] ?? 0,
                          AppColors.green,
                        ),
                        _buildLegendRow(
                          'PC',
                          summary['pc'] ?? 0,
                          const Color.fromRGBO(20, 120, 230, 1),
                        ),
                        _buildLegendRow(
                          'Smartphone',
                          summary['smartphone'] ?? 0,
                          AppColors.orange,
                        ),
                        if (_selectedPeriodIndex <= 1)
                          _buildLegendRow(
                            'People',
                            summary['personOnly'] ?? 0,
                            AppColors.gray,
                            dimWhenZero: true,
                          ),
                        if (_selectedPeriodIndex <= 1)
                          _buildLegendRow(
                            'No Detection',
                            summary['nothingDetected'] ?? 0,
                            AppColors.lightblackgray,
                            dimWhenZero: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendRow(
    String label,
    double hours,
    Color color, {
    bool dimWhenZero = false,
  }) {
    final effectiveColor = dimWhenZero && hours == 0
        ? AppColors.disabledGray
        : color;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatMinutesShort(hours),
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatMinutesShort(double hours) {
    final minutes = (hours * 60).round();
    if (minutes < 60) {
      return '${minutes}m';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) {
      return '${h}h';
    }
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  Future<List<BarChartGroupData>> _getChartData() async {
    final data = await _getDataPointsForCurrentPeriod();
    final isDay = _selectedPeriodIndex == 0;
    final isWeek = _selectedPeriodIndex == 1;
    final isMonth = _selectedPeriodIndex == 2;
    final denseBarWidth = 10.0;
    final normalBarWidth = 16.0;

    // デバッグログ: データポイント数を確認
    debugPrint('📊 [report.dart] _getChartData: データポイント数=${data.length}, isDay=$isDay');

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      double cursor = 0;
      final stackItems = <BarChartRodStackItem>[];

      void addSegment(double? value, Color color) {
        if (value == null || value == 0) return;
        stackItems.add(BarChartRodStackItem(cursor, cursor + value, color));
        cursor += value;
      }

      addSegment(point.values['study'], AppColors.green);
      // PC用の濃い青
      addSegment(point.values['pc'], const Color.fromRGBO(20, 120, 230, 1));
      addSegment(point.values['smartphone'], AppColors.orange);

      if (isDay || isWeek) {
        addSegment(point.values['personOnly'], AppColors.gray);
        addSegment(point.values['nothingDetected'], AppColors.lightblackgray);
      }

      final barWidth = (isDay || isMonth || data.length > 20)
          ? denseBarWidth
          : normalBarWidth;

      // iOS実機での表示問題を回避: 空のbarRodsを返さず、最小値（0.001）を設定
      // これにより、グラフの軸とレイアウトが正しく表示される
      if (cursor == 0) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: 0.001, // 最小値を設定してグラフのレイアウトを維持
              width: barWidth,
              borderRadius: BorderRadius.circular(8),
              rodStackItems: const [], // 空のスタックアイテム
              color: Colors.transparent, // 透明にして見えないようにする
            ),
          ],
        );
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: cursor,
            width: barWidth,
            borderRadius: BorderRadius.circular(8),
            rodStackItems: List.from(stackItems),
          ),
        ],
      );
    }).toList();
  }

  Future<double> _getMaxY() async {
    final data = await _getChartData();
    if (data.isEmpty) {
      // デフォルト値
      switch (_selectedPeriodIndex) {
        case 0:
          return 2.0;
        case 1:
          return 10.0;
        case 2:
          return 15.0;
        case 3:
          return 250.0;
        default:
          return 10.0;
      }
    }
    
    // 一番長い棒の値を取得
    double maxValue = 0.0;
    for (final group in data) {
      if (group.barRods.isNotEmpty) {
        final rod = group.barRods.first;
        if (rod.toY > maxValue) {
          maxValue = rod.toY;
        }
      }
    }
    
    // 最大値が0の場合はデフォルト値を返す
    if (maxValue == 0.0) {
      switch (_selectedPeriodIndex) {
        case 0:
          return 2.0;
        case 1:
          return 10.0;
        case 2:
          return 15.0;
        case 3:
          return 250.0;
        default:
          return 10.0;
      }
    }
    
    // 一番長い棒がちょうど枠の上につくように、少し余裕を持たせる（10%増し）
    return maxValue * 1.1;
  }


  List<PieChartSectionData> _getPieChartSectionsFromSummary(Map<String, double> summary) {
    final isMonthOrYear = _selectedPeriodIndex == 2 || _selectedPeriodIndex == 3;
    
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: summary['study'] ?? 0,
        color: AppColors.green,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: summary['pc'] ?? 0,
        color: const Color.fromRGBO(20, 120, 230, 1),
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: summary['smartphone'] ?? 0,
        color: AppColors.orange,
        radius: 50,
        showTitle: false,
      ),
    ];
    
    // 月次と年次ではpeopleとno detectionを含めない
    if (!isMonthOrYear) {
      final peopleValue = summary['personOnly'] ?? 0;
      final peopleColor = peopleValue == 0
          ? AppColors.disabledGray
          : AppColors.gray;
      final nothingValue = summary['nothingDetected'] ?? 0;
      
      sections.add(
        PieChartSectionData(
          value: peopleValue,
          color: peopleColor,
          radius: 50,
          showTitle: false,
        ),
      );
      sections.add(
        PieChartSectionData(
          value: nothingValue,
          color: AppColors.lightblackgray,
          radius: 50,
          showTitle: false,
        ),
      );
    }
    
    return sections;
  }

  /// カテゴリ別のサマリーを取得（Firestoreの統計データを優先、なければローカルデータから計算）
  Future<Map<String, double>> _getCategorySummary() async {
    try {
      // Firestoreから統計データを取得
      Map<String, int>? categorySeconds;
      
      switch (_selectedPeriodIndex) {
        case 0: // Daily
          final dailyManager = DailyStatisticsDataManager();
          final dateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          final dailyStats = await dailyManager.getByDateWithAuth(dateOnly);
          if (dailyStats != null) {
            categorySeconds = dailyStats.categorySeconds;
          }
          break;
        case 1: // Weekly
          final weeklyManager = WeeklyStatisticsDataManager();
          final weeklyStats = await weeklyManager.getByWeekWithAuth(_selectedDate);
          if (weeklyStats != null) {
            categorySeconds = weeklyStats.categorySeconds;
          }
          break;
        case 2: // Monthly
          final monthlyManager = MonthlyStatisticsDataManager();
          final monthlyStats = await monthlyManager.getByMonthWithAuth(
            _selectedDate.year,
            _selectedDate.month,
          );
          if (monthlyStats != null) {
            categorySeconds = monthlyStats.categorySeconds;
          }
          break;
        case 3: // Yearly
          final yearlyManager = YearlyStatisticsDataManager();
          final yearlyStats = await yearlyManager.getByYearWithAuth(_selectedDate.year);
          if (yearlyStats != null) {
            categorySeconds = yearlyStats.categorySeconds;
          }
          break;
      }
      
      // Firestoreから統計データを取得できた場合
      if (categorySeconds != null) {
        final summary = <String, double>{};
        for (final entry in categorySeconds.entries) {
          // 秒を時間に変換
          summary[entry.key] = entry.value / 3600.0;
        }
        
        // すべてのカテゴリが存在することを保証
        summary['study'] ??= 0.0;
        summary['pc'] ??= 0.0;
        summary['smartphone'] ??= 0.0;
        summary['personOnly'] ??= 0.0;
        summary['nothingDetected'] ??= 0.0;
        
        return summary;
      }
    } catch (e) {
      debugPrint('❌ [report.dart] Firestore統計データ取得エラー: $e');
    }
    
    // 統計データが取得できない場合は、空のサマリーを返す
    return <String, double>{
      'study': 0.0,
      'pc': 0.0,
      'smartphone': 0.0,
      'personOnly': 0.0,
      'nothingDetected': 0.0,
    };
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        NavigationHelper.pushReplacement(context, AppRoutes.home);
        break;
      case 1:
        NavigationHelper.pushReplacement(context, AppRoutes.goal);
        break;
      case 3:
        NavigationHelper.pushReplacement(context, AppRoutes.friend);
        break;
      case 4:
        NavigationHelper.pushReplacement(context, AppRoutes.settings);
        break;
    }
  }
}
