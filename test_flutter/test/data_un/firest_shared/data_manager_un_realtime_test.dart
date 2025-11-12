import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/repositories/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テスト用のシンプルなモデル
class TestModel {
  final String id;
  final String name;
  final DateTime lastModified;

  TestModel({
    required this.id,
    required this.name,
    required this.lastModified,
  });

  factory TestModel.fromFirestore(Map<String, dynamic> data) {
    return TestModel(
      id: data['id'] as String,
      name: data['name'] as String,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastModified': lastModified.toIso8601String(),
    };
  }
}

void main() {
  late FirestoreDataManager<TestModel> manager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    manager = FirestoreDataManager<TestModel>(
      collectionPathBuilder: (userId) => 'users/$userId/items',
      fromFirestore: TestModel.fromFirestore,
      toFirestore: (item) => item.toFirestore(),
      storageKey: 'test_items',
      toJson: (item) => item.toJson(),
      fromJson: TestModel.fromJson,
    );
  });

  group('DataManager Phase 2: リアルタイム同期 Tests', () {
    // Firebaseエミュレータが必要
    test('watchAll - 全アイテムのリアルタイム監視', () {
      // final stream = manager.watchAll('test_user');
      // expect(stream, isA<Stream<List<TestModel>>>());
    });

    test('watchById - 指定IDのリアルタイム監視', () {
      // final stream = manager.watchById('test_user', 'test_id');
      // expect(stream, isA<Stream<TestModel?>>());
    });

    // startRealtimeSync/stopRealtimeSyncのテストはモックが必要
  });

  group('DataManager Phase 2: 認証統合 Tests', () {
    // 認証が必要なため、モックまたはエミュレータが必要
    test('addWithAuth - ログインしていない場合はfalse', () async {
      final item = TestModel(
        id: 'test1',
        name: 'Test Item',
        lastModified: DateTime.now(),
      );
      
      final result = await manager.addWithAuth(item);
      expect(result, false);
    });

    test('getAllWithAuth - ログインしていない場合は空リスト', () async {
      final result = await manager.getAllWithAuth();
      expect(result, isEmpty);
    });
  });
}

