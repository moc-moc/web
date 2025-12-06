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
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/data/services/goal_event_service.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:test_flutter/data/services/streak_milestone_service.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/total/total_model.dart';
import 'package:test_flutter/feature/total/total_hours_milestone_manager.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/date_utils.dart' as DateUtilsHelper;
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/leveling/level_data_manager.dart';
import 'package:test_flutter/feature/leveling/level_formula.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';

class AggregationPhaseResult {
  const AggregationPhaseResult({
    required this.phase1Success,
    required this.phase2Future,
  });

  final bool phase1Success;
  final Future<AggregationPhase2Result> phase2Future;
}

class AggregationPhase2Result {
  const AggregationPhase2Result({
    required this.goalSummary,
    required this.totalHours,
    required this.totalMilestone,
    required this.streakSummary,
    required this.levelSummary,
  });

  final GoalUpdateSummary? goalSummary;
  final int totalHours;
  final Map<String, int>? totalMilestone;
  final StreakUpdateSummary? streakSummary;
  final LevelUpdateSummary? levelSummary;
}

class GoalUpdateSummary {
  const GoalUpdateSummary({
    required this.localGoals,
    required this.achievementCandidates,
  });

  final List<Goal> localGoals;
  final List<GoalAchievementCandidate> achievementCandidates;
}

class GoalAchievementCandidate {
  const GoalAchievementCandidate({
    required this.goal,
    required this.achievedTimeSeconds,
  });

  final Goal goal;
  final int achievedTimeSeconds;
}

class StreakUpdateSummary {
  const StreakUpdateSummary({
    required this.newStreak,
    required this.currentStreak,
    required this.milestonePayload,
  });

  final int newStreak;
  final int currentStreak;
  final StreakMilestonePayload? milestonePayload;
}

class StreakMilestonePayload {
  const StreakMilestonePayload({
    required this.days,
    required this.nextMilestone,
  });

  final int days;
  final int? nextMilestone;
}

class LevelUpdateSummary {
  const LevelUpdateSummary({
    required this.state,
    required this.gainedPersonSeconds,
    required this.leveledUp,
  });

