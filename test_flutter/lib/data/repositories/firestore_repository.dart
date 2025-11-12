import 'dart:async';
import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/services/sync_service.dart';
import 'package:test_flutter/data/services/retry_queue_service.dart';
import 'package:test_flutter/data/services/retry_item.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';
import 'package:test_flutter/data/services/lock_service.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/network_source.dart';
import 'package:test_flutter/data/sources/event_source.dart';
import 'package:async_locks/async_locks.dart';

/// Firestore + SharedPreferences統合データマネージャー
/// 
/// FirestoreとSharedPreferencesの両方を必須とし、
/// データごとに設定を渡すだけで、CRUD・同期・リトライが全て自動で動く
/// 汎用的なデータ管理機能を提供する
/// 
/// **必須ストレージ**: FirestoreとSharedPreferencesの両方
/// **対応データモデル**: Freezedを使用したモデル
/// **段階的実装**: Phase 1〜6で段階的に機能を追加
/// 
class FirestoreDataManager<T> {
  /// Firestoreコレクションパスを生成する関数
  final String Function(String userId) collectionPathBuilder;
  
  /// Firestoreデータをモデルに変換する関数
  final T Function(Map<String, dynamic> data) fromFirestore;
  
  /// モデルをFirestoreデータに変換する関数
  final Map<String, dynamic> Function(T item) toFirestore;
  
  /// IDフィールド名（デフォルト: 'id'）
  final String idField;
  
  /// 最終更新フィールド名（デフォルト: 'lastModified'）
  final String lastModifiedField;

  /// SharedPreferencesのキー（必須パラメータ）
  final String storageKey;
  
  /// モデルをJSONに変換する関数（必須パラメータ）
  final Map<String, dynamic> Function(T item) toJson;
  
  /// JSONをモデルに変換する関数（必須パラメータ）
  final T Function(Map<String, dynamic> json) fromJson;

  // Phase 1: 並行実行制御用のロック
  final Lock _syncLock = Lock();
  final Lock _queueLock = Lock();

  // Phase 2: リアルタイム同期用
  StreamSubscription<List<T>>? _realtimeSyncSubscription;
  bool _isRealtimeSyncActive = false;
  String? _currentUserId;

  // Phase 5: バックグラウンド処理用
  StreamSubscription<NetworkStatus>? _networkStatusSubscription;
  bool _isBackgroundSyncActive = false;

  /// コンストラクタ
  /// 
  FirestoreDataManager({
    required this.collectionPathBuilder,
    required this.fromFirestore,
    required this.toFirestore,
    required this.storageKey,
    required this.toJson,
    required this.fromJson,
    this.idField = 'id',
    this.lastModifiedField = 'lastModified',
  });

  // ===== Phase 1: CRUD操作 =====

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
      
      await LogMk.logInfo('✅ アイテム取得完了: ${items.length}件');
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
      
      await LogMk.logInfo('✅ アイテム取得完了: $id');
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

  // ===== Phase 2: ローカル操作 =====

