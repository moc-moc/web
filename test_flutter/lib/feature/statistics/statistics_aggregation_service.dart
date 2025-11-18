import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';

/// 統計集計サービス
/// 
/// トラッキングセッション終了時に、各期間の統計データを集計・更新します。
class StatisticsAggregationService {
  // シングルトンインスタンス（パフォーマンス最適化）
  static final DailyStatisticsDataManager _dailyManager = DailyStatisticsDataManager();
  static final WeeklyStatisticsDataManager _weeklyManager = WeeklyStatisticsDataManager();
  static final MonthlyStatisticsDataManager _monthlyManager = MonthlyStatisticsDataManager();
  static final YearlyStatisticsDataManager _yearlyManager = YearlyStatisticsDataManager();
  static final GoalDataManager _goalManager = GoalDataManager();
  static final TotalDataManager _totalManager = TotalDataManager();
  
  // 目標キャッシュ（セッション処理中は再利用）
  List<Goal>? _cachedGoals;
  DateTime? _goalsCacheTime;
  static const _goalsCacheExpiry = Duration(minutes: 5);

  /// セッション終了時の集計処理
  /// 
  /// トラッキングセッションのデータを各期間の統計に反映します。
  /// 
  /// **パラメータ**:
  /// - `session`: トラッキングセッション
  /// 
  /// **戻り値**: 処理成功時true、失敗時false
  Future<bool> aggregateSessionData(TrackingSession session) async {
    try {
      LogMk.logDebug(
        '📊 統計集計処理を開始: セッションID ${session.id}',
        tag: 'StatisticsAggregationService',
      );

      // 1. nothingDetected時間を計算
      final nothingDetectedSeconds = _calculateNothingDetectedSeconds(session);
      
      // categorySecondsにnothingDetectedを追加
      final categorySecondsWithNothing = Map<String, int>.from(session.categorySeconds);
      categorySecondsWithNothing['nothingDetected'] = nothingDetectedSeconds;

      // 2. 作業時間を計算（study + pc）
      final workSeconds = (session.categorySeconds['study'] ?? 0) +
                         (session.categorySeconds['pc'] ?? 0);

      // 3-6. 統計データをバッチで事前取得（パフォーマンス最適化）
      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      final year = session.startTime.year;
      final month = session.startTime.month;
      
      // 並列で既存データを取得
      final existingData = await Future.wait([
        _dailyManager.getByDateWithAuth(date),
        _weeklyManager.getByWeekWithAuth(session.startTime),
        _monthlyManager.getByMonthWithAuth(year, month),
        _yearlyManager.getByYearWithAuth(year),
      ]);
      
      final existingDaily = existingData[0] as DailyStatistics?;
      final existingWeekly = existingData[1] as WeeklyStatistics?;
      final existingMonthly = existingData[2] as MonthlyStatistics?;
      final existingYearly = existingData[3] as YearlyStatistics?;

      // 3. 日次データの集計・更新
      await _updateDailyStatistics(session, categorySecondsWithNothing, workSeconds, existingDaily);

      // 4. 週次データの集計・更新
      await _updateWeeklyStatistics(session, categorySecondsWithNothing, workSeconds, existingWeekly);

      // 5. 月次データの集計・更新（personOnly/nothingDetected除外）
      await _updateMonthlyStatistics(session, workSeconds, existingMonthly);

      // 6. 年次データの集計・更新（personOnly/nothingDetected除外）
      await _updateYearlyStatistics(session, workSeconds, existingYearly);

      // 7. 目標の更新
      await _updateGoalProgress(session);

      // 8. Total Timeの更新
      await _updateTotalTime(workSeconds, session.startTime);

      LogMk.logDebug(
        '✅ 統計集計処理が完了しました',
        tag: 'StatisticsAggregationService',
      );

      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 統計集計処理中にエラーが発生しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// nothingDetected時間を計算
  int _calculateNothingDetectedSeconds(TrackingSession session) {
    return session.detectionPeriods
        .where((p) => p.category == 'nothingDetected')
        .fold(0, (sum, p) => sum + p.endTime.difference(p.startTime).inSeconds);
  }

  /// セッションから時間ごとのカテゴリ別秒数を集計（日次用）
  /// 戻り値: {"0": {study: 600, pc: 300, ...}, "1": {...}, ...}
  Map<String, Map<String, int>> _aggregateHourlyCategorySeconds(
    TrackingSession session,
  ) {
    final date = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    );
    final hourlyData = <String, Map<String, int>>{};
    
    // 24時間分の初期化
    for (int hour = 0; hour < 24; hour++) {
      hourlyData[hour.toString()] = {
        'study': 0,
        'pc': 0,
        'smartphone': 0,
        'personOnly': 0,
        'nothingDetected': 0,
      };
    }
    
    // detectionPeriodsから時間ごとに集計
    for (final period in session.detectionPeriods) {
      final periodStart = period.startTime.isAfter(date)
          ? period.startTime
          : date;
      final periodEnd = period.endTime;
      
      // 期間が複数の時間帯にまたがる場合を処理
      var currentTime = periodStart;
      while (currentTime.isBefore(periodEnd)) {
        final hour = currentTime.hour;
        final hourStart = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          hour,
        );
        final hourEnd = hourStart.add(const Duration(hours: 1));
        
        // この時間帯に該当する期間の開始と終了を計算
        final segmentStart = currentTime.isAfter(hourStart) ? currentTime : hourStart;
        final segmentEnd = periodEnd.isBefore(hourEnd) ? periodEnd : hourEnd;
        
        if (segmentStart.isBefore(segmentEnd)) {
          final durationSeconds = segmentEnd.difference(segmentStart).inSeconds;
          final hourKey = hour.toString();
          
          if (hourlyData.containsKey(hourKey)) {
            final category = period.category;
            if (hourlyData[hourKey]!.containsKey(category)) {
              hourlyData[hourKey]![category] = 
                  (hourlyData[hourKey]![category] ?? 0) + durationSeconds;
            }
          }
        }
        
        currentTime = hourEnd;
      }
    }
    
    return hourlyData;
  }

