import 'package:test_flutter/data/sources/event_source.dart';
import 'package:test_flutter/data/repositories/firestore/firestore_stream_extension.dart';

/// イベント通知統合のMixin
/// 
/// イベント監視機能を提供
mixin FirestoreEventMixin<T> {
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
}

