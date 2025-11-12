import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// Firestore操作の汎用的な基本関数
/// 
/// Firestoreとの通信に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class FirestoreMk {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 単一ドキュメントを取得
  /// 
  /// 指定されたコレクションとドキュメントIDから単一のドキュメントを取得する
  /// ドキュメントが存在しない場合はnullを返す
  static Future<Map<String, dynamic>?> fetchDocument(
    String collectionPath,
    String documentId,
  ) async {
    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
      return null;
    } catch (e) {
      debugPrint('❌ ドキュメント取得エラー: $e');
      return null;
    }
  }
  
  /// コレクション全体を取得
  /// 
  /// 指定されたコレクションの全てのドキュメントを取得する
  /// 空のコレクションの場合は空のリストを返す
  static Future<List<Map<String, dynamic>>> fetchCollection(
    String collectionPath,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('❌ コレクション取得エラー: $e');
      return [];
    }
  }
  
  /// クエリ条件付きでドキュメントを取得
  /// 
  /// 指定された条件でフィルタリングしてドキュメントを取得する
  /// 条件はMap形式で指定（例: {'field': 'value', 'age': 25}）
  static Future<List<Map<String, dynamic>>> fetchWithQuery(
    String collectionPath,
    Map<String, dynamic> whereConditions,
  ) async {
    try {
      Query query = _firestore.collection(collectionPath);
      
      // 条件を適用
      whereConditions.forEach((field, value) {
        if (value is String) {
          query = query.where(field, isEqualTo: value);
        } else if (value is int || value is double) {
          query = query.where(field, isEqualTo: value);
        } else if (value is bool) {
          query = query.where(field, isEqualTo: value);
        }
      });
      
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('❌ クエリ取得エラー: $e');
      return [];
    }
  }
  
  /// 指定時刻以降に変更されたデータを取得
  /// 
  /// lastModifiedフィールドが指定時刻以降のドキュメントを取得する
  /// 差分同期などに使用する
  static Future<List<Map<String, dynamic>>> fetchModifiedSince(
    String collectionPath,
    DateTime since,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('lastModified', isGreaterThan: Timestamp.fromDate(since))
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('❌ 差分データ取得エラー: $e');
      return [];
    }
  }
  
  /// 単一ドキュメントを保存
  /// 
  /// 指定されたコレクションとドキュメントIDにデータを保存する
  /// 既存のドキュメントがある場合は上書きされる
  static Future<bool> saveDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data);
      
      debugPrint('✅ ドキュメント保存完了: $collectionPath/$documentId');
      return true;
    } catch (e) {
      debugPrint('❌ ドキュメント保存エラー: $e');
      return false;
    }
  }
  
  /// 単一ドキュメントを更新
  /// 
  /// 指定されたコレクションとドキュメントIDのデータを更新する
  /// ドキュメントが存在しない場合はエラーになる
  static Future<bool> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .update(data);
      
      debugPrint('✅ ドキュメント更新完了: $collectionPath/$documentId');
      return true;
    } catch (e) {
      debugPrint('❌ ドキュメント更新エラー: $e');
      return false;
    }
  }
  
  /// 単一ドキュメントを削除
  /// 
  /// 指定されたコレクションとドキュメントIDのドキュメントを削除する
  static Future<bool> deleteDocument(
    String collectionPath,
    String documentId,
  ) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .delete();
      
      debugPrint('✅ ドキュメント削除完了: $collectionPath/$documentId');
      return true;
    } catch (e) {
      debugPrint('❌ ドキュメント削除エラー: $e');
      return false;
    }
  }
  
  /// バッチで複数ドキュメントを書き込み
  /// 
  /// 複数のドキュメントを一度に書き込む（追加・更新・削除）
  /// 全て成功するか全て失敗するかのトランザクション処理
  static Future<bool> batchWrite(
    String collectionPath,
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final batch = _firestore.batch();
      final collectionRef = _firestore.collection(collectionPath);
      
      for (final docData in documents) {
        final docId = docData['id'] as String? ?? 
                     _firestore.collection(collectionPath).doc().id;
        final docRef = collectionRef.doc(docId);
        
        // idフィールドを除外して保存
        final dataToSave = Map<String, dynamic>.from(docData);
        dataToSave.remove('id');
        
        batch.set(docRef, dataToSave);
      }
      
      await batch.commit();
      debugPrint('✅ バッチ書き込み完了: ${documents.length}件');
      return true;
    } catch (e) {
      debugPrint('❌ バッチ書き込みエラー: $e');
      return false;
    }
  }
  
  /// 最終同期時刻を取得（Firestore側）
  /// 
  /// 指定されたユーザーの最終同期時刻を取得する
  /// 同期メタデータは'users/{userId}/sync_metadata/last_sync'に保存される
  static Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_metadata')
          .doc('last_sync')
          .get();
      
      if (doc.exists && doc.data() != null) {
        final timestamp = doc.data()!['timestamp'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      debugPrint('❌ 最終同期時刻取得エラー: $e');
      return null;
    }
  }
  
  /// 最終同期時刻を設定（Firestore側）
  /// 
  /// 指定されたユーザーの最終同期時刻を設定する
  /// 同期メタデータは'users/{userId}/sync_metadata/last_sync'に保存される
  static Future<bool> setLastSyncTime(String userId, DateTime time) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_metadata')
          .doc('last_sync')
          .set({'timestamp': Timestamp.fromDate(time)});
      
      debugPrint('✅ 最終同期時刻設定完了: $userId');
      return true;
    } catch (e) {
      debugPrint('❌ 最終同期時刻設定エラー: $e');
      return false;
    }
  }
  
  /// ドキュメントの存在確認
  /// 
  /// 指定されたコレクションとドキュメントIDのドキュメントが存在するか確認する
  static Future<bool> documentExists(
    String collectionPath,
    String documentId,
  ) async {
    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();
      
      return doc.exists;
    } catch (e) {
      debugPrint('❌ ドキュメント存在確認エラー: $e');
      return false;
    }
  }
  
  /// コレクションのドキュメント数を取得
  /// 
  /// 指定されたコレクションのドキュメント数を取得する
  /// 大量のドキュメントがある場合は時間がかかる可能性がある
  static Future<int> getCollectionCount(String collectionPath) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ コレクション数取得エラー: $e');
      return 0;
    }
  }
  
  /// タイムスタンプを現在時刻で作成
  /// 
  /// Firestore用のTimestampオブジェクトを現在時刻で作成する
  static Timestamp createTimestamp() {
    return Timestamp.fromDate(DateTime.now());
  }
  
  /// タイムスタンプを指定時刻で作成
  /// 
  /// Firestore用のTimestampオブジェクトを指定時刻で作成する
  static Timestamp createTimestampFromDate(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  // ===== Phase 2: リアルタイム同期（Stream購読） =====

  /// コレクション全体の変更をリアルタイム監視
  /// 
  /// **処理フロー**:
  /// 1. Firestoreのsnapshots()でストリーム作成
  /// 2. 各スナップショットのデータをMapに変換
  /// 3. エラー時は空リストを流す
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// 
  /// **戻り値**: ドキュメントリストのStream
  static Stream<List<Map<String, dynamic>>> watchCollection(
    String collectionPath,
  ) {
    try {
      return _firestore
          .collection(collectionPath)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => doc.data())
                .toList();
          })
          .handleError((error) async {
            await LogMk.logError(
              'コレクション監視エラー: $collectionPath',
              tag: 'FirestoreMk.watchCollection',
              error: error,
            );
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      LogMk.logError(
        'コレクション監視開始エラー: $collectionPath',
        tag: 'FirestoreMk.watchCollection',
        error: e,
      );
      return Stream.value([]);
    }
  }

  /// 単一ドキュメントの変更をリアルタイム監視
  /// 
  /// **処理フロー**:
  /// 1. Firestoreのsnapshots()でストリーム作成
  /// 2. ドキュメントが存在する場合はデータを返す
  /// 3. 存在しない場合はnullを返す
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `documentId`: ドキュメントID
  /// 
  /// **戻り値**: ドキュメントデータのStream（存在しない場合はnull）
  static Stream<Map<String, dynamic>?> watchDocument(
    String collectionPath,
    String documentId,
  ) {
    try {
      return _firestore
          .collection(collectionPath)
          .doc(documentId)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              return snapshot.data()!;
            }
            return null;
          })
          .handleError((error) async {
            await LogMk.logError(
              'ドキュメント監視エラー: $collectionPath/$documentId',
              tag: 'FirestoreMk.watchDocument',
              error: error,
            );
            return null;
          });
    } catch (e) {
      LogMk.logError(
        'ドキュメント監視開始エラー: $collectionPath/$documentId',
        tag: 'FirestoreMk.watchDocument',
        error: e,
      );
      return Stream.value(null);
    }
  }

  /// クエリ条件付きの変更をリアルタイム監視
  /// 
  /// **処理フロー**:
  /// 1. クエリ条件を適用
  /// 2. snapshots()でストリーム作成
  /// 3. 各スナップショットのデータをMapに変換
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `whereConditions`: クエリ条件（Map形式）
  /// 
  /// **戻り値**: ドキュメントリストのStream
  static Stream<List<Map<String, dynamic>>> watchQuery(
    String collectionPath,
    Map<String, dynamic> whereConditions,
  ) {
    try {
      Query query = _firestore.collection(collectionPath);
      
      // 条件を適用
      whereConditions.forEach((field, value) {
        if (value is String) {
          query = query.where(field, isEqualTo: value);
        } else if (value is int || value is double) {
          query = query.where(field, isEqualTo: value);
        } else if (value is bool) {
          query = query.where(field, isEqualTo: value);
        }
      });
      
      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          })
          .handleError((error) async {
            await LogMk.logError(
              'クエリ監視エラー: $collectionPath',
              tag: 'FirestoreMk.watchQuery',
              error: error,
            );
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      LogMk.logError(
        'クエリ監視開始エラー: $collectionPath',
        tag: 'FirestoreMk.watchQuery',
        error: e,
      );
      return Stream.value([]);
    }
  }

  /// 指定時刻以降に変更されたデータをリアルタイム監視
  /// 
  /// **処理フロー**:
  /// 1. lastModifiedフィールドでクエリ作成
  /// 2. snapshots()でストリーム作成
  /// 3. 各スナップショットのデータをMapに変換
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `since`: 基準時刻
  /// 
  /// **戻り値**: ドキュメントリストのStream
  static Stream<List<Map<String, dynamic>>> watchModifiedSince(
    String collectionPath,
    DateTime since,
  ) {
    try {
      return _firestore
          .collection(collectionPath)
          .where('lastModified', isGreaterThan: Timestamp.fromDate(since))
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => doc.data())
                .toList();
          })
          .handleError((error) async {
            await LogMk.logError(
              '差分監視エラー: $collectionPath',
              tag: 'FirestoreMk.watchModifiedSince',
              error: error,
            );
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      LogMk.logError(
        '差分監視開始エラー: $collectionPath',
        tag: 'FirestoreMk.watchModifiedSince',
        error: e,
      );
      return Stream.value([]);
    }
  }

  // ===== Phase 2: ID生成機能 =====

  /// Firestoreの自動ID生成
  /// 
  /// **処理フロー**:
  /// 1. Firestoreの.doc().idで自動ID生成
  /// 2. 生成されたIDを返す
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// 
  /// **戻り値**: 生成されたドキュメントID
  static String generateDocumentId(String collectionPath) {
    try {
      final id = _firestore.collection(collectionPath).doc().id;
      LogMk.logDebug('ドキュメントID生成: $id', tag: 'FirestoreMk.generateDocumentId');
      return id;
    } catch (e) {
      LogMk.logError(
        'ドキュメントID生成エラー: $collectionPath',
        tag: 'FirestoreMk.generateDocumentId',
        error: e,
      );
      rethrow;
    }
  }

  // ===== Phase 3: 高度なクエリ機能 =====

  /// 高度なクエリでドキュメントを取得
  /// 
  /// **処理フロー**:
  /// 1. クエリ条件、ソート、limit、offsetを適用
  /// 2. Firestoreからデータを取得
  /// 3. リストで返す
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `whereConditions`: where条件（Map形式、オプション）
  /// - `orderBy`: ソートフィールド（オプション）
  /// - `descending`: 降順フラグ（デフォルト: false）
  /// - `limit`: 取得件数制限（オプション）
  /// - `offset`: オフセット（オプション）
  /// 
  /// **戻り値**: ドキュメントのリスト
  static Future<List<Map<String, dynamic>>> fetchWithAdvancedQuery(
    String collectionPath, {
    Map<String, dynamic>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);
      
      // where条件を適用
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          if (value is String) {
            query = query.where(field, isEqualTo: value);
          } else if (value is int || value is double) {
            query = query.where(field, isEqualTo: value);
          } else if (value is bool) {
            query = query.where(field, isEqualTo: value);
          }
        });
      }
      
      // ソートを適用
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // limitを適用
      if (limit != null) {
        // offsetがある場合は、limit + offsetで取得してから後でスライス
        if (offset != null && offset > 0) {
          query = query.limit(limit + offset);
        } else {
          query = query.limit(limit);
        }
      }
      
      final querySnapshot = await query.get();
      var docs = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      // offsetがある場合はスライス
      if (offset != null && offset > 0) {
        docs = docs.skip(offset).toList();
      }
      
      await LogMk.logDebug(
        '高度なクエリ取得完了: ${docs.length}件',
        tag: 'FirestoreMk.fetchWithAdvancedQuery',
      );
      return docs;
    } catch (e, stackTrace) {
      await LogMk.logError(
        '高度なクエリ取得エラー: $collectionPath',
        tag: 'FirestoreMk.fetchWithAdvancedQuery',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// ページング機能付きの取得
  /// 
  /// **処理フロー**:
  /// 1. ページサイズとページ番号からoffsetを計算
  /// 2. fetchWithAdvancedQuery()を使用
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `pageSize`: ページサイズ
  /// - `pageNumber`: ページ番号（0始まり）
  /// - `orderBy`: ソートフィールド（オプション）
  /// - `descending`: 降順フラグ（デフォルト: false）
  /// 
  /// **戻り値**: ドキュメントのリスト
  static Future<List<Map<String, dynamic>>> fetchWithPagination(
    String collectionPath,
    int pageSize,
    int pageNumber, {
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final offset = pageSize * pageNumber;
      
      await LogMk.logDebug(
        'ページング取得: page=$pageNumber, size=$pageSize, offset=$offset',
        tag: 'FirestoreMk.fetchWithPagination',
      );
      
      return await fetchWithAdvancedQuery(
        collectionPath,
        orderBy: orderBy,
        descending: descending,
        limit: pageSize,
        offset: offset,
      );
    } catch (e, stackTrace) {
      await LogMk.logError(
        'ページング取得エラー: $collectionPath',
        tag: 'FirestoreMk.fetchWithPagination',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// カーソルベースのページング
  /// 
  /// **処理フロー**:
  /// 1. orderByでソート
  /// 2. startAfterDocがあればそれ以降を取得
  /// 3. limit+1件取得して、hasMoreを判定
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `limit`: 取得件数
  /// - `startAfterDoc`: 開始位置のドキュメント（オプション）
  /// - `orderBy`: ソートフィールド（デフォルト: 'id'）
  /// - `descending`: 降順フラグ（デフォルト: false）
  /// 
  /// **戻り値**: Map {'data': List, 'lastDoc': Map?, 'hasMore': bool}
  static Future<Map<String, dynamic>> fetchWithCursor(
    String collectionPath,
    int limit, {
    Map<String, dynamic>? startAfterDoc,
    String orderBy = 'id',
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);
      
      // ソートを適用
      query = query.orderBy(orderBy, descending: descending);
      
      // カーソル位置を適用
      if (startAfterDoc != null) {
        final startAfterValue = startAfterDoc[orderBy];
        if (startAfterValue != null) {
          query = query.startAfter([startAfterValue]);
        }
      }
      
      // limit+1件取得（hasMore判定用）
      query = query.limit(limit + 1);
      
      final querySnapshot = await query.get();
      final allDocs = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      // hasMoreを判定
      final hasMore = allDocs.length > limit;
      
      // 実際のデータ（limit件まで）
      final data = hasMore ? allDocs.sublist(0, limit) : allDocs;
      
      // 最後のドキュメント
      final lastDoc = data.isNotEmpty ? data.last : null;
      
      await LogMk.logDebug(
        'カーソルページング取得: ${data.length}件, hasMore=$hasMore',
        tag: 'FirestoreMk.fetchWithCursor',
      );
      
      return {
        'data': data,
        'lastDoc': lastDoc,
        'hasMore': hasMore,
      };
    } catch (e, stackTrace) {
      await LogMk.logError(
        'カーソルページング取得エラー: $collectionPath',
        tag: 'FirestoreMk.fetchWithCursor',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'data': <Map<String, dynamic>>[],
        'lastDoc': null,
        'hasMore': false,
      };
    }
  }

  // ===== Phase 3: 部分更新機能 =====

  /// 指定フィールドのみを更新
  /// 
  /// **処理フロー**:
  /// 1. updateDocument()を使用してフィールドを更新
  /// 2. ドキュメントが存在しない場合でもエラーにならない
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `documentId`: ドキュメントID
  /// - `fields`: 更新するフィールド（Map形式）
  /// 
  /// **戻り値**: 成功時true、失敗時false
  static Future<bool> updateDocumentPartial(
    String collectionPath,
    String documentId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .update(fields);
      
      await LogMk.logDebug(
        '部分更新完了: $collectionPath/$documentId (${fields.keys.length}フィールド)',
        tag: 'FirestoreMk.updateDocumentPartial',
      );
      return true;
    } catch (e, stackTrace) {
      await LogMk.logError(
        '部分更新エラー: $collectionPath/$documentId',
        tag: 'FirestoreMk.updateDocumentPartial',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// mergeオプション付きの保存
  /// 
  /// **処理フロー**:
  /// 1. SetOptions(merge: true)を使用
  /// 2. ドキュメントが存在しない場合は作成、存在する場合は指定フィールドのみ更新
  /// 
  /// **パラメータ**:
  /// - `collectionPath`: コレクションパス
  /// - `documentId`: ドキュメントID
  /// - `data`: 保存するデータ
  /// - `merge`: マージフラグ（デフォルト: true）
  /// 
  /// **戻り値**: 成功時true、失敗時false
  static Future<bool> mergeDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      if (merge) {
        await _firestore
            .collection(collectionPath)
            .doc(documentId)
            .set(data, SetOptions(merge: true));
      } else {
        await _firestore
            .collection(collectionPath)
            .doc(documentId)
            .set(data);
      }
      
      await LogMk.logDebug(
        'マージ保存完了: $collectionPath/$documentId (merge=$merge)',
        tag: 'FirestoreMk.mergeDocument',
      );
      return true;
    } catch (e, stackTrace) {
      await LogMk.logError(
        'マージ保存エラー: $collectionPath/$documentId',
        tag: 'FirestoreMk.mergeDocument',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
