import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/firestore_hive_repository.dart';

part 'goal_data_manager.freezed.dart';
part 'goal_data_manager.g.dart';

/// 比較タイプ（以上/以下）
enum ComparisonType {
  /// 以上
  above,

  /// 以下
  below,
}

/// 検出項目（本/スマホ/パソコン）
enum DetectionItem {
  /// 本
  book,

  /// スマホ
  smartphone,

  /// パソコン
  pc,
}

/// 目標モデル
///
/// ユーザーが設定する目標を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
///
@freezed
abstract class Goal with _$Goal {
  /// Goalモデルのコンストラクタ
  const factory Goal({
    required String id,
    required String tag,
    required String title,
    required int targetTime,
    required ComparisonType comparisonType,
    required DetectionItem detectionItem,
    required DateTime startDate,
    required int durationDays,
    @Default(0) int consecutiveAchievements,
    int? achievedTime,
    @Default(false) bool isDeleted,
    required DateTime lastModified,
  }) = _Goal;

  /// JSONからGoalモデルを生成
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}

/// 目標用データマネージャー
///
/// data_manager_hive_un.dartのFirestoreHiveDataManagerを使用して
/// 目標データの管理を行います。
///
class GoalDataManager {
  /// FirestoreHiveDataManagerのインスタンス
  late final FirestoreHiveDataManager<Goal> _manager;

  /// コンストラクタ
  GoalDataManager() {
    _manager = FirestoreHiveDataManager<Goal>(
      // コレクションパス: users/{userId}/goals
      collectionPathBuilder: (userId) => 'users/$userId/goals',

      // Firestoreデータ → Goalモデル変換
      fromFirestore: (data) {
        return Goal(
          id: data['id'] as String,
          tag: data['tag'] as String,
          title: data['title'] as String,
          targetTime: data['targetTime'] as int,
          comparisonType: ComparisonType.values.byName(
            data['comparisonType'] as String,
          ),
          detectionItem: DetectionItem.values.byName(
            data['detectionItem'] as String,
          ),
          startDate: (data['startDate'] as Timestamp).toDate(),
          durationDays: data['durationDays'] as int,
          consecutiveAchievements: data['consecutiveAchievements'] as int? ?? 0,
          achievedTime: data['achievedTime'] as int?,
          isDeleted: data['isDeleted'] as bool? ?? false,
          lastModified: (data['lastModified'] as Timestamp).toDate(),
        );
      },

      // Goalモデル → Firestoreデータ変換
      toFirestore: (goal) {
        return {
          'id': goal.id,
          'tag': goal.tag,
          'title': goal.title,
          'targetTime': goal.targetTime,
          'comparisonType': goal.comparisonType.name,
          'detectionItem': goal.detectionItem.name,
          'startDate': Timestamp.fromDate(goal.startDate),
          'durationDays': goal.durationDays,
          'consecutiveAchievements': goal.consecutiveAchievements,
          'achievedTime': goal.achievedTime,
          'isDeleted': goal.isDeleted,
          'lastModified': Timestamp.fromDate(goal.lastModified),
        };
      },

      // Hiveのボックス名
      hiveBoxName: 'goals',

      // JSON → Goalモデル変換
      fromJson: (json) => Goal.fromJson(json),

      // Goalモデル → JSON変換
      toJson: (goal) => goal.toJson(),

      // IDフィールド名
      idField: 'id',

      // 最終更新フィールド名
      lastModifiedField: 'lastModified',
    );
  }

  // ===== 基本CRUD操作 =====

  /// 目標を追加
  Future<bool> addGoal(String userId, Goal goal) async {
    return await _manager.add(userId, goal);
  }

  /// 目標を追加（認証自動取得版）
  Future<bool> addGoalWithAuth(Goal goal) async {
    return await _manager.addWithAuth(goal);
  }

  /// 全目標を取得
  Future<List<Goal>> getAllGoals(String userId) async {
    return await _manager.getAll(userId);
  }

  /// 全目標を取得（認証自動取得版）
  Future<List<Goal>> getAllGoalsWithAuth() async {
    return await _manager.getAllWithAuth();
  }

  /// 目標を更新
  Future<bool> updateGoal(String userId, Goal goal) async {
    return await _manager.update(userId, goal);
  }