  /// ローカルから全アイテムを取得
  /// 
  Future<List<T>> getLocalAll() async {
    try {
      // 1. ローカルデータを取得
      final dataList = await SharedMk.getAllFromSharedPrefs(storageKey);
      
      // 2. 各データをモデルに変換
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromJson(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(' ローカルデータ変換エラー: $e');
          // 変換に失敗したアイテムはスキップ
        }
      }
      
      await LogMk.logInfo('✅ ローカルアイテム取得完了: ${items.length}件');
      return items;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム取得エラー: $e');
      return [];
    }
  }

  /// ローカルから指定IDのアイテムを取得
  /// 
  Future<T?> getLocalById(String id) async {
    try {
      // 1. ローカルからデータを取得
      final data = await SharedMk.getItemFromSharedPrefs(
        storageKey,
        id,
        idField,
      );
      
      if (data == null) {
        await LogMk.logInfo('ℹ️ ローカルアイテムが見つかりません: $id');
        return null;
      }
      
      // 2. モデルに変換
      final item = fromJson(data);
      
      await LogMk.logInfo('✅ ローカルアイテム取得完了: $id');
      return item;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム取得エラー: $e');
      return null;
    }
  }

  /// ローカルに全アイテムを保存
  /// 
  Future<void> saveLocal(List<T> items) async {
    try {
      // 1. 各アイテムをMapに変換
      final dataList = items.map((item) => toJson(item)).toList();
      
      // 2. ローカルに保存
      await SharedMk.saveAllToSharedPrefs(storageKey, dataList);
      
      await LogMk.logInfo('✅ ローカルアイテム保存完了: ${items.length}件');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム保存エラー: $e');
    }
  }

  /// ローカルにアイテムを追加
  /// 
  Future<void> addLocal(T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toJson(item);
      
      // 2. ローカルに追加
      await SharedMk.addItemToSharedPrefs(
        storageKey,
        data,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム追加完了: ${_getItemId(item)}');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム追加エラー: $e');
    }
  }

  /// ローカルのアイテムを更新
  /// 
  Future<void> updateLocal(T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toJson(item);
      
      // 2. ローカルを更新
      await SharedMk.updateItemInSharedPrefs(
        storageKey,
        data,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム更新完了: ${_getItemId(item)}');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム更新エラー: $e');
    }
  }

  /// ローカルからアイテムを削除
  /// 
  Future<void> deleteLocal(String id) async {
    try {
      // 1. ローカルから削除
      await SharedMk.removeItemFromSharedPrefs(
        storageKey,
        id,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム削除完了: $id');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム削除エラー: $e');
    }
  }

  /// ローカルデータを全てクリア
  /// 
  Future<void> clearLocal() async {
    try {
      // 1. ローカルデータをクリア
      await SharedMk.removeFromSharedPrefs(storageKey);
      
      await LogMk.logInfo('✅ ローカルデータクリア完了: $storageKey');
    } catch (e) {
      await LogMk.logError(' ローカルデータクリアエラー: $e');
    }
  }

  /// ローカルのアイテム数を取得
  /// 
  Future<int> getLocalCount() async {
    try {
      // 1. ローカルのアイテム数を取得
      final count = await SharedMk.getListCount(storageKey);
      
      await LogMk.logInfo('✅ ローカルアイテム数取得完了: $count件');
      return count;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム数取得エラー: $e');
      return 0;
    }
  }

  // ===== Phase 3: 同期機能 =====

  /// FirestoreとSharedPreferencesを同期
  /// 
  Future<List<T>> sync(String userId) async {
    // Phase 1: 並行実行保護
    return await LockMk.withLock(_syncLock, () async {
      try {
        await LogMk.logInfo('同期開始: $userId', tag: 'DataManager.sync');
        
        // 1. 最終同期時刻を取得
        final lastSyncTime = await SharedMk.getLastSyncTimeFromSharedPrefs(storageKey);
        await LogMk.logDebug('最終同期時刻: $lastSyncTime', tag: 'DataManager.sync');
        
        // 2. ローカルデータを事前取得
        final localDataList = await SharedMk.getAllFromSharedPrefs(storageKey);
        await LogMk.logDebug('ローカルデータ取得: ${localDataList.length}件', tag: 'DataManager.sync');
        
        // 3. Firestoreから差分データを取得
        List<Map<String, dynamic>> remoteDataList;
        if (lastSyncTime != null && localDataList.isNotEmpty) {
          // ローカルデータが存在する場合は差分同期
          remoteDataList = await FirestoreMk.fetchModifiedSince(
            collectionPathBuilder(userId),
            lastSyncTime,
          );
          await LogMk.logDebug('Firestore差分データ取得: ${remoteDataList.length}件', tag: 'DataManager.sync');
        } else {
          // 初回同期またはローカルデータが空の場合は全データを取得
          remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
          await LogMk.logDebug('Firestore全データ取得: ${remoteDataList.length}件', tag: 'DataManager.sync');
        }
        
        // 4. データをマージ（競合解決）
        final mergedDataList = SyncMk.mergeData(
          localDataList,
          remoteDataList,
          idField,
          lastModifiedField,
        );
        await LogMk.logDebug('データマージ完了: ${mergedDataList.length}件', tag: 'DataManager.sync');
        
        // 5. マージ結果をJSON形式に変換（DataMk層の汎用関数を使用）
        final jsonDataList = SyncMk.convertToJsonFormat<T>(
          mergedDataList,
          fromFirestore,
          toJson,
          fromJson,
        );
        await LogMk.logDebug('JSON変換完了: ${jsonDataList.length}件', tag: 'DataManager.sync');
        
        // 6. JSON形式でローカルに保存
        await SharedMk.saveAllToSharedPrefs(storageKey, jsonDataList);
        
        // 7. ローカルの新しいデータをFirestoreにプッシュ（削除：Firestore優先のため）
        // Firestore優先にするため、この処理は削除しました。
        // tracking完了時など、明示的に保存する場合はsaveWithRetry()を使用してください。
        
        // 8. 最終同期時刻を更新
        await SharedMk.setLastSyncTimeToSharedPrefs(storageKey, DateTime.now());
        
        // 9. モデルに変換して返す
        final items = jsonDataList.map((json) => fromJson(json)).toList();
        
        await LogMk.logInfo('同期完了: ${items.length}件', tag: 'DataManager.sync');
        return items;
      } catch (e, stackTrace) {
        final error = DataManagerError.handleError(
          e,
          defaultType: ErrorType.sync,
          stackTrace: stackTrace,
        );
        await LogMk.logError(
          '同期エラー: $userId',
          tag: 'DataManager.sync',
          error: error,
          stackTrace: stackTrace,
        );
        return [];
      }
    });
  }

  /// 強制同期（全データ取得）
  /// 
  Future<List<T>> forceSync(String userId) async {
    try {
      await LogMk.logInfo('🔄 強制同期開始: $userId');
      
      // 1. Firestoreから全データを取得
      final remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
      await LogMk.logInfo('📥 Firestore全データ取得: ${remoteDataList.length}件');
      
      // 2. JSON形式に変換（DataMk層の汎用関数を使用）
      final jsonDataList = SyncMk.convertToJsonFormat<T>(
        remoteDataList,
        fromFirestore,
        toJson,
        fromJson,
      );
      
      // 3. ローカルに保存
      await SharedMk.saveAllToSharedPrefs(storageKey, jsonDataList);
      
      // 4. 最終同期時刻を更新
      await SharedMk.setLastSyncTimeToSharedPrefs(storageKey, DateTime.now());
      
      // 5. モデルに変換して返す
      final items = jsonDataList.map((json) => fromJson(json)).toList();
      
      await LogMk.logInfo('✅ 強制同期完了: ${items.length}件');
      return items;
    } catch (e) {
      await LogMk.logError(' 強制同期エラー: $e');
      return [];
    }
  }

  /// ローカルの変更をFirestoreにプッシュ
  /// 
  Future<int> pushLocalChanges(String userId) async {
    try {
      await LogMk.logInfo('📤 ローカル変更プッシュ開始: $userId');
      
      // 1. ローカルデータを取得
      final localDataList = await SharedMk.getAllFromSharedPrefs(storageKey);
      await LogMk.logInfo('📱 ローカルデータ取得: ${localDataList.length}件');
      
      int successCount = 0;
      
      // 2. 各アイテムをFirestoreに保存
      for (final data in localDataList) {
        try {
          final itemId = data[idField] as String?;
          if (itemId == null || itemId.isEmpty) {
            await LogMk.logWarning(' アイテムIDが無効です: $data');
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
            await LogMk.logInfo('✅ プッシュ成功: $itemId');
          } else {
            await LogMk.logError(' プッシュ失敗: $itemId');
          }
        } catch (e) {
          await LogMk.logError(' アイテムプッシュエラー: $e');
        }
      }
      
      await LogMk.logInfo('✅ ローカル変更プッシュ完了: $successCount/${localDataList.length}件');
      return successCount;
    } catch (e) {
      await LogMk.logError(' ローカル変更プッシュエラー: $e');
      return 0;
    }
  }

  /// 最終同期時刻を取得
  /// 
  Future<DateTime?> getLastSyncTime() async {
    try {
      final lastSyncTime = await SharedMk.getLastSyncTimeFromSharedPrefs(storageKey);
      await LogMk.logInfo('📅 最終同期時刻取得: $lastSyncTime');
      return lastSyncTime;
    } catch (e) {
      await LogMk.logError(' 最終同期時刻取得エラー: $e');
      return null;
    }
  }

  /// 同期状態をリセット
  /// 
  Future<void> resetSyncState() async {
    try {
      await LogMk.logInfo('🔄 同期状態リセット開始');
      
      // 1. ローカルデータをクリア
      await SharedMk.removeFromSharedPrefs(storageKey);
      
      // 2. 最終同期時刻をクリア
      await SharedMk.removeFromSharedPrefs('${storageKey}_last_sync');
      
      await LogMk.logInfo('✅ 同期状態リセット完了');
    } catch (e) {
      await LogMk.logError(' 同期状態リセットエラー: $e');
    }
  }

  // ===== Phase 4-5: リトライ機能とキュー管理 =====

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

  // ===== ヘルパーメソッド =====

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

  /// アイテムからIDを取得
  /// 
  /// リフレクションを使わず、toFirestore()でMapに変換してからIDを取得
  /// 
  String _getItemId(T item) {
    final data = toFirestore(item);
    final id = data[idField] as String?;
    
    if (id == null || id.isEmpty) {
      throw Exception('アイテムのIDが取得できませんでした。$idFieldフィールドを確認してください。');
    }
    
    return id;
  }

  // 削除：Firestore優先にするため、_getLocalNewerItems()関数は不要
  // tracking完了時など、明示的に保存する場合はsaveWithRetry()を使用してください。

  /// ===== Phase 6: キュー統計と管理 =====

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

  // ===== Phase 2: リアルタイム同期機能 =====

  /// 全アイテムのリアルタイム監視
  /// 
  Stream<List<T>> watchAll(String userId) {
    try {
      return FirestoreMk.watchCollection(collectionPathBuilder(userId))
          .map((dataList) {
            final items = <T>[];
            for (final data in dataList) {
              try {
                final item = fromFirestore(data);
                items.add(item);
              } catch (e) {
                LogMk.logWarning('watchAll: データ変換エラー: $e', tag: 'DataManager.watchAll');
              }
            }
            return items;
          });
    } catch (e) {
      LogMk.logError('watchAll: エラー: $userId', tag: 'DataManager.watchAll', error: e);
      return Stream.value([]);
    }
  }

  /// 指定IDのアイテムをリアルタイム監視
  /// 
  Stream<T?> watchById(String userId, String id) {
    try {
      return FirestoreMk.watchDocument(collectionPathBuilder(userId), id)
          .map((data) {
            if (data == null) return null;
            try {
              return fromFirestore(data);
            } catch (e) {
              LogMk.logWarning('watchById: データ変換エラー: $e', tag: 'DataManager.watchById');
              return null;
            }
          });
    } catch (e) {
      LogMk.logError('watchById: エラー: $userId/$id', tag: 'DataManager.watchById', error: e);
      return Stream.value(null);
    }
  }

  /// リアルタイム同期を開始
  /// 
  Future<void> startRealtimeSync(String userId) async {
    if (_isRealtimeSyncActive) {
      await LogMk.logInfo('リアルタイム同期は既に開始しています', tag: 'DataManager.startRealtimeSync');
      return;
    }

    try {
      await LogMk.logInfo('リアルタイム同期開始: $userId', tag: 'DataManager.startRealtimeSync');
      
      _currentUserId = userId;
      _isRealtimeSyncActive = true;

      // ユーザーIDの変更を監視して自動停止
      AuthMk.watchUserId().listen((newUserId) {
        if (newUserId != _currentUserId) {
          LogMk.logInfo('ユーザー切替検知、リアルタイム同期を停止', tag: 'DataManager.startRealtimeSync');
          stopRealtimeSync();
        }
      });

      // リアルタイム同期開始
      _realtimeSyncSubscription = watchAll(userId).listen(
        (items) async {
          try {
            // ローカルに保存
            final dataList = items.map((item) => toJson(item)).toList();
            await SharedMk.saveAllToSharedPrefs(storageKey, dataList);
            await LogMk.logDebug('リアルタイム同期: ${items.length}件保存', tag: 'DataManager.startRealtimeSync');
          } catch (e) {
            await LogMk.logError('リアルタイム同期保存エラー', tag: 'DataManager.startRealtimeSync', error: e);
          }
        },
        onError: (error) {
          LogMk.logError('リアルタイム同期エラー', tag: 'DataManager.startRealtimeSync', error: error);
        },
      );

      await LogMk.logInfo('リアルタイム同期開始完了', tag: 'DataManager.startRealtimeSync');
    } catch (e, stackTrace) {
      _isRealtimeSyncActive = false;
      final error = DataManagerError.handleError(e, defaultType: ErrorType.sync, stackTrace: stackTrace);
      await LogMk.logError('リアルタイム同期開始エラー', tag: 'DataManager.startRealtimeSync', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// リアルタイム同期を停止
  /// 
  Future<void> stopRealtimeSync() async {
    if (!_isRealtimeSyncActive) {
      await LogMk.logInfo('リアルタイム同期は開始していません', tag: 'DataManager.stopRealtimeSync');
      return;
    }

    try {
      await LogMk.logInfo('リアルタイム同期停止', tag: 'DataManager.stopRealtimeSync');
      
      await _realtimeSyncSubscription?.cancel();
      _realtimeSyncSubscription = null;
      _isRealtimeSyncActive = false;
      _currentUserId = null;

      await LogMk.logInfo('リアルタイム同期停止完了', tag: 'DataManager.stopRealtimeSync');
    } catch (e) {
      await LogMk.logError('リアルタイム同期停止エラー', tag: 'DataManager.stopRealtimeSync', error: e);
    }
  }

  // ===== Phase 2: 認証統合メソッド =====

  /// userId自動取得版のadd
  /// 
  Future<bool> addWithAuth(T item) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await add(userId, item);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('addWithAuth: エラー', tag: 'DataManager.addWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のupdate
  /// 
  Future<bool> updateWithAuth(T item) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await update(userId, item);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('updateWithAuth: エラー', tag: 'DataManager.updateWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のdelete
  /// 
  Future<bool> deleteWithAuth(String id) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await delete(userId, id);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('deleteWithAuth: エラー', tag: 'DataManager.deleteWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のsync
  /// 
  Future<List<T>> syncWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await sync(userId);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('syncWithAuth: エラー', tag: 'DataManager.syncWithAuth', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// userId自動取得版のgetAll
  /// 
  Future<List<T>> getAllWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await getAll(userId);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('getAllWithAuth: エラー', tag: 'DataManager.getAllWithAuth', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  // ===== Phase 3: 高度なクエリ機能 =====

  /// クエリ条件付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithQuery(
    String userId, {
    Map<String, dynamic>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      await LogMk.logDebug(
        'クエリ取得開始: $userId',
        tag: 'DataManager.getAllWithQuery',
      );
      
      final dataList = await FirestoreMk.fetchWithAdvancedQuery(
        collectionPathBuilder(userId),
        whereConditions: whereConditions,
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'クエリ取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithQuery',
          );
        }
      }
      
      await LogMk.logInfo('クエリ取得完了: ${items.length}件', tag: 'DataManager.getAllWithQuery');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('クエリ取得エラー: $userId', tag: 'DataManager.getAllWithQuery', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// ページング付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithPagination(
    String userId,
    int pageSize,
    int pageNumber, {
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      await LogMk.logDebug(
        'ページング取得開始: $userId (page=$pageNumber, size=$pageSize)',
        tag: 'DataManager.getAllWithPagination',
      );
      
      final dataList = await FirestoreMk.fetchWithPagination(
        collectionPathBuilder(userId),
        pageSize,
        pageNumber,
        orderBy: orderBy,
        descending: descending,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'ページング取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithPagination',
          );
        }
      }
      
      await LogMk.logInfo('ページング取得完了: ${items.length}件', tag: 'DataManager.getAllWithPagination');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('ページング取得エラー: $userId', tag: 'DataManager.getAllWithPagination', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// ソート付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithSort(
    String userId,
    String orderBy, {
    bool descending = false,
    int? limit,
  }) async {
    try {
      await LogMk.logDebug(
        'ソート取得開始: $userId (orderBy=$orderBy, desc=$descending)',
        tag: 'DataManager.getAllWithSort',
      );
      
      final dataList = await FirestoreMk.fetchWithAdvancedQuery(
        collectionPathBuilder(userId),
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'ソート取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithSort',
          );
        }
      }
      
      await LogMk.logInfo('ソート取得完了: ${items.length}件', tag: 'DataManager.getAllWithSort');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('ソート取得エラー: $userId', tag: 'DataManager.getAllWithSort', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// カーソルベースのページング
  /// 
  Future<Map<String, dynamic>> getAllWithCursor(
    String userId,
    int limit, {
    Map<String, dynamic>? startAfterDoc,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      await LogMk.logDebug(
        'カーソルページング取得開始: $userId (limit=$limit)',
        tag: 'DataManager.getAllWithCursor',
      );
      
      final result = await FirestoreMk.fetchWithCursor(
        collectionPathBuilder(userId),
        limit,
        startAfterDoc: startAfterDoc,
        orderBy: orderBy ?? idField,
        descending: descending,
      );
      
      final dataList = result['data'] as List<Map<String, dynamic>>;
      final items = <T>[];
      
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'カーソルページング: データ変換エラー: $e',
            tag: 'DataManager.getAllWithCursor',
          );
        }
      }
      
      await LogMk.logInfo('カーソルページング取得完了: ${items.length}件', tag: 'DataManager.getAllWithCursor');
      
      return {
        'items': items,
        'lastDoc': result['lastDoc'],
        'hasMore': result['hasMore'],
      };
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('カーソルページング取得エラー: $userId', tag: 'DataManager.getAllWithCursor', error: error, stackTrace: stackTrace);
      return {
        'items': <T>[],
        'lastDoc': null,
        'hasMore': false,
      };
    }
  }

  // ===== Phase 3: 部分更新機能 =====

  /// 部分更新（指定フィールドのみ）
  /// 
  Future<bool> updatePartial(
    String userId,
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      await LogMk.logDebug(
        '部分更新開始: $userId/$id (${fields.keys.length}フィールド)',
        tag: 'DataManager.updatePartial',
      );
      
      // lastModifiedを自動追加
      final updatedFields = Map<String, dynamic>.from(fields);
      updatedFields[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final success = await FirestoreMk.updateDocumentPartial(
        collectionPathBuilder(userId),
        id,
        updatedFields,
      );
      
      if (success) {
        await LogMk.logInfo('部分更新完了: $id', tag: 'DataManager.updatePartial');
      } else {
        await LogMk.logWarning('部分更新失敗: $id', tag: 'DataManager.updatePartial');
      }
      
      return success;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('部分更新エラー: $userId/$id', tag: 'DataManager.updatePartial', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のupdatePartial
  /// 
  Future<bool> updatePartialWithAuth(
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await updatePartial(userId, id, fields);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('updatePartialWithAuth: エラー', tag: 'DataManager.updatePartialWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  // ===== Phase 4: 変更追跡機能 =====

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

  // ===== Phase 4: スキーマバージョニング機能 =====

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

  // ===== Phase 5: バックグラウンド処理統合 =====

  /// バックグラウンド同期を開始
  /// 
  Future<void> startBackgroundSync(
    String userId, {
    Duration queueInterval = const Duration(seconds: 30),
    Duration networkCheckInterval = const Duration(seconds: 5),
  }) async {
    
    if (_isBackgroundSyncActive) {
      await LogMk.logInfo('バックグラウンド同期は既に開始しています', tag: 'DataManager.startBackgroundSync');
      return;
    }

    try {
      await LogMk.logInfo('バックグラウンド同期開始: $userId', tag: 'DataManager.startBackgroundSync');
      
      _isBackgroundSyncActive = true;

      // 1. 定期的なキュー処理を開始
      QueMk.startBackgroundProcessing(
        interval: queueInterval,
        processFunction: () async {
          await processQueue(userId);
        },
      );

      // 2. ネットワーク状態を監視
      _networkStatusSubscription = NetworkMk.watchNetworkStatus(
        checkInterval: networkCheckInterval,
      ).listen((status) async {
        if (status == NetworkStatus.online) {
          await LogMk.logInfo('ネットワーク復帰検知、キュー処理実行', tag: 'DataManager.startBackgroundSync');
          
          // オンライン復帰時にキュー処理を即座に実行
          try {
            await processQueue(userId);
          } catch (e) {
            await LogMk.logError('ネットワーク復帰時のキュー処理エラー', tag: 'DataManager.startBackgroundSync', error: e);
          }
        }
      });

      await LogMk.logInfo('バックグラウンド同期開始完了', tag: 'DataManager.startBackgroundSync');
    } catch (e, stackTrace) {
      _isBackgroundSyncActive = false;
      final error = DataManagerError.handleError(e, defaultType: ErrorType.sync, stackTrace: stackTrace);
      await LogMk.logError('バックグラウンド同期開始エラー', tag: 'DataManager.startBackgroundSync', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// バックグラウンド同期を停止
  /// 
  Future<void> stopBackgroundSync() async {
    if (!_isBackgroundSyncActive) {
      await LogMk.logInfo('バックグラウンド同期は開始していません', tag: 'DataManager.stopBackgroundSync');
      return;
    }

    try {
      await LogMk.logInfo('バックグラウンド同期停止', tag: 'DataManager.stopBackgroundSync');
      
      // キュー処理を停止
      QueMk.stopBackgroundProcessing();
      
      // ネットワーク監視を停止
      await _networkStatusSubscription?.cancel();
      _networkStatusSubscription = null;
      
      _isBackgroundSyncActive = false;

      await LogMk.logInfo('バックグラウンド同期停止完了', tag: 'DataManager.stopBackgroundSync');
    } catch (e) {
      await LogMk.logError('バックグラウンド同期停止エラー', tag: 'DataManager.stopBackgroundSync', error: e);
    }
  }

  /// バックグラウンド同期が実行中かどうか
  /// 
  bool isBackgroundSyncActive() {
    return _isBackgroundSyncActive;
  }

  // ===== Phase 6: イベント通知統合 =====

  /// 同期イベントを監視
  /// 
  Stream<EventData> watchSyncEvents() {
    return EventMk.watch(EventType.syncStarted)
        .mergeWith([
          EventMk.watch(EventType.syncCompleted),
          EventMk.watch(EventType.syncFailed),
        ]);
  }

  /// データ変更イベントを監視
  /// 
  Stream<EventData> watchDataEvents() {
    return EventMk.watch(EventType.dataAdded)
        .mergeWith([
          EventMk.watch(EventType.dataUpdated),
          EventMk.watch(EventType.dataDeleted),
        ]);
  }

  /// 全イベントを監視
  /// 
  Stream<EventData> watchAllEvents() {
    return EventMk.watchAll();
  }

  // ===== Phase 6: ローカルサイズ管理統合 =====

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

// Stream拡張: mergeWith
extension _StreamExtension<T> on Stream<T> {
  Stream<T> mergeWith(List<Stream<T>> others) {
    final controller = StreamController<T>.broadcast();
    final subscriptions = <StreamSubscription<T>>[];

    void addStream(Stream<T> stream) {
      subscriptions.add(stream.listen(
        (data) => controller.add(data),
        onError: (error) => controller.addError(error),
      ));
    }

    addStream(this);
    for (final stream in others) {
      addStream(stream);
    }

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }
}
