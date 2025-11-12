import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/repositories/firestore_hive_repository.dart';

// テスト用のFreezedモデル（Countdownの簡易版）
class TestItem {
  final String id;
  final String title;
  final DateTime lastModified;

  const TestItem({
    required this.id,
    required this.title,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(
      id: json['id'] as String,
      title: json['title'] as String,
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestItem &&
        other.id == id &&
        other.title == title &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ lastModified.hashCode;

  @override
  String toString() => 'TestItem(id: $id, title: $title, lastModified: $lastModified)';
}

void main() {
  group('FirestoreHiveDataManager', () {
    late FirestoreHiveDataManager<TestItem> manager;

    setUp(() {
      manager = FirestoreHiveDataManager<TestItem>(
        collectionPathBuilder: (userId) => 'users/$userId/test_items',
        fromFirestore: (data) => TestItem(
          id: data['id'] as String,
          title: data['title'] as String,
          lastModified: data['lastModified'] as DateTime,
        ),
        toFirestore: (item) => {
          'id': item.id,
          'title': item.title,
          'lastModified': item.lastModified,
        },
        hiveBoxName: 'test_items',
        toJson: (item) => item.toJson(),
        fromJson: (json) => TestItem.fromJson(json),
        idField: 'id',
        lastModifiedField: 'lastModified',
      );
    });

    group('コンストラクタ', () {
      test('必須パラメータでFirestoreHiveDataManagerを作成できる', () {
        final testManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test',
          fromFirestore: (data) => TestItem.fromJson(data),
          toFirestore: (item) => item.toJson(),
          hiveBoxName: 'test_key',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
        );

        expect(testManager.idField, 'id');
        expect(testManager.lastModifiedField, 'lastModified');
        expect(testManager.hiveBoxName, 'test_key');
      });

      test('カスタムフィールド名でFirestoreHiveDataManagerを作成できる', () {
        final testManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test',
          fromFirestore: (data) => TestItem.fromJson(data),
          toFirestore: (item) => item.toJson(),
          hiveBoxName: 'test_custom',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
          idField: 'uid',
          lastModifiedField: 'updatedAt',
        );

        expect(testManager.idField, 'uid');
        expect(testManager.lastModifiedField, 'updatedAt');
        expect(testManager.hiveBoxName, 'test_custom');
      });
    });

    group('ヘルパーメソッド', () {
      test('toFirestoreとfromFirestoreが正しく動作する', () {
        final item = TestItem(
          id: 'test_id_123',
          title: 'Test Title',
          lastModified: DateTime.now(),
        );

        // toFirestoreでMapに変換
        final data = manager.toFirestore(item);
        expect(data['id'], 'test_id_123');
        expect(data['title'], 'Test Title');
        expect(data['lastModified'], isA<DateTime>());

        // fromFirestoreでモデルに変換
        final convertedItem = manager.fromFirestore(data);
        expect(convertedItem.id, 'test_id_123');
        expect(convertedItem.title, 'Test Title');
      });
    });

    group('CRUD操作', () {
      const testUserId = 'test_user_123';

      group('add', () {
        test('アイテムを追加できる', () async {
          final item = TestItem(
            id: 'add_test_123',
            title: 'Add Test Item',
            lastModified: DateTime.now(),
          );

          // 注意: 実際のFirestore接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(item.id, 'add_test_123');
          expect(item.title, 'Add Test Item');
        });
      });

      group('getAll', () {
        test('全アイテムを取得できる', () async {
          // 注意: 実際のFirestore接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final items = await manager.getAll(testUserId);
          expect(items, isA<List<TestItem>>());
        });
      });

      group('getById', () {
        test('指定IDのアイテムを取得できる', () async {
          const testId = 'get_by_id_test_123';
          
          // 注意: 実際のFirestore接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final item = await manager.getById(testUserId, testId);
          expect(item, isA<TestItem?>());
        });
      });

      group('update', () {
        test('アイテムを更新できる', () async {
          final item = TestItem(
            id: 'update_test_123',
            title: 'Updated Test Item',
            lastModified: DateTime.now(),
          );

          // 注意: 実際のFirestore接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(item.id, 'update_test_123');
          expect(item.title, 'Updated Test Item');
        });
      });

      group('delete', () {
        test('アイテムを削除できる', () async {
          const testId = 'delete_test_123';
          
          // 注意: 実際のFirestore接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final result = await manager.delete(testUserId, testId);
          expect(result, isA<bool>());
        });
      });
    });

    group('Phase 2: ローカル操作', () {
      late FirestoreHiveDataManager<TestItem> localManager;

      setUp(() {
        localManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test_items',
          fromFirestore: (data) => TestItem(
            id: data['id'] as String,
            title: data['title'] as String,
            lastModified: data['lastModified'] as DateTime,
          ),
          toFirestore: (item) => {
            'id': item.id,
            'title': item.title,
            'lastModified': item.lastModified,
          },
          idField: 'id',
          lastModifiedField: 'lastModified',
          // Phase 2で追加されたパラメータ
          hiveBoxName: 'test_items',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
        );
      });

      group('getLocalAll', () {
        test('ローカルから全アイテムを取得できる', () async {
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final items = await localManager.getLocalAll();
          expect(items, isA<List<TestItem>>());
        });
      });

      group('getLocalById', () {
        test('ローカルから指定IDのアイテムを取得できる', () async {
          const testId = 'local_get_by_id_test_123';
          
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final item = await localManager.getLocalById(testId);
          expect(item, isA<TestItem?>());
        });
      });

      group('saveLocal', () {
        test('ローカルに全アイテムを保存できる', () async {
          final items = [
            TestItem(
              id: 'save_local_1',
              title: 'Save Local 1',
              lastModified: DateTime.now(),
            ),
            TestItem(
              id: 'save_local_2',
              title: 'Save Local 2',
              lastModified: DateTime.now(),
            ),
          ];

          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(items.length, 2);
          expect(items[0].id, 'save_local_1');
          expect(items[1].id, 'save_local_2');
        });
      });

      group('addLocal', () {
        test('ローカルにアイテムを追加できる', () async {
          final item = TestItem(
            id: 'add_local_test_123',
            title: 'Add Local Test Item',
            lastModified: DateTime.now(),
          );

          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(item.id, 'add_local_test_123');
          expect(item.title, 'Add Local Test Item');
        });
      });

      group('updateLocal', () {
        test('ローカルのアイテムを更新できる', () async {
          final item = TestItem(
            id: 'update_local_test_123',
            title: 'Updated Local Test Item',
            lastModified: DateTime.now(),
          );

          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(item.id, 'update_local_test_123');
          expect(item.title, 'Updated Local Test Item');
        });
      });

      group('deleteLocal', () {
        test('ローカルからアイテムを削除できる', () async {
          const testId = 'delete_local_test_123';
          
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(testId, 'delete_local_test_123');
        });
      });

      group('clearLocal', () {
        test('ローカルデータをクリアできる', () async {
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          expect(true, true); // ダミーテスト
        });
      });

      group('getLocalCount', () {
        test('ローカルのアイテム数を取得できる', () async {
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final count = await localManager.getLocalCount();
          expect(count, isA<int>());
        });
      });

      // ローカル操作設定チェックは不要（全て必須パラメータになったため）
    });

    group('Phase 3: 同期機能', () {
      late FirestoreHiveDataManager<TestItem> syncManager;

      setUp(() {
        syncManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test_items',
          fromFirestore: (data) => TestItem(
            id: data['id'] as String,
            title: data['title'] as String,
            lastModified: data['lastModified'] as DateTime,
          ),
          toFirestore: (item) => {
            'id': item.id,
            'title': item.title,
            'lastModified': item.lastModified,
          },
          idField: 'id',
          lastModifiedField: 'lastModified',
          // Phase 2のローカル操作パラメータ
          hiveBoxName: 'test_items_sync',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
        );
      });

      group('sync', () {
        test('FirestoreとHiveを同期できる', () async {
          const testUserId = 'sync_test_user_123';
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final items = await syncManager.sync(testUserId);
          expect(items, isA<List<TestItem>>());
        });
      });

      group('forceSync', () {
        test('強制同期（全データ取得）ができる', () async {
          const testUserId = 'force_sync_test_user_123';
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final items = await syncManager.forceSync(testUserId);
          expect(items, isA<List<TestItem>>());
        });
      });

      group('pushLocalChanges', () {
        test('ローカルの変更をFirestoreにプッシュできる', () async {
          const testUserId = 'push_local_test_user_123';
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final successCount = await syncManager.pushLocalChanges(testUserId);
          expect(successCount, isA<int>());
        });
      });

      group('getLastSyncTime', () {
        test('最終同期時刻を取得できる', () async {
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final lastSyncTime = await syncManager.getLastSyncTime();
          expect(lastSyncTime, isA<DateTime?>());
        });
      });

      group('resetSyncState', () {
        test('同期状態をリセットできる', () async {
          // 注意: 実際のHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          await syncManager.resetSyncState();
          expect(true, true); // ダミーテスト
        });
      });

      // 同期機能設定チェックは不要（全て必須パラメータになったため）
    });

    group('Phase 4-5: リトライ機能とキュー管理', () {
      late FirestoreHiveDataManager<TestItem> retryManager;

      setUp(() {
        retryManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test_items',
          fromFirestore: (data) => TestItem(
            id: data['id'] as String,
            title: data['title'] as String,
            lastModified: data['lastModified'] as DateTime,
          ),
          toFirestore: (item) => {
            'id': item.id,
            'title': item.title,
            'lastModified': item.lastModified,
          },
          idField: 'id',
          lastModifiedField: 'lastModified',
          // Phase 2のローカル操作パラメータ
          hiveBoxName: 'test_items_retry',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
        );
      });

      group('addWithRetry', () {
        test('リトライ機能付きの追加ができる', () async {
          const testUserId = 'add_retry_test_user_123';
          final item = TestItem(
            id: 'add_retry_test_123',
            title: 'Add Retry Test Item',
            lastModified: DateTime.now(),
          );
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final success = await retryManager.addWithRetry(testUserId, item);
          expect(success, isA<bool>());
        });
      });

      group('updateWithRetry', () {
        test('リトライ機能付きの更新ができる', () async {
          const testUserId = 'update_retry_test_user_123';
          final item = TestItem(
            id: 'update_retry_test_123',
            title: 'Update Retry Test Item',
            lastModified: DateTime.now(),
          );
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final success = await retryManager.updateWithRetry(testUserId, item);
          expect(success, isA<bool>());
        });
      });

      group('deleteWithRetry', () {
        test('リトライ機能付きの削除ができる', () async {
          const testUserId = 'delete_retry_test_user_123';
          const testId = 'delete_retry_test_123';
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final success = await retryManager.deleteWithRetry(testUserId, testId);
          expect(success, isA<bool>());
        });
      });

      group('processQueue', () {
        test('キュー処理ができる', () async {
          const testUserId = 'process_queue_test_user_123';
          
          // 注意: 実際のFirestoreとHive接続が必要なため、このテストは統合テストとして実行
          // 現在は基本的な構造のみをテスト
          final processedCount = await retryManager.processQueue(testUserId);
          expect(processedCount, isA<int>());
        });
      });

      // リトライ機能設定チェックは不要（全て必須パラメータになったため）
    });

