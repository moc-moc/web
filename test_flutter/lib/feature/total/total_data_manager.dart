import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/total/total_model.dart';

/// 累計データ用データマネージャー
/// 
/// BaseDataManager<TotalData>を継承して、累計データの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - トラッキング機能（1日1回のみログイン記録、作業時間加算）
class TotalDataManager extends BaseDataManager<TotalData> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/total';

  @override
  TotalData convertFromFirestore(Map<String, dynamic> data) {
    return TotalData(
      id: data['id'] as String,
      totalLoginDays: data['totalLoginDays'] as int,
      totalWorkTimeMinutes: data['totalWorkTimeMinutes'] as int,
      lastTrackedDate: (data['lastTrackedDate'] as Timestamp).toDate(),
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(TotalData item) {
    return {
      'id': item.id,
      'totalLoginDays': item.totalLoginDays,
      'totalWorkTimeMinutes': item.totalWorkTimeMinutes,
      'lastTrackedDate': Timestamp.fromDate(item.lastTrackedDate),
      'lastModified': Timestamp.fromDate(item.lastModified),
    };
  }

  @override
  TotalData convertFromJson(Map<String, dynamic> json) => TotalData.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(TotalData item) => item.toJson();

  @override
  String get storageKey => 'total_data';

  // ===== カスタム機能（累計データ特有） =====

  /// 累計データを取得（認証自動取得版・Firestore優先）
  /// 
  /// Firestoreから最新データを取得し、取得できない場合のみローカルを使用します。
  Future<TotalData?> getTotalDataWithAuth() async {
    // Firestoreから取得を試みる（Firestore優先）
    try {
      final allData = await manager.getAllWithAuth();
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

  /// ローカルから累計データを取得
  Future<TotalData?> getLocalTotalData() async {
    return await manager.getLocalById('user_total');
  }

  /// ローカルに累計データを保存
  Future<void> saveLocalTotalData(TotalData totalData) async {
    await manager.addLocal(totalData);
  }

  /// ローカルの累計データを更新
  Future<void> updateLocalTotalData(TotalData totalData) async {
    await manager.updateLocal(totalData);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  Future<List<TotalData>> syncTotalDataWithAuth() async {
    return await manager.syncWithAuth();
  }

  /// 累計データを取得（ローカル優先、なければ初期値）
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
            final firestoreSuccess = await manager.saveWithRetry(userId, newData);
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
          final firestoreSuccess = await manager.saveWithRetry(userId, updatedData);
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
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