  /// セッションから日ごとのカテゴリ別秒数を集計（週次・月次用）
  /// 戻り値: {"1": {study: 3600, pc: 1800, ...}, "2": {...}, ...}
  Map<String, Map<String, int>> _aggregateDailyCategorySeconds(
    TrackingSession session,
    DateTime periodStart,
  ) {
    final dailyData = <String, Map<String, int>>{};
    
    // detectionPeriodsから日ごとに集計
    for (final period in session.detectionPeriods) {
      final periodDate = DateTime(
        period.startTime.year,
        period.startTime.month,
        period.startTime.day,
      );
      
      // 期間がperiodStart以降かチェック
      if (periodDate.isBefore(periodStart)) {
        continue;
      }
      
      final dayKey = periodDate.day.toString();
      if (!dailyData.containsKey(dayKey)) {
        dailyData[dayKey] = {
          'study': 0,
          'pc': 0,
          'smartphone': 0,
          'personOnly': 0,
          'nothingDetected': 0,
        };
      }
      
      final durationSeconds = period.endTime.difference(period.startTime).inSeconds;
      final category = period.category;
      if (dailyData[dayKey]!.containsKey(category)) {
        dailyData[dayKey]![category] = 
            (dailyData[dayKey]![category] ?? 0) + durationSeconds;
      }
    }
    
    return dailyData;
  }

  /// セッションから月ごとのカテゴリ別秒数を集計（年次用）
  /// 戻り値: {"1": {study: 36000, pc: 18000, ...}, "2": {...}, ...}
  Map<String, Map<String, int>> _aggregateMonthlyCategorySeconds(
    TrackingSession session,
  ) {
    final monthlyData = <String, Map<String, int>>{};
    
    // detectionPeriodsから月ごとに集計
    for (final period in session.detectionPeriods) {
      final month = period.startTime.month;
      final monthKey = month.toString();
      
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {
          'study': 0,
          'pc': 0,
          'smartphone': 0,
        };
      }
      
      final durationSeconds = period.endTime.difference(period.startTime).inSeconds;
      final category = period.category;
      
      // personOnlyとnothingDetectedは除外
      if (category == 'personOnly' || category == 'nothingDetected') {
        continue;
      }
      
      if (monthlyData[monthKey]!.containsKey(category)) {
        monthlyData[monthKey]![category] = 
            (monthlyData[monthKey]![category] ?? 0) + durationSeconds;
      }
    }
    