  /// 目標を更新（認証自動取得版）
  Future<bool> updateGoalWithAuth(Goal goal) async {
    return await _manager.updateWithAuth(goal);
  }

  /// 目標を削除（物理削除）
  Future<bool> deleteGoal(String userId, String id) async {
    return await _manager.delete(userId, id);
  }

  /// 目標を削除（認証自動取得版）
  Future<bool> deleteGoalWithAuth(String id) async {
    return await _manager.deleteWithAuth(id);
  }

  // ===== ローカルストレージ操作 =====

  /// ローカルから全目標を取得
  Future<List<Goal>> getLocalGoals() async {
    return await _manager.getLocalAll();
  }

  /// ローカルから目標を取得
  Future<Goal?> getLocalGoalById(String id) async {
    return await _manager.getLocalById(id);
  }

  /// ローカルに目標を保存
  Future<void> saveLocalGoals(List<Goal> goals) async {
    await _manager.saveLocal(goals);
  }

  /// ローカルデータをクリア
  Future<void> clearLocalGoals() async {
    await _manager.clearLocal();
  }

  /// ローカルの目標数を取得
  Future<int> getLocalGoalsCount() async {
    return await _manager.getLocalCount();
  }

  // ===== リトライ機能 =====

  /// リトライ機能付きで目標を追加
  Future<bool> addGoalWithRetry(String userId, Goal goal) async {
    return await _manager.addWithRetry(userId, goal);
  }

  /// リトライ機能付きで目標を更新
  Future<bool> updateGoalWithRetry(String userId, Goal goal) async {
    return await _manager.updateWithRetry(userId, goal);
  }

  /// リトライ機能付きで目標を削除
  Future<bool> deleteGoalWithRetry(String userId, String id) async {
    return await _manager.deleteWithRetry(userId, id);
  }

  /// キュー処理
  Future<int> processQueue(String userId) async {
    return await _manager.processQueue(userId);
  }

  /// キュー統計を取得
  Future<Map<String, int>> getQueueStats() async {
    return await _manager.getQueueStats();
  }

  /// キューを全クリア
  Future<void> clearQueue() async {
    await _manager.clearQueue();
  }

  /// 失敗した操作を再試行
  Future<int> retryFailedOperations(String userId) async {
    return await _manager.retryFailedOperations(userId);
  }

  // ===== カスタム機能（目標特有） =====

  /// 目標を論理削除
  Future<bool> softDeleteGoal(String userId, String id) async {
    return await _manager.updatePartial(userId, id, {'isDeleted': true});
  }

  /// 目標を論理削除（認証自動取得版）
  Future<bool> softDeleteGoalWithAuth(String id) async {
    return await _manager.updatePartialWithAuth(id, {'isDeleted': true});
  }

  /// アクティブな目標のみを取得
  Future<List<Goal>> getActiveGoals(String userId) async {
    return await _manager.getAllWithQuery(
      userId,
      whereConditions: {'isDeleted': false},
    );
  }

  /// アクティブな目標のみを取得（認証自動取得版）
  Future<List<Goal>> getActiveGoalsWithAuth() async {
    final goals = await _manager.getAllWithAuth();
    return goals.where((goal) => !goal.isDeleted).toList();
  }

  /// Firestoreから直接目標を取得（認証自動取得版）
  ///
  /// ローカルキャッシュを無視して、Firestoreから最新データを取得します。
  Future<List<Goal>> getGoalsFromFirestoreWithAuth() async {
    try {
      debugPrint('🔍 [getGoalsFromFirestoreWithAuth] Firestoreから直接取得開始');
      final goals = await _manager.getAllWithAuth();
      debugPrint(
        '✅ [getGoalsFromFirestoreWithAuth] Firestoreから取得成功: ${goals.length}件',
      );
      return goals;
    } catch (e) {
      debugPrint('❌ [getGoalsFromFirestoreWithAuth] 取得エラー: $e');
      return [];
    }
  }

  /// 達成記録を更新
  ///
  /// 連続達成回数をインクリメントし、達成時間を記録します。
  Future<bool> recordAchievement(
    String userId,
    String id,
    int achievedTime,
  ) async {
    try {
      // 現在の目標を取得
      final goal = await _manager.getById(userId, id);
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
      return await _manager.update(userId, updatedGoal);
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
