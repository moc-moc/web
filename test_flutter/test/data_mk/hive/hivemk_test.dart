import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_flutter/data/sources/hive_source.dart';

/// HiveMkの基本機能のテスト
/// 
/// Hiveの基本的なCRUD操作と管理機能をテストする
void main() {
  group('HiveMk Tests', () {
    // テスト前にHiveを初期化
    setUpAll(() async {
      await Hive.initFlutter();
      await HiveMk.initialize();
    });

    // 各テスト後にクリーンアップ
    tearDown(() async {
      // テスト用ボックスをクリア
      try {
        if (Hive.isBoxOpen('test_box')) {
          final box = Hive.box('test_box');
          await box.clear();
        }
      } catch (e) {
        // エラーは無視
      }
    });

    // 全テスト終了後にHiveをクローズ
    tearDownAll(() async {
      await HiveMk.close();
    });

    group('初期化とセットアップ', () {
      test('HiveMkを初期化できる', () async {
        await HiveMk.initialize();
        expect(true, true); // 例外が発生しなければ成功
      });
    });

    group('基本CRUD操作', () {
      test('saveAllToHive - リストデータを保存できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1', 'lastModified': DateTime.now().toIso8601String()},
          {'id': '2', 'name': 'Item 2', 'lastModified': DateTime.now().toIso8601String()},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        expect(true, true); // 例外が発生しなければ成功
      });

      test('getAllFromHive - リストデータを取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        final items = await HiveMk.getAllFromHive('test_box');

        expect(items, isA<List<Map<String, dynamic>>>());
        expect(items.length, 2);
        expect(items[0]['id'], '1');
        expect(items[1]['id'], '2');
      });

      test('getListCount - データ件数を取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
          {'id': '3', 'name': 'Item 3'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        final count = await HiveMk.getListCount('test_box');

        expect(count, 3);
      });

      test('空のボックスから取得した場合は空リストを返す', () async {
        final items = await HiveMk.getAllFromHive('empty_box');
        expect(items, isEmpty);
      });
    });

    group('単一アイテム操作', () {
      test('addItemToHive - アイテムを追加できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final newItem = {'id': '2', 'name': 'Item 2'};
        await HiveMk.addItemToHive('test_box', newItem, 'id');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 2);
        expect(items[1]['id'], '2');
      });

      test('updateItemInHive - アイテムを更新できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final updatedItem = {'id': '2', 'name': 'Updated Item 2'};
        await HiveMk.updateItemInHive('test_box', updatedItem, 'id');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 2);
        expect(items[1]['name'], 'Updated Item 2');
      });

      test('removeItemFromHive - アイテムを削除できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
          {'id': '3', 'name': 'Item 3'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.removeItemFromHive('test_box', '2', 'id');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 2);
        expect(items.every((item) => item['id'] != '2'), true);
      });

      test('getItemFromHive - 指定IDのアイテムを取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final item = await HiveMk.getItemFromHive('test_box', '2', 'id');

        expect(item, isNotNull);
        expect(item!['id'], '2');
        expect(item['name'], 'Item 2');
      });

      test('存在しないアイテムを取得した場合はnullを返す', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final item = await HiveMk.getItemFromHive('test_box', '999', 'id');

        expect(item, isNull);
      });
    });

    group('同期時刻管理', () {
      test('setLastSyncTimeToHive - 最終同期時刻を設定できる', () async {
        final now = DateTime.now();
        await HiveMk.setLastSyncTimeToHive('test_box', now);

        final retrieved = await HiveMk.getLastSyncTimeFromHive('test_box');
        expect(retrieved, isNotNull);
        expect(retrieved!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('getLastSyncTimeFromHive - 未設定の場合はnullを返す', () async {
        final time = await HiveMk.getLastSyncTimeFromHive('nonexistent_box');
        expect(time, isNull);
      });

      test('updateLastSyncTimeToHive - 現在時刻で更新できる', () async {
        await HiveMk.updateLastSyncTimeToHive('test_box');
        
        final time = await HiveMk.getLastSyncTimeFromHive('test_box');
        expect(time, isNotNull);
      });
    });

    group('差分取得', () {
      test('getModifiedItemsSince - 指定時刻以降のアイテムを取得できる', () async {
        final now = DateTime.now();
        final past = now.subtract(const Duration(hours: 1));
        final future = now.add(const Duration(hours: 1));

        final testData = [
          {'id': '1', 'name': 'Old Item', 'lastModified': past.toIso8601String()},
          {'id': '2', 'name': 'New Item', 'lastModified': future.toIso8601String()},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final modifiedItems = await HiveMk.getModifiedItemsSince(
          'test_box',
          now,
          'lastModified',
        );

        expect(modifiedItems.length, 1);
        expect(modifiedItems[0]['id'], '2');
      });

      test('getActiveItemsFromHive - 削除されていないアイテムのみ取得', () async {
        final testData = [
          {'id': '1', 'name': 'Active Item', 'isDeleted': false},
          {'id': '2', 'name': 'Deleted Item', 'isDeleted': true},
          {'id': '3', 'name': 'Active Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final activeItems = await HiveMk.getActiveItemsFromHive('test_box', 'isDeleted');

        expect(activeItems.length, 2);
        expect(activeItems.every((item) => item['isDeleted'] != true), true);
      });
    });

    group('Phase 4: 変更追跡機能', () {
      test('markAsDirty - 変更フラグを付与できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.markAsDirty('test_box', '1', 'id');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items[0]['_isDirty'], true);
        expect(items[0]['_dirtyTimestamp'], isNotNull);
      });

      test('getDirtyItems - 変更されたアイテムのみ取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.markAsDirty('test_box', '1', 'id');

        final dirtyItems = await HiveMk.getDirtyItems('test_box');
        expect(dirtyItems.length, 1);
        expect(dirtyItems[0]['id'], '1');
      });

      test('clearDirtyFlags - 変更フラグをクリアできる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.markAsDirty('test_box', '1', 'id');
        await HiveMk.markAsDirty('test_box', '2', 'id');

        await HiveMk.clearDirtyFlags('test_box', itemIds: ['1'], idField: 'id');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items[0]['_isDirty'], isNull);
        expect(items[1]['_isDirty'], true);
      });

      test('getDirtyItemCount - 変更アイテム数を取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
          {'id': '3', 'name': 'Item 3'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.markAsDirty('test_box', '1', 'id');
        await HiveMk.markAsDirty('test_box', '3', 'id');

        final count = await HiveMk.getDirtyItemCount('test_box');
        expect(count, 2);
      });
    });

    group('Phase 4: スキーマバージョニング', () {
      test('saveSchemaVersion - スキーマバージョンを保存できる', () async {
        await HiveMk.saveSchemaVersion('test_box', 1);
        
        final version = await HiveMk.getSchemaVersion('test_box');
        expect(version, 1);
      });

      test('getSchemaVersion - 未設定の場合は0を返す', () async {
        final version = await HiveMk.getSchemaVersion('nonexistent_box');
        expect(version, 0);
      });

      test('migrateData - データマイグレーションが実行される', () async {
        final oldData = [
          {'id': '1', 'oldField': 'value1'},
          {'id': '2', 'oldField': 'value2'},
        ];

        await HiveMk.saveAllToHive('test_box', oldData);
        await HiveMk.saveSchemaVersion('test_box', 1);

        // マイグレーション関数（v1 -> v2）
        Future<List<Map<String, dynamic>>> migrate(
          List<Map<String, dynamic>> oldData,
          int currentVersion,
        ) async {
          return oldData.map((item) {
            return {
              'id': item['id'],
              'newField': item['oldField'], // oldField -> newFieldに変更
            };
          }).toList();
        }

        final migrated = await HiveMk.migrateData('test_box', 2, migrate);

        expect(migrated, true);
        
        final newData = await HiveMk.getAllFromHive('test_box');
        expect(newData[0]['newField'], 'value1');
        expect(newData[0]['oldField'], isNull);
        
        final version = await HiveMk.getSchemaVersion('test_box');
        expect(version, 2);
      });

      test('migrateData - 既に最新バージョンの場合はマイグレーション不要', () async {
        await HiveMk.saveSchemaVersion('test_box', 2);

        final migrated = await HiveMk.migrateData('test_box', 2, (data, version) async => data);

        expect(migrated, false);
      });

      test('saveWithVersion - バージョン付きでデータを保存できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
        ];

        await HiveMk.saveWithVersion('test_box', testData, 3);

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 1);
        
        final version = await HiveMk.getSchemaVersion('test_box');
        expect(version, 3);
      });
    });

    group('Phase 6: ローカルサイズ管理', () {
      test('getStorageSize - ストレージサイズを取得できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final size = await HiveMk.getStorageSize();
        expect(size, greaterThan(0));
      });

      test('clearOldData - 古いデータをクリアできる', () async {
        final now = DateTime.now();
        final oldTime = now.subtract(const Duration(days: 10));
        final newTime = now.subtract(const Duration(hours: 1));

        final testData = [
          {'id': '1', 'name': 'Old Item', 'timestamp': oldTime.toIso8601String()},
          {'id': '2', 'name': 'New Item', 'timestamp': newTime.toIso8601String()},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final removedCount = await HiveMk.clearOldData(
          'test_box',
          const Duration(days: 7),
          timestampField: 'timestamp',
        );

        expect(removedCount, 1);
        
        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 1);
        expect(items[0]['id'], '2');
      });

      test('isStorageOverLimit - 容量超過チェックができる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final isOver = await HiveMk.isStorageOverLimit(1); // 1バイト制限
        expect(isOver, true);
        
        final isNotOver = await HiveMk.isStorageOverLimit(1000000); // 1MB制限
        expect(isNotOver, false);
      });

      test('clearOldestItems - 最古アイテムを削除できる', () async {
        final now = DateTime.now();

        final testData = [
          {'id': '1', 'name': 'Item 1', 'timestamp': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': '2', 'name': 'Item 2', 'timestamp': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': '3', 'name': 'Item 3', 'timestamp': now.subtract(const Duration(days: 1)).toIso8601String()},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        
        final removedCount = await HiveMk.clearOldestItems(
          'test_box',
          1,
          timestampField: 'timestamp',
        );

        expect(removedCount, 1);
        
        final items = await HiveMk.getAllFromHive('test_box');
        expect(items.length, 2);
        // 最も古い'1'が削除されているはず
        expect(items.every((item) => item['id'] != '1'), true);
      });
    });

    group('ユーティリティ機能', () {
      test('containsBox - ボックス存在チェック', () async {
        final exists1 = await HiveMk.containsBox('test_box');
        expect(exists1, false);

        await HiveMk.saveAllToHive('test_box', [{'id': '1'}]);
        
        final exists2 = await HiveMk.containsBox('test_box');
        expect(exists2, true);
      });

      test('removeFromHive - ボックス全体を削除できる', () async {
        final testData = [
          {'id': '1', 'name': 'Item 1'},
        ];

        await HiveMk.saveAllToHive('test_box', testData);
        await HiveMk.removeFromHive('test_box');

        final items = await HiveMk.getAllFromHive('test_box');
        expect(items, isEmpty);
      });
    });
  });
}

