import 'dart:async';
import 'package:test_flutter/data/services/retry_queue_service.dart';
import 'package:test_flutter/data/sources/network_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// バックグラウンド処理統合のMixin
/// 
/// バックグラウンド同期機能を提供
mixin FirestoreBackgroundMixin<T> {
  // 必要なフィールドとメソッド
  StreamSubscription<NetworkStatus>? get _networkStatusSubscription;
  bool get _isBackgroundSyncActive;
  set _networkStatusSubscription(StreamSubscription<NetworkStatus>? value);
  set _isBackgroundSyncActive(bool value);
  Future<int> processQueue(String userId);

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
}

