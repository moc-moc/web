import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/firestore_repository.dart';

part 'streak_data_manager.freezed.dart';
part 'streak_data_manager.g.dart';

/// 連続継続日数モデル
/// 
/// ユーザーのトラッキング連続日数を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **フィールド**:
/// - `id`: 固定値 'user_streak'（ユーザーごとに1つのドキュメント）
/// - `currentStreak`: 現在の連続日数
/// - `longestStreak`: 最長連続記録
/// - `lastTrackedDate`: 最後にトラッキングした日
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class StreakData with _$StreakData {
  /// StreakDataモデルのコンストラクタ
  /// 
  /// **パラメータ**:
  /// - `id`: 固定値 'user_streak'
  /// - `currentStreak`: 現在の連続日数
  /// - `longestStreak`: 最長連続記録
  /// - `lastTrackedDate`: 最後にトラッキングした日
  /// - `lastModified`: 最終更新日時
  const factory StreakData({
    required String id,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastTrackedDate,
    required DateTime lastModified,
  }) = _StreakData;

  /// JSONからStreakDataモデルを生成
  /// 
  /// SharedPreferencesからの読み込み時に使用されます。
  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);
}

/// 連続継続日数用データマネージャー
/// 
/// data_manager_shared_un.dartのFirestoreDataManagerを使用して
/// 連続継続日数データの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - トラッキング機能（1日1回のみ記録、連続日数計算）
class StreakDataManager {
  /// FirestoreDataManagerのインスタンス
  /// 
  /// このインスタンスがすべてのデータ操作を担当します。
  late final FirestoreDataManager<StreakData> _manager;

  /// コンストラクタ
  /// 
  /// FirestoreDataManager<StreakData>のインスタンスを作成し、
  /// 各種変換関数とコレクションパスを設定します。
  StreakDataManager() {
    _manager = FirestoreDataManager<StreakData>(
      // コレクションパス: users/{userId}/streak
      collectionPathBuilder: (userId) => 'users/$userId/streak',
      
      // Firestoreデータ → StreakDataモデル変換
      // Timestamp → DateTime変換を行う
      fromFirestore: (data) {
        return StreakData(
          id: data['id'] as String,
          currentStreak: data['currentStreak'] as int,
          longestStreak: data['longestStreak'] as int,
          lastTrackedDate: (data['lastTrackedDate'] as Timestamp).toDate(),
          lastModified: (data['lastModified'] as Timestamp).toDate(),
        );
      },
      
      // StreakDataモデル → Firestoreデータ変換
      // DateTime → Timestamp変換を行う
      toFirestore: (streakData) {
        return {
          'id': streakData.id,
          'currentStreak': streakData.currentStreak,
          'longestStreak': streakData.longestStreak,
          'lastTrackedDate': Timestamp.fromDate(streakData.lastTrackedDate),
          'lastModified': Timestamp.fromDate(streakData.lastModified),
        };
      },
      
      // SharedPreferencesのストレージキー
      storageKey: 'streak_data',
      
      // JSON → StreakDataモデル変換（Freezedの生成メソッドを使用）
      fromJson: (json) => StreakData.fromJson(json),
      
      // StreakDataモデル → JSON変換（Freezedの生成メソッドを使用）
      toJson: (streakData) => streakData.toJson(),
      
      // IDフィールド名（デフォルト値）
      idField: 'id',
      
      // 最終更新フィールド名（デフォルト値）
      lastModifiedField: 'lastModified',
    );
  }

  // ===== 基本CRUD操作 =====

  /// 連続継続日数データを追加
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `streakData`: 追加する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  Future<bool> addStreakData(String userId, StreakData streakData) async {
    return await _manager.add(userId, streakData);
  }

