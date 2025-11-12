import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/data/services/retry_item.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// キュー管理の汎用的な基本関数
/// 
/// キュー管理、ネットワーク監視、リトライロジックに関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class QueMk {
  // ===== キュー管理関連 =====
  
  /// キューにアイテムを追加
  /// 
  /// 失敗した操作をキューに追加して後で再試行する
  /// キーはSharedPreferencesに保存される
  static Future<void> addToQueue(RetryItem item) async {
    try {
      final queue = await _getQueue();
      queue.add(item);
      await _saveQueue(queue);
      debugPrint('📤 送信キューに追加: ${item.type.name} (ID: ${item.id})');
    } catch (e) {
      debugPrint('❌ 送信キュー追加エラー: $e');
    }
  }
  
  /// キューからアイテムを削除
  /// 
  /// 指定されたIDのアイテムをキューから削除する
  static Future<void> removeFromQueue(String itemId) async {
    try {
      final queue = await _getQueue();
      queue.removeWhere((item) => item.id == itemId);
      await _saveQueue(queue);
      debugPrint('🗑️ 送信キューから削除: $itemId');
    } catch (e) {
      debugPrint('❌ 送信キュー削除エラー: $e');
    }
  }
  
  /// 送信待ちのアイテムを取得
  /// 
  /// ステータスがpendingまたは再試行可能なfailedのアイテムを取得する
  static Future<List<RetryItem>> getPendingItems() async {
    final queue = await _getQueue();
    return queue.where((item) => 
      item.status == RetryStatus.pending || 
      (item.status == RetryStatus.failed && item.isReadyForRetry)
    ).toList();
  }
  
  /// 再試行可能なアイテムを取得
  /// 
  /// 再試行条件を満たすアイテムを取得する
  static Future<List<RetryItem>> getRetryableItems() async {
    final queue = await _getQueue();
    return queue.where((item) => item.isReadyForRetry).toList();
  }
  
  /// キュー全体を取得
  /// 
  /// 保存されている全てのキューアイテムを取得する
  static Future<List<RetryItem>> getQueueItems() async {
    return await _getQueue();
  }
  
  /// アイテムのステータスを更新
  /// 
  /// 指定されたIDのアイテムのステータスを更新する
  static Future<void> updateQueueItemStatus(
    String itemId, 
    RetryStatus status, 
    {String? errorMessage}
  ) async {
    try {
      final queue = await _getQueue();
      final index = queue.indexWhere((item) => item.id == itemId);
      
      if (index != -1) {
        RetryItem updatedItem;
        switch (status) {
          case RetryStatus.processing:
            updatedItem = queue[index].markAsProcessing();
            break;
          case RetryStatus.success:
            updatedItem = queue[index].markAsSuccess();
            break;
          case RetryStatus.failed:
            updatedItem = queue[index].markAsFailed(errorMessage ?? 'Unknown error');
            break;
          case RetryStatus.pending:
            updatedItem = queue[index].markForRetry();
            break;
        }
        
        queue[index] = updatedItem;
        await _saveQueue(queue);
        debugPrint('🔄 送信キューアイテム更新: $itemId -> ${status.name}');
      }
    } catch (e) {
      debugPrint('❌ 送信キュー更新エラー: $e');
    }
  }
  
  /// 成功したアイテムをクリーンアップ
  /// 
  /// ステータスがsuccessのアイテムをキューから削除する
  static Future<void> cleanupSuccessItems() async {
    try {
      final queue = await _getQueue();
      final beforeCount = queue.length;
      
      // 成功したアイテムを削除
      queue.removeWhere((item) => item.status == RetryStatus.success);
      
      if (queue.length < beforeCount) {
        await _saveQueue(queue);
        debugPrint('🧹 送信キュークリーンアップ: ${beforeCount - queue.length}件の成功アイテムを削除');
      }
    } catch (e) {
      debugPrint('❌ 送信キュークリーンアップエラー: $e');
    }
  }
  
  /// 失敗回数が上限に達したアイテムをクリーンアップ
  /// 
  /// 最大再試行回数に達したアイテムをキューから削除する
  static Future<void> cleanupFailedItems({int maxRetryCount = 5}) async {
    try {
      final queue = await _getQueue();
      final beforeCount = queue.length;
      
      // 最大再試行回数に達したアイテムを削除
      queue.removeWhere((item) => 
        item.status == RetryStatus.failed && item.retryCount >= maxRetryCount
      );
      
      if (queue.length < beforeCount) {
        await _saveQueue(queue);
        debugPrint('🧹 送信キュークリーンアップ: ${beforeCount - queue.length}件の失敗アイテムを削除');
      }
    } catch (e) {
      debugPrint('❌ 送信キュークリーンアップエラー: $e');
    }
  }
  
  /// キューの統計情報を取得
  /// 
  /// キューの各ステータス別の件数を取得する
  static Future<Map<String, int>> getQueueStats() async {
    final queue = await _getQueue();
    final stats = <String, int>{
      'total': queue.length,
      'pending': 0,
      'processing': 0,
      'success': 0,
      'failed': 0,
    };

    for (final item in queue) {
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

    return stats;
  }
  
  /// キューをクリア（デバッグ用）
  /// 
  /// 全てのキューアイテムを削除する
  static Future<void> clearQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('retry_queue');
      debugPrint('🗑️ 送信キューをクリアしました');
    } catch (e) {
      debugPrint('❌ 送信キュークリアエラー: $e');
    }
  }
  
  // ===== ネットワーク監視関連 =====
  
  /// ネットワーク接続をチェック
  /// 
  /// Google.comへの接続テストでネットワーク状態を確認する
  static Future<bool> checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// ネットワーク状態を監視
  /// 
  /// 定期的にネットワーク接続をチェックするStreamを返す
  /// 指定された間隔（デフォルト30秒）でチェックする
  static Stream<bool> watchNetworkStatus({Duration interval = const Duration(seconds: 30)}) async* {
    while (true) {
      yield await checkNetworkConnection();
      await Future.delayed(interval);
    }
  }
  
  /// オンライン状態かどうかを確認
  /// 
  /// 現在のネットワーク接続状態を同期的に取得する
  /// 注意: この関数は最後にチェックした結果を返すため、リアルタイムではない
  static bool isOnline() {
    // 注意: この実装は簡易版です
    // 実際のアプリでは状態管理システムと連携することを推奨
    return true; // デフォルトでオンラインと仮定
  }
  
  // ===== リトライロジック関連 =====
  
  /// 再試行可能かどうかを判定
  /// 
  /// 現在の再試行回数と最大再試行回数を比較して判定する
  static bool canRetry(int retryCount, int maxRetries) {
    return retryCount < maxRetries;
  }
  
  /// 再試行遅延時間を計算（指数バックオフ）
  /// 
  /// 再試行回数に基づいて指数バックオフで遅延時間を計算する
  /// デフォルトの基本遅延は30秒
  static Duration calculateRetryDelay(int retryCount, {Duration baseDelay = const Duration(seconds: 30)}) {
    final exponentialDelay = Duration(seconds: baseDelay.inSeconds * (1 << retryCount));
    return exponentialDelay;
  }
  
  /// 次の再試行時刻を計算
  /// 
  /// 最後の再試行時刻と再試行回数から次の再試行時刻を計算する
  static DateTime getNextRetryTime(DateTime lastRetryTime, int retryCount, {Duration baseDelay = const Duration(seconds: 30)}) {
    final delay = calculateRetryDelay(retryCount, baseDelay: baseDelay);
    return lastRetryTime.add(delay);
  }
  
  /// 再試行可能かどうかを判定（時間ベース）
  /// 
  /// 次の再試行時刻が現在時刻を過ぎているかどうかを判定する
  static bool isReadyForRetry(DateTime nextRetryTime) {
    return DateTime.now().isAfter(nextRetryTime);
  }
  
  /// 再試行アイテムを作成
  /// 
  /// 指定されたパラメータで再試行アイテムを作成する
  static RetryItem createRetryItem({
    required String id,
    required RetryType type,
    required String userId,
    required Map<String, dynamic> data,
    DateTime? timestamp,
  }) {
    return RetryItem(
      id: id,
      type: type,
      userId: userId,
      data: data,
      timestamp: timestamp ?? DateTime.now(),
      retryCount: 0,
      status: RetryStatus.pending,
    );
  }
  
  /// キューアイテムをバッチ処理
  /// 
  /// 複数のキューアイテムを一括で処理する
  /// 各アイテムに対して指定された処理関数を実行する
  static Future<void> processQueueItems(
    List<RetryItem> items,
    Future<bool> Function(RetryItem) processFunction,
  ) async {
    for (final item in items) {
      try {
        debugPrint('🔄 送信キューアイテム処理: ${item.type.name} (ID: ${item.id})');
        
        // 処理中にマーク
        await updateQueueItemStatus(item.id, RetryStatus.processing);
        
        // 処理を実行
        final success = await processFunction(item);
        
        if (success) {
          // 成功した場合
          await updateQueueItemStatus(item.id, RetryStatus.success);
          debugPrint('✅ 送信成功: ${item.type.name} (ID: ${item.id})');
        } else {
          // 失敗した場合
          await updateQueueItemStatus(item.id, RetryStatus.failed, errorMessage: '送信に失敗しました');
          debugPrint('❌ 送信失敗: ${item.type.name} (ID: ${item.id})');
        }
      } catch (e) {
        // エラーが発生した場合
        await updateQueueItemStatus(item.id, RetryStatus.failed, errorMessage: e.toString());
        debugPrint('❌ 送信キューアイテム処理エラー: $e');
      }
    }
  }
  
  // ===== プライベートヘルパー関数 =====
  
  /// ローカルストレージからキューを取得
  static Future<List<RetryItem>> _getQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('retry_queue');
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => RetryItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ 送信キュー取得エラー: $e');
      return [];
    }
  }
  
  /// ローカルストレージにキューを保存
  static Future<void> _saveQueue(List<RetryItem> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(queue.map((item) => item.toJson()).toList());
      await prefs.setString('retry_queue', jsonString);
    } catch (e) {
      debugPrint('❌ 送信キュー保存エラー: $e');
    }
  }

  // ===== Phase 5: バックグラウンド処理機能 =====

  // バックグラウンド処理用のタイマー
  static Timer? _backgroundProcessingTimer;
  static bool _isBackgroundProcessingActive = false;

  /// バックグラウンド処理を開始
  /// 
  /// **処理フロー**:
  /// 1. 指定間隔でキュー処理を実行
  /// 2. 既に開始している場合は何もしない
  /// 
  /// **パラメータ**:
  /// - `interval`: 処理間隔（デフォルト: 30秒）
  /// - `processFunction`: キュー処理関数
  static void startBackgroundProcessing({
    Duration interval = const Duration(seconds: 30),
    required Future<void> Function() processFunction,
  }) {
    if (_isBackgroundProcessingActive) {
      LogMk.logInfo('バックグラウンド処理は既に開始しています', tag: 'QueMk.startBackgroundProcessing');
      return;
    }

    LogMk.logInfo('バックグラウンド処理開始: ${interval.inSeconds}秒間隔', tag: 'QueMk.startBackgroundProcessing');
    
    _isBackgroundProcessingActive = true;
    
    // 定期的にキュー処理を実行
    _backgroundProcessingTimer = Timer.periodic(interval, (timer) async {
      try {
        await LogMk.logDebug('バックグラウンド処理実行', tag: 'QueMk.backgroundProcessing');
        await processFunction();
      } catch (e, stackTrace) {
        await LogMk.logError(
          'バックグラウンド処理エラー',
          tag: 'QueMk.backgroundProcessing',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// バックグラウンド処理を停止
  /// 
  /// **処理フロー**:
  /// 1. タイマーをキャンセル
  /// 2. フラグをリセット
  static void stopBackgroundProcessing() {
    if (!_isBackgroundProcessingActive) {
      LogMk.logInfo('バックグラウンド処理は開始していません', tag: 'QueMk.stopBackgroundProcessing');
      return;
    }

    LogMk.logInfo('バックグラウンド処理停止', tag: 'QueMk.stopBackgroundProcessing');
    
    _backgroundProcessingTimer?.cancel();
    _backgroundProcessingTimer = null;
    _isBackgroundProcessingActive = false;
  }

  /// バックグラウンド処理が実行中かどうか
  /// 
  /// **戻り値**: 実行中の場合はtrue
  static bool isBackgroundProcessingActive() {
    return _isBackgroundProcessingActive;
  }
}
