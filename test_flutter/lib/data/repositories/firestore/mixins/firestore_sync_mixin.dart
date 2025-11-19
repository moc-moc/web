import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/services/sync_service.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';
import 'package:test_flutter/data/services/lock_service.dart';
import 'package:async_locks/async_locks.dart';

/// 同期機能のMixin
/// 
/// FirestoreとSharedPreferencesの同期機能を提供
mixin FirestoreSyncMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  String get storageKey;
  String get idField;
  String get lastModifiedField;
  T Function(Map<String, dynamic> data) get fromFirestore;
  T Function(Map<String, dynamic> json) get fromJson;
  Map<String, dynamic> Function(T item) get toJson;
  Map<String, dynamic> Function(T item) get toFirestore;
  Lock get _syncLock;

  /// FirestoreとSharedPreferencesを同期
  /// 
  Future<List<T>> sync(String userId) async {
    // Phase 1: 並行実行保護
    return await LockMk.withLock(_syncLock, () async {
      try {
        // 1. 最終同期時刻を取得
        final lastSyncTime = await SharedMk.getLastSyncTimeFromSharedPrefs(storageKey);
        
        // 2. ローカルデータを事前取得
        final localDataList = await SharedMk.getAllFromSharedPrefs(storageKey);
        
        // 3. Firestoreから差分データを取得
        List<Map<String, dynamic>> remoteDataList;
        if (lastSyncTime != null) {
          // lastSyncTimeがあれば差分同期を試みる
          try {
            remoteDataList = await FirestoreMk.fetchModifiedSince(
              collectionPathBuilder(userId),
              lastSyncTime,
            );
            await LogMk.logInfo('📥 差分データ取得成功: ${remoteDataList.length}件');
          } catch (e) {
            // 差分同期が失敗した場合は全データ取得にフォールバック
            await LogMk.logWarning('差分同期失敗、全データ取得にフォールバック: $e');
            remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
            await LogMk.logInfo('📥 全データ取得: ${remoteDataList.length}件');
          }
        } else {
          // 初回同期の場合は全データを取得
          remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
          await LogMk.logInfo('📥 初回同期: 全データ取得 ${remoteDataList.length}件');
        }
        
        // 4. データをマージ（競合解決）
        final mergedDataList = SyncMk.mergeData(
          localDataList,
          remoteDataList,
          idField,
          lastModifiedField,
        );
        
        // 5. マージ結果をJSON形式に変換（DataMk層の汎用関数を使用）
        final jsonDataList = SyncMk.convertToJsonFormat<T>(
          mergedDataList,
          fromFirestore,
          toJson,
          fromJson,
        );
        
        // 6. JSON形式でローカルに保存
        await SharedMk.saveAllToSharedPrefs(storageKey, jsonDataList);
        
        // 7. ローカルの新しいデータをFirestoreにプッシュ（削除：Firestore優先のため）
        // Firestore優先にするため、この処理は削除しました。
        // tracking完了時など、明示的に保存する場合はsaveWithRetry()を使用してください。
        
        // 8. 最終同期時刻を更新
        await SharedMk.setLastSyncTimeToSharedPrefs(storageKey, DateTime.now());
        
        // 9. モデルに変換して返す
        final items = jsonDataList.map((json) => fromJson(json)).toList();
        
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

  /// 強制同期（可能であれば差分同期を試みる）
  /// 
  Future<List<T>> forceSync(String userId) async {
    try {
      await LogMk.logInfo('🔄 強制同期開始: $userId');
      
      // 最終同期時刻を取得
      final lastSyncTime = await SharedMk.getLastSyncTimeFromSharedPrefs(storageKey);
      
      List<Map<String, dynamic>> remoteDataList;
      
      // 可能であれば差分同期を試みる
      if (lastSyncTime != null) {
        try {
          // 最終同期時刻以降のすべての変更を取得
          remoteDataList = await FirestoreMk.fetchModifiedSince(
            collectionPathBuilder(userId),
            lastSyncTime,
          );
          await LogMk.logInfo('📥 差分データ取得: ${remoteDataList.length}件');
        } catch (e) {
          // 差分同期が失敗した場合は全データ取得
          await LogMk.logWarning('差分同期失敗、全データ取得: $e');
          remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
          await LogMk.logInfo('📥 Firestore全データ取得: ${remoteDataList.length}件');
        }
      } else {
        // 初回同期の場合は全データを取得
        remoteDataList = await FirestoreMk.fetchCollection(collectionPathBuilder(userId));
        await LogMk.logInfo('📥 Firestore全データ取得: ${remoteDataList.length}件');
      }
      
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
}

