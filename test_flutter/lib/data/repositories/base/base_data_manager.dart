import 'package:test_flutter/data/repositories/firestore_repository.dart';
import 'package:test_flutter/data/repositories/firestore_hive_repository.dart';

/// Firestore + SharedPreferences統合データマネージャーの抽象基底クラス
/// 
/// FirestoreDataManager<T>をラップし、共通CRUD操作を提供。
/// サブクラスは変換処理のみ実装。
abstract class BaseDataManager<T> {
  /// FirestoreDataManagerのインスタンス
  late final FirestoreDataManager<T> manager;

  BaseDataManager() {
    manager = FirestoreDataManager<T>(
      collectionPathBuilder: getCollectionPath,
      fromFirestore: convertFromFirestore,
      toFirestore: convertToFirestore,
      storageKey: storageKey,
      fromJson: convertFromJson,
      toJson: convertToJson,
      idField: idField,
      lastModifiedField: lastModifiedField,
    );
  }

  // ===== 抽象メソッド（サブクラスで実装） =====

  /// コレクションパスを返す（例: 'users/\$userId/streak'）
  String getCollectionPath(String userId);

  /// Firestoreデータをモデルに変換
  T convertFromFirestore(Map<String, dynamic> data);

  /// モデルをFirestoreデータに変換
  Map<String, dynamic> convertToFirestore(T item);

  /// JSONをモデルに変換（SharedPreferences用）
  T convertFromJson(Map<String, dynamic> json);

  /// モデルをJSONに変換（SharedPreferences用）
  Map<String, dynamic> convertToJson(T item);

  /// SharedPreferencesのストレージキー
  String get storageKey;

  /// IDフィールド名（デフォルト: 'id'）
  String get idField => 'id';

  /// 最終更新フィールド名（デフォルト: 'lastModified'）
  String get lastModifiedField => 'lastModified';

  // ===== 共通メソッド（managerに委譲） =====

  Future<bool> add(String userId, T item) async =>
      await manager.add(userId, item);
  Future<bool> addWithAuth(T item) async =>
      await manager.addWithAuth(item);
  Future<T?> getById(String userId, String id) async =>
      await manager.getById(userId, id);
  Future<List<T>> getAll(String userId) async =>
      await manager.getAll(userId);
  Future<List<T>> getAllWithAuth() async =>
      await manager.getAllWithAuth();
  Future<bool> update(String userId, T item) async =>
      await manager.update(userId, item);
  Future<bool> updateWithAuth(T item) async =>
      await manager.updateWithAuth(item);

  Future<List<T>> getLocalAll() async =>
      await manager.getLocalAll();
  Future<T?> getLocalById(String id) async =>
      await manager.getLocalById(id);
  Future<void> saveLocal(List<T> items) async =>
      await manager.saveLocal(items);
  Future<void> addLocal(T item) async =>
      await manager.addLocal(item);
  Future<void> updateLocal(T item) async =>
      await manager.updateLocal(item);
  Future<void> clearLocal() async =>
      await manager.clearLocal();

  Future<List<T>> sync(String userId) async =>
      await manager.sync(userId);
  Future<List<T>> syncWithAuth() async =>
      await manager.syncWithAuth();

  Future<bool> addWithRetry(String userId, T item) async =>
      await manager.addWithRetry(userId, item);
  Future<bool> updateWithRetry(String userId, T item) async =>
      await manager.updateWithRetry(userId, item);
  Future<bool> saveWithRetry(String userId, T item) async =>
      await manager.saveWithRetry(userId, item);
  Future<bool> saveWithRetryAuth(T item) async =>
      await manager.saveWithRetryAuth(item);
}

/// Firestore + Hive統合データマネージャーの抽象基底クラス
/// 
/// FirestoreHiveDataManager<T>をラップし、共通CRUD操作を提供。
/// サブクラスは変換処理のみ実装。
abstract class BaseHiveDataManager<T> {
  late final FirestoreHiveDataManager<T> manager;

  BaseHiveDataManager() {
    manager = FirestoreHiveDataManager<T>(
      collectionPathBuilder: getCollectionPath,
      fromFirestore: convertFromFirestore,
      toFirestore: convertToFirestore,
      hiveBoxName: hiveBoxName,
      fromJson: convertFromJson,
      toJson: convertToJson,
      idField: idField,
      lastModifiedField: lastModifiedField,
    );
  }

  // ===== 抽象メソッド（サブクラスで実装） =====

  /// コレクションパスを返す（例: 'users/\$userId/goals'）
  String getCollectionPath(String userId);

  /// Firestoreデータをモデルに変換
  T convertFromFirestore(Map<String, dynamic> data);

  /// モデルをFirestoreデータに変換
  Map<String, dynamic> convertToFirestore(T item);

  /// JSONをモデルに変換（Hive用）
  T convertFromJson(Map<String, dynamic> json);

  /// モデルをJSONに変換（Hive用）
  Map<String, dynamic> convertToJson(T item);

  /// Hiveのボックス名
  String get hiveBoxName;

  /// IDフィールド名（デフォルト: 'id'）
  String get idField => 'id';

  /// 最終更新フィールド名（デフォルト: 'lastModified'）
  String get lastModifiedField => 'lastModified';

  // ===== 共通メソッド（managerに委譲） =====

  Future<bool> add(String userId, T item) async =>
      await manager.add(userId, item);
  Future<bool> addWithAuth(T item) async =>
      await manager.addWithAuth(item);
  Future<T?> getById(String userId, String id) async =>
      await manager.getById(userId, id);
  Future<List<T>> getAll(String userId) async =>
      await manager.getAll(userId);
  Future<List<T>> getAllWithAuth() async =>
      await manager.getAllWithAuth();
  Future<bool> update(String userId, T item) async =>
      await manager.update(userId, item);
  Future<bool> updateWithAuth(T item) async =>
      await manager.updateWithAuth(item);
  Future<bool> delete(String userId, String id) async =>
      await manager.delete(userId, id);
  Future<bool> deleteWithAuth(String id) async =>
      await manager.deleteWithAuth(id);
  Future<bool> updatePartial(String userId, String id,
          Map<String, dynamic> updates) async =>
      await manager.updatePartial(userId, id, updates);
  Future<bool> updatePartialWithAuth(String id,
          Map<String, dynamic> updates) async =>
      await manager.updatePartialWithAuth(id, updates);
  Future<List<T>> getAllWithQuery(String userId,
          {Map<String, dynamic>? whereConditions}) async =>
      await manager.getAllWithQuery(userId,
          whereConditions: whereConditions);

  Future<List<T>> getLocalAll() async =>
      await manager.getLocalAll();
  Future<T?> getLocalById(String id) async =>
      await manager.getLocalById(id);
  Future<void> saveLocal(List<T> items) async =>
      await manager.saveLocal(items);
  Future<void> clearLocal() async =>
      await manager.clearLocal();
  Future<int> getLocalCount() async =>
      await manager.getLocalCount();

  Future<bool> addWithRetry(String userId, T item) async =>
      await manager.addWithRetry(userId, item);
  Future<bool> updateWithRetry(String userId, T item) async =>
      await manager.updateWithRetry(userId, item);
  Future<bool> deleteWithRetry(String userId, String id) async =>
      await manager.deleteWithRetry(userId, id);
  Future<int> processQueue(String userId) async =>
      await manager.processQueue(userId);
  Future<Map<String, int>> getQueueStats() async =>
      await manager.getQueueStats();
  Future<void> clearQueue() async =>
      await manager.clearQueue();
  Future<int> retryFailedOperations(String userId) async =>
      await manager.retryFailedOperations(userId);
}

