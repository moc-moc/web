import 'package:test_flutter/data/sources/firestore_source.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// クエリ機能のMixin
/// 
/// 高度なクエリ機能と部分更新機能を提供
mixin FirestoreQueryMixin<T> {
  // 必要なフィールドとメソッド
  String Function(String userId) get collectionPathBuilder;
  String get idField;
  String get lastModifiedField;
  T Function(Map<String, dynamic> data) get fromFirestore;

  /// クエリ条件付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithQuery(
    String userId, {
    Map<String, dynamic>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      await LogMk.logDebug(
        'クエリ取得開始: $userId',
        tag: 'DataManager.getAllWithQuery',
      );
      
      final dataList = await FirestoreMk.fetchWithAdvancedQuery(
        collectionPathBuilder(userId),
        whereConditions: whereConditions,
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'クエリ取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithQuery',
          );
        }
      }
      
      await LogMk.logInfo('クエリ取得完了: ${items.length}件', tag: 'DataManager.getAllWithQuery');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('クエリ取得エラー: $userId', tag: 'DataManager.getAllWithQuery', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// ページング付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithPagination(
    String userId,
    int pageSize,
    int pageNumber, {
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      await LogMk.logDebug(
        'ページング取得開始: $userId (page=$pageNumber, size=$pageSize)',
        tag: 'DataManager.getAllWithPagination',
      );
      
      final dataList = await FirestoreMk.fetchWithPagination(
        collectionPathBuilder(userId),
        pageSize,
        pageNumber,
        orderBy: orderBy,
        descending: descending,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'ページング取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithPagination',
          );
        }
      }
      
      await LogMk.logInfo('ページング取得完了: ${items.length}件', tag: 'DataManager.getAllWithPagination');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('ページング取得エラー: $userId', tag: 'DataManager.getAllWithPagination', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// ソート付きでアイテムを取得
  /// 
  Future<List<T>> getAllWithSort(
    String userId,
    String orderBy, {
    bool descending = false,
    int? limit,
  }) async {
    try {
      await LogMk.logDebug(
        'ソート取得開始: $userId (orderBy=$orderBy, desc=$descending)',
        tag: 'DataManager.getAllWithSort',
      );
      
      final dataList = await FirestoreMk.fetchWithAdvancedQuery(
        collectionPathBuilder(userId),
        orderBy: orderBy,
        descending: descending,
        limit: limit,
      );
      
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'ソート取得: データ変換エラー: $e',
            tag: 'DataManager.getAllWithSort',
          );
        }
      }
      
      await LogMk.logInfo('ソート取得完了: ${items.length}件', tag: 'DataManager.getAllWithSort');
      return items;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('ソート取得エラー: $userId', tag: 'DataManager.getAllWithSort', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// カーソルベースのページング
  /// 
  Future<Map<String, dynamic>> getAllWithCursor(
    String userId,
    int limit, {
    Map<String, dynamic>? startAfterDoc,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      await LogMk.logDebug(
        'カーソルページング取得開始: $userId (limit=$limit)',
        tag: 'DataManager.getAllWithCursor',
      );
      
      final result = await FirestoreMk.fetchWithCursor(
        collectionPathBuilder(userId),
        limit,
        startAfterDoc: startAfterDoc,
        orderBy: orderBy ?? idField,
        descending: descending,
      );
      
      final dataList = result['data'] as List<Map<String, dynamic>>;
      final items = <T>[];
      
      for (final data in dataList) {
        try {
          final item = fromFirestore(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(
            'カーソルページング: データ変換エラー: $e',
            tag: 'DataManager.getAllWithCursor',
          );
        }
      }
      
      await LogMk.logInfo('カーソルページング取得完了: ${items.length}件', tag: 'DataManager.getAllWithCursor');
      
      return {
        'items': items,
        'lastDoc': result['lastDoc'],
        'hasMore': result['hasMore'],
      };
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('カーソルページング取得エラー: $userId', tag: 'DataManager.getAllWithCursor', error: error, stackTrace: stackTrace);
      return {
        'items': <T>[],
        'lastDoc': null,
        'hasMore': false,
      };
    }
  }

  /// 部分更新（指定フィールドのみ）
  /// 
  Future<bool> updatePartial(
    String userId,
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      await LogMk.logDebug(
        '部分更新開始: $userId/$id (${fields.keys.length}フィールド)',
        tag: 'DataManager.updatePartial',
      );
      
      // lastModifiedを自動追加
      final updatedFields = Map<String, dynamic>.from(fields);
      updatedFields[lastModifiedField] = FirestoreMk.createTimestamp();
      
      final success = await FirestoreMk.updateDocumentPartial(
        collectionPathBuilder(userId),
        id,
        updatedFields,
      );
      
      if (success) {
        await LogMk.logInfo('部分更新完了: $id', tag: 'DataManager.updatePartial');
      } else {
        await LogMk.logWarning('部分更新失敗: $id', tag: 'DataManager.updatePartial');
      }
      
      return success;
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.storage, stackTrace: stackTrace);
      await LogMk.logError('部分更新エラー: $userId/$id', tag: 'DataManager.updatePartial', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// userId自動取得版のupdatePartial
  /// 
  Future<bool> updatePartialWithAuth(
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final userId = AuthMk.getCurrentUserId();
      return await updatePartial(userId, id, fields);
    } catch (e, stackTrace) {
      final error = DataManagerError.handleError(e, defaultType: ErrorType.authentication, stackTrace: stackTrace);
      await LogMk.logError('updatePartialWithAuth: エラー', tag: 'DataManager.updatePartialWithAuth', error: error, stackTrace: stackTrace);
      return false;
    }
  }
}

