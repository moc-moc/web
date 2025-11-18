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
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: true);
      
      final dailyStats = DailyStatistics(
        id: id,
        date: date,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
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
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: true);
      
      final weeklyStats = WeeklyStatistics(
        id: id,
        weekStart: weekStart,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
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
      
      // 円グラフデータを計算（personOnly/nothingDetected除外）
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: false);
      
      final monthlyStats = MonthlyStatistics(
        id: id,
        year: year,
        month: month,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
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
      
      // 円グラフデータを計算（personOnly/nothingDetected除外）
      final pieChartData = _calculatePieChartData(updatedCategorySeconds, includeAllCategories: false);
      
      final yearlyStats = YearlyStatistics(
        id: id,
        year: year,
        categorySeconds: updatedCategorySeconds,
        totalWorkTimeSeconds: updatedWorkSeconds,
        pieChartData: pieChartData,
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
          final categoryMinutes = categorySeconds ~/ 60;
          final currentAchievedTime = goal.achievedTime ?? 0;
          final updatedAchievedTime = currentAchievedTime + categoryMinutes;
          
          // 目標を更新（copyWithで新しいGoalを作成）
          final updatedGoal = goal.copyWith(
            achievedTime: updatedAchievedTime,
            lastModified: DateTime.now(),
          );
          
          goalsToUpdate.add(updatedGoal);
          
          LogMk.logDebug(
            '📝 目標更新予約: ${goal.id} ($categoryKey: +$categoryMinutes分)',
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

