import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';

/// 目標用データマネージャー
/// 
/// BaseHiveDataManager<Goal>を継承して、目標データの管理を行います。
/// 
class GoalDataManager extends BaseHiveDataManager<Goal> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/goals';

  @override
  Goal convertFromFirestore(Map<String, dynamic> data) {
    return Goal(
      id: data['id'] as String,
      tag: data['tag'] as String,
      title: data['title'] as String,
      targetTime: data['targetTime'] as int,
      comparisonType: ComparisonType.values.byName(data['comparisonType'] as String),
      detectionItem: DetectionItem.values.byName(data['detectionItem'] as String),
      startDate: (data['startDate'] as Timestamp).toDate(),
      durationDays: data['durationDays'] as int,
      consecutiveAchievements: data['consecutiveAchievements'] as int? ?? 0,
      achievedTime: data['achievedTime'] as int?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(Goal item) {
    return {
      'id': item.id,
      'tag': item.tag,
      'title': item.title,
      'targetTime': item.targetTime,
      'comparisonType': item.comparisonType.name,
      'detectionItem': item.detectionItem.name,
      'startDate': Timestamp.fromDate(item.startDate),
      'durationDays': item.durationDays,
      'consecutiveAchievements': item.consecutiveAchievements,
      'achievedTime': item.achievedTime,
      'isDeleted': item.isDeleted,
      'lastModified': Timestamp.fromDate(item.lastModified),
    };
  }

  @override
  Goal convertFromJson(Map<String, dynamic> json) => Goal.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(Goal item) => item.toJson();

  @override
  String get hiveBoxName => 'goals';

  // ===== カスタム機能（目標特有） =====

  /// 目標を追加（認証自動取得版）
  Future<bool> addGoalWithAuth(Goal goal) async {
    return await manager.addWithAuth(goal);
  }

  /// 全目標を取得（認証自動取得版）
  Future<List<Goal>> getAllGoalsWithAuth() async {
    return await manager.getAllWithAuth();
  }

  /// 目標を更新（認証自動取得版）
  Future<bool> updateGoalWithAuth(Goal goal) async {
    return await manager.updateWithAuth(goal);
  }

  /// ローカルから全目標を取得
  Future<List<Goal>> getLocalGoals() async {
    return await manager.getLocalAll();
  }

  /// ローカルに目標を保存
  Future<void> saveLocalGoals(List<Goal> goals) async {
    await manager.saveLocal(goals);
  }

  /// 目標を論理削除（認証自動取得版）
  Future<bool> softDeleteGoalWithAuth(String id) async {
    return await manager.updatePartialWithAuth(id, {'isDeleted': true});
  }

  /// アクティブな目標のみを取得（認証自動取得版）
  Future<List<Goal>> getActiveGoalsWithAuth() async {
    final goals = await getAllGoalsWithAuth();
    return goals.where((goal) => !goal.isDeleted).toList();
  }

  /// Firestoreから直接目標を取得（認証自動取得版）
  /// 
  /// ローカルキャッシュを無視して、Firestoreから最新データを取得します。
  Future<List<Goal>> getGoalsFromFirestoreWithAuth() async {
    try {
      debugPrint('🔍 [getGoalsFromFirestoreWithAuth] Firestoreから直接取得開始');
      final goals = await manager.getAllWithAuth();
      debugPrint('✅ [getGoalsFromFirestoreWithAuth] Firestoreから取得成功: ${goals.length}件');
      return goals;
    } catch (e) {
      debugPrint('❌ [getGoalsFromFirestoreWithAuth] 取得エラー: $e');
      return [];
    }
  }

  /// 達成記録を更新
  /// 
  /// 連続達成回数をインクリメントし、達成時間を記録します。
  Future<bool> recordAchievement(String userId, String id, int achievedTime) async {
    try {
      // 現在の目標を取得
      final goal = await manager.getById(userId, id);
      if (goal == null) {
        debugPrint('❌ 目標が見つかりません: $id');
        return false;
      }

      // 連続達成回数をインクリメント
      final updatedGoal = goal.copyWith(
        consecutiveAchievements: goal.consecutiveAchievements + 1,
        achievedTime: achievedTime,
        lastModified: DateTime.now(),
      );

      // 更新
      return await manager.update(userId, updatedGoal);
    } catch (e) {
      debugPrint('❌ 達成記録更新エラー: $e');
      return false;
    }
  }

  /// 達成記録を更新（認証自動取得版）
  Future<bool> recordAchievementWithAuth(String id, int achievedTime) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('⚠️ 未ログイン');
      return false;
    }
    return await recordAchievement(currentUser.uid, id, achievedTime);
  }
}
