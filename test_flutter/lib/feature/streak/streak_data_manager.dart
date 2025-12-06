import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/streak/streak_model.dart';
import 'package:test_flutter/data/sources/date_utils.dart';

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
    final now = DateTime.now();
    final milestoneList = _readIntList(data['milestoneList']);
    return StreakData(
      id: _readString(data['id']).isNotEmpty
          ? _readString(data['id'])
          : 'user_streak',
      currentStreak: _readInt(data['currentStreak']) ?? 0,
      longestStreak: _readInt(data['longestStreak']) ?? 0,
      lastTrackedDate: _readDateTime(data['lastTrackedDate']) ?? now,
      lastModified: _readDateTime(data['lastModified']) ?? now,
      milestoneList: milestoneList,
      lastAchievedMilestone: _readInt(data['lastAchievedMilestone']),
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
      'milestoneList': item.milestoneList,
      if (item.lastAchievedMilestone != null) 'lastAchievedMilestone': item.lastAchievedMilestone,
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
        return await getLocalStreakData();
      }
      
      // Firestoreから単一データを取得（パフォーマンス最適化）
      final firestoreData = await manager.getById(userId, 'user_streak');
      if (firestoreData != null) {
        // Firestoreから取得できた場合は、ローカルにも保存
        await updateLocalStreakData(firestoreData);
        return firestoreData;
      }
    } catch (e) {
      // エラーは無視してローカルデータを使用
    }
    
    // Firestoreから取得できない場合のみローカルを使用
    final localData = await getLocalStreakData();
    if (localData != null) {
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

  /// アプリ起動時にstreak daysを更新（最後のトラッキングから1日以上空いているかチェック）
  /// 
  /// **処理フロー**:
  /// 1. ローカルから現在のStreakDataを取得
  /// 2. データが存在しない場合は何もしない（初回トラッキング待ち）
  /// 3. 最後のトラッキング日から1日以上空いているかチェック
  /// 4. 1日以上空いていたらリセット（currentStreak=0）
  /// 5. 新しいStreakDataを作成してローカルに保存
  /// 6. ログイン済みならFirestoreにも保存
  /// 
  /// **戻り値**: 更新された場合true、そうでない場合false
  Future<bool> checkAndUpdateStreakOnAppLaunch() async {
    try {
      // 1. ローカルから現在のStreakDataを取得
      StreakData? currentData = await getLocalStreakData();
      
      if (currentData == null) {
        // データが存在しない場合は何もしない（初回トラッキング待ち）
        return false;
      }
      
      final now = DateTime.now();
      final lastTrackedDate = currentData.lastTrackedDate;
      
      // 2. 最後のトラッキング日から1日以上空いているかチェック
      final daysSinceLastTrack = now.difference(lastTrackedDate).inDays;
      
      if (daysSinceLastTrack < 1) {
        // 1日未満の場合は更新不要
        return false;
      }
      
      // 3. 1日以上空いていたらリセット（currentStreak=0）
      final updatedData = currentData.copyWith(
        currentStreak: 0,
        lastModified: now,
      );
      
      // 4. ローカルに保存
      await updateLocalStreakData(updatedData);
      debugPrint('✅ [checkAndUpdateStreakOnAppLaunch] ストリークリセット: currentStreak=0 (${daysSinceLastTrack}日空いていました)');
      
      // 5. Firestoreへの保存（awaitして確実に実行）
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        try {
          debugPrint('🔄 [checkAndUpdateStreakOnAppLaunch] Firestore保存開始');
          final success = await manager.saveWithRetry(userId, updatedData);
          if (success) {
            debugPrint('✅ [checkAndUpdateStreakOnAppLaunch] Firestore保存成功');
          } else {
            debugPrint('⚠️ [checkAndUpdateStreakOnAppLaunch] Firestore保存失敗（リトライキューに追加済み）');
          }
        } catch (e) {
          debugPrint('❌ [checkAndUpdateStreakOnAppLaunch] Firestore保存エラー: $e');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ [checkAndUpdateStreakOnAppLaunch] エラー: $e');
      return false;
    }
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
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用、日付判定に使用、オプション）
  /// 
  /// **戻り値**: {'success': bool, 'message': String, 'streak': int}
  Future<Map<String, dynamic>> trackFinished({dynamic ref}) async {
    try {
      // 1. ローカルから現在のStreakDataを取得
      StreakData? currentData = await getLocalStreakData();
      
      final now = DateTime.now();
      
      // 2. データが存在しない場合は初期データを作成（初回トラッキング）
      if (currentData == null) {
        // デフォルトのマイルストーンリストを生成
        final defaultMilestones = _generateDefaultMilestoneList();
        
        final newData = StreakData(
          id: 'user_streak',
          currentStreak: 1,
          longestStreak: 1,
          lastTrackedDate: now,
          lastModified: now,
          milestoneList: defaultMilestones,
        );
        
        // ローカルに保存（即座に完了）
        await saveLocalStreakData(newData);
        debugPrint('✅ [trackFinished] ローカル保存完了: currentStreak=${newData.currentStreak}');
        
        // Firestoreへの保存（awaitして確実に実行）
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userId = currentUser.uid;
          try {
            debugPrint('🔄 [trackFinished] Firestore保存開始');
            final success = await manager.saveWithRetry(userId, newData);
            if (success) {
              debugPrint('✅ [trackFinished] Firestore保存成功');
            } else {
              debugPrint('⚠️ [trackFinished] Firestore保存失敗（リトライキューに追加済み）');
            }
          } catch (e) {
            debugPrint('❌ [trackFinished] Firestore保存エラー: $e');
          }
        }
        
        return {
          'success': true,
          'message': '1日連続記録中！',
          'streak': 1,
        };
      }
      
      // 日付比較結果をキャッシュ（同じ日付の比較を避ける）
      final lastTrackedDate = currentData.lastTrackedDate;
      final isSameDayResult = ref != null
          ? DateUtils.isSameDay(ref, lastTrackedDate, now)
          : _isSameDay(lastTrackedDate, now);
      
      // 3. 同じ日かチェック
      if (isSameDayResult) {
        // 同じ日でもlastModifiedだけ更新
        final updatedData = currentData.copyWith(
          lastModified: now,
        );
        
        // ローカルに保存（即座に完了）
        await updateLocalStreakData(updatedData);
        debugPrint('✅ [trackFinished] 本日記録済み - lastModified更新');
        
        // Firestoreへの保存（awaitして確実に実行）
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userId = currentUser.uid;
          try {
            debugPrint('🔄 [trackFinished] Firestore更新開始');
            final success = await manager.saveWithRetry(userId, updatedData);
            if (success) {
              debugPrint('✅ [trackFinished] Firestore更新成功');
            } else {
              debugPrint('⚠️ [trackFinished] Firestore更新失敗（リトライキューに追加済み）');
            }
          } catch (e) {
            debugPrint('⚠️ [trackFinished] Firestore更新エラー: $e');
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
      final isYesterdayResult = ref != null
          ? DateUtils.isYesterday(ref, lastTrackedDate)
          : _isYesterday(lastTrackedDate, now);
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
      
      // 7. 新しいStreakDataを作成（既存のマイルストーン情報を保持）
      final milestoneList = currentData.milestoneList.isNotEmpty
          ? currentData.milestoneList
          : _generateDefaultMilestoneList();
      
      final updatedData = StreakData(
        id: 'user_streak',
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastTrackedDate: now,
        lastModified: now,
        milestoneList: milestoneList,
        lastAchievedMilestone: currentData.lastAchievedMilestone,
      );
      
      // ローカルに保存（即座に完了）
      await updateLocalStreakData(updatedData);
      debugPrint('✅ [trackFinished] ローカル更新完了: currentStreak=${updatedData.currentStreak}');
      
      // Firestoreへの保存（awaitして確実に実行）
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        try {
          debugPrint('🔄 [trackFinished] Firestore保存開始');
          final success = await manager.saveWithRetry(userId, updatedData);
          if (success) {
            debugPrint('✅ [trackFinished] Firestore保存成功');
          } else {
            debugPrint('⚠️ [trackFinished] Firestore保存失敗（リトライキューに追加済み）');
          }
        } catch (e) {
          debugPrint('❌ [trackFinished] Firestore保存エラー: $e');
        }
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

  /// デフォルトのマイルストーンリストを生成
  /// 
  /// 最初は変則的で、その後は50日おきと1年おきを組み合わせた周期
  static List<int> _generateDefaultMilestoneList() {
    final List<int> milestones = [1, 3, 5, 7, 10, 15, 30, 50, 100, 150, 200, 250, 300, 350, 365];
    
    // 365日以降は50日おきと1年おきを組み合わせ
    // 365の次は400（+35）、その次は450（+50）、その後は50日おき
    int current = 400; // 365の次は400
    milestones.add(current);
    
    // その後は50日おき
    while (current < 1000) {
      current += 50;
      milestones.add(current);
    }
    
    return milestones;
  }

  static String _readString(dynamic value) {
    if (value is String) return value.trim();
    return '';
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<int> _readIntList(dynamic value) {
    if (value is List) {
      return value
          .where((e) => e != null)
          .map((e) => _readInt(e) ?? 0)
          .toList();
    }
    return [];
  }
}
