import 'dart:async';
import 'package:test_flutter/data/services/log_service.dart';

/// イベントタイプ
enum EventType {
  syncStarted, // 同期開始
  syncCompleted, // 同期完了
  syncFailed, // 同期失敗
  dataAdded, // データ追加
  dataUpdated, // データ更新
  dataDeleted, // データ削除
  queueProcessed, // キュー処理完了
  networkOnline, // ネットワークオンライン
  networkOffline, // ネットワークオフライン
  error, // エラー発生
}

/// イベントデータ
class EventData {
  final EventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  EventData({required this.type, required this.timestamp, this.metadata});

  @override
  String toString() {
    return 'EventData(type: ${type.name}, timestamp: $timestamp, metadata: $metadata)';
  }
}

/// イベント発行/購読の汎用的な基本関数
///
/// イベント管理に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class EventMk {
  // イベントリスナーのマップ（キー: イベントタイプ, 値: リスナーのリスト）
  static final Map<EventType, List<void Function(EventData)>> _listeners = {};

  // 全イベントのリスナー
  static final List<void Function(EventData)> _globalListeners = [];

  /// イベントリスナーを登録
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ
  /// - `listener`: リスナー関数
  ///
  /// **戻り値**: リスナーを削除するための関数
  static void Function() on(EventType type, void Function(EventData) listener) {
    if (!_listeners.containsKey(type)) {
      _listeners[type] = [];
    }

    _listeners[type]!.add(listener);

    LogMk.logDebug('イベントリスナー登録: ${type.name}', tag: 'EventMk.on');

    // リスナーを削除するための関数を返す
    return () => off(type, listener);
  }

  /// グローバルイベントリスナーを登録（全イベントを監視）
  ///
  /// **パラメータ**:
  /// - `listener`: リスナー関数
  ///
  /// **戻り値**: リスナーを削除するための関数
  static void Function() onAny(void Function(EventData) listener) {
    _globalListeners.add(listener);

    LogMk.logDebug('グローバルイベントリスナー登録', tag: 'EventMk.onAny');

    // リスナーを削除するための関数を返す
    return () => offAny(listener);
  }

  /// イベントリスナーを削除
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ
  /// - `listener`: 削除するリスナー関数
  static void off(EventType type, void Function(EventData) listener) {
    if (_listeners.containsKey(type)) {
      _listeners[type]!.remove(listener);
      LogMk.logDebug('イベントリスナー削除: ${type.name}', tag: 'EventMk.off');
    }
  }

  /// グローバルイベントリスナーを削除
  ///
  /// **パラメータ**:
  /// - `listener`: 削除するリスナー関数
  static void offAny(void Function(EventData) listener) {
    _globalListeners.remove(listener);
    LogMk.logDebug('グローバルイベントリスナー削除', tag: 'EventMk.offAny');
  }

  /// 指定タイプの全リスナーを削除
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ
  static void offAll(EventType type) {
    if (_listeners.containsKey(type)) {
      final count = _listeners[type]!.length;
      _listeners[type]!.clear();
      LogMk.logDebug(
        '全イベントリスナー削除: ${type.name} ($count件)',
        tag: 'EventMk.offAll',
      );
    }
  }

  /// 全てのリスナーを削除
  static void clearAllListeners() {
    final count = _listeners.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    _listeners.clear();
    _globalListeners.clear();
    LogMk.logDebug('全リスナークリア: $count件', tag: 'EventMk.clearAllListeners');
  }

  /// イベントを発行
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ
  /// - `metadata`: イベントのメタデータ（オプション）
  static void emit(EventType type, {Map<String, dynamic>? metadata}) {
    final eventData = EventData(
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    LogMk.logDebug('イベント発行: ${type.name}', tag: 'EventMk.emit');

    // 特定のイベントタイプのリスナーに通知
    if (_listeners.containsKey(type)) {
      for (final listener in _listeners[type]!) {
        try {
          listener(eventData);
        } catch (e, stackTrace) {
          LogMk.logError(
            'イベントリスナーエラー: ${type.name}',
            tag: 'EventMk.emit',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    }

    // グローバルリスナーに通知
    for (final listener in _globalListeners) {
      try {
        listener(eventData);
      } catch (e, stackTrace) {
        LogMk.logError(
          'グローバルイベントリスナーエラー: ${type.name}',
          tag: 'EventMk.emit',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// イベントをStreamとして監視
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ
  ///
  /// **戻り値**: イベントデータのStream
  static Stream<EventData> watch(EventType type) {
    final controller = StreamController<EventData>.broadcast();

    void listener(EventData data) {
      controller.add(data);
    }

    on(type, listener);

    controller.onCancel = () {
      off(type, listener);
    };

    return controller.stream;
  }

  /// 全イベントをStreamとして監視
  ///
  /// **戻り値**: イベントデータのStream
  static Stream<EventData> watchAll() {
    final controller = StreamController<EventData>.broadcast();

    void listener(EventData data) {
      controller.add(data);
    }

    onAny(listener);

    controller.onCancel = () {
      offAny(listener);
    };

    return controller.stream;
  }

  /// リスナーの数を取得
  ///
  /// **パラメータ**:
  /// - `type`: イベントタイプ（オプション、指定しない場合は全体）
  ///
  /// **戻り値**: リスナーの数
  static int getListenerCount([EventType? type]) {
    if (type != null) {
      return (_listeners[type]?.length ?? 0) + _globalListeners.length;
    } else {
      final specificCount = _listeners.values.fold<int>(
        0,
        (sum, list) => sum + list.length,
      );
      return specificCount + _globalListeners.length;
    }
  }
}
