import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';

/// ゴール期間終了イベントサービス
/// 
/// アプリ起動時にゴールの期間終了をチェックし、
/// 必要に応じてイベント画面を表示する処理を提供します。
class GoalPeriodEndedEventService {
  /// ゴール期間終了をチェックし、必要に応じてイベント画面を表示
  /// 
  /// **パラメータ**:
  /// - `ref`: RiverpodのWidgetRef
  /// - `navigator`: NavigatorState（イベント画面を表示するために使用）
  /// - `mounted`: ウィジェットがマウントされているかどうか
  /// 
  /// **戻り値**: イベント画面が表示された場合true、そうでない場合false
  static Future<bool> checkAndShowEndedGoalPeriod({
    required WidgetRef ref,
    required NavigatorState? navigator,
    required bool mounted,
  }) async {
    debugPrint('🔍 [GoalPeriodEndedEventService] checkAndShowEndedGoalPeriod 開始');
    
    if (!mounted || navigator == null) {
      debugPrint('⚠️ [GoalPeriodEndedEventService] mounted=false または navigator=null');
      return false;
    }

    try {
      // ゴールリストを取得
      final goals = ref.read(goalsListProvider);
      final now = DateTime.now();
      debugPrint('📋 [GoalPeriodEndedEventService] ゴール数: ${goals.length}, 現在時刻: $now');

      // 期間が終了したゴールを検出
      final endedGoals = goals.where((goal) {
        if (goal.isDeleted) {
          debugPrint('⏭️ [GoalPeriodEndedEventService] 削除済み目標をスキップ: ${goal.id}');
          return false;
        }
        // periodEndDateがnullの場合はスキップ
        if (goal.periodEndDate == null) {
          debugPrint('⏭️ [GoalPeriodEndedEventService] periodEndDateがnullの目標をスキップ: ${goal.id}');
          return false;
        }
        final isEnded = now.isAfter(goal.periodEndDate!) || now.isAtSameMomentAs(goal.periodEndDate!);
        if (isEnded) {
          debugPrint('✅ [GoalPeriodEndedEventService] 期間終了目標を検出: ${goal.id}, 終了日: ${goal.periodEndDate}');
        }
        return isEnded;
      }).toList();

      debugPrint('📊 [GoalPeriodEndedEventService] 期間終了した目標数: ${endedGoals.length}');

      // 期間が終了したゴールがある場合、最初の1つを表示
      if (endedGoals.isNotEmpty) {
        final endedGoal = endedGoals.first;
        debugPrint('🎯 [GoalPeriodEndedEventService] イベント画面を表示: ${endedGoal.title}');
        
        // 進捗率を計算（0.0-1.0）
        final progress = endedGoal.targetTime > 0
            ? ((endedGoal.achievedTime ?? 0) / endedGoal.targetTime).clamp(0.0, 1.0)
            : 0.0;
        
        // 期間ラベルを生成
        final periodLabel = _getPeriodLabel(endedGoal.durationDays);
        
        // Navigatorが準備できているか確認
        if (navigator.mounted) {
          debugPrint('🚀 [GoalPeriodEndedEventService] Navigatorに画面をpush');
          await navigator.pushNamed(
            AppRoutes.goalPeriodEndedEvent,
            arguments: {
              'goalName': endedGoal.title,
              'targetHours': endedGoal.targetTime / 3600.0,
              'achievedHours': (endedGoal.achievedTime ?? 0) / 3600.0,
              'progress': progress,
              'consecutiveDays': endedGoal.consecutiveAchievements,
              'period': periodLabel,
              'goalId': endedGoal.id,
            },
          );
          debugPrint('✅ [GoalPeriodEndedEventService] イベント画面表示完了');
          return true;
        } else {
          debugPrint('⚠️ [GoalPeriodEndedEventService] Navigatorがmountedではない');
        }
      } else {
        debugPrint('ℹ️ [GoalPeriodEndedEventService] 期間終了した目標なし');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [GoalPeriodEndedEventService] エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
    }

    return false;
  }

  /// アプリ起動時にゴール期間終了をチェックする処理をスケジュール
  /// 
  /// データ読み込み完了を待ってからチェック処理を実行します。
  /// 
  /// **パラメータ**:
  /// - `ref`: RiverpodのWidgetRef
  /// - `navigatorKey`: NavigatorStateを取得するためのGlobalKey
  /// - `mounted`: ウィジェットがマウントされているかどうか
  static void scheduleGoalPeriodCheck({
    required WidgetRef ref,
    required GlobalKey<NavigatorState> navigatorKey,
    required bool mounted,
  }) {
    // フレーム描画完了を待ってからチェック処理を実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // NavigatorKeyから現在のNavigatorStateを取得
        final navigator = navigatorKey.currentState;
        checkAndShowEndedGoalPeriod(
          ref: ref,
          navigator: navigator,
          mounted: mounted,
        );
      }
    });
  }

  /// 期間日数から期間ラベルを生成
  static String _getPeriodLabel(int durationDays) {
    if (durationDays == 1) {
      return 'Daily';
    } else if (durationDays == 7) {
      return 'Weekly';
    } else if (durationDays == 30) {
      return 'Monthly';
    } else if (durationDays == 90) {
      return 'Quarterly';
    } else if (durationDays == 365) {
      return 'Yearly';
    } else {
      return '$durationDays days';
    }
  }
}

