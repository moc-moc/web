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
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/statistics/statistics_aggregation_service.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/goal_event_service.dart';
import 'package:test_flutter/data/services/streak_milestone_service.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';

/// トラッキング終了画面（新デザインシステム版）
class TrackingFinishedScreenNew extends ConsumerStatefulWidget {
  const TrackingFinishedScreenNew({super.key});

  @override
  ConsumerState<TrackingFinishedScreenNew> createState() => _TrackingFinishedScreenNewState();
}

class _TrackingFinishedScreenNewState extends ConsumerState<TrackingFinishedScreenNew> {
  SessionInfo? _sessionInfo;
  bool _isLoading = true;
  final StatisticsAggregationService _aggregationService = StatisticsAggregationService();
  final StreakDataManager _streakManager = StreakDataManager();
  final TotalDataManager _totalManager = TotalDataManager();
  bool _isAggregating = false;
  Future<void>? _aggregationFuture;
  
  // データキャッシュ（OKボタン押下時に再利用）
  List<Goal>? _cachedGoals;
  int? _cachedTotalHours;
  Map<String, int?>? _pendingStreakMilestoneEvent;
  bool _isHandlingOkTap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator引数からSessionInfoを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is SessionInfo) {
      _sessionInfo = arguments;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // 画面表示後に集計処理を開始（バックグラウンドで実行）
        _aggregationFuture = _aggregateSessionData(_sessionInfo!);
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
  Future<void> _aggregateSessionData(SessionInfo sessionInfo) async {
    if (_isAggregating) return;
    
    setState(() {
      _isAggregating = true;
    });

    try {
      // SessionInfoをTrackingSessionに変換（統計集計サービス用）
      final trackingSession = TrackingSession(
        id: sessionInfo.id,
        startTime: sessionInfo.startTime,
        endTime: sessionInfo.endTime,
        categorySeconds: Map<String, int>.from(sessionInfo.categorySeconds),
        detectionPeriods: List<DetectionPeriod>.from(sessionInfo.detectionPeriods),
        selectedGoalIds: Map<String, String?>.from(sessionInfo.selectedGoalIds),
        lastModified: sessionInfo.lastModified,
      );
      
      // 統計集計処理を実行（Phase 1のみ同期的に実行、Phase 2はバックグラウンド）
      final success =
          await _aggregationService.aggregateSessionData(trackingSession);
      triggerTrackingCompleted(ref);
      
      // 目標リストをキャッシュ（ローカルから取得、Firestoreからは取得しない）
      try {
        final manager = GoalDataManager();
        final localGoals = await manager.getLocalGoals();
        _cachedGoals = localGoals;
        // Providerも更新（統計集計サービスで既に更新されている可能性があるが、念のため）
        ref.read(goalsListProvider.notifier).updateList(localGoals);
        LogMk.logDebug(
          '📋 目標リストをキャッシュ（ローカルから取得）: ${_cachedGoals?.length ?? 0}件',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      } catch (e) {
        LogMk.logError(
          '❌ 目標リストのキャッシュに失敗しました: $e',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      }
      
      // Total Timeをキャッシュ
      try {
        final totalData = await _totalManager.getTotalDataOrDefault();
        _cachedTotalHours = totalData.totalWorkTimeMinutes ~/ 60;
        LogMk.logDebug(
          '📊 Total Timeをキャッシュ: ${_cachedTotalHours}時間',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      } catch (e) {
        LogMk.logError(
          '❌ Total Timeのキャッシュに失敗しました: $e',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      }
      
      // ストリーク更新を実行
      try {
        LogMk.logDebug(
          '🔍 ストリーク更新開始',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
        
        final streakResult = await _streakManager.trackFinished();
        final newStreak = streakResult['streak'] as int? ?? 0;
        
        // ストリークデータを取得してProviderを更新
        try {
          final streakData = await _streakManager.getStreakDataOrDefault();
          final container = AppInitUN.getGlobalContainer();
          if (container != null) {
            container.read(streakDataProvider.notifier).updateStreak(streakData);
            LogMk.logDebug(
              '✅ streakDataProviderを更新しました: streak=${streakData.currentStreak}',
              tag: 'TrackingFinishedScreen._aggregateSessionData',
            );
          }
        } catch (e) {
          LogMk.logWarning(
            '⚠️ streakDataProviderの更新に失敗: $e',
            tag: 'TrackingFinishedScreen._aggregateSessionData',
          );
        }
        
        LogMk.logDebug(
          '📊 ストリーク更新結果: streak=$newStreak, success=${streakResult['success']}, message=${streakResult['message']}',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
        
        // マイルストーンチェック
        if (newStreak > 0 && mounted) {
          LogMk.logDebug(
            '🔍 マイルストーンチェック開始: currentStreak=$newStreak',
            tag: 'TrackingFinishedScreen._aggregateSessionData',
          );
          
          final achievedMilestone = await StreakMilestoneService.checkAchievedMilestone(newStreak);
          
          LogMk.logDebug(
            '📊 マイルストーンチェック結果: achievedMilestone=$achievedMilestone',
            tag: 'TrackingFinishedScreen._aggregateSessionData',
          );
          
          if (achievedMilestone != null) {
            final nextMilestone = await StreakMilestoneService.getNextMilestone();
            LogMk.logDebug(
              '🎉 マイルストーン達成を検出: $achievedMilestone日（次のマイルストーン: $nextMilestone日）',
              tag: 'TrackingFinishedScreen._aggregateSessionData',
            );

            void updatePendingEvent() {
              _pendingStreakMilestoneEvent = {
                'days': achievedMilestone,
                'nextMilestone': nextMilestone,
              };
            }

            if (mounted) {
              setState(updatePendingEvent);
            } else {
              updatePendingEvent();
            }

            LogMk.logDebug(
              '🕒 ストリークイベント表示をOKボタン押下後まで待機',
              tag: 'TrackingFinishedScreen._aggregateSessionData',
            );
          } else {
            LogMk.logDebug(
              'ℹ️ マイルストーン未達成（現在のストリーク: $newStreak日）',
              tag: 'TrackingFinishedScreen._aggregateSessionData',
            );
          }
        } else {
          LogMk.logDebug(
            '⚠️ ストリークが0以下またはウィジェットがマウントされていないため、マイルストーンチェックをスキップ: newStreak=$newStreak, mounted=$mounted',
            tag: 'TrackingFinishedScreen._aggregateSessionData',
          );
        }
      } catch (e) {
        LogMk.logError(
          '❌ ストリーク更新エラー: $e',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      }
      
      
      if (!success && mounted) {
        // エラー時はユーザーに通知
        showSnackBarMessage(
          context,
          '統計データの更新中にエラーが発生しました',
          mounted: mounted,
        );
      }
    } catch (e) {
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
      }
    }
  }

  /// 総時間マイルストーンをチェックし、必要に応じてイベントを表示
  /// 
  /// OKボタンを押した後に呼び出されます。
  /// キャッシュされたTotal Timeを使用します。
  /// 
  /// **戻り値**: イベントが表示された場合true、そうでない場合false
  Future<bool> _checkAndShowTotalHoursMilestone() async {
    try {
      if (!mounted) return false;
      
      LogMk.logDebug(
        '🔍 総時間マイルストーンチェック開始（キャッシュ使用）',
        tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
      );
      
      // キャッシュされたTotal Timeを使用（なければ再取得）
      int totalHours;
      if (_cachedTotalHours != null) {
        totalHours = _cachedTotalHours!;
        LogMk.logDebug(
          '📊 キャッシュからTotal Timeを取得: ${totalHours}時間',
          tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
        );
      } else {
        // キャッシュがない場合は再取得
        final totalData = await _totalManager.getTotalDataOrDefault();
        totalHours = totalData.totalWorkTimeMinutes ~/ 60;
        _cachedTotalHours = totalHours;
        LogMk.logDebug(
          '📊 Total Timeを再取得してキャッシュ: ${totalHours}時間',
          tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
        );
      }
      
      // マイルストーンチェック（キャッシュされた値を使用）
      final milestoneInfo = await _aggregationService.checkTotalHoursMilestoneWithCache(totalHours);
      
      if (milestoneInfo != null) {
        LogMk.logDebug(
          '🎉 マイルストーン達成を検出: ${milestoneInfo['achievedMilestone']}時間',
          tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
        );
        
        // イベント画面に遷移（画面が閉じられるまで待つ）
        if (mounted) {
          await Navigator.of(context).pushNamed(
            AppRoutes.totalHoursMilestoneEvent,
            arguments: {
              'hours': milestoneInfo['totalHours'],
              'nextMilestone': milestoneInfo['nextMilestone'],
              'achievedMilestone': milestoneInfo['achievedMilestone'],
            },
          );
          return true;
        }
      } else {
        LogMk.logDebug(
          'ℹ️ マイルストーン未達成',
          tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
        );
      }
      
      return false;
    } catch (e) {
      LogMk.logError(
        '❌ 総時間マイルストーンチェックエラー: $e',
        tag: 'TrackingFinishedScreen._checkAndShowTotalHoursMilestone',
      );
      return false;
    }
  }

  /// ストリークマイルストーンイベントを表示（必要な場合のみ）
  Future<bool> _showPendingStreakMilestoneEvent() async {
    if (!mounted) return false;
    final eventData = _pendingStreakMilestoneEvent;
    if (eventData == null) {
      LogMk.logDebug(
        'ℹ️ 表示待ちのストリークイベントなし',
        tag: 'TrackingFinishedScreen._showPendingStreakMilestoneEvent',
      );
      return false;
    }

    _pendingStreakMilestoneEvent = null;

    try {
      await Navigator.of(context).pushNamed(
        AppRoutes.streakMilestoneEvent,
        arguments: {
          'days': eventData['days'],
          'nextMilestone': eventData['nextMilestone'],
        },
      );
      LogMk.logDebug(
        '✅ ストリークイベントを表示完了',
        tag: 'TrackingFinishedScreen._showPendingStreakMilestoneEvent',
      );
      return true;
    } catch (e) {
      LogMk.logError(
        '❌ ストリークイベント表示エラー: $e',
        tag: 'TrackingFinishedScreen._showPendingStreakMilestoneEvent',
      );
      return false;
    }
  }

  /// 目標達成をチェックし、必要に応じてイベントを表示
  /// 
  /// **重要**: このメソッドはOKボタンが押された後にのみ呼び出されます。
  /// `tracking_finished.dart`が表示されたタイミングでは呼び出されません。
  /// キャッシュされた目標リストを使用します。
  /// 
  /// **戻り値**: イベントが表示された場合true、そうでない場合false
  Future<bool> _checkAndShowGoalAchievedEvents() async {
    try {
      // キャッシュされた目標リストを使用（なければ再取得）
      List<Goal> goals;
      if (_cachedGoals != null && _cachedGoals!.isNotEmpty) {
        goals = _cachedGoals!;
        LogMk.logDebug(
          '📋 キャッシュから目標リストを取得: ${goals.length}件',
          tag: 'TrackingFinishedScreen._checkAndShowGoalAchievedEvents',
        );
      } else {
        // キャッシュがない場合は再取得
        await syncGoalsHelper(ref);
        goals = ref.read(goalsListProvider);
        _cachedGoals = goals;
        LogMk.logDebug(
          '📋 目標リストを再取得してキャッシュ: ${goals.length}件',
          tag: 'TrackingFinishedScreen._checkAndShowGoalAchievedEvents',
        );
      }
      
      // 達成した目標をチェック
      bool hasShownEvent = false;
      for (final goal in goals) {
        // 目標時間より達成時間が多くなったかチェック
        final achievedTime = goal.achievedTime ?? 0;
        final targetTime = goal.targetTime;
        
        if (achievedTime >= targetTime && targetTime > 0) {
          // イベントが既に表示されていないかチェック（達成時間も含めてチェック）
          final hasBeenShown = await GoalEventService.hasEventBeenShown(goal.id, achievedTime);
          
          if (!hasBeenShown) {
            // イベントを表示（画面が閉じられるまで待つ）
            final eventShown = await _showGoalAchievedEvent(goal);
            
            if (eventShown) {
              // イベントが表示されたことを記録（達成時間も含めて記録）
              await GoalEventService.markEventAsShown(goal.id, achievedTime);
              hasShownEvent = true;
            }
          }
        }
      }
      
      return hasShownEvent;
    } catch (e) {
      LogMk.logError(
        '❌ 目標達成イベントチェックエラー: $e',
        tag: 'TrackingFinishedScreen._checkAndShowGoalAchievedEvents',
      );
      return false;
    }
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

      // 1. 総時間イベント
      await _checkAndShowTotalHoursMilestone();

      // 2. ストリークマイルストーンイベント
      await _showPendingStreakMilestoneEvent();

      // 3. 目標達成イベント（複数あっても順番に表示）
      await _checkAndShowGoalAchievedEvents();

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
  Future<bool> _showGoalAchievedEvent(Goal goal) async {
    if (!mounted) return false;
    
    try {
      // 期間を取得
      final period = _getPeriodLabelFromDurationDays(goal.durationDays);
      
      // 連続日数を取得
      final streakData = await _streakManager.getStreakDataOrDefault();
      final consecutiveDays = streakData.currentStreak;
      
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final sessionInfo = _sessionInfo;
    if (sessionInfo == null) {
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
    
    // SessionInfoをTrackingSessionに変換（表示用）
    final session = TrackingSession(
      id: sessionInfo.id,
      startTime: sessionInfo.startTime,
      endTime: sessionInfo.endTime,
      categorySeconds: Map<String, int>.from(sessionInfo.categorySeconds),
      detectionPeriods: List<DetectionPeriod>.from(sessionInfo.detectionPeriods),
      lastModified: sessionInfo.lastModified,
    );

    return AppScaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCongratulations(),
              _buildTimeRange(session),
              _buildSummaryCards(session),
              _buildBreakdownCard(session),
              _buildGoalUpdates(session),
              SizedBox(height: AppSpacing.md),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratulations() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
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
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRange(TrackingSession session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.6),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.gray,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            _formatTimeRange(session),
            style: AppTextStyles.body1.copyWith(
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            SizedBox(width: AppSpacing.md),
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
              Icon(icon, color: accentColor, size: 30),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: accentColor,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    fontSize: valueFontSize,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: [const FontFeature.tabularFigures()],
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[0]),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildCategoryCard(categories[1]),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[2]),
              ),
              SizedBox(width: AppSpacing.md),
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
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${(data.hours * 3600).round()}秒',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: data.color,
              fontFeatures: [const FontFeature.tabularFigures()],
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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
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
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 1.0),
                ),
              ),
              Text(
                '目標: ${targetHours.toStringAsFixed(1)}h',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
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
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+$plusSeconds秒',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
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
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                  height: 56.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: AppColors.gray,
                          size: 18.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Share on Social Media',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 18.0,
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
          SizedBox(height: AppSpacing.md),
          Container(
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
                onTap: _handleOkButtonPressed,
                borderRadius: borderRadiusValue,
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 20.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'OK',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20.0,
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
        ],
      ),
    );
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
