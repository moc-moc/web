import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/statistics/statistics_aggregation_service.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/goal_event_service.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/tracking/tracking_limit_providers.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/data/repositories/survey_data_manager.dart';
import 'package:test_flutter/data/models/survey_model.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:uuid/uuid.dart';

/// トラッキング終了画面（新デザインシステム版）
class TrackingFinishedScreenNew extends ConsumerStatefulWidget {
  const TrackingFinishedScreenNew({super.key});

  @override
  ConsumerState<TrackingFinishedScreenNew> createState() => _TrackingFinishedScreenNewState();
}

class _TrackingFinishedScreenNewState extends ConsumerState<TrackingFinishedScreenNew> {
  TrackingSession? _trackingSession;
  bool _isLoading = true;
  final StatisticsAggregationService _aggregationService = StatisticsAggregationService();
  bool _isAggregating = false;
  Future<void>? _aggregationFuture;
  Future<void>? _phase2Future;
  bool _isPhase1Complete = false;
  bool _isPhase2Complete = false;
  DateTime? _phase1StartedAt;
  DateTime? _phase1FinishedAt;
  DateTime? _phase2StartedAt;
  DateTime? _phase2FinishedAt;
  
  // データキャッシュ（OKボタン押下時に再利用）
  List<Goal>? _cachedGoals;
  List<_PendingUiEvent> _pendingEvents = [];
  StreakUpdateSummary? _streakSummary;
  bool _isHandlingOkTap = false;
  bool _hasScheduledAggregation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator引数からTrackingSessionを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is TrackingSession) {
      final isDifferentSession = _trackingSession?.id != arguments.id;
      _trackingSession = arguments;
      if (isDifferentSession) {
        _hasScheduledAggregation = false;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (!_hasScheduledAggregation) {
          _hasScheduledAggregation = true;
          // 画面表示後に集計処理を開始（バックグラウンドで実行）
          _aggregationFuture = _aggregateSessionData(_trackingSession!);
        }
      }
    } else {
      // 引数がない場合はエラー表示
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// セッションデータの集計処理
  /// 
  /// 画面表示後にバックグラウンドで実行されます。
  Future<void> _aggregateSessionData(TrackingSession trackingSession) async {
    if (_isAggregating) return;
    
    setState(() {
      _isAggregating = true;
      _isPhase1Complete = false;
      _isPhase2Complete = false;
      _phase1StartedAt = DateTime.now();
      _phase1FinishedAt = null;
      _phase2StartedAt = null;
      _phase2FinishedAt = null;
      _pendingEvents = [];
    });

    try {
      // TrackingSessionを直接使用（統計集計サービス用）
      final trackingSession = _trackingSession;
      if (trackingSession == null) {
        LogMk.logError(
          '❌ TrackingSessionがnullです',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
        return;
      }
      
      LogMk.logDebug(
        '⏱️ Phase1計測開始: sessionId=${trackingSession.id}',
        tag: 'TrackingFinishedScreen._aggregateSessionData',
      );

      // トラッキング終了時に現在のtrackingCountを取得
      final currentTrackingCount = await DailyTrackingCountHelper.loadCount(ref);
      LogMk.logDebug(
        '📊 現在のtrackingCount: $currentTrackingCount',
        tag: 'TrackingFinishedScreen._aggregateSessionData',
      );

      // 統計集計処理を実行（Phase 1のみ同期的に実行、Phase 2はバックグラウンド）
      final aggregationResult = await _aggregationService.aggregateSessionData(
        trackingSession,
        trackingCount: currentTrackingCount,
      );
      triggerTrackingCompleted(ref);
      
      // レベルデータを再読み込みしてホーム画面のプログレスバーを更新
      try {
        await loadLevelingStateHelper(ref);
        debugPrint('✅ [TrackingFinishedScreen] レベルデータ再読み込み完了');
      } catch (e) {
        debugPrint('⚠️ [TrackingFinishedScreen] レベルデータ再読み込みエラー: $e');
        // エラーは無視して続行
      }

      _phase1FinishedAt = DateTime.now();
      final phase1Duration = _phase1FinishedAt!.difference(_phase1StartedAt!);
      LogMk.logDebug(
        '✅ Phase1完了: duration=${phase1Duration.inMilliseconds}ms',
        tag: 'TrackingFinishedScreen._aggregateSessionData',
      );

      if (!aggregationResult.phase1Success && mounted) {
        showSnackBarMessage(
          context,
          '統計データの更新中にエラーが発生しました',
          mounted: mounted,
        );
      }

      if (mounted) {
        setState(() {
          _isPhase1Complete = true;
        });
      } else {
        _isPhase1Complete = true;
      }

      _phase2StartedAt = DateTime.now();
      LogMk.logDebug(
        '🏃 Phase2起動: sessionId=${trackingSession.id}',
        tag: 'TrackingFinishedScreen._aggregateSessionData',
      );

      final phase2Future = aggregationResult.phase2Future
          .then((result) => _handlePhase2Result(result))
          .catchError((error, stackTrace) {
        LogMk.logError(
          '❌ Phase2処理中にエラー: $error',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
          stackTrace: stackTrace,
        );
        if (mounted) {
          setState(() {
            _isPhase2Complete = true;
            _phase2FinishedAt = DateTime.now();
          });
        } else {
          _isPhase2Complete = true;
          _phase2FinishedAt = DateTime.now();
        }
      });

      _phase2Future = phase2Future;
      _aggregationFuture = phase2Future;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 統計データ処理中に例外: $e',
        tag: 'TrackingFinishedScreen._aggregateSessionData',
        stackTrace: stackTrace,
      );
      if (mounted) {
        showSnackBarMessage(
          context,
          '統計データの更新中にエラーが発生しました',
          mounted: mounted,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAggregating = false;
        });
      } else {
        _isAggregating = false;
      }
    }
  }

  Future<void> _handlePhase2Result(AggregationPhase2Result result) async {
    final pendingEvents = await _buildPendingUiEvents(result);
    _phase2FinishedAt = DateTime.now();
    final elapsed = _phase2FinishedAt!.difference(_phase2StartedAt ?? _phase2FinishedAt!);
    LogMk.logDebug(
      '✅ Phase2完了: duration=${elapsed.inMilliseconds}ms, pendingEvents=${pendingEvents.length}',
      tag: 'TrackingFinishedScreen._handlePhase2Result',
    );

    void updateState() {
      _cachedGoals = result.goalSummary?.localGoals ?? _cachedGoals;
      _pendingEvents = pendingEvents;
      _streakSummary = result.streakSummary;
      _isPhase2Complete = true;
    }

    if (mounted) {
      setState(updateState);
    } else {
      updateState();
    }
  }

  Future<List<_PendingUiEvent>> _buildPendingUiEvents(AggregationPhase2Result result) async {
    final events = <_PendingUiEvent>[];

    final totalMilestone = result.totalMilestone;
    if (totalMilestone != null) {
      events.add(_PendingUiEvent.total(totalMilestone));
    }

    final streakPayload = result.streakSummary?.milestonePayload;
    if (streakPayload != null) {
      events.add(_PendingUiEvent.streak(streakPayload));
    }

    final goalSummary = result.goalSummary;
    if (goalSummary != null) {
      _cachedGoals ??= goalSummary.localGoals;
      for (final candidate in goalSummary.achievementCandidates) {
        events.add(
          _PendingUiEvent.goal(
            goal: candidate.goal,
            achievedTime: candidate.achievedTimeSeconds,
            consecutiveDays: result.streakSummary?.currentStreak,
          ),
        );
      }
    }

    final levelSummary = result.levelSummary;
    if (levelSummary != null && levelSummary.leveledUp) {
      events.add(_PendingUiEvent.level(levelSummary));
    }

    return events;
  }

  Future<void> _handleOkButtonPressed() async {
    if (_isHandlingOkTap) {
      LogMk.logDebug(
        '⚠️ OKボタン多重タップを無視',
        tag: 'TrackingFinishedScreen._handleOkButtonPressed',
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isHandlingOkTap = true;
      });
    } else {
      _isHandlingOkTap = true;
    }

    try {
      // 集計処理が完了するまで待機
      if (_aggregationFuture != null) {
        await _aggregationFuture;
      }

      final waitTarget = _phase2Future ?? _aggregationFuture;
      if (waitTarget != null) {
        await waitTarget;
      }

      await _processPendingEvents();

      // 初回3回終了時のアンケート表示
      await _showSurveyIfNeeded();

      // すべてのイベントが閉じられた後にホームへ遷移
      if (mounted) {
        await NavigationHelper.pushAndRemoveUntil(
          context,
          AppRoutes.home,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingOkTap = false;
        });
      } else {
        _isHandlingOkTap = false;
      }
    }
  }
  /// 目標達成イベントを表示
  /// 
  /// **戻り値**: イベントが表示された場合true、そうでない場合false
  Future<void> _processPendingEvents() async {
    final events = List<_PendingUiEvent>.from(_pendingEvents);
    for (final event in events) {
      switch (event.type) {
        case _PendingEventType.totalHours:
          if (event.totalMilestonePayload != null) {
            await _showTotalHoursEvent(event.totalMilestonePayload!);
          }
          break;
        case _PendingEventType.streakMilestone:
          if (event.streakPayload != null) {
            await _showStreakMilestoneEvent(event.streakPayload!);
          }
          break;
        case _PendingEventType.goalAchieved:
          if (event.goal != null && event.achievedTimeSeconds != null) {
            final shown = await _showGoalAchievedEvent(
              event.goal!,
              consecutiveDaysOverride: event.consecutiveDays,
            );
            if (shown) {
              await GoalEventService.markEventAsShown(
                event.goal!.id,
                event.achievedTimeSeconds!,
              );
            }
          }
          break;
        case _PendingEventType.levelUp:
          if (event.levelSummary != null) {
            await _showLevelUpEvent(event.levelSummary!);
          }
          break;
      }
    }

    if (mounted) {
      setState(() {
        _pendingEvents = [];
      });
    } else {
      _pendingEvents = [];
    }
  }

  Future<void> _showTotalHoursEvent(Map<String, int> milestoneInfo) async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(
      AppRoutes.totalHoursMilestoneEvent,
      arguments: {
        'hours': milestoneInfo['totalHours'],
        'nextMilestone': milestoneInfo['nextMilestone'],
        'achievedMilestone': milestoneInfo['achievedMilestone'],
      },
    );
  }

  Future<void> _showStreakMilestoneEvent(StreakMilestonePayload payload) async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(
      AppRoutes.streakMilestoneEvent,
      arguments: {
        'days': payload.days,
        'nextMilestone': payload.nextMilestone,
      },
    );
  }

  Future<bool> _showGoalAchievedEvent(
    Goal goal, {
    int? consecutiveDaysOverride,
  }) async {
    if (!mounted) return false;
    
    try {
      // 期間を取得
      final period = _getPeriodLabelFromDurationDays(goal.durationDays);
      
      final consecutiveDays =
          consecutiveDaysOverride ?? _streakSummary?.currentStreak ?? 0;
      
      // 目標時間と達成時間を時間単位に変換
      final targetHours = goal.targetTime / 3600.0;
      final achievedHours = (goal.achievedTime ?? 0) / 3600.0;
      
      // 進捗率を計算
      final progressPercent = targetHours > 0
          ? (achievedHours / targetHours * 100).clamp(0.0, 999.0)
          : 0.0;
      
      // イベント画面に遷移（画面が閉じられるまで待つ）
      await Navigator.of(context).pushNamed(
        AppRoutes.goalAchievedEvent,
        arguments: {
          'goalName': goal.title,
          'period': period,
          'targetHours': targetHours,
          'achievedHours': achievedHours,
          'progressPercent': progressPercent,
          'consecutiveDays': consecutiveDays,
        },
      );
      
      return true;
    } catch (e) {
      LogMk.logError(
        '❌ 目標達成イベント表示エラー: $e',
        tag: 'TrackingFinishedScreen._showGoalAchievedEvent',
      );
      return false;
    }
  }

  Future<void> _showLevelUpEvent(LevelUpdateSummary summary) async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(
      AppRoutes.levelUpEvent,
      arguments: {
        'level': summary.state.level,
        'rank': summary.state.rank.name,
        'exactLevel': summary.state.exactLevel,
        'personSeconds': summary.state.personSeconds,
        'progress': summary.state.progressToNextLevel,
      },
    );
  }

  /// 期間ラベルを取得
  String _getPeriodLabelFromDurationDays(int durationDays) {
    if (durationDays == 1) {
      return 'Daily';
    } else if (durationDays == 7) {
      return 'Weekly';
    } else if (durationDays == 30) {
      return 'Monthly';
    } else {
      return '$durationDays days';
    }
  }

  @override
  void dispose() {
    // Futureのキャンセル処理
    try {
      // 注意: DartのFutureは直接キャンセルできないため、
      // 実行中の処理が完了するまで待つか、フラグで制御する
      // ここでは、mountedフラグで制御されているため、追加の処理は不要
      LogMk.logDebug(
        '🧹 TrackingFinishedScreenのdispose()を実行',
        tag: 'TrackingFinishedScreen.dispose',
      );
    } catch (e) {
      LogMk.logError(
        '❌ dispose()処理中にエラー: $e',
        tag: 'TrackingFinishedScreen.dispose',
      );
    }

    // キャッシュのクリア
    _cachedGoals = null;
    _pendingEvents.clear();
    _streakSummary = null;
    _trackingSession = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final session = _trackingSession;
    if (session == null) {
      return AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: Center(
          child: Text(
            'セッションデータが見つかりません',
            style: AppTextStyles.body1,
          ),
        ),
      );
    }

    return AppScaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.sm,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCongratulations(),
              _buildTimeRange(session),
              _buildSummaryCards(session),
              _buildBreakdownCard(session),
              _buildGoalUpdates(session),
              SizedBox(height: AppSpacing.lg),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratulations() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withValues(alpha: 0.3),
            AppColors.purple.withValues(alpha: 0.3),
            AppColors.green.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Great Work!',
        style: AppTextStyles.h1.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          fontSize: 28,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRange(TrackingSession session) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.gray,
            size: 18,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            _formatTimeRange(session),
            style: AppTextStyles.body2.copyWith(
              color: AppColors.gray,
              fontFeatures: [const FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TrackingSession session) {
    final sessionDisplay = _formatTotalTimeDisplay(session.duration.inSeconds);
    final workSeconds =
        (session.categorySeconds['study'] ?? 0) + (session.categorySeconds['pc'] ?? 0);
    final workDisplay = _formatTotalTimeDisplay(workSeconds);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.blue,
                icon: Icons.timer_rounded,
                title: 'Session Total',
                value: sessionDisplay.text,
                valueFontSize: sessionDisplay.fontSize,
                subtitle: '',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.orange,
                icon: Icons.work_history_rounded,
                title: 'Work Total',
                value: workDisplay.text,
                valueFontSize: workDisplay.fontSize,
                subtitle: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required Color accentColor,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    double? valueFontSize,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 24),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Center(
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: accentColor,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800,
                    fontSize: valueFontSize != null ? valueFontSize * 0.85 : 32,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: [const FontFeature.tabularFigures()],
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _TimeDisplayValue _formatTotalTimeDisplay(int totalSeconds) {
    if (totalSeconds < 60) {
      final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
      final text = '$safeSeconds秒';
      return _TimeDisplayValue(text: text, fontSize: _fontSizeForText(text.length));
    }

    if (totalSeconds < 3600) {
      final minutes = totalSeconds / 60;
      final displayValue = minutes >= 10 ? minutes.floor().toString() : minutes.toStringAsFixed(1);
      final text = '$displayValue分';
      return _TimeDisplayValue(text: text, fontSize: _fontSizeForText(text.length));
    }

    final hours = totalSeconds / 3600;
    final displayValue = hours >= 10 ? hours.floor().toString() : hours.toStringAsFixed(1);
    final text = '$displayValue時間';
    return _TimeDisplayValue(text: text, fontSize: _fontSizeForText(text.length));
  }

  double _fontSizeForText(int length) {
    if (length <= 5) {
      return 48;
    } else if (length <= 7) {
      return 42;
    } else if (length <= 9) {
      return 36;
    } else {
      return 32;
    }
  }

  Widget _buildBreakdownCard(TrackingSession session) {
    final categories = [
      _CategoryStat(
        label: 'Study',
        icon: Icons.menu_book,
        color: AppColors.green,
        hours: session.getStudyHours(),
      ),
      _CategoryStat(
        label: 'Computer',
        icon: Icons.computer,
        color: AppColors.blue,
        hours: session.getPcHours(),
      ),
      _CategoryStat(
        label: 'Smartphone',
        icon: Icons.smartphone,
        color: AppColors.orange,
        hours: session.getSmartphoneHours(),
      ),
      _CategoryStat(
        label: 'People',
        icon: Icons.person,
        color: AppColors.gray,
        hours: session.getPersonOnlyHours(),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[0]),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCategoryCard(categories[1]),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[2]),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCategoryCard(categories[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryStat data) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: data.color.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 24,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            data.label,
            style: AppTextStyles.body2.copyWith(
              color: data.color.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatSecondsToHMS((data.hours * 3600).round()),
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: data.color,
              fontFeatures: [const FontFeature.tabularFigures()],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalUpdates(TrackingSession session) {
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
      todaysGoals.add(studyGoal);
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
      todaysGoals.add(pcGoal);
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
      todaysGoals.add(smartphoneGoal);
    }
    
    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    // 秒単位でカテゴリ別時間を取得
    final plusSecondsByCategory = <String, int>{
      'study': session.categorySeconds['study'] ?? 0,
      'pc': session.categorySeconds['pc'] ?? 0,
      'smartphone': session.categorySeconds['smartphone'] ?? 0,
      'person': session.categorySeconds['personOnly'] ?? 0,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Goal Progress',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...todaysGoals.asMap().entries.map((entry) {
            final goal = entry.value;
            final category = _getCategoryFromDetectionItem(goal.detectionItem);
            // 秒単位で計算
            final plusSeconds = plusSecondsByCategory[category] ?? 0;
            final afterSeconds = goal.achievedTime ?? 0;
            final previousSeconds =
                afterSeconds >= plusSeconds ? afterSeconds - plusSeconds : 0;
            final targetSeconds = goal.targetTime;
            // パーセンテージ計算（秒単位で計算）
            final previousPercent = targetSeconds > 0
                ? (previousSeconds / targetSeconds * 100).clamp(0.0, 999.0)
                : 0.0;
            final plusPercent = targetSeconds > 0
                ? (plusSeconds / targetSeconds * 100).clamp(0.0, 999.0)
                : 0.0;
            final afterPercent = targetSeconds > 0
                ? (afterSeconds / targetSeconds * 100).clamp(0.0, 999.0)
                : 0.0;

            final isLast = entry.key == todaysGoals.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              child: _buildGoalUpdateRow(
                goal: goal,
                category: category,
                previousSeconds: previousSeconds,
                previousPercent: previousPercent,
                plusSeconds: plusSeconds,
                plusPercent: plusPercent,
                targetSeconds: targetSeconds,
                afterSeconds: afterSeconds,
                afterPercent: afterPercent,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalUpdateRow({
    required Goal goal,
    required String category,
    required int previousSeconds,
    required double previousPercent,
    required int plusSeconds,
    required double plusPercent,
    required int targetSeconds,
    required int afterSeconds,
    required double afterPercent,
  }) {
    final color = _getGoalColor(category);
    final progress = targetSeconds > 0
        ? (afterSeconds / targetSeconds).clamp(0.0, 1.0)
        : 0.0;
    
    // 表示用に時間単位に変換
    final targetHours = targetSeconds / 3600.0;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 1.0),
                  fontSize: 14,
                ),
              ),
              Text(
                '目標: ${targetHours.toStringAsFixed(1)}h',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          LinearProgressBar(
            percentage: progress,
            height: 12,
            progressColor: color,
            backgroundColor: AppColors.blackgray,
            barBackgroundColor: AppColors.gray.withValues(alpha: 0.4),
            showFlowAnimation: false,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '$previousSeconds秒 → $afterSeconds秒',
                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+$plusSeconds秒',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${previousPercent.toStringAsFixed(1)}% → ${afterPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+${plusPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context) {
    final borderRadiusValue = BorderRadius.circular(30.0);
    final bool isPrimaryEnabled = _isPhase1Complete && !_isHandlingOkTap;
    final bool isBackgroundRunning = !_isPhase2Complete;
    final String statusText = _isPhase1Complete
        ? (isBackgroundRunning ? 'イベント準備中... 数秒お待ちください' : 'OKでホームへ戻れます')
        : '統計データを保存しています...';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // シェアボタン（中央配置、横幅を半分に）
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.gray.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Material(
              color: AppColors.blackgray,
              borderRadius: borderRadiusValue,
              elevation: 2,
              shadowColor: AppColors.black.withValues(alpha: 0.2),
              child: InkWell(
                onTap: () {
                  // 将来実装
                },
                borderRadius: borderRadiusValue,
                child: Container(
                      height: 48.0,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: AppColors.gray,
                              size: 16.0,
                        ),
                            SizedBox(width: AppSpacing.xs),
                        Text(
                              'Share',
                          style: TextStyle(
                            color: AppColors.gray,
                                fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (isBackgroundRunning || !_isPhase1Complete) ...[
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.blue),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            ),
          ],
          Opacity(
            opacity: isPrimaryEnabled ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadiusValue,
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.blue.withValues(alpha: 0.5),
                borderRadius: borderRadiusValue,
                elevation: 4,
                shadowColor: AppColors.blue.withValues(alpha: 0.3),
                child: InkWell(
                  onTap: isPrimaryEnabled ? _handleOkButtonPressed : null,
                  borderRadius: borderRadiusValue,
                  child: Container(
                    height: 48.0,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 18.0,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            _isHandlingOkTap ? 'Working...' : 'OK',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 初回3回終了時のアンケートを表示（必要に応じて）
  Future<void> _showSurveyIfNeeded() async {
    try {
      LogMk.logDebug('アンケート表示チェック開始', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');
      
      // 3回目のトラッキング終了かどうかを確認
      final isThird = await DailyTrackingCountHelper.isThirdTrackingCompletion(ref);
      LogMk.logDebug('3回目のトラッキング: $isThird', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');
      
      if (!isThird) {
        return;
      }

      // 既にアンケートを表示済みかどうかを確認
      final hasShown = await DailyTrackingCountHelper.hasShownFirstSurvey();
      LogMk.logDebug('アンケート表示済み: $hasShown', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');
      
      if (hasShown) {
        return;
      }
      
      LogMk.logDebug('アンケートを表示します', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');

      // アンケートを表示
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => SurveyDialog(
          onSubmit: (rating, feedback) async {
            // アンケート結果をFirestoreに保存
            try {
              final currentUser = AuthMk.getCurrentUser();
              if (currentUser != null) {
                final survey = Survey(
                  id: const Uuid().v4(),
                  rating: rating,
                  feedback: feedback,
                  createdAt: DateTime.now(),
                );
                // saveWithRetryAuthを使用してFirestoreとローカルの両方に保存
                final success = await surveyDataManager.saveWithRetryAuth(survey);
                if (success) {
                  LogMk.logDebug('アンケート結果をFirestoreに保存しました', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');
                } else {
                  LogMk.logWarning('アンケート結果の保存に失敗しました（リトライキューに追加済み）', tag: 'TrackingFinishedScreen._showSurveyIfNeeded');
                }
              }
            } catch (e) {
              LogMk.logError(
                'アンケート結果の保存エラー: $e',
                tag: 'TrackingFinishedScreen._showSurveyIfNeeded',
              );
            }

            // 表示済みフラグを設定
            await DailyTrackingCountHelper.markFirstSurveyAsShown();
          },
        ),
      );
    } catch (e) {
      LogMk.logError(
        'アンケート表示処理エラー: $e',
        tag: 'TrackingFinishedScreen._showSurveyIfNeeded',
      );
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

  String _formatTimeRange(TrackingSession session) {
    final start = _formatTime(session.startTime);
    final end = _formatTime(session.endTime);
    return '$start - $end';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 秒数を時間・分・秒の形式に変換（例: "1時間23分45秒"）
  String _formatSecondsToHMS(int totalSeconds) {
    if (totalSeconds < 0) {
      return '0秒';
    }
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    final parts = <String>[];
    
    if (hours > 0) {
      parts.add('$hours時間');
    }
    if (minutes > 0) {
      parts.add('$minutes分');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds秒');
    }
    
    return parts.join('');
  }
}

enum _PendingEventType { totalHours, streakMilestone, goalAchieved, levelUp }

class _PendingUiEvent {
  const _PendingUiEvent._({
    required this.type,
    this.totalMilestonePayload,
    this.streakPayload,
    this.goal,
    this.achievedTimeSeconds,
    this.consecutiveDays,
    this.levelSummary,
  });

  factory _PendingUiEvent.total(Map<String, int> payload) {
    return _PendingUiEvent._(
      type: _PendingEventType.totalHours,
      totalMilestonePayload: payload,
    );
  }

  factory _PendingUiEvent.streak(StreakMilestonePayload payload) {
    return _PendingUiEvent._(
      type: _PendingEventType.streakMilestone,
      streakPayload: payload,
    );
  }

  factory _PendingUiEvent.goal({
    required Goal goal,
    required int achievedTime,
    int? consecutiveDays,
  }) {
    return _PendingUiEvent._(
      type: _PendingEventType.goalAchieved,
      goal: goal,
      achievedTimeSeconds: achievedTime,
      consecutiveDays: consecutiveDays,
    );
  }

  factory _PendingUiEvent.level(LevelUpdateSummary summary) {
    return _PendingUiEvent._(
      type: _PendingEventType.levelUp,
      levelSummary: summary,
    );
  }

  final _PendingEventType type;
  final Map<String, int>? totalMilestonePayload;
  final StreakMilestonePayload? streakPayload;
  final Goal? goal;
  final int? achievedTimeSeconds;
  final int? consecutiveDays;
  final LevelUpdateSummary? levelSummary;
}

class _CategoryStat {
  const _CategoryStat({
    required this.label,
    required this.icon,
    required this.color,
    required this.hours,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double hours;
}

class _TimeDisplayValue {
  const _TimeDisplayValue({
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;
}
