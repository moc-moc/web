import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// ストレージ管理のMixin
/// 
/// 変更追跡、スキーマバージョニング、ストレージサイズ管理機能を提供
mixin FirestoreStorageMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  String get storageKey;
  String get idField;
  String get lastModifiedField;
  T Function(Map<String, dynamic> json) get fromJson;
  Map<String, dynamic> Function(T item) get toFirestore;

  /// ローカルの変更されたアイテムのみをFirestoreにプッシュ
  /// 
  Future<int> pushLocalChangesSelective(String userId) async {
    try {
      await LogMk.logInfo('選択的プッシュ開始: $userId', tag: 'DataManager.pushLocalChangesSelective');
      
      // 1. 変更されたアイテムのみを取得
      final dirtyDataList = await SharedMk.getDirtyItems(storageKey);
      await LogMk.logDebug('変更アイテム取得: ${dirtyDataList.length}件', tag: 'DataManager.pushLocalChangesSelective');
      
      int successCount = 0;
      final successIds = <String>[];
      
      // 2. 各アイテムをFirestoreに保存
      for (final data in dirtyDataList) {
        try {
          final itemId = data[idField] as String?;
          if (itemId == null || itemId.isEmpty) {
            await LogMk.logWarning('アイテムIDが無効です: $data', tag: 'DataManager.pushLocalChangesSelective');
            continue;
          }
          
          // toFirestoreで変換（Timestamp変換含む）
          final item = fromJson(data);
          final firestoreData = toFirestore(item);
          
          // lastModifiedを現在時刻に更新
          firestoreData[lastModifiedField] = FirestoreMk.createTimestamp();
          
          // Firestoreに保存
          final success = await FirestoreMk.saveDocument(
            collectionPathBuilder(userId),
            itemId,
            firestoreData,
          );
          
          if (success) {
            successCount++;
            successIds.add(itemId);
            await LogMk.logDebug('プッシュ成功: $itemId', tag: 'DataManager.pushLocalChangesSelective');
          } else {
            await LogMk.logWarning('プッシュ失敗: $itemId', tag: 'DataManager.pushLocalChangesSelective');
          }
        } catch (e, stackTrace) {
          await LogMk.logError('アイテムプッシュエラー', tag: 'DataManager.pushLocalChangesSelective', error: e, stackTrace: stackTrace);
        }
      }
      
      // 3. 成功したアイテムの変更フラグをクリア
      if (successIds.isNotEmpty) {
        await SharedMk.clearDirtyFlags(storageKey, itemIds: successIds, idField: idField);
      }
      
      await LogMk.logInfo('選択的プッシュ完了: $successCount/${dirtyDataList.length}件', tag: 'DataManager.pushLocalChangesSelective');
      return successCount;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.sync, stackTrace: stackTrace);
      await LogMk.logError('選択的プッシュエラー: $userId', tag: 'DataManager.pushLocalChangesSelective', error: error, stackTrace: stackTrace);
      return 0;
    }
  }

  /// 変更されたアイテムを取得
  /// 
  Future<List<T>> getDirtyItems() async {
    try {
      final dirtyDataList = await SharedMk.getDirtyItems(storageKey);
      
      final items = <T>[];
      for (final data in dirtyDataList) {
        try {
          final item = fromJson(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning('変更アイテム変換エラー: $e', tag: 'DataManager.getDirtyItems');
        }
      }
      
      await LogMk.logInfo('変更アイテム取得完了: ${items.length}件', tag: 'DataManager.getDirtyItems');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('変更アイテム取得エラー', tag: 'DataManager.getDirtyItems', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// スキーマバージョンをチェックして必要に応じてマイグレーション
  /// 
  Future<bool> checkAndMigrateSchema(
    int targetVersion,
    Future<List<Map<String, dynamic>>> Function(
      List<Map<String, dynamic>> oldData,
      int currentVersion,
    ) migrationFunction,
  ) async {
    try {
      await LogMk.logInfo('スキーマバージョンチェック開始: 目標v$targetVersion', tag: 'DataManager.checkAndMigrateSchema');
      
      final migrated = await SharedMk.migrateData(
        storageKey,
        targetVersion,
        migrationFunction,
      );
      
      if (migrated) {
        await LogMk.logInfo('マイグレーション完了', tag: 'DataManager.checkAndMigrateSchema');
      } else {
        await LogMk.logDebug('マイグレーション不要', tag: 'DataManager.checkAndMigrateSchema');
      }
      
      return migrated;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('マイグレーションエラー', tag: 'DataManager.checkAndMigrateSchema', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// 現在のスキーマバージョンを取得
  /// 
  Future<int> getSchemaVersion() async {
    try {
      final version = await SharedMk.getSchemaVersion(storageKey);
      await LogMk.logDebug('スキーマバージョン: v$version', tag: 'DataManager.getSchemaVersion');
      return version;
    } catch (e) {
      await LogMk.logError('スキーマバージョン取得エラー', tag: 'DataManager.getSchemaVersion', error: e);
      return 0;
    }
  }

  /// ローカルストレージのサイズを取得
  /// 
  Future<int> getLocalStorageSize() async {
    try {
      final size = await SharedMk.getStorageSize();
      await LogMk.logDebug('ストレージサイズ: $sizeバイト', tag: 'DataManager.getLocalStorageSize');
      return size;
    } catch (e) {
      await LogMk.logError('ストレージサイズ取得エラー', tag: 'DataManager.getLocalStorageSize', error: e);
      return 0;
    }
  }

  /// 古いローカルデータをクリア
  /// 
  Future<int> clearOldLocalData(
    Duration ttl, {
    String? timestampField,
  }) async {
    try {
      final removed = await SharedMk.clearOldData(
        storageKey,
        ttl,
        timestampField: timestampField ?? lastModifiedField,
      );
      
      await LogMk.logInfo('古いデータクリア: $removed件削除', tag: 'DataManager.clearOldLocalData');
      return removed;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('古いデータクリアエラー', tag: 'DataManager.clearOldLocalData', error: error, stackTrace: stackTrace);
      return 0;
    }
  }

  /// ストレージサイズが制限を超えているかチェック
  /// 
  Future<bool> isLocalStorageOverLimit(int maxSize) async {
    try {
      final isOver = await SharedMk.isStorageOverLimit(maxSize);
      
      if (isOver) {
        await LogMk.logWarning('ストレージ容量超過', tag: 'DataManager.isLocalStorageOverLimit');
      }
      
      return isOver;
    } catch (e) {
      await LogMk.logError('ストレージ容量チェックエラー', tag: 'DataManager.isLocalStorageOverLimit', error: e);
      return false;
    }
  }
}

