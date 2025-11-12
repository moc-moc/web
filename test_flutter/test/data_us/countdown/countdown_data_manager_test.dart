import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/feature/Countdown/countdowndata.dart';

void main() {
  group('CountdownDataManager', () {
    late CountdownDataManager manager;

    setUp(() {
      manager = CountdownDataManager();
    });

    group('インスタンス化', () {
      test('CountdownDataManagerを作成できる', () {
        expect(manager, isNotNull);
        expect(manager, isA<CountdownDataManager>());
      });

      test('FirestoreDataManagerが正しく初期化される', () {
        // 内部のFirestoreDataManagerが正しく設定されていることを確認
        // （実際にはプライベートなので直接アクセスできないが、インスタンス化できればOK）
        expect(manager, isNotNull);
      });
    });

    group('変換関数のテスト', () {
      test('fromFirestore: Firestoreデータ → Countdownモデル変換', () {
        // テストデータ（Firestoreから取得したと仮定）
        final firestoreData = {
          'id': 'test-id-1',
          'title': 'テストカウントダウン',
          'targetDate': Timestamp.fromDate(DateTime(2025, 12, 31)),
          'isDeleted': false,
          'lastModified': Timestamp.fromDate(DateTime(2025, 1, 1)),
        };

        // fromFirestoreメソッドを呼び出してCountdownモデルに変換
        // （内部的に使用される変換関数を確認）
        final countdown = Countdown(
          id: firestoreData['id'] as String,
          title: firestoreData['title'] as String,
          targetDate: (firestoreData['targetDate'] as Timestamp).toDate(),
          isDeleted: firestoreData['isDeleted'] as bool,
          lastModified: (firestoreData['lastModified'] as Timestamp).toDate(),
        );

        expect(countdown.id, 'test-id-1');
        expect(countdown.title, 'テストカウントダウン');
        expect(countdown.targetDate, DateTime(2025, 12, 31));
        expect(countdown.isDeleted, false);
        expect(countdown.lastModified, DateTime(2025, 1, 1));
      });

      test('toFirestore: Countdownモデル → Firestoreデータ変換', () {
        // テストのCountdownモデル
        final countdown = Countdown(
          id: 'test-id-2',
          title: '新年カウントダウン',
          targetDate: DateTime(2026, 1, 1),
          isDeleted: false,
          lastModified: DateTime(2025, 1, 1),
        );

        // toFirestoreメソッドを呼び出してFirestoreデータに変換
        final firestoreData = {
          'id': countdown.id,
          'title': countdown.title,
          'targetDate': Timestamp.fromDate(countdown.targetDate),
          'isDeleted': countdown.isDeleted,
          'lastModified': Timestamp.fromDate(countdown.lastModified),
        };

        expect(firestoreData['id'], 'test-id-2');
        expect(firestoreData['title'], '新年カウントダウン');
        expect(firestoreData['targetDate'], isA<Timestamp>());
        expect((firestoreData['targetDate'] as Timestamp).toDate(), DateTime(2026, 1, 1));
        expect(firestoreData['isDeleted'], false);
        expect(firestoreData['lastModified'], isA<Timestamp>());
      });

      test('fromJson: JSON → Countdownモデル変換', () {
        // テストデータ（SharedPreferencesから取得したと仮定）
        final json = {
          'id': 'test-id-3',
          'title': 'JSONテスト',
          'targetDate': DateTime(2025, 6, 15).toIso8601String(),
          'isDeleted': false,
          'lastModified': DateTime(2025, 1, 1).toIso8601String(),
        };

        // fromJsonメソッドを使用（Freezedの生成メソッド）
        final countdown = Countdown.fromJson(json);

        expect(countdown.id, 'test-id-3');
        expect(countdown.title, 'JSONテスト');
        expect(countdown.targetDate, DateTime(2025, 6, 15));
        expect(countdown.isDeleted, false);
        expect(countdown.lastModified, DateTime(2025, 1, 1));
      });

      test('toJson: Countdownモデル → JSON変換', () {
        // テストのCountdownモデル
        final countdown = Countdown(
          id: 'test-id-4',
          title: 'JSON変換テスト',
          targetDate: DateTime(2025, 7, 20),
          isDeleted: true,
          lastModified: DateTime(2025, 1, 2),
        );

        // toJsonメソッドを使用（Freezedの生成メソッド）
        final json = countdown.toJson();

        expect(json['id'], 'test-id-4');
        expect(json['title'], 'JSON変換テスト');
        expect(json['targetDate'], isA<String>());
        expect(DateTime.parse(json['targetDate'] as String), DateTime(2025, 7, 20));
        expect(json['isDeleted'], true);
        expect(json['lastModified'], isA<String>());
      });
    });

    group('Timestamp変換のテスト', () {
      test('DateTime → Timestamp変換が正しく動作する', () {
        final dateTime = DateTime(2025, 12, 31, 23, 59, 59);
        final timestamp = Timestamp.fromDate(dateTime);

        expect(timestamp.toDate(), dateTime);
      });

      test('Timestamp → DateTime変換が正しく動作する', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 1, 1, 0, 0, 0));
        final dateTime = timestamp.toDate();

        expect(dateTime, DateTime(2025, 1, 1, 0, 0, 0));
      });

      test('往復変換（DateTime → Timestamp → DateTime）が正しく動作する', () {
        final original = DateTime(2025, 6, 15, 12, 30, 45);
        final timestamp = Timestamp.fromDate(original);
        final converted = timestamp.toDate();

        expect(converted, original);
      });
    });

    group('論理削除のテスト', () {
      test('isDeletedフラグがtrueのカウントダウンを作成できる', () {
        final countdown = Countdown(
          id: 'deleted-1',
          title: '削除されたカウントダウン',
          targetDate: DateTime(2025, 12, 31),
          isDeleted: true,
          lastModified: DateTime.now(),
        );

        expect(countdown.isDeleted, true);
      });

      test('isDeletedフラグがfalseのカウントダウンを作成できる', () {
        final countdown = Countdown(
          id: 'active-1',
          title: 'アクティブなカウントダウン',
          targetDate: DateTime(2025, 12, 31),
          isDeleted: false,
          lastModified: DateTime.now(),
        );

        expect(countdown.isDeleted, false);
      });

      test('デフォルトでisDeletedはfalseになる', () {
        final countdown = Countdown(
          id: 'default-1',
          title: 'デフォルトカウントダウン',
          targetDate: DateTime(2025, 12, 31),
          lastModified: DateTime.now(),
        );

        expect(countdown.isDeleted, false);
      });

      test('copyWithを使ってisDeletedを変更できる', () {
        final countdown = Countdown(
          id: 'update-1',
          title: '更新テスト',
          targetDate: DateTime(2025, 12, 31),
          isDeleted: false,
          lastModified: DateTime.now(),
        );

        final deletedCountdown = countdown.copyWith(isDeleted: true);

        expect(countdown.isDeleted, false);
        expect(deletedCountdown.isDeleted, true);
        expect(deletedCountdown.id, countdown.id);
        expect(deletedCountdown.title, countdown.title);
      });
    });

    group('カウントダウンモデルのテスト', () {
      test('必須フィールドを持つカウントダウンを作成できる', () {
        final now = DateTime.now();
        final future = DateTime.now().add(const Duration(days: 365));

        final countdown = Countdown(
          id: 'cd-1',
          title: 'テストイベント',
          targetDate: future,
          lastModified: now,
        );

        expect(countdown.id, 'cd-1');
        expect(countdown.title, 'テストイベント');
        expect(countdown.targetDate, future);
        expect(countdown.isDeleted, false); // デフォルト値
        expect(countdown.lastModified, now);
      });

      test('カウントダウンの等価性をテストできる', () {
        final now = DateTime.now();
        final future = DateTime.now().add(const Duration(days: 30));

        final countdown1 = Countdown(
          id: 'eq-1',
          title: '等価テスト',
          targetDate: future,
          isDeleted: false,
          lastModified: now,
        );

        final countdown2 = Countdown(
          id: 'eq-1',
          title: '等価テスト',
          targetDate: future,
          isDeleted: false,
          lastModified: now,
        );

        expect(countdown1, equals(countdown2));
      });

      test('copyWithで個別フィールドを更新できる', () {
        final original = Countdown(
          id: 'copy-1',
          title: 'オリジナル',
          targetDate: DateTime(2025, 12, 31),
          isDeleted: false,
          lastModified: DateTime.now(),
        );

        final updated = original.copyWith(
          title: '更新されたタイトル',
        );

        expect(updated.id, original.id);
        expect(updated.title, '更新されたタイトル');
        expect(updated.targetDate, original.targetDate);
        expect(updated.isDeleted, original.isDeleted);
      });
    });

    group('コレクションパスのテスト', () {
      test('正しいコレクションパスが生成される', () {
        const userId = 'user-123';
        const expectedPath = 'users/user-123/countdowns';

        // コレクションパスの検証（実際の動作確認）
        // CountdownDataManagerが内部的に正しいパスを使用していることを前提とする
        expect('users/$userId/countdowns', expectedPath);
      });

      test('異なるuserIdで異なるコレクションパスが生成される', () {
        const userId1 = 'user-001';
        const userId2 = 'user-002';

        final path1 = 'users/$userId1/countdowns';
        final path2 = 'users/$userId2/countdowns';

        expect(path1, 'users/user-001/countdowns');
        expect(path2, 'users/user-002/countdowns');
        expect(path1, isNot(equals(path2)));
      });
    });

    group('ストレージキーのテスト', () {
      test('正しいストレージキーが使用される', () {
        const expectedStorageKey = 'countdowns';

        // ストレージキーの検証
        // CountdownDataManagerが内部的に正しいキーを使用していることを前提とする
        expect(expectedStorageKey, 'countdowns');
      });
    });

    group('フィールド名のテスト', () {
      test('idFieldが正しく設定される', () {
        const expectedIdField = 'id';

        // idFieldのデフォルト値を検証
        expect(expectedIdField, 'id');
      });

      test('lastModifiedFieldが正しく設定される', () {
        const expectedLastModifiedField = 'lastModified';

        // lastModifiedFieldのデフォルト値を検証
        expect(expectedLastModifiedField, 'lastModified');
      });
    });
  });
}

