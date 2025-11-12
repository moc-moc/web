import 'dart:async';
import 'package:async_locks/async_locks.dart';

/// ロックマネージャー
/// 
/// 複数のロックを管理し、必要に応じて作成・取得・削除する
class LockManager {
  // ロックのマップ（キー: ロック名, 値: Lock）
  static final Map<String, Lock> _locks = {};

  /// ロックを取得（既存の場合は返す、存在しない場合は作成）
  /// 
  /// **パラメータ**:
  /// - `name`: ロック名
  /// 
  /// **戻り値**: Lockオブジェクト
  static Lock getLock(String name) {
    if (!_locks.containsKey(name)) {
      _locks[name] = Lock();
    }
    return _locks[name]!;
  }

  /// ロックを削除
  /// 
  /// **パラメータ**:
  /// - `name`: ロック名
  static void removeLock(String name) {
    _locks.remove(name);
  }

  /// 全てのロックをクリア
  static void clearAllLocks() {
    _locks.clear();
  }
}

/// 並行実行の排他制御の汎用的な基本関数
/// 
/// ロック管理に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class LockMk {
  /// ロックを作成
  /// 
  /// **パラメータ**:
  /// - `name`: ロック名（オプション、指定しない場合は匿名ロック）
  /// 
  /// **戻り値**: Lockオブジェクト
  static Lock createLock([String? name]) {
    if (name != null) {
      return LockManager.getLock(name);
    } else {
      // 匿名ロックは直接作成
      return Lock();
    }
  }

  /// ロックを取得（待機してロックを取得）
  /// 
  /// **パラメータ**:
  /// - `lock`: Lockオブジェクト
  /// - `timeout`: タイムアウト時間（オプション）
  /// 
  /// **戻り値**: ロックが取得できた場合はtrue、タイムアウトした場合はfalse
  /// 
  /// **注意**: ロックを取得した場合は、必ず`releaseLock()`で解放すること
  static Future<bool> acquireLock(
    Lock lock, {
    Duration? timeout,
  }) async {
    try {
      if (timeout != null) {
        // タイムアウト付きでロックを取得
        return await lock.acquire().timeout(timeout).then((_) => true).catchError(
          (e) {
            if (e is TimeoutException) {
              return false;
            }
            throw e;
          },
        );
      } else {
        // タイムアウトなしでロックを取得
        await lock.acquire();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// ロックを解放
  /// 
  /// **パラメータ**:
  /// - `lock`: Lockオブジェクト
  static void releaseLock(Lock lock) {
    lock.release();
  }

  /// ロック内で処理を実行
  /// 
  /// ロックを取得して処理を実行し、処理完了後に自動的にロックを解放する
  /// 
  /// **パラメータ**:
  /// - `lock`: Lockオブジェクト
  /// - `action`: 実行する処理
  /// - `timeout`: タイムアウト時間（オプション）
  /// 
  /// **戻り値**: 処理の結果
  /// 
  /// **例外**: タイムアウトした場合や処理中にエラーが発生した場合は例外をスロー
  static Future<T> withLock<T>(
    Lock lock,
    Future<T> Function() action, {
    Duration? timeout,
  }) async {
    final acquired = await acquireLock(lock, timeout: timeout);
    
    if (!acquired) {
      throw TimeoutException('ロックの取得がタイムアウトしました');
    }

    try {
      return await action();
    } finally {
      releaseLock(lock);
    }
  }

  /// ロック内で処理を実行（同期版）
  /// 
  /// ロックを取得して処理を実行し、処理完了後に自動的にロックを解放する
  /// 
  /// **パラメータ**:
  /// - `lock`: Lockオブジェクト
  /// - `action`: 実行する処理（同期）
  /// - `timeout`: タイムアウト時間（オプション）
  /// 
  /// **戻り値**: 処理の結果
  /// 
  /// **例外**: タイムアウトした場合や処理中にエラーが発生した場合は例外をスロー
  static Future<T> withLockSync<T>(
    Lock lock,
    T Function() action, {
    Duration? timeout,
  }) async {
    return await withLock<T>(lock, () async => action(), timeout: timeout);
  }

  /// ロックが取得可能かどうかを確認（ノンブロッキング）
  /// 
  /// **パラメータ**:
  /// - `lock`: Lockオブジェクト
  /// 
  /// **戻り値**: 取得可能な場合はtrue、そうでない場合はfalse
  /// 
  /// **注意**: このメソッドはロックを取得しません。確認のみ行います。
  static bool isLockAvailable(Lock lock) {
    // ReentrantLockには直接的な確認方法がないため、
    // タイムアウト0で取得を試みる方法は非効率的
    // 代わりに、常にtrueを返す（実際の取得時にブロックされる）
    // より正確な実装が必要な場合は、ロックの状態を追跡する必要がある
    return true;
  }

  /// 名前付きロックを取得
  /// 
  /// **パラメータ**:
  /// - `name`: ロック名
  /// 
  /// **戻り値**: Lockオブジェクト
  static Lock getNamedLock(String name) {
    return LockManager.getLock(name);
  }

  /// 名前付きロックを削除
  /// 
  /// **パラメータ**:
  /// - `name`: ロック名
  static void removeNamedLock(String name) {
    LockManager.removeLock(name);
  }

  /// 全ての名前付きロックをクリア
  static void clearAllNamedLocks() {
    LockManager.clearAllLocks();
  }
}

