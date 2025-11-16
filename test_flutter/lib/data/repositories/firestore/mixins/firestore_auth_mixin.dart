import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// 認証統合メソッドのMixin
/// 
/// userId自動取得版のCRUD操作を提供
mixin FirestoreAuthMixin<T> {
  // 必要なメソッド
  Future<bool> add(String userId, T item);
  Future<bool> update(String userId, T item);
  Future<bool> delete(String userId, String id);
  Future<List<T>> sync(String userId);
  Future<List<T>> getAll(String userId);

  /// userId自動取得版のadd
  /// 
  Future<bool> addWithAuth(T item) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await add(userId, item);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('addWithAuth: エラー', tag: 'DataManager.addWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のupdate
  /// 
  Future<bool> updateWithAuth(T item) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await update(userId, item);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('updateWithAuth: エラー', tag: 'DataManager.updateWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のdelete
  /// 
  Future<bool> deleteWithAuth(String id) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await delete(userId, id);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('deleteWithAuth: エラー', tag: 'DataManager.deleteWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のsync
  /// 
  Future<List<T>> syncWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await sync(userId);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('syncWithAuth: エラー', tag: 'DataManager.syncWithAuth', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// userId自動取得版のgetAll
  /// 
  Future<List<T>> getAllWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await getAll(userId);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('getAllWithAuth: エラー', tag: 'DataManager.getAllWithAuth', error: error, stackTrace: stackTrace);
      return [];
    }
  }
}

