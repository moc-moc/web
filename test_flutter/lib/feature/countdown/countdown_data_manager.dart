import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/countdown/countdown_model.dart';

/// カウントダウン用データマネージャー
/// 
/// BaseDataManager<Countdown>を継承して、カウントダウンデータの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - クエリ機能（条件付き取得）
/// - 物理削除（Firestoreから完全に削除）
class CountdownDataManager extends BaseDataManager<Countdown> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/countdowns';

  @override
  Countdown convertFromFirestore(Map<String, dynamic> data) {
    return Countdown(
      id: data['id'] as String,
      title: data['title'] as String,
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(Countdown item) {
    return {
      'id': item.id,
      'title': item.title,
      'targetDate': Timestamp.fromDate(item.targetDate),
      'isDeleted': item.isDeleted,
      'lastModified': Timestamp.fromDate(item.lastModified),
    };
  }

  @override
  Countdown convertFromJson(Map<String, dynamic> json) => Countdown.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(Countdown item) => item.toJson();

  @override
  String get storageKey => 'countdowns';

  // ===== カスタム機能（カウントダウン特有） =====

  /// カウントダウンを追加（認証自動取得版）
  Future<bool> addCountdownWithAuth(Countdown countdown) async {
    return await manager.addWithAuth(countdown);
  }

  /// 全カウントダウンを取得（認証自動取得版）
  Future<List<Countdown>> getAllCountdownsWithAuth() async {
    return await manager.getAllWithAuth();
  }

  /// カウントダウンを更新（認証自動取得版）
  Future<bool> updateCountdownWithAuth(Countdown countdown) async {
    return await manager.updateWithAuth(countdown);
  }

  /// カウントダウンを削除（認証自動取得版）
  Future<bool> deleteCountdownWithAuth(String id) async {
    return await manager.deleteWithAuth(id);
  }

  /// ローカルから全カウントダウンを取得
  Future<List<Countdown>> getLocalCountdowns() async {
    return await manager.getLocalAll();
  }

  /// ローカルにカウントダウンを保存
  Future<void> saveLocalCountdowns(List<Countdown> countdowns) async {
    await manager.saveLocal(countdowns);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  Future<List<Countdown>> syncCountdownsWithAuth() async {
    return await manager.syncWithAuth();
  }

  /// アクティブなカウントダウンのみを取得（認証自動取得版）
  /// 
  /// 全カウントダウンを取得します（物理削除のため、削除済みは存在しません）
  Future<List<Countdown>> getActiveCountdownsWithAuth() async {
    return await getAllCountdownsWithAuth();
  }
}

