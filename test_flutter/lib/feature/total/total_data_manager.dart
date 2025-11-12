import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/firestore_repository.dart';

part 'total_data_manager.freezed.dart';
part 'total_data_manager.g.dart';

/// 累計データモデル
/// 
/// ユーザーの総ログイン日数と総作業時間を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **フィールド**:
/// - `id`: 固定値 'user_total'（ユーザーごとに1つのドキュメント）
/// - `totalLoginDays`: 総ログイン日数
/// - `totalWorkTimeMinutes`: 総作業時間（分単位）
/// - `lastTrackedDate`: 最後にトラッキングした日
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class TotalData with _$TotalData {
  /// TotalDataモデルのコンストラクタ
  /// 
  /// **パラメータ**:
  /// - `id`: 固定値 'user_total'
  /// - `totalLoginDays`: 総ログイン日数
  /// - `totalWorkTimeMinutes`: 総作業時間（分単位）
  /// - `lastTrackedDate`: 最後にトラッキングした日
  /// - `lastModified`: 最終更新日時
  const factory TotalData({
    required String id,
    required int totalLoginDays,
    required int totalWorkTimeMinutes,
    required DateTime lastTrackedDate,
    required DateTime lastModified,
  }) = _TotalData;

  /// JSONからTotalDataモデルを生成
  /// 
  /// SharedPreferencesからの読み込み時に使用されます。
  factory TotalData.fromJson(Map<String, dynamic> json) =>
      _$TotalDataFromJson(json);
}

/// 累計データ用データマネージャー
/// 
/// data_manager_shared_un.dartのFirestoreDataManagerを使用して
/// 累計データの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - トラッキング機能（1日1回のみログイン記録、作業時間加算）
class TotalDataManager {
  /// FirestoreDataManagerのインスタンス
  /// 
  /// このインスタンスがすべてのデータ操作を担当します。
  late final FirestoreDataManager<TotalData> _manager;

  /// コンストラクタ
  /// 
  /// FirestoreDataManager<TotalData>のインスタンスを作成し、
  /// 各種変換関数とコレクションパスを設定します。
  TotalDataManager() {
    _manager = FirestoreDataManager<TotalData>(
      // コレクションパス: users/{userId}/total
      collectionPathBuilder: (userId) => 'users/$userId/total',
      
      // Firestoreデータ → TotalDataモデル変換
      // Timestamp → DateTime変換を行う
      fromFirestore: (data) {
        return TotalData(
          id: data['id'] as String,
          totalLoginDays: data['totalLoginDays'] as int,
          totalWorkTimeMinutes: data['totalWorkTimeMinutes'] as int,
          lastTrackedDate: (data['lastTrackedDate'] as Timestamp).toDate(),
          lastModified: (data['lastModified'] as Timestamp).toDate(),
        );
      },
      
      // TotalDataモデル → Firestoreデータ変換
      // DateTime → Timestamp変換を行う
      toFirestore: (totalData) {
        return {
          'id': totalData.id,
          'totalLoginDays': totalData.totalLoginDays,
          'totalWorkTimeMinutes': totalData.totalWorkTimeMinutes,
          'lastTrackedDate': Timestamp.fromDate(totalData.lastTrackedDate),
          'lastModified': Timestamp.fromDate(totalData.lastModified),
        };
      },
      
      // SharedPreferencesのストレージキー
      storageKey: 'total_data',
      
      // JSON → TotalDataモデル変換（Freezedの生成メソッドを使用）
      fromJson: (json) => TotalData.fromJson(json),
      
      // TotalDataモデル → JSON変換（Freezedの生成メソッドを使用）
      toJson: (totalData) => totalData.toJson(),
      
      // IDフィールド名（デフォルト値）
      idField: 'id',
      
      // 最終更新フィールド名（デフォルト値）
      lastModifiedField: 'lastModified',
    );
  }

  // ===== 基本CRUD操作 =====

  /// 累計データを追加
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `totalData`: 追加する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  Future<bool> addTotalData(String userId, TotalData totalData) async {
    return await _manager.add(userId, totalData);
  }

