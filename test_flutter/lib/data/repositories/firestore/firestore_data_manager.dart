import 'dart:async';
import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/network_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:async_locks/async_locks.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_crud_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_local_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_sync_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_retry_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_realtime_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_query_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_auth_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_background_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_event_mixin.dart';
import 'package:test_flutter/data/repositories/firestore/mixins/firestore_storage_mixin.dart';

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
class FirestoreDataManager<T> with
    FirestoreCrudMixin<T>,
    FirestoreLocalMixin<T>,
    FirestoreSyncMixin<T>,
    FirestoreRetryMixin<T>,
    FirestoreRealtimeMixin<T>,
    FirestoreQueryMixin<T>,
    FirestoreAuthMixin<T>,
    FirestoreBackgroundMixin<T>,
    FirestoreEventMixin<T>,
    FirestoreStorageMixin<T> {
  /// Firestoreコレクションパスを生成する関数
  @override
  final String Function(String userId) collectionPathBuilder;
  
  /// Firestoreデータをモデルに変換する関数
  @override
  final T Function(Map<String, dynamic> data) fromFirestore;
  
  /// モデルをFirestoreデータに変換する関数
  @override
  final Map<String, dynamic> Function(T item) toFirestore;
  
  /// IDフィールド名（デフォルト: 'id'）
  @override
  final String idField;
  
  /// 最終更新フィールド名（デフォルト: 'lastModified'）
  @override
  final String lastModifiedField;

  /// SharedPreferencesのキー（必須パラメータ）
  @override
  final String storageKey;
  
  /// モデルをJSONに変換する関数（必須パラメータ）
  @override
  final Map<String, dynamic> Function(T item) toJson;
  
  /// JSONをモデルに変換する関数（必須パラメータ）
  @override
  final T Function(Map<String, dynamic> json) fromJson;

  // Phase 1: 並行実行制御用のロック
  // TODO: [最適化] Phase 1で使用予定 - 並行実行制御の実装時に使用
  // ignore: unused_field
  final Lock _syncLock = Lock();
  // TODO: [最適化] Phase 1で使用予定 - リトライキュー制御の実装時に使用
  // ignore: unused_field
  final Lock _queueLock = Lock();

  // Phase 2: リアルタイム同期用
  // TODO: [最適化] Phase 2で使用予定 - リアルタイム同期機能の実装時に使用
  // ignore: unused_field
  StreamSubscription<List<T>>? _realtimeSyncSubscription;
  // TODO: [最適化] Phase 2で使用予定 - リアルタイム同期の状態管理に使用
  // ignore: unused_field
  final bool _isRealtimeSyncActive = false;
  // TODO: [最適化] Phase 2で使用予定 - 現在のユーザーIDの追跡に使用
  // ignore: unused_field
  String? _currentUserId;

  // Phase 5: バックグラウンド処理用
  // TODO: [最適化] Phase 5で使用予定 - ネットワーク状態監視の実装時に使用
  // ignore: unused_field
  StreamSubscription<NetworkStatus>? _networkStatusSubscription;
  // TODO: [最適化] Phase 5で使用予定 - バックグラウンド同期の状態管理に使用
  // ignore: unused_field
  final bool _isBackgroundSyncActive = false;

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

  /// アイテムからIDを取得
  /// 
  /// リフレクションを使わず、toFirestore()でMapに変換してからIDを取得
  /// 
  /// TODO: [最適化] 将来的に使用予定 - 現在はMixinで実装されているため未使用
  // ignore: unused_element
  String _getItemId(T item) {
    final data = toFirestore(item);
    final id = data[idField] as String?;
    
    if (id == null || id.isEmpty) {
      throw Exception('アイテムのIDが取得できませんでした。$idFieldフィールドを確認してください。');
    }
    
    return id;
  }

  /// 全アイテムのリアルタイム監視
  /// 
  @override
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
}