  final LevelingState state;
  final int gainedPersonSeconds;
  final bool leveledUp;
}

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
  static final TimeSettingsDataManager _timeSettingsManager = TimeSettingsDataManager();
  static final StreakDataManager _streakManager = StreakDataManager();
  static final LevelingDataManager _levelingManager = LevelingDataManager();
  
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
  /// - `trackingCount`: 現在のトラッキング回数（トラッキング終了時に取得した値）
  /// 
  /// **戻り値**: Phase1の成否と、Phase2完了時に詳細結果を返すFuture
  Future<AggregationPhaseResult> aggregateSessionData(
    TrackingSession session, {
    int? trackingCount,
  }) async {
    try {
      if (!_markSessionAsProcessing(session.id)) {
        LogMk.logWarning(
          '⚠️ セッションID ${session.id} は既に処理済みのためスキップします',
          tag: 'StatisticsAggregationService',
        );
        return AggregationPhaseResult(
          phase1Success: false,
          phase2Future: Future.value(
            const AggregationPhase2Result(
              goalSummary: null,
              totalHours: 0,
              totalMilestone: null,
              streakSummary: null,
              levelSummary: null,
            ),
          ),
        );
      }

      LogMk.logDebug(
        '📊 統計集計処理を開始: セッションID ${session.id}',
        tag: 'StatisticsAggregationService',
      );

      // 1. categorySecondsをそのまま使用（nothingDetectedはhourlyCategorySecondsから計算されるため、ここでは追加しない）
      final categorySecondsWithNothing = Map<String, int>.from(session.categorySeconds);

      // 2. 作業時間を計算（study + pc）
      final workSeconds = (session.categorySeconds['study'] ?? 0) +
                         (session.categorySeconds['pc'] ?? 0);

      // 3. reset timeを考慮した日付を取得
      final date = await _getDateWithResetTime(session.startTime);
      final year = date.year;
      final month = date.month;
      
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
        trackingCount: trackingCount,
      );
      
      if (!dailySuccess) {
        LogMk.logError(
          '❌ Phase 1: 日次統計の更新に失敗しました',
          tag: 'StatisticsAggregationService',
        );
        return AggregationPhaseResult(
          phase1Success: false,
          phase2Future: Future.value(
            const AggregationPhase2Result(
              goalSummary: null,
              totalHours: 0,
              totalMilestone: null,
              streakSummary: null,
              levelSummary: null,
            ),
          ),
        );
      }
      
      LogMk.logDebug(
        '✅ Phase 1: 日次統計の更新が完了しました',
        tag: 'StatisticsAggregationService',
      );

      // ===== Phase 2: バックグラウンドで並列実行 =====
      final phase2Future = _runPhase2InBackground(
        session,
        categorySecondsWithNothing,
        workSeconds,
        year,
        month,
      );

      return AggregationPhaseResult(
        phase1Success: true,
        phase2Future: phase2Future,
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 統計集計処理中にエラーが発生しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return AggregationPhaseResult(
        phase1Success: false,
        phase2Future: Future.value(
          const AggregationPhase2Result(
            goalSummary: null,
            totalHours: 0,
            totalMilestone: null,
            streakSummary: null,
            levelSummary: null,
          ),
        ),
      );
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

  /// Phase 2をバックグラウンドで実行し、完了時に結果を返す
  Future<AggregationPhase2Result> _runPhase2InBackground(
    TrackingSession session,
    Map<String, int> categorySecondsWithNothing,
    int workSeconds,
    int year,
    int month,
  ) {
    return Future(() async {
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

        GoalUpdateSummary? goalSummary;
        TotalData? updatedTotalData;
        StreakUpdateSummary? streakSummary;
        LevelUpdateSummary? levelSummary;

        // 週次、月次、年次、目標、Total Time、ストリークを並列実行
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
          _updateGoalProgress(session).then((value) {
            goalSummary = value;
          }).catchError((e, stackTrace) {
            LogMk.logError(
              '❌ 目標更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateTotalTime(workSeconds, session.startTime).then((value) {
            updatedTotalData = value;
          }).catchError((e, stackTrace) {
            LogMk.logError(
              '❌ Total Time更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateStreakData().then((value) {
            streakSummary = value;
          }).catchError((e, stackTrace) {
            LogMk.logError(
              '❌ ストリーク更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
          _updateLevelingProgress(session).then((value) {
            levelSummary = value;
          }).catchError((e, stackTrace) {
            LogMk.logError(
              '❌ レベル更新に失敗しました: $e',
              tag: 'StatisticsAggregationService',
              stackTrace: stackTrace,
            );
          }),
        ]);

        // 更新後の総時間を確認
        final totalDataSnapshot = updatedTotalData ?? await _totalManager.getTotalDataOrDefault();
        LogMk.logDebug(
          '📊 Total Time更新後: ${totalDataSnapshot.totalWorkTimeMinutes}分（${totalDataSnapshot.totalWorkTimeMinutes ~/ 60}時間）',
          tag: 'StatisticsAggregationService',
        );

        final totalHours = totalDataSnapshot.totalWorkTimeMinutes ~/ 60;
        final milestoneInfo = await checkTotalHoursMilestoneWithCache(totalHours);

        LogMk.logDebug(
          '✅ Phase 2: バックグラウンド処理が完了しました',
          tag: 'StatisticsAggregationService',
        );

        return AggregationPhase2Result(
          goalSummary: goalSummary,
          totalHours: totalHours,
          totalMilestone: milestoneInfo,
          streakSummary: streakSummary,
          levelSummary: levelSummary,
        );
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ Phase 2: バックグラウンド処理中にエラーが発生しました: $e',
          tag: 'StatisticsAggregationService',
          stackTrace: stackTrace,
        );
        return const AggregationPhase2Result(
          goalSummary: null,
          totalHours: 0,
          totalMilestone: null,
          streakSummary: null,
          levelSummary: null,
        );
      }
    });
  }

  Future<LevelUpdateSummary?> _updateLevelingProgress(
    TrackingSession session,
  ) async {
    final gainedSeconds = session.categorySeconds['personOnly'] ?? 0;
    if (gainedSeconds <= 0) {
      return null;
    }

    final referenceDate = session.startTime;
    final periodId = LevelFormula.periodId(referenceDate);
    LevelingState currentState;
    try {
      currentState =
          await _levelingManager.getOrCreateCurrentState(referenceDate);
    } catch (_) {
      currentState = LevelingState.initial(now: referenceDate);
    }

    final previousLevel = currentState.level;
    if (currentState.periodId != periodId) {
      currentState = LevelingState.initial(
        now: referenceDate,
        id: currentState.id,
      );
    }

    final updatedSeconds = currentState.personSeconds + gainedSeconds;
    final computation = LevelFormula.computeLevel(updatedSeconds);

    final updatedState = currentState.copyWith(
      periodId: periodId,
      level: computation.level,
      exactLevel: computation.exactLevel,
      progressToNextLevel: computation.progressToNextLevel,
      personSeconds: updatedSeconds,
      requiredSecondsForNextLevel: computation.requiredSecondsForNextLevel,
      rank: computation.rank,
      periodStart: LevelFormula.periodStart(referenceDate),
      periodEnd: LevelFormula.periodEnd(referenceDate),
      nextResetAt: LevelFormula.nextResetDate(referenceDate),
      lastUpdated: DateTime.now(),
    );

    await _levelingManager.saveCurrentLevel(updatedState);
    
    // Providerを更新してホーム画面のプログレスバーを即座に反映
    final container = AppInitUN.getGlobalContainer();
    if (container != null) {
      try {
        container.read(levelingStateProvider.notifier).updateState(updatedState);
        LogMk.logDebug(
          '✅ levelingStateProviderを更新しました: level=${updatedState.level}',
          tag: 'StatisticsAggregationService',
        );
      } catch (e) {
        LogMk.logWarning(
          '⚠️ levelingStateProviderの更新に失敗: $e',
          tag: 'StatisticsAggregationService',
        );
      }
    }
    
    LogMk.logDebug(
      '🎯 レベル更新: ${currentState.level} -> ${updatedState.level} (人検出 +${gainedSeconds}s)',
      tag: 'StatisticsAggregationService',
    );

    return LevelUpdateSummary(
      state: updatedState,
      gainedPersonSeconds: gainedSeconds,
      leveledUp: updatedState.level > previousLevel,
    );
  }

  /// Phase 1: 日次データの集計・更新（ローカル保存優先、Firestoreは非同期）
  /// 
  /// 既存のセッション情報を考慮して、新しいセッションを追加または更新します。
  /// 日次統計を更新（categorySeconds、hourlyCategorySeconds、trackingCountを保存）
  /// 
  /// セッションが複数日に跨る場合、それぞれの日のhourlyCategorySecondsに正しく保存されます。
  /// 
  /// saveOrUpdateWithAuth()を使用することで、updateFromCategorySeconds()が自動的に呼ばれ、
  /// categorySecondsからtotalWorkTimeSeconds等が再計算されます。
  Future<bool> _updateDailyStatisticsPhase1(
    TrackingSession session,
    Map<String, int> categorySeconds,
    int workSeconds,
    DailyStatistics? existing, {
    int? trackingCount,
  }) async {
    try {
      // reset timeを考慮した日付を取得（セッション開始時刻の日付）
      final startDate = await _getDateWithResetTime(session.startTime);
      final endDate = await _getDateWithResetTime(session.endTime);
      
      // セッションが跨ぐ日をすべて取得
      final datesToProcess = <DateTime>[];
      var currentDate = startDate;
      // 日付が同じか、endDateより前または同じ日までループ
      while (currentDate.year == endDate.year && 
             currentDate.month == endDate.month && 
             currentDate.day == endDate.day ||
             currentDate.isBefore(endDate)) {
        datesToProcess.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
        // 無限ループ防止（最大2日分まで）
        if (datesToProcess.length > 2) {
          break;
        }
      }
      
      LogMk.logDebug(
        '📅 セッションが跨ぐ日: ${datesToProcess.length}日（開始: ${_formatDateId(startDate)}, 終了: ${_formatDateId(endDate)}）',
        tag: 'StatisticsAggregationService',
      );
      
      // 各日に対して処理
      bool allSuccess = true;
      for (final date in datesToProcess) {
        final id = _formatDateId(date);
        
        // その日の既存データを取得
        final existingForDate = await _dailyManager.getByDateWithAuth(date);
        
        // trackingCountは開始日の日付の場合のみ使用
        final isStartDate = date.year == startDate.year && 
                           date.month == startDate.month && 
                           date.day == startDate.day;
        final finalTrackingCount = isStartDate
            ? (trackingCount ?? existingForDate?.trackingCount ?? 0)
            : (existingForDate?.trackingCount ?? 0);
        
        // 既存データがあればcategorySecondsをマージ、なければ新規作成
        Map<String, int> mergedCategorySeconds;
        Map<String, Map<String, int>> mergedHourlyCategorySeconds;
        int mergedTrackingCount;
        
        if (existingForDate != null) {
          // 既存データとマージ（categorySecondsを加算）
          // ただし、categorySecondsは開始日の日付の場合のみ加算
          mergedCategorySeconds = <String, int>{};
          if (isStartDate) {
            // 開始日の日付の場合のみ、セッションのcategorySecondsを加算
            for (final key in ['study', 'pc', 'smartphone', 'personOnly', 'nothingDetected']) {
              mergedCategorySeconds[key] = (existingForDate.categorySeconds[key] ?? 0) + 
                                          (categorySeconds[key] ?? 0);
            }
          } else {
            // 他の日の場合は既存の値を保持
            mergedCategorySeconds = Map<String, int>.from(existingForDate.categorySeconds);
          }
          
          // hourlyCategorySecondsを既存の値からコピー
          mergedHourlyCategorySeconds = Map<String, Map<String, int>>.from(existingForDate.hourlyCategorySeconds);
          
          // trackingCountは開始日の日付の場合のみ更新
          mergedTrackingCount = finalTrackingCount;
          
          LogMk.logDebug(
            '📝 既存日次統計を更新: $id',
            tag: 'StatisticsAggregationService',
          );
        } else {
          // 新規作成
          // categorySecondsは開始日の日付の場合のみ設定
          if (isStartDate) {
            mergedCategorySeconds = Map<String, int>.from(categorySeconds);
          } else {
            mergedCategorySeconds = <String, int>{
              'study': 0,
              'pc': 0,
              'smartphone': 0,
              'personOnly': 0,
              'nothingDetected': 0,
            };
          }
          mergedHourlyCategorySeconds = <String, Map<String, int>>{};
          mergedTrackingCount = finalTrackingCount;
          
          LogMk.logDebug(
            '🆕 新規日次統計を作成: $id',
            tag: 'StatisticsAggregationService',
          );
        }
        
        // セッションのdetectionPeriodsから時間ごとの検出時間を集計してhourlyCategorySecondsに追加
        // その日に該当する部分だけを集計（reset timeを考慮）
        final sessionHourlyData = await _aggregateHourlyCategorySecondsForDate(session, date);
        for (final entry in sessionHourlyData.entries) {
          final hourKey = entry.key;
          final hourData = entry.value;
          
          // 既存の時間帯データを取得（なければ空のMapを作成）
          final existingHourData = mergedHourlyCategorySeconds[hourKey] ?? <String, int>{};
          
          // 既存のデータと新しいデータをマージ（加算）
          final mergedHourData = <String, int>{};
          for (final key in ['study', 'pc', 'smartphone', 'personOnly', 'nothingDetected']) {
            mergedHourData[key] = (existingHourData[key] ?? 0) + (hourData[key] ?? 0);
          }
          
          mergedHourlyCategorySeconds[hourKey] = mergedHourData;
        }
        
        LogMk.logDebug(
          '📊 hourlyCategorySecondsを更新: $id, ${sessionHourlyData.length}時間帯',
          tag: 'StatisticsAggregationService',
        );
        
        // hourlyCategorySecondsからcategorySecondsを再計算（nothingDetectedを含む）
        final recalculatedCategorySeconds = <String, int>{
          'study': mergedCategorySeconds['study'] ?? 0,
          'pc': mergedCategorySeconds['pc'] ?? 0,
          'smartphone': mergedCategorySeconds['smartphone'] ?? 0,
          'personOnly': mergedCategorySeconds['personOnly'] ?? 0,
          'nothingDetected': 0,
        };
        
        // hourlyCategorySecondsからnothingDetectedを集計
        for (final hourData in mergedHourlyCategorySeconds.values) {
          recalculatedCategorySeconds['nothingDetected'] = 
              (recalculatedCategorySeconds['nothingDetected'] ?? 0) + 
              (hourData['nothingDetected'] ?? 0);
        }
        
        // 開始日の日付の場合のみ、セッションのcategorySecondsを加算（nothingDetectedは除く）
        if (isStartDate) {
          recalculatedCategorySeconds['study'] = 
              (recalculatedCategorySeconds['study'] ?? 0) + 
              (categorySeconds['study'] ?? 0);
          recalculatedCategorySeconds['pc'] = 
              (recalculatedCategorySeconds['pc'] ?? 0) + 
              (categorySeconds['pc'] ?? 0);
          recalculatedCategorySeconds['smartphone'] = 
              (recalculatedCategorySeconds['smartphone'] ?? 0) + 
              (categorySeconds['smartphone'] ?? 0);
          recalculatedCategorySeconds['personOnly'] = 
              (recalculatedCategorySeconds['personOnly'] ?? 0) + 
              (categorySeconds['personOnly'] ?? 0);
          // nothingDetectedはhourlyCategorySecondsから計算した値を使用（セッションのcategorySecondsには含まれていない）
        }
        
        // 日次統計データを作成（categorySecondsとtrackingCountを設定、totalWorkTimeSeconds等はsaveOrUpdateWithAuth内で計算）
        final dailyStats = DailyStatistics(
          id: id,
          date: date,
          categorySeconds: recalculatedCategorySeconds,
          totalWorkTimeSeconds: existingForDate?.totalWorkTimeSeconds ?? 0,
          pieChartData: existingForDate?.pieChartData,
          hourlyCategorySeconds: mergedHourlyCategorySeconds,
          trackingCount: mergedTrackingCount,
          lastModified: DateTime.now(),
        );
        
        // 保存（既にマージ済みなのでsaveDirectlyを使用）
        // saveOrUpdateWithAuthを使うと二重に加算されてしまうため、saveDirectlyを使用
        final success = await _dailyManager.saveDirectly(dailyStats);
        if (!success) {
          allSuccess = false;
          LogMk.logWarning(
            '⚠️ 日次統計の保存に失敗: $id',
            tag: 'StatisticsAggregationService',
          );
        } else {
          LogMk.logDebug(
            '✅ 日次統計を更新しました（ローカル保存完了）: $id',
            tag: 'StatisticsAggregationService',
          );
        }
      }
      
      return allSuccess;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 日次統計の更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// セッションから時間ごとのカテゴリ別秒数を集計（日次用・指定日のみ）
  /// 
  /// detectionPeriodsから時間ごと（0-23時）のカテゴリ別秒数を集計します。
  /// reset timeを考慮して、指定された日に該当する部分だけを処理します。
  /// 
  /// **パラメータ**:
  /// - `session`: トラッキングセッション
  /// - `date`: 集計対象の日付（reset time考慮済み）
  /// 
  /// **戻り値**: {"0": {study: 600, pc: 300, ...}, "1": {...}, ..., "23": {...}}
  Future<Map<String, Map<String, int>>> _aggregateHourlyCategorySecondsForDate(
    TrackingSession session,
    DateTime date,
  ) async {
    final hourlyData = <String, Map<String, int>>{};
    
    // 24時間分のデータを初期化
    for (int hour = 0; hour < 24; hour++) {
      hourlyData[hour.toString()] = <String, int>{
        'study': 0,
        'pc': 0,
        'smartphone': 0,
        'personOnly': 0,
        'nothingDetected': 0,
      };
    }
    
    // reset timeを取得して、その日の範囲を計算
    int resetHour = 0;
    try {
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser != null) {
        final userId = currentUser.uid;
        final timeSettings = await _timeSettingsManager.getById(userId, 'time_settings');
        if (timeSettings != null) {
          final resetTimeParts = timeSettings.dayBoundaryTime.split(':');
          resetHour = int.tryParse(resetTimeParts[0]) ?? 0;
        }
      }
    } catch (e) {
      // エラー時はデフォルト0時を使用
    }
    
    // その日の範囲を計算（reset time考慮）
    // 例：reset timeが22時の場合、「12月6日」は「12/5 22:00～12/6 22:00」の範囲
    final dateEnd = DateTime(date.year, date.month, date.day, resetHour);
    final dateStart = dateEnd.subtract(const Duration(days: 1));
    
    LogMk.logDebug(
      '📅 日付範囲: ${_formatDateId(date)}, reset=${resetHour}時, 範囲=${dateStart.toIso8601String()} ～ ${dateEnd.toIso8601String()}',
      tag: 'StatisticsAggregationService',
    );
    LogMk.logDebug(
      '📝 セッションのdetectionPeriods数: ${session.detectionPeriods.length}',
      tag: 'StatisticsAggregationService',
    );
    
    // その日に該当するdetectionPeriodsだけを処理
    int processedPeriods = 0;
    for (final period in session.detectionPeriods) {
      final periodStart = period.startTime;
      final periodEnd = period.endTime;
      final category = period.category;
      
      // 期間がその日の範囲外の場合はスキップ
      if (periodEnd.isBefore(dateStart) || 
          periodEnd.isAtSameMomentAs(dateStart) ||
          periodStart.isAfter(dateEnd) ||
          periodStart.isAtSameMomentAs(dateEnd)) {
        continue;
      }
      
      processedPeriods++;
      
      // 期間の開始時刻と終了時刻をその日の範囲内に制限
      final effectiveStart = periodStart.isBefore(dateStart) ? dateStart : periodStart;
      final effectiveEnd = periodEnd.isAfter(dateEnd) ? dateEnd : periodEnd;
      
      // 時間ごとに分割して集計
      var currentTime = effectiveStart;
      while (currentTime.isBefore(effectiveEnd)) {
        // 現在の時間帯の終了時刻を計算（次の時間の開始時刻、または期間の終了時刻のうち早い方）
        final currentHour = currentTime.hour;
        final nextHourStart = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          currentHour + 1,
        );
        final segmentEnd = effectiveEnd.isBefore(nextHourStart) ? effectiveEnd : nextHourStart;
        
        // この時間帯の秒数を計算
        final durationSeconds = segmentEnd.difference(currentTime).inSeconds;
        
        // 時間帯のキー（0-23の文字列）
        final hourKey = currentHour.toString();
        
        // 時間帯のデータに加算
        if (hourlyData.containsKey(hourKey) && hourlyData[hourKey]!.containsKey(category)) {
          hourlyData[hourKey]![category] = (hourlyData[hourKey]![category] ?? 0) + durationSeconds;
        }
        
        // 次の時間帯へ
        currentTime = segmentEnd;
      }
    }
    
    LogMk.logDebug(
      '📊 ${_formatDateId(date)} 時間ごとの集計完了: ${processedPeriods}個の期間を処理（reset time: ${resetHour}時）',
      tag: 'StatisticsAggregationService',
    );
    
    // デバッグ: 集計結果を確認
    int totalSeconds = 0;
    for (final entry in hourlyData.entries) {
      final hourTotal = entry.value.values.fold(0, (sum, val) => sum + val);
      if (hourTotal > 0) {
        totalSeconds += hourTotal;
        LogMk.logDebug(
          '  時間帯${entry.key}: 合計${hourTotal}秒 (${entry.value})',
          tag: 'StatisticsAggregationService',
        );
      }
    }
    LogMk.logDebug(
      '📊 集計合計: ${totalSeconds}秒',
      tag: 'StatisticsAggregationService',
    );
    
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
      final sessionPersonSeconds = session.categorySeconds['personOnly'] ?? 0;
      final updatedPersonSeconds =
          (existing?.personDetectedSeconds ?? 0) + sessionPersonSeconds;
      
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
        personDetectedSeconds: updatedPersonSeconds,
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
  Future<GoalUpdateSummary?> _updateGoalProgress(TrackingSession session) async {
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
      final Map<String, GoalAchievementCandidate> achievementCandidateMap = {};
      
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

          final targetSeconds = goal.targetTime;
          final hasJustAchieved = targetSeconds > 0 &&
              currentAchievedTime < targetSeconds &&
              updatedAchievedTime >= targetSeconds;
          if (hasJustAchieved) {
            achievementCandidateMap[updatedGoal.id] = GoalAchievementCandidate(
              goal: updatedGoal,
              achievedTimeSeconds: updatedAchievedTime,
            );
          }
          
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
          final newlyAchievedGoals = <GoalAchievementCandidate>[];
          for (final goal in successfulGoals) {
            final candidate = achievementCandidateMap[goal.id];
            if (candidate != null) {
              newlyAchievedGoals.add(candidate);
            }
          }

          final pendingGoalEvents = <GoalAchievementCandidate>[];
          for (final candidate in newlyAchievedGoals) {
            try {
              final alreadyShown = await GoalEventService.hasEventBeenShown(
                candidate.goal.id,
                candidate.achievedTimeSeconds,
              );
              if (!alreadyShown) {
                pendingGoalEvents.add(candidate);
              }
            } catch (e) {
              LogMk.logWarning(
                '⚠️ GoalEventService既読チェックに失敗: $e',
                tag: 'StatisticsAggregationService',
              );
              // 判定に失敗した場合はイベント表示対象として扱う
              pendingGoalEvents.add(candidate);
            }
          }

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

          return GoalUpdateSummary(
            localGoals: updatedLocalGoals,
            achievementCandidates: pendingGoalEvents,
          );
        } else {
          LogMk.logWarning(
            '⚠️ すべての目標のFirestore更新に失敗しました（リトライキューに追加済み）: ${goalsToUpdate.length}件',
            tag: 'StatisticsAggregationService',
          );
        }
      }

      return null;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 目標更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<StreakUpdateSummary?> _updateStreakData() async {
    try {
      LogMk.logDebug(
        '🔍 ストリーク更新開始',
        tag: 'StatisticsAggregationService',
      );

      final streakResult = await _streakManager.trackFinished();
      final newStreak = streakResult['streak'] as int? ?? 0;
      final streakData = await _streakManager.getStreakDataOrDefault();

      final container = AppInitUN.getGlobalContainer();
      if (container != null) {
        try {
          container.read(streakDataProvider.notifier).updateStreak(streakData);
          LogMk.logDebug(
            '✅ streakDataProviderを更新しました: streak=${streakData.currentStreak}',
            tag: 'StatisticsAggregationService',
          );
        } catch (e) {
          LogMk.logWarning(
            '⚠️ streakDataProviderの更新に失敗: $e',
            tag: 'StatisticsAggregationService',
          );
        }
      }

      StreakMilestonePayload? milestonePayload;
      if (newStreak > 0) {
        final achievedMilestone = await StreakMilestoneService.checkAchievedMilestone(newStreak);
        if (achievedMilestone != null) {
          final nextMilestone = await StreakMilestoneService.getNextMilestone();
          milestonePayload = StreakMilestonePayload(
            days: achievedMilestone,
            nextMilestone: nextMilestone,
          );
          LogMk.logDebug(
            '🎉 マイルストーン達成を検出: $achievedMilestone日（次: $nextMilestone日）',
            tag: 'StatisticsAggregationService',
          );
        }
      }

      return StreakUpdateSummary(
        newStreak: newStreak,
        currentStreak: streakData.currentStreak,
        milestonePayload: milestonePayload,
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ ストリーク更新に失敗しました: $e',
        tag: 'StatisticsAggregationService',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Total Timeの更新
  Future<TotalData> _updateTotalTime(int workSeconds, DateTime sessionStartTime) async {
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
      return updatedTotalData;
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
        '🔍 総時間マイルストーンチェック開始: 総時間=$totalHours時間',
        tag: 'StatisticsAggregationService',
      );
      
      // 達成したマイルストーンをチェック
      final achievedMilestone = await _milestoneManager.checkMilestone(totalHours);
      
      if (achievedMilestone == null) {
        LogMk.logDebug(
          'ℹ️ マイルストーン未達成: 総時間=$totalHours時間',
          tag: 'StatisticsAggregationService',
        );
        return null;
      }
      
      // マイルストーンの記録を先に実施しておく（イベント重複防止）
      try {
        await _milestoneManager.recordAchievedMilestone(achievedMilestone);
      } catch (e) {
        LogMk.logWarning(
          '⚠️ マイルストーン記録に失敗しました（後でイベント画面側で再試行されます）: $e',
          tag: 'StatisticsAggregationService',
        );
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

  /// reset timeを考慮した日付を取得
  /// 
  /// `session.startTime`からreset timeを考慮した日付を計算します。
  Future<DateTime> _getDateWithResetTime(DateTime sessionStartTime) async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser == null) {
        // ユーザーがログインしていない場合は、通常の日付を使用
        return DateTime(sessionStartTime.year, sessionStartTime.month, sessionStartTime.day);
      }
      
      final userId = currentUser.uid;
      final timeSettings = await _timeSettingsManager.getById(userId, 'time_settings');
      final dayBoundaryTime = timeSettings?.dayBoundaryTime ?? '24:00';
      
      // reset timeを考慮した日付を計算
      return DateUtilsHelper.DateUtils.getTodayDateFromBoundaryTime(dayBoundaryTime, now: sessionStartTime);
    } catch (e, stackTrace) {
      LogMk.logError(
        'reset timeを考慮した日付取得エラー: $e',
        tag: 'StatisticsAggregationService._getDateWithResetTime',
        error: e,
        stackTrace: stackTrace,
      );
      // エラー時は通常の日付を使用
      return DateTime(sessionStartTime.year, sessionStartTime.month, sessionStartTime.day);
    }
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

