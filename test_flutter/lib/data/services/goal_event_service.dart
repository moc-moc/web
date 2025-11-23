import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';

/// 目標達成イベントサービス
/// 
/// 目標達成イベントの表示状態を管理し、
/// 同じ目標で再度達成してもイベントが表示されないようにします。
/// FirebaseとSharedPreferencesの両方に保存します。
class GoalEventService {
  static const String _keyPrefix = 'goal_achieved_event_';
  static const String _achievedTimePrefix = 'goal_achieved_time_';

  /// 目標達成イベントが既に表示されたかどうかをチェック
  /// 
  /// **パラメータ**:
  /// - `goalId`: 目標ID
  /// - `achievedTime`: 現在の達成時間（秒単位）
  /// 
  /// **戻り値**: 既に表示された場合true、そうでない場合false
  /// 
  /// **注意**: 同じ目標で同じ`achievedTime`以上になったら表示しないようにします。
  /// FirebaseとSharedPreferencesの両方をチェックします。
  static Future<bool> hasEventBeenShown(String goalId, int achievedTime) async {
    try {
      // まずFirebaseからチェック
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final manager = GoalDataManager();
          final goal = await manager.manager.getById(currentUser.uid, goalId);
          
          if (goal != null && goal.lastAchievedEventShownAt != null) {
            // Firebaseに記録があり、現在の達成時間が記録時の達成時間以上の場合、既に表示済み
            // ただし、achievedTimeが増えている場合は再表示する可能性があるため、
            // SharedPreferencesの達成時間もチェック
            final prefs = await SharedPreferences.getInstance();
            final lastShownAchievedTime = prefs.getInt('$_achievedTimePrefix$goalId');
            
            if (lastShownAchievedTime != null && achievedTime >= lastShownAchievedTime) {
              return true;
            }
          }
        } catch (e) {
          debugPrint('⚠️ [GoalEventService] Firebaseからの取得エラー: $e');
          // エラー時はSharedPreferencesをチェック
        }
      }
      
      // SharedPreferencesからチェック（後方互換性のため）
      final prefs = await SharedPreferences.getInstance();
      final lastShownAchievedTime = prefs.getInt('$_achievedTimePrefix$goalId');
      
      // 記録がない場合は、まだ表示されていない
      if (lastShownAchievedTime == null) {
        return false;
      }
      
      // 現在の達成時間が、イベントが表示された時点の達成時間以上の場合、既に表示済み
      return achievedTime >= lastShownAchievedTime;
    } catch (e) {
      debugPrint('❌ [GoalEventService] イベント表示状態の取得エラー: $e');
      return false;
    }
  }

  /// 目標達成イベントが表示されたことを記録
  /// 
  /// **パラメータ**:
  /// - `goalId`: 目標ID
  /// - `achievedTime`: 達成時間（秒単位）
  /// 
  /// FirebaseとSharedPreferencesの両方に保存します。
  static Future<void> markEventAsShown(String goalId, int achievedTime) async {
    try {
      final now = DateTime.now();
      
      // 1. SharedPreferencesに保存（後方互換性のため）
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_keyPrefix$goalId', true);
      await prefs.setInt('$_achievedTimePrefix$goalId', achievedTime);
      
      // 2. Firebaseに保存
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final manager = GoalDataManager();
          final goal = await manager.manager.getById(currentUser.uid, goalId);
          
          if (goal != null) {
            // Goalを更新してFirestoreに保存
            final updatedGoal = goal.copyWith(
              lastAchievedEventShownAt: now,
              lastModified: now,
            );
            
            final success = await manager.updateGoalWithAuth(updatedGoal);
            if (success) {
              debugPrint('✅ [GoalEventService] 目標達成イベントをFirebaseに記録: $goalId (achievedTime: $achievedTime秒)');
            } else {
              debugPrint('⚠️ [GoalEventService] Firebaseへの保存に失敗しました（リトライキューに追加された可能性）: $goalId');
            }
          } else {
            debugPrint('⚠️ [GoalEventService] 目標が見つかりません: $goalId');
          }
        } catch (e) {
          debugPrint('❌ [GoalEventService] Firebaseへの保存エラー: $e');
          // エラーが発生してもSharedPreferencesには保存されているので続行
        }
      } else {
        debugPrint('⚠️ [GoalEventService] ユーザー未認証のため、Firebaseへの保存をスキップ: $goalId');
      }
      
      debugPrint('✅ [GoalEventService] 目標達成イベントを記録: $goalId (achievedTime: $achievedTime秒)');
    } catch (e) {
      debugPrint('❌ [GoalEventService] イベント表示状態の保存エラー: $e');
    }
  }

  /// 目標達成イベントの表示状態をリセット（デバッグ用）
  /// 
  /// **パラメータ**:
  /// - `goalId`: 目標ID
  static Future<void> resetEventShown(String goalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$goalId');
      await prefs.remove('$_achievedTimePrefix$goalId');
      debugPrint('🔄 [GoalEventService] 目標達成イベントの表示状態をリセット: $goalId');
    } catch (e) {
      debugPrint('❌ [GoalEventService] イベント表示状態のリセットエラー: $e');
    }
  }

  /// すべての目標達成イベントの表示状態をリセット（デバッグ用）
  static Future<void> resetAllEventsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final goalEventKeys = keys.where((key) => 
        key.startsWith(_keyPrefix) || key.startsWith(_achievedTimePrefix)
      );
      for (final key in goalEventKeys) {
        await prefs.remove(key);
      }
      debugPrint('🔄 [GoalEventService] すべての目標達成イベントの表示状態をリセット');
    } catch (e) {
      debugPrint('❌ [GoalEventService] すべてのイベント表示状態のリセットエラー: $e');
    }
  }
}

