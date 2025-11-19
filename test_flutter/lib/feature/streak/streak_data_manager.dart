import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/streak/streak_model.dart';

/// 連続継続日数用データマネージャー
/// 
/// BaseDataManager<StreakData>を継承して、連続継続日数データの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - トラッキング機能（1日1回のみ記録、連続日数計算）
class StreakDataManager extends BaseDataManager<StreakData> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/streak';

  @override
  StreakData convertFromFirestore(Map<String, dynamic> data) {
    return StreakData(
      id: data['id'] as String,
      currentStreak: data['currentStreak'] as int,
      longestStreak: data['longestStreak'] as int,
      lastTrackedDate: (data['lastTrackedDate'] as Timestamp).toDate(),
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(StreakData item) {
    return {
      'id': item.id,
      'currentStreak': item.currentStreak,
      'longestStreak': item.longestStreak,
      'lastTrackedDate': Timestamp.fromDate(item.lastTrackedDate),
      'lastModified': Timestamp.fromDate(item.lastModified),
    };
  }

  @override
  StreakData convertFromJson(Map<String, dynamic> json) => StreakData.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(StreakData item) => item.toJson();

  @override
  String get storageKey => 'streak_data';

  // ===== カスタム機能（連続継続日数特有） =====

  /// 連続継続日数データを取得（認証自動取得版・Firestore優先）
  /// 
  /// Firestoreから最新データを取得し、取得できない場合のみローカルを使用します。
  /// パフォーマンス最適化: 全データ取得ではなく単一データ取得を使用
  Future<StreakData?> getStreakDataWithAuth() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('⚠️ [getStreakDataWithAuth] ユーザー未認証');
        return await getLocalStreakData();
      }
      
      // Firestoreから単一データを取得（パフォーマンス最適化）
      final firestoreData = await manager.getById(userId, 'user_streak');
      if (firestoreData != null) {
        // Firestoreから取得できた場合は、ローカルにも保存
        await updateLocalStreakData(firestoreData);
        debugPrint('✅ Firestoreからデータ取得・ローカル保存完了');
        return firestoreData;
      }
    } catch (e) {
      debugPrint('⚠️ Firestore取得失敗（オフライン？）: $e');
    }
    
    // Firestoreから取得できない場合のみローカルを使用
    final localData = await getLocalStreakData();
    if (localData != null) {
      debugPrint('📱 ローカルデータを使用');
      return localData;
    }
    
    return null;
  }

  /// ローカルから連続継続日数データを取得
  Future<StreakData?> getLocalStreakData() async {
    return await manager.getLocalById('user_streak');
  }

  /// ローカルに連続継続日数データを保存
  Future<void> saveLocalStreakData(StreakData streakData) async {
    await manager.addLocal(streakData);
  }

  /// ローカルの連続継続日数データを更新
  Future<void> updateLocalStreakData(StreakData streakData) async {
    await manager.updateLocal(streakData);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  Future<List<StreakData>> syncStreakDataWithAuth() async {
    return await manager.syncWithAuth();
  }

  /// 連続継続日数データを取得（ローカル優先、なければ初期値）
  Future<StreakData> getStreakDataOrDefault() async {
    // ローカルから取得を試みる
    final localData = await getLocalStreakData();
    if (localData != null) {
      return localData;
    }
    
    // ローカルになければ初期値を返す
    return StreakData(
      id: 'user_streak',
      currentStreak: 0,
      longestStreak: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  /// トラッキング完了時の記録
  /// 
  /// **処理フロー**:
  /// 1. ローカルから現在のStreakDataを取得
  /// 2. データが存在しない場合は初期データを作成
  /// 3. 同じ日なら「本日は記録済みです」を返す
  /// 4. 前日なら連続日数+1
  /// 5. 1日以上空いていたらリセット（currentStreak=1）
  /// 6. longestStreakの更新チェック
  /// 7. 新しいStreakDataを作成してローカルに保存
  /// 8. ログイン済みならFirestoreにも保存
  /// 
  /// **戻り値**: {'success': bool, 'message': String, 'streak': int}
  Future<Map<String, dynamic>> trackFinished() async {
    try {
      // 1. ローカルから現在のStreakDataを取得
      StreakData? currentData = await getLocalStreakData();
      
      final now = DateTime.now();
      
      // 2. データが存在しない場合は初期データを作成（初回トラッキング）
      if (currentData == null) {
        final newData = StreakData(
          id: 'user_streak',
          currentStreak: 1,
          longestStreak: 1,
          lastTrackedDate: now,
          lastModified: now,
        );
        
        // ローカルに保存
        await saveLocalStreakData(newData);
        debugPrint('✅ [trackFinished] ローカル保存完了: currentStreak=${newData.currentStreak}');
        
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
          'message': '1日連続記録中！',
          'streak': 1,
        };
      }
      
      // 日付比較結果をキャッシュ（同じ日付の比較を避ける）
      final lastTrackedDate = currentData.lastTrackedDate;
      final isSameDayResult = _isSameDay(lastTrackedDate, now);
      
      // 3. 同じ日かチェック
      if (isSameDayResult) {
        // 同じ日でもlastModifiedだけ更新
        final updatedData = currentData.copyWith(
          lastModified: now,
        );
        
        // ローカルに保存
        await updateLocalStreakData(updatedData);
        debugPrint('✅ [trackFinished] 本日記録済み - lastModified更新');
        
        // Firestoreにも保存
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final userId = currentUser.uid;
            await manager.saveWithRetry(userId, updatedData);
            debugPrint('✅ [trackFinished] Firestore lastModified更新完了');
          } catch (e) {
            debugPrint('⚠️ Firestore更新エラー: $e');
          }
        }
        
        return {
          'success': false,
          'message': '本日は記録済みです',
          'streak': updatedData.currentStreak,
        };
      }
      
      int newStreak;
      
      // 4. 前日なら連続日数+1（日付比較結果を再利用）
      final isYesterdayResult = _isYesterday(lastTrackedDate, now);
      if (isYesterdayResult) {
        newStreak = currentData.currentStreak + 1;
      } else {
        // 5. 1日以上空いていたらリセット
        newStreak = 1;
      }
      
      // 6. longestStreakの更新チェック
      final newLongestStreak = newStreak > currentData.longestStreak 
          ? newStreak 
          : currentData.longestStreak;
      
      // 7. 新しいStreakDataを作成
      final updatedData = StreakData(
        id: 'user_streak',
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastTrackedDate: now,
        lastModified: now,
      );
      
      // ローカルに保存
      await updateLocalStreakData(updatedData);
      debugPrint('✅ [trackFinished] ローカル更新完了: currentStreak=${updatedData.currentStreak}');
      
      // 8. ログイン済みならFirestoreにも保存（upsert: 存在確認付き）
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
        'message': '$newStreak日連続記録中！',
        'streak': newStreak,
      };
      
    } catch (e) {
      debugPrint('❌ トラッキングエラー: $e');
      return {
        'success': false,
        'message': 'エラーが発生しました',
        'streak': 0,
      };
    }
  }

  // ===== ヘルパーメソッド =====

  /// 2つの日付が同じ日かどうかを判定
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 指定された日付が今日の前日かどうかを判定
  bool _isYesterday(DateTime date, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }
}