  /// 連続継続日数データを追加（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `streakData`: 追加する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> addStreakDataWithAuth(StreakData streakData) async {
    return await _manager.addWithAuth(streakData);
  }

  /// 連続継続日数データを取得
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// 
  /// **戻り値**: 連続継続日数データ（存在しない場合はnull）
  Future<StreakData?> getStreakData(String userId) async {
    return await _manager.getById(userId, 'user_streak');
  }

  /// 連続継続日数データを取得（認証自動取得版・Firestore優先）
  /// 
  /// Firestoreから最新データを取得し、取得できない場合のみローカルを使用します。
  /// 
  /// **戻り値**: 連続継続日数データ（存在しない場合はnull）
  /// 
  /// **動作フロー**:
  /// 1. Firestoreから取得を試みる
  /// 2. 取得成功時はローカルにも保存して最新化
  /// 3. 取得失敗時（オフライン等）はローカルを使用
  /// 
  /// **注意**: ログインしていない場合やオフラインの場合はローカルデータを返します
  Future<StreakData?> getStreakDataWithAuth() async {
    // Firestoreから取得を試みる（Firestore優先）
    try {
      final allData = await _manager.getAllWithAuth();
      if (allData.isNotEmpty) {
        final firestoreData = allData.first;
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

  /// 連続継続日数データを更新
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `streakData`: 更新する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  Future<bool> updateStreakData(String userId, StreakData streakData) async {
    return await _manager.update(userId, streakData);
  }

  /// 連続継続日数データを更新（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `streakData`: 更新する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> updateStreakDataWithAuth(StreakData streakData) async {
    return await _manager.updateWithAuth(streakData);
  }

  // ===== ローカルストレージ操作 =====

  /// ローカルから連続継続日数データを取得
  /// 
  /// **戻り値**: 連続継続日数データ（存在しない場合はnull）
  Future<StreakData?> getLocalStreakData() async {
    return await _manager.getLocalById('user_streak');
  }

  /// ローカルに連続継続日数データを保存
  /// 
  /// **パラメータ**:
  /// - `streakData`: 保存する連続継続日数データ
  Future<void> saveLocalStreakData(StreakData streakData) async {
    await _manager.addLocal(streakData);
  }

  /// ローカルの連続継続日数データを更新
  /// 
  /// **パラメータ**:
  /// - `streakData`: 更新する連続継続日数データ
  Future<void> updateLocalStreakData(StreakData streakData) async {
    await _manager.updateLocal(streakData);
  }

  /// ローカルデータをクリア
  Future<void> clearLocalStreakData() async {
    await _manager.clearLocal();
  }

  // ===== 同期機能 =====

  /// FirestoreとSharedPreferencesを同期
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// 
  /// **戻り値**: 同期された連続継続日数データのリスト
  Future<List<StreakData>> syncStreakData(String userId) async {
    return await _manager.sync(userId);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  /// 
  /// **戻り値**: 同期された連続継続日数データのリスト
  Future<List<StreakData>> syncStreakDataWithAuth() async {
    return await _manager.syncWithAuth();
  }

  // ===== リトライ機能 =====

  /// リトライ機能付きで連続継続日数データを追加
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `streakData`: 追加する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> addStreakDataWithRetry(String userId, StreakData streakData) async {
    return await _manager.addWithRetry(userId, streakData);
  }

  /// リトライ機能付きで連続継続日数データを更新
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `streakData`: 更新する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> updateStreakDataWithRetry(String userId, StreakData streakData) async {
    return await _manager.updateWithRetry(userId, streakData);
  }

  /// リトライ機能付きで連続継続日数データを保存（upsert: 存在確認付き）
  /// 
  /// Firestoreに存在するか自動判定してaddまたはupdateを使用します。
  /// ローカルとFirestoreの状態が不一致の場合でも正しく動作します。
  /// 
  /// **パラメータ**:
  /// - `userId`: ユーザーID
  /// - `streakData`: 保存する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false（キューに追加された場合もfalse）
  Future<bool> saveStreakDataWithRetry(String userId, StreakData streakData) async {
    return await _manager.saveWithRetry(userId, streakData);
  }

  /// リトライ機能付きで連続継続日数データを保存（認証自動取得版）
  /// 
  /// Firestoreに存在するか自動判定してaddまたはupdateを使用します。
  /// 
  /// **パラメータ**:
  /// - `streakData`: 保存する連続継続日数データ
  /// 
  /// **戻り値**: 成功時true、失敗時false
  /// 
  /// **注意**: ログインしていない場合は失敗します
  Future<bool> saveStreakDataWithRetryAuth(StreakData streakData) async {
    return await _manager.saveWithRetryAuth(streakData);
  }

  // ===== カスタム機能（連続継続日数特有） =====

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
          'message': '1日連続記録中！',
          'streak': 1,
        };
      }
      
      // 3. 同じ日かチェック
      if (_isSameDay(currentData.lastTrackedDate, now)) {
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
            await _manager.saveWithRetry(userId, updatedData);
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
      
      // 4. 前日なら連続日数+1
      if (_isYesterday(currentData.lastTrackedDate, now)) {
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

  /// 連続継続日数データを取得（ローカル優先、なければ初期値）
  /// 
  /// **戻り値**: 連続継続日数データ
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

  /// 指定された日付が今日の前日かどうかを判定
  /// 
  /// **パラメータ**:
  /// - `date`: チェックする日付
  /// - `today`: 今日の日付
  /// 
  /// **戻り値**: 前日ならtrue
  bool _isYesterday(DateTime date, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }
}

