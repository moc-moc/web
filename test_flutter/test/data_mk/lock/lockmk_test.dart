import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/services/lock_service.dart';

void main() {
  group('LockMk Tests', () {
    test('createLock - ロックを作成', () {
      final lock = LockMk.createLock();
      expect(lock, isNotNull);
    });

    test('getNamedLock - 名前付きロックを取得', () {
      final lock1 = LockMk.getNamedLock('test_lock');
      final lock2 = LockMk.getNamedLock('test_lock');
      
      // 同じ名前のロックは同じインスタンスを返す
      expect(identical(lock1, lock2), true);
    });

    test('withLock - ロック内で処理を実行', () async {
      final lock = LockMk.createLock();
      var counter = 0;
      
      await LockMk.withLock(lock, () async {
        counter++;
      });
      
      expect(counter, 1);
    });

    test('withLock - 並行実行時のロック保護', () async {
      final lock = LockMk.createLock();
      var counter = 0;
      final results = <int>[];
      
      // 並行で実行
      await Future.wait([
        LockMk.withLock(lock, () async {
          final current = counter;
          await Future.delayed(Duration(milliseconds: 10));
          counter = current + 1;
          results.add(counter);
        }),
        LockMk.withLock(lock, () async {
          final current = counter;
          await Future.delayed(Duration(milliseconds: 10));
          counter = current + 1;
          results.add(counter);
        }),
      ]);
      
      // ロックが正しく動作していれば、counter = 2
      expect(counter, 2);
      expect(results, [1, 2]);
    });

    test('withLockSync - 同期処理をロック内で実行', () async {
      final lock = LockMk.createLock();
      
      final result = await LockMk.withLockSync(lock, () {
        return 'test_result';
      });
      
      expect(result, 'test_result');
    });

    test('clearAllNamedLocks - 全てのロックをクリア', () {
      LockMk.getNamedLock('lock1');
      LockMk.getNamedLock('lock2');
      
      LockMk.clearAllNamedLocks();
      
      // クリア後は新しいインスタンスが作成される
      final newLock1 = LockMk.getNamedLock('lock1');
      expect(newLock1, isNotNull);
    });
  });
}

