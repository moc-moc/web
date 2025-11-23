import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/total/total_hours_milestone_manager.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';

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
  static final TotalHoursMilestoneManager _milestoneManager = TotalHoursMilestoneManager();
  static final TrackingSettingsDataManager _trackingSettingsManager = TrackingSettingsDataManager();
  
  // 目標キャッシュ（セッション処理中は再利用）
  List<Goal>? _cachedGoals;
  DateTime? _goalsCacheTime;
  static const _goalsCacheExpiry = Duration(minutes: 5);

  // 同じセッションを短時間で重複処理しないためのガード
  static final Map<String, DateTime> _processedSessionHistory = {};
  static const _processedSessionRetention = Duration(hours: 2);

  /// セッション終了時の集計処理（最適化版）
  /// 
  /// トラッキングセッションのデータを各期間の統計に反映します。
  /// Phase 1: 日次統計のみ同期的に実行（画面表示に必須）
  /// Phase 2: 週次、月次、年次、目標、Total Timeを並列実行（バックグラウンド）
  /// 
  /// **パラメータ**:
  /// - `session`: トラッキングセッション
  /// 
  /// **戻り値**: Phase 1の処理成功時true、失敗時false（Phase 2はバックグラウンドで実行）
  Future<bool> aggregateSessionData(TrackingSession session) async {
    try {
      if (!_markSessionAsProcessing(session.id)) {
        LogMk.logWarning(
          '⚠️ セッションID ${session.id} は既に処理済みのためスキップします',
          tag: 'StatisticsAggregationService',
        );
        return false;
      }

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

      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      final year = session.startTime.year;
      final month = session.startTime.month;
      
      // ===== Phase 1: 日次統計のみ同期的に実行（画面表示に必須） =====
      LogMk.logDebug(
        '📊 Phase 1: 日次統計の更新を開始',
        tag: 'StatisticsAggregationService',
      );
      
      final existingDaily = await _dailyManager.getByDateWithAuth(date);
      final dailySuccess = await _updateDailyStatisticsPhase1(
        session, 
        categorySecondsWithNothing, 
        workSeconds, 
        existingDaily,
      );
      
      if (!dailySuccess) {
        LogMk.logError(
          '❌ Phase 1: 日次統計の更新に失敗しました',
          tag: 'StatisticsAggregationService',
        );
        return false;
      }
      
      LogMk.logDebug(
        '✅ Phase 1: 日次統計の更新が完了しました',
        tag: 'StatisticsAggregationService',
      );

      // ===== Phase 2: バックグラウンドで並列実行 =====
      // 画面表示をブロックしないため、非同期で実行
      _runPhase2InBackground(session, categorySecondsWithNothing, workSeconds, year, month);

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

  bool _markSessionAsProcessing(String sessionId) {
    final now = DateTime.now();
    _processedSessionHistory.removeWhere(
      (_, processedAt) => now.difference(processedAt) >= _processedSessionRetention,
    );

    final lastProcessed = _processedSessionHistory[sessionId];
    if (lastProcessed != null) {
      // retention期間内に同一セッションが再度来た場合は重複とみなす
      if (now.difference(lastProcessed) < _processedSessionRetention) {
        return false;
      }
    }

    _processedSessionHistory[sessionId] = now;
    return true;
  }

  /// Phase 2をバックグラウンドで実行（非同期、エラーをログに記録するのみ）
  void _runPhase2InBackground(
    TrackingSession session,
    Map<String, int> categorySecondsWithNothing,
    int workSeconds,
    int year,
    int month,
  ) {
    // 非同期で実行（awaitしない）
    Future(() async {
      try {
        LogMk.logDebug(
          '📊 Phase 2: バックグラウンド処理を開始',
          tag: 'StatisticsAggregationService',
        );

        // 並列で既存データを取得
        final existingData = await Future.wait([
          _weeklyManager.getByWeekWithAuth(session.startTime),
          _monthlyManager.getByMonthWithAuth(year, month),
          _yearlyManager.getByYearWithAuth(year),
        ]);
        
        final existingWeekly = existingData[0] as WeeklyStatistics?;
        final existingMonthly = existingData[1] as MonthlyStatistics?;
        final existingYearly = existingData[2] as YearlyStatistics?;

        // 週次、月次、年次、目標、Total Timeを並列実行
        await Future.wait([
          _updateWeeklyStatistics(session, categorySecondsWithNothing, workSeconds, existingWeekly)
              .catchError((e, stackTrace) {
            LogMk.logError(
              '❌ 週次統計の更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateMonthlyStatistics(session, workSeconds, existingMonthly)
              .catchError((e, stackTrace) {
            LogMk.logError(
              '❌ 月次統計の更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateYearlyStatistics(session, workSeconds, existingYearly)
              .catchError((e, stackTrace) {
            LogMk.logError(
              '❌ 年次統計の更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateGoalProgress(session)
              .catchError((e, stackTrace) {
            LogMk.logError(
              '❌ 目標更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateTotalTime(workSeconds, session.startTime)
              .catchError((e, stackTrace) {
            LogMk.logError(
              '❌ Total Time更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
        ]);

        // 更新後の総時間を確認
        final updatedTotalData = await _totalManager.getTotalDataOrDefault();
        LogMk.logDebug(
          '📊 Total Time更新後: ${updatedTotalData.totalWorkTimeMinutes}分（${updatedTotalData.totalWorkTimeMinutes ~/ 60}時間）',
          tag: 'StatisticsAggregationService',
        );

        LogMk.logDebug(
          '✅ Phase 2: バックグラウンド処理が完了しました',
          tag: 'StatisticsAggregationService',
        );
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ Phase 2: バックグラウンド処理中にエラーが発生しました: $e',
          tag: 'StatisticsAggregationService',
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Phase 1: 日次データの集計・更新（ローカル保存優先、Firestoreは非同期）
  /// 
  /// 既存のセッション情報を考慮して、新しいセッションを追加または更新します。
  /// saveOrUpdateWithAuth()を使用することで、updateFromSessions()が自動的に呼ばれ、
  /// すべてのセッションからcategorySeconds等が再計算されます。
  Future<bool> _updateDailyStatisticsPhase1(
    TrackingSession session,
    Map<String, int> categorySeconds,
    int workSeconds,
    DailyStatistics? existing,
  ) async {
    try {
      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      final id = _formatDateId(date);
      
      // TrackingSessionをSessionInfoに変換
      final sessionInfo = SessionInfo(
        id: session.id,
        startTime: session.startTime,
        endTime: session.endTime,
        categorySeconds: Map<String, int>.from(session.categorySeconds),
        detectionPeriods: List<DetectionPeriod>.from(session.detectionPeriods),
        lastModified: session.lastModified,
      );
      
      // 既存データがあればセッションをマージ、なければ新規作成
      List<SessionInfo> updatedSessions;
      if (existing != null) {
        // 既存のセッションリストを取得
        updatedSessions = List<SessionInfo>.from(existing.sessions);
        
        // 同じIDのセッションがあれば置き換え、なければ追加
        final existingIndex = updatedSessions.indexWhere((s) => s.id == sessionInfo.id);
        if (existingIndex >= 0) {
          updatedSessions[existingIndex] = sessionInfo;
          LogMk.logDebug(
            '📝 既存セッションを更新: ${sessionInfo.id}',
            tag: 'StatisticsAggregationService',
          );
        } else {
          updatedSessions.add(sessionInfo);
          LogMk.logDebug(
            '➕ 新規セッションを追加: ${sessionInfo.id}',
            tag: 'StatisticsAggregationService',
          );
        }
      } else {
        // 新規作成
        updatedSessions = [sessionInfo];
        LogMk.logDebug(
          '🆕 新規日次統計を作成: $id',
          tag: 'StatisticsAggregationService',
        );
      }
      
      // 日次統計データを作成（sessionsのみ設定、categorySeconds等はsaveOrUpdateWithAuth内で計算）
      final dailyStats = DailyStatistics(
        id: id,
        date: date,
        categorySeconds: existing?.categorySeconds ?? {},
        totalWorkTimeSeconds: existing?.totalWorkTimeSeconds ?? 0,
        pieChartData: existing?.pieChartData,
        hourlyCategorySeconds: existing?.hourlyCategorySeconds ?? {},
        sessions: updatedSessions,
        lastModified: DateTime.now(),
      );
      
      // 保存（saveOrUpdateWithAuth内でupdateFromSessionsが呼ばれ、すべてのセッションから再計算される）
      await _dailyManager.saveOrUpdateWithAuth(dailyStats);
      
      LogMk.logDebug(
        '✅ 日次統計を更新しました（ローカル保存完了）: $id',
        tag: 'StatisticsAggregationService',
      );
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 日次統計の更新に失敗しました: $e',
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
      
      // セッション開始時の選択目標IDを取得（セッションに記録されたIDを使用）
      // セッションに記録されていない場合は、現在のトラッキング設定から取得
      String? selectedStudyGoalId;
      String? selectedPcGoalId;
      String? selectedSmartphoneGoalId;
      
      if (session.selectedGoalIds.isNotEmpty) {
        // セッションに記録された選択目標IDを使用
        selectedStudyGoalId = session.selectedGoalIds['study'];
        selectedPcGoalId = session.selectedGoalIds['pc'];
        selectedSmartphoneGoalId = session.selectedGoalIds['smartphone'];
        
        LogMk.logDebug(
          '📋 セッションから選択目標IDを取得: study=$selectedStudyGoalId, pc=$selectedPcGoalId, smartphone=$selectedSmartphoneGoalId',
          tag: 'StatisticsAggregationService',
        );
      } else {
        // セッションに記録されていない場合は、現在のトラッキング設定から取得（後方互換性）
        TrackingSettings? trackingSettings;
        try {
          final settingsList = await _trackingSettingsManager.getAllWithAuth();
          trackingSettings = settingsList.isNotEmpty ? settingsList.first : null;
          if (trackingSettings == null) {
            // ローカルから取得を試みる
            final localSettings = await _trackingSettingsManager.getLocalById('tracking_settings');
            trackingSettings = localSettings;
          }
        } catch (e) {
          LogMk.logWarning(
            '⚠️ トラッキング設定の取得に失敗: $e',
            tag: 'StatisticsAggregationService',
          );
        }
        
        selectedStudyGoalId = trackingSettings?.selectedStudyGoalId;
        selectedPcGoalId = trackingSettings?.selectedPcGoalId;
        selectedSmartphoneGoalId = trackingSettings?.selectedSmartphoneGoalId;
      }
      
      // セッション期間内の目標のみをフィルタリング
      final relevantGoals = goals.where((goal) {
        final goalEndDate =
            goal.periodEndDate ?? goal.startDate.add(Duration(days: goal.durationDays));
        return !session.startTime.isBefore(goal.startDate) &&
               !session.startTime.isAfter(goalEndDate);
      }).toList();
      
      LogMk.logDebug(
        '📋 関連する目標: ${relevantGoals.length}件（全目標: ${goals.length}件）',
        tag: 'StatisticsAggregationService',
      );
      
      // バッチ更新用のリスト
      final goalsToUpdate = <Goal>[];
      
      for (final goal in relevantGoals) {
        // 選択された目標かどうかをチェック
        bool isSelected = false;
        int categorySeconds = 0;
        String categoryKey = '';
        
        switch (goal.detectionItem) {
          case DetectionItem.book:
            isSelected = goal.id == selectedStudyGoalId;
            categoryKey = 'study';
            categorySeconds = session.categorySeconds['study'] ?? 0;
            LogMk.logDebug(
              '🔍 目標チェック [study]: goal.id=${goal.id}, selectedStudyGoalId=$selectedStudyGoalId, isSelected=$isSelected, categorySeconds=$categorySeconds',
              tag: 'StatisticsAggregationService',
            );
            break;
          case DetectionItem.smartphone:
            isSelected = goal.id == selectedSmartphoneGoalId;
            categoryKey = 'smartphone';
            categorySeconds = session.categorySeconds['smartphone'] ?? 0;
            LogMk.logDebug(
              '🔍 目標チェック [smartphone]: goal.id=${goal.id}, selectedSmartphoneGoalId=$selectedSmartphoneGoalId, isSelected=$isSelected, categorySeconds=$categorySeconds',
              tag: 'StatisticsAggregationService',
            );
            break;
          case DetectionItem.pc:
            isSelected = goal.id == selectedPcGoalId;
            categoryKey = 'pc';
            categorySeconds = session.categorySeconds['pc'] ?? 0;
            LogMk.logDebug(
              '🔍 目標チェック [pc]: goal.id=${goal.id}, selectedPcGoalId=$selectedPcGoalId, isSelected=$isSelected, categorySeconds=$categorySeconds',
              tag: 'StatisticsAggregationService',
            );
            break;
        }
        
        // 選択された目標のみに時間を加算
        if (isSelected && categorySeconds > 0) {
          // achievedTime（累積）は秒単位で保存・加算
          final currentAchievedTime = goal.achievedTime ?? 0;
          final updatedAchievedTime = currentAchievedTime + categorySeconds;
          
          // todayAchievedTime（その日）も秒単位で保存・加算
          final currentTodayAchievedTime = goal.todayAchievedTime ?? 0;
          final updatedTodayAchievedTime = currentTodayAchievedTime + categorySeconds;
          
          // 目標を更新（copyWithで新しいGoalを作成）
          final updatedGoal = goal.copyWith(
            achievedTime: updatedAchievedTime,
            todayAchievedTime: updatedTodayAchievedTime,
            lastModified: DateTime.now(),
          );
          
          goalsToUpdate.add(updatedGoal);
          
          LogMk.logDebug(
            '📝 目標更新予約: ${goal.id} ($categoryKey: +$categorySeconds秒) [選択済み]',
            tag: 'StatisticsAggregationService',
          );
        } else if (!isSelected && categorySeconds > 0) {
          LogMk.logDebug(
            '⏭️ 目標スキップ: ${goal.id} ($categoryKey: +$categorySeconds秒) [未選択]',
            tag: 'StatisticsAggregationService',
          );
        }
      }
      
      // バッチ更新（パフォーマンス最適化）
      if (goalsToUpdate.isNotEmpty) {
        // Firestoreに更新（updateGoalWithRetryWithAuthを使用してリトライ機能付き）
        // 各目標の更新結果を個別に確認
        final updateResults = await Future.wait(
          goalsToUpdate.map((goal) async {
            try {
              final success = await _goalManager.updateGoalWithRetryWithAuth(goal);
              return {'goal': goal, 'success': success};
            } catch (e, stackTrace) {
              LogMk.logError(
                '❌ 目標更新エラー: ${goal.id} (${goal.title}): $e',
                tag: 'StatisticsAggregationService._updateGoalProgress',
                stackTrace: stackTrace,
              );
              return {'goal': goal, 'success': false};
            }
          }),
        );
        
        // 成功した目標と失敗した目標を分離
        final successfulGoals = <Goal>[];
        final failedGoals = <Goal>[];
        
        for (final result in updateResults) {
          final goal = result['goal'] as Goal;
          final success = result['success'] as bool;
          if (success) {
            successfulGoals.add(goal);
          } else {
            failedGoals.add(goal);
            LogMk.logWarning(
              '⚠️ 目標のFirestore更新に失敗（リトライキューに追加済み）: ${goal.id} (${goal.title})',
              tag: 'StatisticsAggregationService._updateGoalProgress',
            );
          }
        }
        
        // 成功した目標のみローカルデータを更新
        if (successfulGoals.isNotEmpty) {
          // 現在のローカル目標リストを取得
          final localGoals = await _goalManager.getLocalGoals();
          
          // 成功した目標でローカルデータを更新
          final updatedLocalGoals = localGoals.map((localGoal) {
            final updatedGoal = successfulGoals.firstWhere(
              (g) => g.id == localGoal.id,
              orElse: () => localGoal,
            );
            return updatedGoal.id == localGoal.id ? updatedGoal : localGoal;
          }).toList();
          
          // 新規追加された目標（ローカルに存在しない）を追加
          for (final updatedGoal in successfulGoals) {
            if (!updatedLocalGoals.any((g) => g.id == updatedGoal.id)) {
              updatedLocalGoals.add(updatedGoal);
            }
          }
          
          // ローカルに保存
          await _goalManager.saveLocalGoals(updatedLocalGoals);
          
          // キャッシュを更新（成功した目標のみ）
          if (_cachedGoals != null) {
            for (final updatedGoal in successfulGoals) {
              final index = _cachedGoals!.indexWhere((g) => g.id == updatedGoal.id);
              if (index != -1) {
                _cachedGoals![index] = updatedGoal;
              } else {
                _cachedGoals!.add(updatedGoal);
              }
            }
          }
          
          // Providerを更新（グローバルコンテナを使用）
          final container = AppInitUN.getGlobalContainer();
          if (container != null) {
            try {
              container.read(goalsListProvider.notifier).updateList(updatedLocalGoals);
              LogMk.logDebug(
                '✅ goalsListProviderを更新しました: ${updatedLocalGoals.length}件',
                tag: 'StatisticsAggregationService',
              );
            } catch (e) {
              LogMk.logWarning(
                '⚠️ goalsListProviderの更新に失敗: $e',
                tag: 'StatisticsAggregationService',
              );
            }
          }
          
          LogMk.logDebug(
            '✅ 目標をバッチ更新しました（成功: ${successfulGoals.length}件、失敗: ${failedGoals.length}件）',
            tag: 'StatisticsAggregationService',
          );
        } else {
          LogMk.logWarning(
            '⚠️ すべての目標のFirestore更新に失敗しました（リトライキューに追加済み）: ${goalsToUpdate.length}件',
            tag: 'StatisticsAggregationService',
          );
        }
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
      
      // ローカルに保存（即座に完了）
      await _totalManager.updateLocalTotalData(updatedTotalData);
      
      // Providerを更新（グローバルコンテナを使用）
      final container = AppInitUN.getGlobalContainer();
      if (container != null) {
        try {
          container.read(totalDataProvider.notifier).updateTotal(updatedTotalData);
          LogMk.logDebug(
            '✅ totalDataProviderを更新しました: ${updatedTotalData.totalWorkTimeMinutes}分',
            tag: 'StatisticsAggregationService',
          );
        } catch (e) {
          LogMk.logWarning(
            '⚠️ totalDataProviderの更新に失敗: $e',
            tag: 'StatisticsAggregationService',
          );
        }
      }
      
      // Firestore保存はバックグラウンドで非同期実行
      _totalManager.manager.saveWithRetryAuth(updatedTotalData).catchError((e) {
        LogMk.logWarning(
          '⚠️ Total TimeのFirestore保存に失敗しました: $e',
          tag: 'StatisticsAggregationService',
        );
        return false;
      });
      
      LogMk.logDebug(
        '✅ Total Timeを更新しました（ローカル + Provider）: +$workMinutes分',
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

  /// 総時間マイルストーンをチェック
  /// 
  /// 現在の総時間がマイルストーンを達成しているかチェックします。
  /// 
  /// **戻り値**: 達成したマイルストーン情報（達成していない場合はnull）
  /// - `achievedMilestone`: 達成したマイルストーン（時間単位）
  /// - `nextMilestone`: 次のマイルストーン（時間単位）
  /// - `totalHours`: 現在の総時間（時間単位）
  Future<Map<String, int>?> checkTotalHoursMilestone() async {
    try {
      final totalData = await _totalManager.getTotalDataOrDefault();
      final totalHours = totalData.totalWorkTimeMinutes ~/ 60;
      
      return await checkTotalHoursMilestoneWithCache(totalHours);
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 総時間マイルストーンチェックエラー: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// 総時間マイルストーンをチェック（キャッシュされた値を使用）
  /// 
  /// キャッシュされた総時間を使用してマイルストーンをチェックします。
  /// 
  /// **パラメータ**:
  /// - `totalHours`: キャッシュされた総時間（時間単位）
  /// 
  /// **戻り値**: 達成したマイルストーン情報（達成していない場合はnull）
  Future<Map<String, int>?> checkTotalHoursMilestoneWithCache(int totalHours) async {
    try {
      LogMk.logDebug(
        '🔍 総時間マイルストーンチェック開始: 総時間=${totalHours}時間',
        tag: 'StatisticsAggregationService',
      );
      
      // 達成したマイルストーンをチェック
      final achievedMilestone = await _milestoneManager.checkMilestone(totalHours);
      
      if (achievedMilestone == null) {
        LogMk.logDebug(
          'ℹ️ マイルストーン未達成: 総時間=${totalHours}時間',
          tag: 'StatisticsAggregationService',
        );
        return null;
      }
      
      // 次のマイルストーンを取得
      final nextMilestone = await _milestoneManager.getNextMilestone(totalHours);
      
      LogMk.logDebug(
        '🎉 マイルストーン達成: $achievedMilestone時間, 次のマイルストーン: ${nextMilestone ?? "なし"}',
        tag: 'StatisticsAggregationService',
      );
      
      return {
        'achievedMilestone': achievedMilestone,
        'nextMilestone': nextMilestone ?? 0,
        'totalHours': totalHours,
      };
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 総時間マイルストーンチェックエラー: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return null;
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

