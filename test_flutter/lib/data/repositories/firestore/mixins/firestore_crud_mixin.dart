import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// CRUD操作のMixin
/// 
/// Firestoreへの基本的なCRUD操作を提供
mixin FirestoreCrudMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  T Function(Map<String, dynamic> data) get fromFirestore;
  Map<String, dynamic> Function(T item) get toFirestore;
  String get idField;
  String get lastModifiedField;
  String _getItemId(T item);

  /// 新しいアイテムをFirestoreに追加
  /// 
  Future<bool> add(String userId, T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toFirestore(item);
      
      // 2. lastModifiedフィールドに現在時刻を自動設定
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      // 3. IDを取得
      final itemId = _getItemId(item);
      
      // 4. Firestoreに保存
      final success = await FirestoreMk.saveDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        await LogMk.logInfo('アイテム追加完了: $itemId', tag: 'DataManager');
      } else {
        await LogMk.logWarning('アイテム追加失敗: $itemId', tag: 'DataManager');
      }
      
      return success;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(
        e,
        defaultType: ErrorType.storage,
        stackTrace: stackTrace,
      );
      await LogMk.logError(
        'アイテム追加エラー',
        tag: 'DataManager',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Firestoreから全アイテムを取得
  /// 
  Future<List<T>> getAll(String userId) async {
    try {
      // 1. Firestoreからデータを取得
      final dataList = await FirestoreMk.fetchCollection(
        collectionPathBuilder(userId),
      );
      
      // 2. 各データをモデルに変換
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(' データ変換エラー: $e');
          // 変換に失敗したアイテムはスキップ
        }
      }
      
      return items;
    } catch (e) {
      await LogMk.logError(' アイテム取得エラー: $e');
      return [];
    }
  }

  /// 指定IDのアイテムを取得
  /// 
  Future<T?> getById(String userId, String id) async {
    try {
      // 1. Firestoreからデータを取得
      final data = await FirestoreMk.fetchDocument(
        collectionPathBuilder(userId),
        id,
      );
      
      if (data == null) {
        await LogMk.logInfo('ℹ️ アイテムが見つかりません: $id');
        return null;
      }
      
      // 2. モデルに変換
      final item = fromFirestore(data);
      
      return item;
    } catch (e) {
      await LogMk.logError(' アイテム取得エラー: $e');
      return null;
    }
  }

  /// アイテムを更新
  /// 
  Future<bool> update(String userId, T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toFirestore(item);
      
      // 2. lastModifiedフィールドを現在時刻に更新
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      // 3. IDを取得
      final itemId = _getItemId(item);
      
      // 4. Firestoreを更新
      final success = await FirestoreMk.updateDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        await LogMk.logInfo('✅ アイテム更新完了: $itemId');
      } else {
        await LogMk.logError(' アイテム更新失敗: $itemId');
      }
      
      return success;
    } catch (e) {
      await LogMk.logError(' アイテム更新エラー: $e');
      return false;
    }
  }

  /// アイテムを削除（物理削除）
  /// 
  Future<bool> delete(String userId, String id) async {
    try {
      // 1. Firestoreから削除
      final success = await FirestoreMk.deleteDocument(
        collectionPathBuilder(userId),
        id,
      );
      
      if (success) {
        await LogMk.logInfo('✅ アイテム削除完了: $id');
      } else {
        await LogMk.logError(' アイテム削除失敗: $id');
      }
      
      return success;
    } catch (e) {
      await LogMk.logError(' アイテム削除エラー: $e');
      return false;
    }
  }
}