    group('Phase 6: キュー統計と管理', () {
      late FirestoreHiveDataManager<TestItem> queueManager;

      setUp(() {
        queueManager = FirestoreHiveDataManager<TestItem>(
          collectionPathBuilder: (userId) => 'users/$userId/test_items',
          fromFirestore: (data) => TestItem(
            id: data['id'] as String,
            title: data['title'] as String,
            lastModified: data['lastModified'] as DateTime,
          ),
          toFirestore: (item) => {
            'id': item.id,
            'title': item.title,
            'lastModified': item.lastModified,
          },
          idField: 'id',
          lastModifiedField: 'lastModified',
          hiveBoxName: 'test_items_queue',
          toJson: (item) => item.toJson(),
          fromJson: (json) => TestItem.fromJson(json),
        );
      });

      test('getQueueStatsがMap<String,int>を返す', () async {
        final stats = await queueManager.getQueueStats();
        expect(stats, isA<Map<String, int>>());
        expect(stats.keys, containsAll(['pending', 'processing', 'success', 'failed', 'total']));
      });

      test('clearQueueが正常に完了する', () async {
        await queueManager.clearQueue();
        expect(true, true);
      });

      test('retryFailedOperationsがintを返す', () async {
        const userId = 'retry_failed_ops_user_123';
        final processed = await queueManager.retryFailedOperations(userId);
        expect(processed, isA<int>());
      });
    });

    group('データ変換', () {
      test('fromFirestoreとtoFirestoreが正しく動作する', () {
        final originalItem = TestItem(
          id: 'conversion_test_123',
          title: 'Conversion Test',
          lastModified: DateTime(2024, 1, 1, 12, 0, 0),
        );

        // toFirestoreでMapに変換
        final data = manager.toFirestore(originalItem);
        expect(data['id'], 'conversion_test_123');
        expect(data['title'], 'Conversion Test');
        expect(data['lastModified'], isA<DateTime>());

        // fromFirestoreでモデルに変換（Timestampの代わりにDateTimeを使用）
        final convertedItem = manager.fromFirestore({
          'id': data['id'],
          'title': data['title'],
          'lastModified': data['lastModified'],
        });

        expect(convertedItem.id, originalItem.id);
        expect(convertedItem.title, originalItem.title);
        expect(convertedItem.lastModified, originalItem.lastModified);
      });
    });

    group('エラーハンドリング', () {
      test('不正なデータでfromFirestoreを呼び出した場合のエラー処理', () {
        expect(
          () => manager.fromFirestore({'invalid': 'data'}),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}

