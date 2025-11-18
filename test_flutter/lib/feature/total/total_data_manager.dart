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
      totalWorkTimeMinutes: data['totalWorkTimeMinutes'] as int,
      lastTrackedDate: (data['lastTrackedDate'] as Timestamp).toDate(),
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(TotalData item) {
    return {
      'id': item.id,
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
  /// パフォーマンス最適化: 全データ取得ではなく単一データ取得を使用
  Future<TotalData?> getTotalDataWithAuth() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('⚠️ [getTotalDataWithAuth] ユーザー未認証');
        return await getLocalTotalData();
      }
      
      // Firestoreから単一データを取得（パフォーマンス最適化）
      final firestoreData = await manager.getById(userId, 'user_total');
      if (firestoreData != null) {
        // Firestoreから取得できた場合は、ローカルにも保存
        await updateLocalTotalData(firestoreData);
        return firestoreData;
      }
    } catch (e) {
      debugPrint('⚠️ [getTotalDataWithAuth] Firestore取得失敗（オフライン？）: $e');
    }
    
    // Firestoreから取得できない場合のみローカルを使用
    return await getLocalTotalData();
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
  /// **戻り値**: {'success': bool, 'message': String, 'totalWorkTimeMinutes': int}
  Future<Map<String, dynamic>> trackFinished({required int workTimeMinutes}) async {
    try {
      // 1. ローカルから現在のTotalDataを取得
      TotalData? currentData = await getLocalTotalData();
      
      final now = DateTime.now();
      
      // 2. データが存在しない場合は初期データを作成（初回トラッキング）
      if (currentData == null) {
        final newData = TotalData(
          id: 'user_total',
          totalWorkTimeMinutes: workTimeMinutes,
          lastTrackedDate: now,
          lastModified: now,
        );
        
        // ローカルに保存
        await saveLocalTotalData(newData);
        
        // ログイン済みならFirestoreにも保存（upsert: 存在確認付き）
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final userId = currentUser.uid;
            await manager.saveWithRetry(userId, newData);
          } catch (e) {
            debugPrint('❌ Firestore保存エラー: $e');
          }
        }
        
        return {
          'success': true,
          'message': 'トラッキング完了！作業時間: ${formatWorkTime(workTimeMinutes)}',
          'totalWorkTimeMinutes': workTimeMinutes,
        };
      }
      
      int newWorkTimeMinutes;
      
      // 3. 同じ日かチェック
      if (_isSameDay(currentData.lastTrackedDate, now)) {
        // 同じ日なら作業時間のみ加算
        newWorkTimeMinutes = currentData.totalWorkTimeMinutes + workTimeMinutes;
      } else {
        // 4. 別の日なら作業時間加算
        newWorkTimeMinutes = currentData.totalWorkTimeMinutes + workTimeMinutes;
      }
      
      // 5. 新しいTotalDataを作成
      final updatedData = TotalData(
        id: 'user_total',
        totalWorkTimeMinutes: newWorkTimeMinutes,
        lastTrackedDate: now,
        lastModified: now,
      );
      
      // ローカルに保存
      await updateLocalTotalData(updatedData);
      
      // 6. ログイン済みならFirestoreにも保存（upsert: 存在確認付き）
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final userId = currentUser.uid;
          await manager.saveWithRetry(userId, updatedData);
        } catch (e) {
          debugPrint('❌ Firestore保存エラー: $e');
        }
      }
      
      return {
        'success': true,
        'message': 'トラッキング完了！総作業時間: ${formatWorkTime(newWorkTimeMinutes)}',
        'totalWorkTimeMinutes': newWorkTimeMinutes,
      };
      
    } catch (e) {
      debugPrint('❌ トラッキングエラー: $e');
      return {
        'success': false,
        'message': 'エラーが発生しました',
        'totalWorkTimeMinutes': 0,
      };
    }
  }

  // フォーマット結果のキャッシュ（パフォーマンス最適化）
  static final Map<int, String> _formatWorkTimeCache = {};
  static const int _maxCacheSize = 100;

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
  /// 
  /// **パフォーマンス最適化**: 結果をキャッシュして再利用
  String formatWorkTime(int minutes) {
    // キャッシュから取得を試みる
    if (_formatWorkTimeCache.containsKey(minutes)) {
      return _formatWorkTimeCache[minutes]!;
    }
    
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
    
    final result = parts.join(' ');
    
    // キャッシュに保存（サイズ制限あり）
    if (_formatWorkTimeCache.length < _maxCacheSize) {
      _formatWorkTimeCache[minutes] = result;
    }
    
    return result;
  }

  // ===== ヘルパーメソッド =====

  /// 2つの日付が同じ日かどうかを判定
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