  /// 累計データを追加（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `totalData`: 追加する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> addTotalDataWithAuth(TotalData totalData) async {
    return await _manager.addWithAuth(totalData);
  }

  /// 累計データを取得
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// 
  /// **戻り値**: 累計データ（存在しない場合はnull）
  Future<TotalData?> getTotalData(String userId) async {
    return await _manager.getById(userId, 'user_total');
  }

  /// 累計データを取得（認証自動取得版・Firestore優先）
  /// 
  /// Firestoreから最新データを取得し、取得できない場合のみローカルを使用します。
  /// 
  /// **戻り値**: 累計データ（存在しない場合はnull）
  /// 
  /// **動作フロー**:
  /// 1. Firestoreから取得を試みる
  /// 2. 取得成功時はローカルにも保存して最新化
  /// 3. 取得失敗時（オフライン等）はローカルを使用
  /// 
  /// **注意**: ログインしていない場合やオフラインの場合はローカルデータを返します
  Future<TotalData?> getTotalDataWithAuth() async {
    // Firestoreから取得を試みる（Firestore優先）
    try {
      final allData = await _manager.getAllWithAuth();
      if (allData.isNotEmpty) {
        final firestoreData = allData.first;
        // Firestoreから取得できた場合は、ローカルにも保存
        await updateLocalTotalData(firestoreData);
        debugPrint('✅ Firestoreからデータ取得・ローカル保存完了');
        return firestoreData;
      }
    } catch (e) {
      debugPrint('⚠️ Firestore取得失敗（オフライン？）: $e');
    }
    
    // Firestoreから取得できない場合のみローカルを使用
    final localData = await getLocalTotalData();
    if (localData != null) {
      debugPrint('📱 ローカルデータを使用');
      return localData;
    }
    
    return null;
  }

  /// 累計データを更新
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `totalData`: 更新する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  Future<bool> updateTotalData(String userId, TotalData totalData) async {
    return await _manager.update(userId, totalData);
  }

  /// 累計データを更新（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `totalData`: 更新する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> updateTotalDataWithAuth(TotalData totalData) async {
    return await _manager.updateWithAuth(totalData);
  }

  // ===== ローカルストレージ操作 =====

  /// ローカルから累計データを取得
  /// 
  /// **戻り値**: 累計データ（存在しない場合はnull）
  Future<TotalData?> getLocalTotalData() async {
    return await _manager.getLocalById('user_total');
  }

  /// ローカルに累計データを保存
  /// 
  /// **パラメータ**:
  /// - `totalData`: 保存する累計データ
  Future<void> saveLocalTotalData(TotalData totalData) async {
    await _manager.addLocal(totalData);
  }

  /// ローカルの累計データを更新
  /// 
  /// **パラメータ**:
  /// - `totalData`: 更新する累計データ
  Future<void> updateLocalTotalData(TotalData totalData) async {
    await _manager.updateLocal(totalData);
  }

  /// ローカルデータをクリア
  Future<void> clearLocalTotalData() async {
    await _manager.clearLocal();
  }

  // ===== 同期機能 =====

  /// FirestoreとSharedPreferencesを同期
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// 
  /// **戻り値**: 同期された累計データのリスト
  Future<List<TotalData>> syncTotalData(String userId) async {
    return await _manager.sync(userId);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  /// 
  /// **戻り値**: 同期された累計データのリスト
  Future<List<TotalData>> syncTotalDataWithAuth() async {
    return await _manager.syncWithAuth();
  }

  // ===== リトライ機能 =====

  /// リトライ機能付きで累計データを追加
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `totalData`: 追加する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> addTotalDataWithRetry(String userId, TotalData totalData) async {
    return await _manager.addWithRetry(userId, totalData);
  }

  /// リトライ機能付きで累計データを更新
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `totalData`: 更新する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> updateTotalDataWithRetry(String userId, TotalData totalData) async {
    return await _manager.updateWithRetry(userId, totalData);
  }

  /// リトライ機能付きで累計データを保存（upsert: 存在確認付き）
  /// 
  /// Firestoreに存在するか自動判定してaddまたはupdateを使用します。
  /// ローカルとFirestoreの状態が不一致の場合でも正しく動作します。
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `totalData`: 保存する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> saveTotalDataWithRetry(String userId, TotalData totalData) async {
    return await _manager.saveWithRetry(userId, totalData);
  }

  /// リトライ機能付きで累計データを保存（認証自動取得版）
  /// 
  /// Firestoreに存在するか自動判定してaddまたはupdateを使用します。
  /// 
  /// **パラメータ**:
  /// - `totalData`: 保存する累計データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> saveTotalDataWithRetryAuth(TotalData totalData) async {
    return await _manager.saveWithRetryAuth(totalData);
  }

  // ===== カスタム機能（累計データ特有） =====

  /// トラッキング完了時の記録
  /// 
  /// **処理フロー**:
  /// 1. ローカルから現在のTotalDataを取得
  /// 2. データが存在しない場合は初期データを作成
  /// 3. 同じ日なら作業時間のみ加算
  /// 4. 別の日ならログイン日数+1、作業時間加算
  /// 5. 新しいTotalDataを作成してローカルに保存
  /// 6. ログイン済みならFirestoreにも保存
  /// 
  /// **パラメータ**:
  /// - `workTimeMinutes`: 作業時間（分単位）
  /// 
  /// **戻り値**: {'success': bool, 'message': String, 'totalLoginDays': int, 'totalWorkTimeMinutes': int}
  Future<Map<String, dynamic>> trackFinished({required int workTimeMinutes}) async {
    try {
      // 1. ローカルから現在のTotalDataを取得
      TotalData? currentData = await getLocalTotalData();
      
      final now = DateTime.now();
      
      // 2. データが存在しない場合は初期データを作成（初回トラッキング）
      if (currentData == null) {
        final newData = TotalData(
          id: 'user_total',
          totalLoginDays: 1,
          totalWorkTimeMinutes: workTimeMinutes,
          lastTrackedDate: now,
          lastModified: now,
        );
        
        // ローカルに保存
        await saveLocalTotalData(newData);
        debugPrint('✅ [trackFinished] ローカル保存完了: totalLoginDays=${newData.totalLoginDays}, totalWorkTime=${newData.totalWorkTimeMinutes}分');
        
        // ログイン済みならFirestoreにも保存（upsert: 存在確認付き）
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final userId = currentUser.uid;
            debugPrint('🔍 [trackFinished] ユーザーID取得成功: $userId');
            debugPrint('🔥 [trackFinished] Firestore保存開始...');
            final firestoreSuccess = await _manager.saveWithRetry(userId, newData);
            debugPrint('🔥 [trackFinished] Firestore保存結果: $firestoreSuccess');
            if (firestoreSuccess) {
              debugPrint('✅ [trackFinished] Firestore保存成功！');
            } else {
              debugPrint('❌ [trackFinished] Firestore保存失敗（リトライキューに追加された可能性）');
            }
          } catch (e) {
            debugPrint('❌ Firestore保存エラー: $e');
            debugPrint('❌ スタックトレース: ${StackTrace.current}');
          }
        } else {
          debugPrint('⚠️ [trackFinished] Firestore保存スキップ（未ログイン）');
        }
        
        return {
          'success': true,
          'message': '1日目のトラッキング完了！作業時間: ${formatWorkTime(workTimeMinutes)}',
          'totalLoginDays': 1,
          'totalWorkTimeMinutes': workTimeMinutes,
        };
      }
      
      int newLoginDays;
      int newWorkTimeMinutes;
      
      // 3. 同じ日かチェック
      if (_isSameDay(currentData.lastTrackedDate, now)) {
        // 同じ日なら作業時間のみ加算
        newLoginDays = currentData.totalLoginDays;
        newWorkTimeMinutes = currentData.totalWorkTimeMinutes + workTimeMinutes;
        
        debugPrint('✅ [trackFinished] 本日2回目以降 - 作業時間のみ加算');
      } else {
        // 4. 別の日ならログイン日数+1、作業時間加算
        newLoginDays = currentData.totalLoginDays + 1;
        newWorkTimeMinutes = currentData.totalWorkTimeMinutes + workTimeMinutes;
        
        debugPrint('✅ [trackFinished] 新しい日 - ログイン日数+1、作業時間加算');
      }
      
      // 5. 新しいTotalDataを作成
      final updatedData = TotalData(
        id: 'user_total',
        totalLoginDays: newLoginDays,
        totalWorkTimeMinutes: newWorkTimeMinutes,
        lastTrackedDate: now,
        lastModified: now,
      );
      
      // ローカルに保存
      await updateLocalTotalData(updatedData);
      debugPrint('✅ [trackFinished] ローカル更新完了: totalLoginDays=${updatedData.totalLoginDays}, totalWorkTime=${updatedData.totalWorkTimeMinutes}分');
      
      // 6. ログイン済みならFirestoreにも保存（upsert: 存在確認付き）
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final userId = currentUser.uid;
          debugPrint('🔍 [trackFinished] ユーザーID取得成功: $userId');
          debugPrint('🔥 [trackFinished] Firestore保存開始...');
          final firestoreSuccess = await _manager.saveWithRetry(userId, updatedData);
          debugPrint('🔥 [trackFinished] Firestore保存結果: $firestoreSuccess');
          if (firestoreSuccess) {
            debugPrint('✅ [trackFinished] Firestore保存成功！');
          } else {
            debugPrint('❌ [trackFinished] Firestore保存失敗（リトライキューに追加された可能性）');
          }
        } catch (e) {
          debugPrint('❌ Firestore保存エラー: $e');
          debugPrint('❌ スタックトレース: ${StackTrace.current}');
        }
      } else {
        debugPrint('⚠️ [trackFinished] Firestore保存スキップ（未ログイン）');
      }
      
      return {
        'success': true,
        'message': 'トラッキング完了！総ログイン: $newLoginDays日、総作業時間: ${formatWorkTime(newWorkTimeMinutes)}',
        'totalLoginDays': newLoginDays,
        'totalWorkTimeMinutes': newWorkTimeMinutes,
      };
      
    } catch (e) {
      debugPrint('❌ トラッキングエラー: $e');
      return {
        'success': false,
        'message': 'エラーが発生しました',
        'totalLoginDays': 0,
        'totalWorkTimeMinutes': 0,
      };
    }
  }

  /// 累計データを取得（ローカル優先、なければ初期値）
  /// 
  /// **戻り値**: 累計データ
  Future<TotalData> getTotalDataOrDefault() async {
    // ローカルから取得を試みる
    final localData = await getLocalTotalData();
    if (localData != null) {
      return localData;
    }
    
    // ローカルになければ初期値を返す
    return TotalData(
      id: 'user_total',
      totalLoginDays: 0,
      totalWorkTimeMinutes: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  /// 作業時間を「X日 X時間 X分」形式でフォーマット
  /// 
  /// **パラメータ**:
  /// - `minutes`: 作業時間（分単位）
  /// 
  /// **戻り値**: フォーマットされた文字列
  /// 
  /// **例**:
  /// - 90分 → "1時間 30分"
  /// - 1500分 → "1日 1時間 0分"
  /// - 30分 → "30分"
  String formatWorkTime(int minutes) {
    final days = minutes ~/ (24 * 60);
    final hours = (minutes % (24 * 60)) ~/ 60;
    final mins = minutes % 60;
    
    final parts = <String>[];
    
    if (days > 0) {
      parts.add('$days日');
    }
    if (hours > 0) {
      parts.add('$hours時間');
    }
    if (mins > 0 || parts.isEmpty) {
      parts.add('$mins分');
    }
    
    return parts.join(' ');
  }

  // ===== ヘルパーメソッド =====

  /// 2つの日付が同じ日かどうかを判定
  /// 
  /// **パラメータ**:
  /// - `date1`: 日付1
  /// - `date2`: 日付2
  /// 
  /// **戻り値**: 同じ日ならtrue
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

