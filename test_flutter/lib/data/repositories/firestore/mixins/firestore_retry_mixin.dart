import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/retry_queue_service.dart';
import 'package:test_flutter/data/services/retry_item.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';
import 'package:test_flutter/data/services/lock_service.dart';
import 'package:async_locks/async_locks.dart';

/// リトライ機能とキュー管理のMixin
/// 
/// リトライ機能付きのCRUD操作とキュー管理を提供
mixin FirestoreRetryMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  String get storageKey;
  String get idField;
  String get lastModifiedField;
  Map<String, dynamic> Function(T item) get toFirestore;
  Map<String, dynamic> Function(T item) get toJson;
  T Function(Map<String, dynamic> json) get fromJson;
  Lock get _queueLock;
  String _getItemId(T item);
  Future<bool> add(String userId, T item);
  Future<bool> update(String userId, T item);
  Future<bool> delete(String userId, String id);

  /// リトライ機能付きの追加
  /// 
  Future<bool> addWithRetry(String userId, T item) async {
    try {
      await LogMk.logInfo('🔄 リトライ付き追加開始: ${_getItemId(item)}');
      
      // 1. Firestoreに追加を試行
      final data = toFirestore(item);
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final itemId = _getItemId(item);
      final success = await FirestoreMk.saveDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        // 2. 成功したらローカルにも保存
        await SharedMk.addItemToSharedPrefs(
          storageKey,
          toJson(item),
          idField,
        );
        await LogMk.logInfo('✅ リトライ付き追加成功: $itemId');
        return true;
      } else {
        // 3. 失敗したらキューに追加
        await _addToRetryQueue(
          RetryType.add,
          userId,
          toJson(item),
        );
        await LogMk.logWarning(' リトライ付き追加失敗 - キューに追加: $itemId');
        return false;
      }
    } catch (e) {
      // エラー時もキューに追加
      await _addToRetryQueue(
        RetryType.add,
        userId,
        toJson(item),
      );
      await LogMk.logError(' リトライ付き追加エラー - キューに追加: $e');
      return false;
    }
  }

  /// リトライ機能付きの更新
  /// 
  Future<bool> updateWithRetry(String userId, T item) async {
    try {
      await LogMk.logInfo('🔄 リトライ付き更新開始: ${_getItemId(item)}');
      
      // 1. Firestoreに更新を試行
      final data = toFirestore(item);
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final itemId = _getItemId(item);
      final success = await FirestoreMk.updateDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        // 2. 成功したらローカルにも更新
        await SharedMk.updateItemInSharedPrefs(
          storageKey,
          toJson(item),
          idField,
        );
        await LogMk.logInfo('✅ リトライ付き更新成功: $itemId');
        return true;
      } else {
        // 3. 失敗したらキューに追加
        await _addToRetryQueue(
          RetryType.update,
          userId,
          toJson(item),
        );
        await LogMk.logWarning(' リトライ付き更新失敗 - キューに追加: $itemId');
        return false;
      }
    } catch (e) {
      // エラー時もキューに追加
      await _addToRetryQueue(
        RetryType.update,
        userId,
        toJson(item),
      );
      await LogMk.logError(' リトライ付き更新エラー - キューに追加: $e');
      return false;
    }
  }

  /// リトライ機能付きの削除
  /// 
  Future<bool> deleteWithRetry(String userId, String id) async {
    try {
      await LogMk.logInfo('🔄 リトライ付き削除開始: $id');
      
      // 1. Firestoreから削除を試行
      final success = await FirestoreMk.deleteDocument(
        collectionPathBuilder(userId),
        id,
      );
      
      if (success) {
        // 2. 成功したらローカルからも削除
        await SharedMk.removeItemFromSharedPrefs(
          storageKey,
          id,
          idField,
        );
        await LogMk.logInfo('✅ リトライ付き削除成功: $id');
        return true;
      } else {
        // 3. 失敗したらキューに追加（削除用のデータを作成）
        final deleteData = {idField: id};
        await _addToRetryQueue(
          RetryType.delete,
          userId,
          deleteData,
        );
        await LogMk.logWarning(' リトライ付き削除失敗 - キューに追加: $id');
        return false;
      }
    } catch (e) {
      // エラー時もキューに追加
      final deleteData = {idField: id};
      await _addToRetryQueue(
        RetryType.delete,
        userId,
        deleteData,
      );
      await LogMk.logError(' リトライ付き削除エラー - キューに追加: $e');
      return false;
    }
  }

  /// リトライ機能付きの保存（upsert: 存在確認付き）
  /// 
  Future<bool> saveWithRetry(String userId, T item) async {
    try {
      final itemId = _getItemId(item);
      await LogMk.logInfo('🔄 Upsert開始: $itemId', tag: 'DataManager.saveWithRetry');
      
      // 1. Firestoreに存在するか確認
      final existsInFirestore = await FirestoreMk.documentExists(
        collectionPathBuilder(userId),
        itemId,
      );
      
      await LogMk.logDebug(
        'Firestore存在確認: $itemId → ${existsInFirestore ? "存在" : "未存在"}',
        tag: 'DataManager.saveWithRetry',
      );
      
      // 2. 存在に応じてaddまたはupdateを使用
      bool firestoreSuccess;
      if (existsInFirestore) {
        firestoreSuccess = await updateWithRetry(userId, item);
      } else {
        firestoreSuccess = await addWithRetry(userId, item);
      }
      
      await LogMk.logInfo(
        '✅ Upsert完了: $itemId (${existsInFirestore ? "update" : "add"})',
        tag: 'DataManager.saveWithRetry',
      );
      
      return firestoreSuccess;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(
        e,
        defaultType: ErrorType.sync,
        stackTrace: stackTrace,
      );
      await LogMk.logError(
        'Upsertエラー',
        tag: 'DataManager.saveWithRetry',
        error: error,
        stackTrace: stackTrace,
      );
      
      // エラー時もキューに追加
      await _addToRetryQueue(
        RetryType.add,
        userId,
        toJson(item),
      );
      
      return false;
    }
  }

  /// userId自動取得版のsaveWithRetry
  /// 
  Future<bool> saveWithRetryAuth(T item) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await saveWithRetry(userId, item);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(
        e,
        defaultType: ErrorType.authentication,
        stackTrace: stackTrace,
      );
      await LogMk.logError(
        'saveWithRetryAuth: エラー',
        tag: 'DataManager.saveWithRetryAuth',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// キュー処理（Phase 4-5の核心機能）
  /// 
  Future<int> processQueue(String userId) async {
    
    // Phase 1: 並行実行保護
    return await LockMk.withLock(_queueLock, () async {
      try {
        await LogMk.logInfo('キュー処理開始: $userId', tag: 'DataManager.processQueue');
        
        // 1. 再試行可能なアイテムを取得
        final retryableItems = await QueMk.getRetryableItems();
        await LogMk.logDebug('再試行可能アイテム: ${retryableItems.length}件', tag: 'DataManager.processQueue');
        
        int processedCount = 0;
        
        // 2. 各アイテムを処理
        for (final item in retryableItems) {
          try {
            // 処理中にマーク
            await QueMk.updateQueueItemStatus(item.id, RetryStatus.processing);
            
            bool success = false;
            
            // アイテムのタイプに応じて処理
            switch (item.type) {
              case RetryType.add:
                success = await _processAddItem(userId, item);
                break;
              case RetryType.update:
                success = await _processUpdateItem(userId, item);
                break;
              case RetryType.delete:
                success = await _processDeleteItem(userId, item);
                break;
            }
            
            if (success) {
              // 成功したらキューから削除
              await QueMk.removeFromQueue(item.id);
              await LogMk.logDebug('キューアイテム処理成功: ${item.id}', tag: 'DataManager.processQueue');
              processedCount++;
            } else {
              // 失敗したらステータスを更新
              await QueMk.updateQueueItemStatus(
                item.id,
                RetryStatus.failed,
                errorMessage: '処理に失敗しました',
              );
              await LogMk.logWarning('キューアイテム処理失敗: ${item.id}', tag: 'DataManager.processQueue');
            }
          } catch (e, stackTrace) {
            // エラー時もステータスを更新
            await QueMk.updateQueueItemStatus(
              item.id,
              RetryStatus.failed,
              errorMessage: e.toString(),
            );
            await LogMk.logError(
              'キューアイテム処理エラー: ${item.id}',
              tag: 'DataManager.processQueue',
              error: e,
              stackTrace: stackTrace,
            );
          }
        }
        
        await LogMk.logInfo('キュー処理完了: $processedCount/${retryableItems.length}件', tag: 'DataManager.processQueue');
        return processedCount;
      } catch (e, stackTrace) {
        final error = DataManagerError.handleError(
          e,
          defaultType: ErrorType.sync,
          stackTrace: stackTrace,
        );
        await LogMk.logError(
          'キュー処理エラー: $userId',
          tag: 'DataManager.processQueue',
          error: error,
          stackTrace: stackTrace,
        );
        return 0;
      }
    });
  }

  /// リトライキューにアイテムを追加
  /// 
  Future<void> _addToRetryQueue(RetryType type, String userId, Map<String, dynamic> data) async {
    final retryItem = RetryItem(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      userId: userId,
      data: data,
      timestamp: DateTime.now(),
    );
    
    await QueMk.addToQueue(retryItem);
  }

  /// 追加アイテムを処理
  /// 
  Future<bool> _processAddItem(String userId, RetryItem item) async {
    try {
      // Firestoreに追加
      final data = Map<String, dynamic>.from(item.data);
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final itemId = data[idField] as String;
      final success = await FirestoreMk.saveDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        // ローカルにも保存
        await SharedMk.addItemToSharedPrefs(
          storageKey,
          item.data,
          idField,
        );
        return true;
      }
      return false;
    } catch (e) {
      await LogMk.logError(' 追加アイテム処理エラー: $e');
      return false;
    }
  }

  /// 更新アイテムを処理
  /// 
  Future<bool> _processUpdateItem(String userId, RetryItem item) async {
    try {
      // Firestoreに更新
      final data = Map<String, dynamic>.from(item.data);
      data[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final itemId = data[idField] as String;
      final success = await FirestoreMk.updateDocument(
        collectionPathBuilder(userId),
        itemId,
        data,
      );
      
      if (success) {
        // ローカルにも更新
        await SharedMk.updateItemInSharedPrefs(
          storageKey,
          item.data,
          idField,
        );
        return true;
      }
      return false;
    } catch (e) {
      await LogMk.logError(' 更新アイテム処理エラー: $e');
      return false;
    }
  }

  /// 削除アイテムを処理
  /// 
  Future<bool> _processDeleteItem(String userId, RetryItem item) async {
    try {
      // Firestoreから削除
      final itemId = item.data[idField] as String;
      final success = await FirestoreMk.deleteDocument(
        collectionPathBuilder(userId),
        itemId,
      );
      
      if (success) {
        // ローカルからも削除
        await SharedMk.removeItemFromSharedPrefs(
          storageKey,
          itemId,
          idField,
        );
        return true;
      }
      return false;
    } catch (e) {
      await LogMk.logError(' 削除アイテム処理エラー: $e');
      return false;
    }
  }

  /// キュー統計を取得
  /// 戻り値: { pending, processing, success, failed, total }
  Future<Map<String, int>> getQueueStats() async {
    try {
      final items = await QueMk.getQueueItems();
      final stats = <String, int>{
        'pending': 0,
        'processing': 0,
        'success': 0,
        'failed': 0,
        'total': 0,
      };
      for (final item in items) {
        switch (item.status) {
          case RetryStatus.pending:
            stats['pending'] = (stats['pending'] ?? 0) + 1;
            break;
          case RetryStatus.processing:
            stats['processing'] = (stats['processing'] ?? 0) + 1;
            break;
          case RetryStatus.success:
            stats['success'] = (stats['success'] ?? 0) + 1;
            break;
          case RetryStatus.failed:
            stats['failed'] = (stats['failed'] ?? 0) + 1;
            break;
        }
      }
      stats['total'] = items.length;
      await LogMk.logInfo('📊 キュー統計: $stats');
      return stats;
    } catch (e) {
      await LogMk.logError(' キュー統計取得エラー: $e');
      return const {
        'pending': 0,
        'processing': 0,
        'success': 0,
        'failed': 0,
        'total': 0,
      };
    }
  }

  /// キューを全クリア
  Future<void> clearQueue() async {
    try {
      await QueMk.clearQueue();
      await LogMk.logInfo('🧹 キューをクリアしました');
    } catch (e) {
      await LogMk.logError(' キュークリアエラー: $e');
    }
  }

  /// 失敗した操作を再試行（内部的にprocessQueueを実行）
  Future<int> retryFailedOperations(String userId) async {
    try {
      final processed = await processQueue(userId);
      await LogMk.logInfo('🔁 失敗操作の再試行完了: $processed 件');
      return processed;
    } catch (e) {
      await LogMk.logError(' 再試行エラー: $e');
      return 0;
    }
  }
}

