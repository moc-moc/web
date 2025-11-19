import 'dart:async';
import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// リアルタイム同期機能のMixin
/// 
/// Firestoreのリアルタイム監視機能を提供
mixin FirestoreRealtimeMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  String get storageKey;
  T Function(Map<String, dynamic> data) get fromFirestore;
  Map<String, dynamic> Function(T item) get toJson;
  StreamSubscription<List<T>>? get _realtimeSyncSubscription;
  bool get _isRealtimeSyncActive;
  String? get _currentUserId;
  set _realtimeSyncSubscription(StreamSubscription<List<T>>? value);
  set _isRealtimeSyncActive(bool value);
  set _currentUserId(String? value);
  Stream<List<T>> watchAll(String userId);

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
}