    return monthlyData;
  }

  /// 日次データの集計・更新
  Future<void> _updateDailyStatistics(
    TrackingSession session,
    Map<String, int> categorySeconds,
    int workSeconds,
    DailyStatistics? existing,
  ) async {
    try {
      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      final id = _formatDateId(date);
      
      // 既存データがあれば加算、なければ新規作成
      final updatedCategorySeconds = <String, int>{
        'study': (existing?.categorySeconds['study'] ?? 0) + (categorySeconds['study'] ?? 0),
        'pc': (existing?.categorySeconds['pc'] ?? 0) + (categorySeconds['pc'] ?? 0),
        'smartphone': (existing?.categorySeconds['smartphone'] ?? 0) + (categorySeconds['smartphone'] ?? 0),
        'personOnly': (existing?.categorySeconds['personOnly'] ?? 0) + (categorySeconds['personOnly'] ?? 0),
        'nothingDetected': (existing?.categorySeconds['nothingDetected'] ?? 0) + (categorySeconds['nothingDetected'] ?? 0),
      };
      final updatedWorkSeconds = (existing?.totalWorkTimeSeconds ?? 0) + workSeconds;
      
      // 時間ごとのデータを集計
      final sessionHourlyData = _aggregateHourlyCategorySeconds(session);
      final updatedHourlyCategorySeconds = <String, Map<String, int>>{};
      
      // 既存の時間ごとのデータと新しいデータをマージ
      for (int hour = 0; hour < 24; hour++) {
        final hourKey = hour.toString();
        final existingHourly = existing?.hourlyCategorySeconds[hourKey] ?? <String, int>{};
        final sessionHourly = sessionHourlyData[hourKey] ?? <String, int>{};
        
        updatedHourlyCategorySeconds[hourKey] = {
          'study': (existingHourly['study'] ?? 0) + (sessionHourly['study'] ?? 0),
          'pc': (existingHourly['pc'] ?? 0) + (sessionHourly['pc'] ?? 0),
          'smartphone': (existingHourly['smartphone'] ?? 0) + (sessionHourly['smartphone'] ?? 0),
          'personOnly': (existingHourly['personOnly'] ?? 0) + (sessionHourly['personOnly'] ?? 0),
          'nothingDetected': (existingHourly['nothingDetected'] ?? 0) + (sessionHourly['nothingDetected'] ?? 0),
        };
      }
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: true);
      
      final dailyStats = DailyStatistics(
        id: id,
        date: date,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
        hourlyCategorySeconds: updatedHourlyCategorySeconds,
        lastModified: DateTime.now(),
      );
      
      await _dailyManager.saveOrUpdateWithAuth(dailyStats);
      
      LogMk.logDebug(
        '✅ 日次統計を更新しました: $id',
        tag: 'StatisticsAggregationService',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 日次統計の更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 週次データの集計・更新
  Future<void> _updateWeeklyStatistics(
    TrackingSession session,
    Map<String, int> categorySeconds,
    int workSeconds,
    WeeklyStatistics? existing,
  ) async {
    try {
      final weekStart = _getWeekStart(session.startTime);
      final id = _formatDateId(weekStart);
      
      // 既存データがあれば加算、なければ新規作成
      final updatedCategorySeconds = <String, int>{
        'study': (existing?.categorySeconds['study'] ?? 0) + (categorySeconds['study'] ?? 0),
        'pc': (existing?.categorySeconds['pc'] ?? 0) + (categorySeconds['pc'] ?? 0),
        'smartphone': (existing?.categorySeconds['smartphone'] ?? 0) + (categorySeconds['smartphone'] ?? 0),
        'personOnly': (existing?.categorySeconds['personOnly'] ?? 0) + (categorySeconds['personOnly'] ?? 0),
        'nothingDetected': (existing?.categorySeconds['nothingDetected'] ?? 0) + (categorySeconds['nothingDetected'] ?? 0),
      };
      final updatedWorkSeconds = (existing?.totalWorkTimeSeconds ?? 0) + workSeconds;
      
      // 日ごとのデータを集計（週次統計用）
      final updatedDailyCategorySeconds = <String, Map<String, int>>{};
      
      // 週の各日（0-6）を処理
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final dayKey = dayOffset.toString();
        final dayDate = weekStart.add(Duration(days: dayOffset));
        final dayEnd = dayDate.add(const Duration(days: 1));
        
        // この日のセッションのdetectionPeriodsを集計
        final dayCategorySeconds = <String, int>{
          'study': 0,
          'pc': 0,
          'smartphone': 0,
          'personOnly': 0,
          'nothingDetected': 0,
        };
        
        for (final period in session.detectionPeriods) {
          // 期間がこの日に該当するかチェック
          if (period.startTime.isBefore(dayEnd) && period.endTime.isAfter(dayDate)) {
            final periodStart = period.startTime.isAfter(dayDate) ? period.startTime : dayDate;
            final periodEnd = period.endTime.isBefore(dayEnd) ? period.endTime : dayEnd;
            
            if (periodStart.isBefore(periodEnd)) {
              final durationSeconds = periodEnd.difference(periodStart).inSeconds;
              final category = period.category;
              if (dayCategorySeconds.containsKey(category)) {
                dayCategorySeconds[category] = (dayCategorySeconds[category] ?? 0) + durationSeconds;
              }
            }
          }
        }
        
        // 既存データとマージ
        final existingDaily = existing?.dailyCategorySeconds[dayKey] ?? <String, int>{};
        updatedDailyCategorySeconds[dayKey] = {
          'study': (existingDaily['study'] ?? 0) + dayCategorySeconds['study']!,
          'pc': (existingDaily['pc'] ?? 0) + dayCategorySeconds['pc']!,
          'smartphone': (existingDaily['smartphone'] ?? 0) + dayCategorySeconds['smartphone']!,
          'personOnly': (existingDaily['personOnly'] ?? 0) + dayCategorySeconds['personOnly']!,
          'nothingDetected': (existingDaily['nothingDetected'] ?? 0) + dayCategorySeconds['nothingDetected']!,
        };
      }
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: true);
      
      final weeklyStats = WeeklyStatistics(
        id: id,
        weekStart: weekStart,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
        dailyCategorySeconds: updatedDailyCategorySeconds,
        lastModified: DateTime.now(),
      );
      
      await _weeklyManager.saveOrUpdateWithAuth(weeklyStats);
      
      LogMk.logDebug(
        '✅ 週次統計を更新しました: $id',
        tag: 'StatisticsAggregationService',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 週次統計の更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 月次データの集計・更新（personOnly/nothingDetected除外）
  Future<void> _updateMonthlyStatistics(
    TrackingSession session,
    int workSeconds,
    MonthlyStatistics? existing,
  ) async {
    try {
      final year = session.startTime.year;
      final month = session.startTime.month;
      final id = _formatMonthId(year, month);
      
      // personOnlyとnothingDetectedを除外したカテゴリ秒数
      final sessionCategorySeconds = <String, int>{
        'study': session.categorySeconds['study'] ?? 0,
        'pc': session.categorySeconds['pc'] ?? 0,
        'smartphone': session.categorySeconds['smartphone'] ?? 0,
      };
      
      // 既存データがあれば加算、なければ新規作成
      final updatedCategorySeconds = <String, int>{
        'study': (existing?.categorySeconds['study'] ?? 0) + sessionCategorySeconds['study']!,
        'pc': (existing?.categorySeconds['pc'] ?? 0) + sessionCategorySeconds['pc']!,
        'smartphone': (existing?.categorySeconds['smartphone'] ?? 0) + sessionCategorySeconds['smartphone']!,
      };
      final updatedWorkSeconds = (existing?.totalWorkTimeSeconds ?? 0) + workSeconds;
      
      // 日ごとのデータを集計
      final monthStart = DateTime(year, month, 1);
      final sessionDailyData = _aggregateDailyCategorySeconds(session, monthStart);
      final updatedDailyCategorySeconds = <String, Map<String, int>>{};
      
      // 既存の日ごとのデータと新しいデータをマージ
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final dayKey = day.toString();
        final existingDaily = existing?.dailyCategorySeconds[dayKey] ?? <String, int>{};
        final sessionDaily = sessionDailyData[dayKey] ?? <String, int>{};
        
        // personOnlyとnothingDetectedを除外
        updatedDailyCategorySeconds[dayKey] = {
          'study': (existingDaily['study'] ?? 0) + (sessionDaily['study'] ?? 0),
          'pc': (existingDaily['pc'] ?? 0) + (sessionDaily['pc'] ?? 0),
          'smartphone': (existingDaily['smartphone'] ?? 0) + (sessionDaily['smartphone'] ?? 0),
        };
      }
      
      // 円グラフデータを計算（personOnly/nothingDetected除外）
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: false);
      
      final monthlyStats = MonthlyStatistics(
        id: id,
        year: year,
        month: month,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
        dailyCategorySeconds: updatedDailyCategorySeconds,
        lastModified: DateTime.now(),
      );
      
      await _monthlyManager.saveOrUpdateWithAuth(monthlyStats);
      
      LogMk.logDebug(
        '✅ 月次統計を更新しました: $id',
        tag: 'StatisticsAggregationService',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 月次統計の更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 年次データの集計・更新（personOnly/nothingDetected除外）
  Future<void> _updateYearlyStatistics(
    TrackingSession session,
    int workSeconds,
    YearlyStatistics? existing,
  ) async {
    try {
      final year = session.startTime.year;
      final id = year.toString();
      
      // personOnlyとnothingDetectedを除外したカテゴリ秒数
      final sessionCategorySeconds = <String, int>{
        'study': session.categorySeconds['study'] ?? 0,
        'pc': session.categorySeconds['pc'] ?? 0,
        'smartphone': session.categorySeconds['smartphone'] ?? 0,
      };
      
      // 既存データがあれば加算、なければ新規作成
      final updatedCategorySeconds = <String, int>{
        'study': (existing?.categorySeconds['study'] ?? 0) + sessionCategorySeconds['study']!,
        'pc': (existing?.categorySeconds['pc'] ?? 0) + sessionCategorySeconds['pc']!,
        'smartphone': (existing?.categorySeconds['smartphone'] ?? 0) + sessionCategorySeconds['smartphone']!,
      };
      final updatedWorkSeconds = (existing?.totalWorkTimeSeconds ?? 0) + workSeconds;
      
      // 月ごとのデータを集計
      final sessionMonthlyData = _aggregateMonthlyCategorySeconds(session);
      final updatedMonthlyCategorySeconds = <String, Map<String, int>>{};
      
      // 既存の月ごとのデータと新しいデータをマージ
      for (int month = 1; month <= 12; month++) {
        final monthKey = month.toString();
        final existingMonthly = existing?.monthlyCategorySeconds[monthKey] ?? <String, int>{};
        final sessionMonthly = sessionMonthlyData[monthKey] ?? <String, int>{};
        
        updatedMonthlyCategorySeconds[monthKey] = {
          'study': (existingMonthly['study'] ?? 0) + (sessionMonthly['study'] ?? 0),
          'pc': (existingMonthly['pc'] ?? 0) + (sessionMonthly['pc'] ?? 0),
          'smartphone': (existingMonthly['smartphone'] ?? 0) + (sessionMonthly['smartphone'] ?? 0),
        };
      }
      
      // 円グラフデータを計算（personOnly/nothingDetected除外）
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: false);
      
      final yearlyStats = YearlyStatistics(
        id: id,
        year: year,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
        monthlyCategorySeconds: updatedMonthlyCategorySeconds,
        lastModified: DateTime.now(),
      );
      
      await _yearlyManager.saveOrUpdateWithAuth(yearlyStats);
      
      LogMk.logDebug(
        '✅ 年次統計を更新しました: $id',
        tag: 'StatisticsAggregationService',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 年次統計の更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 目標達成状況の更新
  Future<void> _updateGoalProgress(TrackingSession session) async {
    try {
      // キャッシュから目標を取得（パフォーマンス最適化）
      List<Goal> goals;
      final now = DateTime.now();
      
      if (_cachedGoals != null && 
          _goalsCacheTime != null && 
          now.difference(_goalsCacheTime!) < _goalsCacheExpiry) {
        goals = _cachedGoals!;
        LogMk.logDebug(
          '📋 目標キャッシュを使用: ${goals.length}件',
          tag: 'StatisticsAggregationService',
        );
      } else {
        goals = await _goalManager.getActiveGoalsWithAuth();
        _cachedGoals = goals;
        _goalsCacheTime = now;
        LogMk.logDebug(
          '📋 目標を取得してキャッシュ: ${goals.length}件',
          tag: 'StatisticsAggregationService',
        );
      }
      
      // セッション期間内の目標のみをフィルタリング
      final relevantGoals = goals.where((goal) {
        final goalEndDate = goal.startDate.add(Duration(days: goal.durationDays));
        return !session.startTime.isBefore(goal.startDate) &&
               !session.startTime.isAfter(goalEndDate);
      }).toList();
      
      // バッチ更新用のリスト
      final goalsToUpdate = <Goal>[];
      
      for (final goal in relevantGoals) {
        
        // detectionItemに応じて時間を取得
        int categorySeconds = 0;
        String categoryKey = '';
        
        switch (goal.detectionItem) {
          case DetectionItem.book:
            categoryKey = 'study';
            categorySeconds = session.categorySeconds['study'] ?? 0;
            break;
          case DetectionItem.smartphone:
            categoryKey = 'smartphone';
            categorySeconds = session.categorySeconds['smartphone'] ?? 0;
            break;
          case DetectionItem.pc:
            categoryKey = 'pc';
            categorySeconds = session.categorySeconds['pc'] ?? 0;
            break;
        }
        
        if (categorySeconds > 0) {
          // achievedTimeは秒単位で保存・加算
          final currentAchievedTime = goal.achievedTime ?? 0;
          final updatedAchievedTime = currentAchievedTime + categorySeconds;
          
          // 目標を更新（copyWithで新しいGoalを作成）
          final updatedGoal = goal.copyWith(
            achievedTime: updatedAchievedTime,
            lastModified: DateTime.now(),
          );
          
          goalsToUpdate.add(updatedGoal);
          
          LogMk.logDebug(
            '📝 目標更新予約: ${goal.id} ($categoryKey: +$categorySeconds秒)',
            tag: 'StatisticsAggregationService',
          );
        }
      }
      
      // バッチ更新（パフォーマンス最適化）
      if (goalsToUpdate.isNotEmpty) {
        await Future.wait(
          goalsToUpdate.map((goal) => _goalManager.updateGoalWithAuth(goal)),
        );
        
        // キャッシュを更新
        for (final updatedGoal in goalsToUpdate) {
          final index = _cachedGoals!.indexWhere((g) => g.id == updatedGoal.id);
          if (index != -1) {
            _cachedGoals![index] = updatedGoal;
          }
        }
        
        LogMk.logDebug(
          '✅ 目標をバッチ更新しました: ${goalsToUpdate.length}件',
          tag: 'StatisticsAggregationService',
        );
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 目標更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Total Timeの更新
  Future<void> _updateTotalTime(int workSeconds, DateTime sessionStartTime) async {
    try {
      final workMinutes = workSeconds ~/ 60;
      
      // TotalDataを取得
      final totalData = await _totalManager.getTotalDataOrDefault();
      
      // 作業時間を加算
      final updatedTotalMinutes = totalData.totalWorkTimeMinutes + workMinutes;
      
      final updatedTotalData = totalData.copyWith(
        totalWorkTimeMinutes: updatedTotalMinutes,
        lastTrackedDate: sessionStartTime,
        lastModified: DateTime.now(),
      );
      
      // ローカルに保存
      await _totalManager.updateLocalTotalData(updatedTotalData);
      
      // Firestoreにも保存
      try {
        await _totalManager.manager.saveWithRetryAuth(updatedTotalData);
      } catch (e) {
        LogMk.logWarning(
          '⚠️ Total TimeのFirestore保存に失敗しました: $e',
          tag: 'StatisticsAggregationService',
        );
      }
      
      LogMk.logDebug(
        '✅ Total Timeを更新しました: +$workMinutes分',
        tag: 'StatisticsAggregationService',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ Total Timeの更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 円グラフデータを計算
  PieChartDataModel _calculatePieChartData(
    Map<String, int> categorySeconds, {
    required bool includeAllCategories,
  }) {
    // 合計時間を計算
    int totalSeconds = categorySeconds.values.fold(0, (sum, val) => sum + val);
    
    // 各カテゴリの割合を計算
    final percentages = <String, double>{};
    final colors = <String, int>{};
    
    for (final entry in categorySeconds.entries) {
      if (entry.value > 0) {
        if (totalSeconds > 0) {
          percentages[entry.key] = (entry.value / totalSeconds) * 100;
        } else {
          percentages[entry.key] = 0.0;
        }
        
        // カテゴリに応じた色を設定
        colors[entry.key] = _getCategoryColor(entry.key).value;
      }
    }
    
    return PieChartDataModel(
      categorySeconds: categorySeconds,
      percentages: percentages,
      colors: colors,
      totalSeconds: totalSeconds,
    );
  }

  /// カテゴリに応じた色を取得
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      case 'personOnly':
        return AppColors.purple;
      case 'nothingDetected':
        return AppColors.red;
      default:
        return AppColors.gray;
    }
  }

  /// 週の開始日（月曜日）を取得
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1=月曜日, 7=日曜日
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// 日付をID形式に変換（例: "2024-01-15"）
  String _formatDateId(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 年月をID形式に変換（例: "2024-01"）
  String _formatMonthId(int year, int month) {
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');
    return '$yearStr-$monthStr';
  }
}

