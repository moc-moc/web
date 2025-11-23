import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:test_flutter/feature/streak/streak_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ストリークマイルストーンサービス
/// 
/// 連続日数のマイルストーンを管理し、達成状況を追跡します。
class StreakMilestoneService {
  /// デフォルトのマイルストーンリスト（日数）
  /// 
  /// 最初は変則的で、その後は50日おきと1年おきを組み合わせた周期
  static List<int> _generateDefaultMilestoneList() {
    final List<int> milestones = [1, 3, 5, 7, 10, 15, 30, 50, 100, 150, 200, 250, 300, 350, 365];
    
    // 365日以降は50日おきと1年おきを組み合わせ
    // 365の次は400（+35）、その次は450（+50）、その後は50日おき
    int current = 365;
    current = 400; // 365の次は400
    milestones.add(current);
    
    // その後は50日おき
    while (current < 1000) {
      current += 50;
      milestones.add(current);
    }
    
    return milestones;
  }
  
  static final List<int> _defaultMilestoneList = _generateDefaultMilestoneList();
  
  /// マイルストーンのリストを取得（Firestoreから取得、なければデフォルト）
  /// 
  /// **戻り値**: マイルストーンリスト（日数）
  static Future<List<int>> getMilestoneList() async {
    try {
      final streakManager = StreakDataManager();
      final streakData = await streakManager.getStreakDataWithAuth();
      
      if (streakData != null && streakData.milestoneList.isNotEmpty) {
        return streakData.milestoneList;
      }
      
      // Firestoreにデータがない場合はデフォルトリストを返す
      return List<int>.from(_defaultMilestoneList);
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] マイルストーンリスト取得エラー: $e');
      return List<int>.from(_defaultMilestoneList);
    }
  }

  /// SharedPreferencesのキー（達成済みマイルストーンリスト）
  static const String _achievedMilestonesKey = 'streak_achieved_milestones';
  
  /// SharedPreferencesのキー（一時保存された達成マイルストーン）
  static const String _pendingMilestoneKey = 'streak_pending_milestone';

  /// 達成済みマイルストーンを取得
  /// 
  /// **戻り値**: 達成済みのマイルストーン日数のリスト
  static Future<List<int>> getAchievedMilestones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievedList = prefs.getStringList(_achievedMilestonesKey);
      
      if (achievedList == null || achievedList.isEmpty) {
        return [];
      }
      
      return achievedList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 達成済みマイルストーン取得エラー: $e');
      return [];
    }
  }

  /// 達成済みマイルストーンを保存
  /// 
  /// **パラメータ**:
  /// - `achievedMilestones`: 達成済みのマイルストーン日数のリスト
  static Future<void> saveAchievedMilestones(List<int> achievedMilestones) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = achievedMilestones.map((e) => e.toString()).toList();
      await prefs.setStringList(_achievedMilestonesKey, stringList);
      debugPrint('✅ [StreakMilestoneService] 達成済みマイルストーン保存完了: $achievedMilestones');
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 達成済みマイルストーン保存エラー: $e');
    }
  }

  /// 達成したマイルストーンをチェック
  /// 
  /// 現在のストリーク日数が、未達成のマイルストーンリストの値以上になった場合、
  /// 達成したマイルストーンを返します。
  /// 
  /// **パラメータ**:
  /// - `currentStreak`: 現在の連続日数
  /// 
  /// **戻り値**: 達成したマイルストーン日数（達成していない場合はnull）
  static Future<int?> checkAchievedMilestone(int currentStreak) async {
    try {
      debugPrint('🔍 [StreakMilestoneService] マイルストーンチェック開始: currentStreak=$currentStreak');
      
      // マイルストーンリストを取得
      final milestoneList = await getMilestoneList();
      debugPrint('📊 [StreakMilestoneService] マイルストーンリスト: $milestoneList');
      
      // 最後に達成したマイルストーンを取得
      final streakManager = StreakDataManager();
      final streakData = await streakManager.getStreakDataWithAuth();
      final lastAchieved = streakData?.lastAchievedMilestone;
      
      debugPrint('📊 [StreakMilestoneService] 最後に達成したマイルストーン: $lastAchieved');
      
      // 未達成のマイルストーンを取得（最後に達成したマイルストーンより大きいもの）
      final unachievedMilestones = milestoneList
          .where((milestone) => lastAchieved == null || milestone > lastAchieved)
          .toList();
      
      debugPrint('📊 [StreakMilestoneService] 未達成マイルストーン: $unachievedMilestones');
      
      if (unachievedMilestones.isEmpty) {
        debugPrint('ℹ️ [StreakMilestoneService] 全てのマイルストーンを達成済み');
        return null;
      }
      
      // 現在のストリーク日数が、未達成マイルストーンの最小値以上かチェック
      unachievedMilestones.sort();
      final minUnachieved = unachievedMilestones.first;
      
      debugPrint('📊 [StreakMilestoneService] 最小未達成マイルストーン: $minUnachieved日, 現在のストリーク: $currentStreak日');
      
      if (currentStreak >= minUnachieved) {
        debugPrint('🎉 [StreakMilestoneService] マイルストーン達成: $minUnachieved日（現在: $currentStreak日）');
        return minUnachieved;
      }
      
      debugPrint('ℹ️ [StreakMilestoneService] マイルストーン未達成: 現在のストリーク($currentStreak日) < 最小未達成マイルストーン($minUnachieved日)');
      return null;
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] マイルストーンチェックエラー: $e');
      debugPrint('❌ [StreakMilestoneService] スタックトレース: ${StackTrace.current}');
      return null;
    }
  }

  /// 達成したマイルストーンを記録（Firestoreに保存）
  /// 
  /// **パラメータ**:
  /// - `milestone`: 達成したマイルストーン日数
  static Future<void> recordAchievedMilestone(int milestone) async {
    try {
      final streakManager = StreakDataManager();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        debugPrint('⚠️ [StreakMilestoneService] ユーザー未認証のため、マイルストーン記録をスキップ');
        return;
      }
      
      // 現在のStreakDataを取得
      StreakData? streakData = await streakManager.getStreakDataWithAuth();
      
      // マイルストーンリストを取得（なければデフォルトを生成）
      List<int> milestoneList;
      if (streakData != null && streakData.milestoneList.isNotEmpty) {
        milestoneList = streakData.milestoneList;
      } else {
        milestoneList = await getMilestoneList();
      }
      
      // StreakDataが存在しない場合は初期データを作成
      if (streakData == null) {
        streakData = StreakData(
          id: 'user_streak',
          currentStreak: 0,
          longestStreak: 0,
          lastTrackedDate: DateTime.now(),
          lastModified: DateTime.now(),
          milestoneList: milestoneList,
          lastAchievedMilestone: milestone,
        );
      } else {
        // 既存のデータを更新
        streakData = streakData.copyWith(
          lastAchievedMilestone: milestone,
          milestoneList: milestoneList,
          lastModified: DateTime.now(),
        );
      }
      
      // Firestoreに保存
      final userId = currentUser.uid;
      final success = await streakManager.manager.saveWithRetry(userId, streakData);
      
      if (success) {
        debugPrint('✅ [StreakMilestoneService] マイルストーンを記録しました: $milestone日');
      } else {
        debugPrint('❌ [StreakMilestoneService] マイルストーン記録失敗（リトライキューに追加された可能性）');
      }
      
      // ローカルにも保存
      await streakManager.updateLocalStreakData(streakData);
      
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] マイルストーン記録エラー: $e');
      debugPrint('❌ [StreakMilestoneService] スタックトレース: ${StackTrace.current}');
    }
  }

  /// 次のマイルストーンを取得
  /// 
  /// **戻り値**: 次のマイルストーン日数（全て達成済みの場合はnull）
  static Future<int?> getNextMilestone() async {
    try {
      // マイルストーンリストを取得
      final milestoneList = await getMilestoneList();
      
      // 最後に達成したマイルストーンを取得
      final streakManager = StreakDataManager();
      final streakData = await streakManager.getStreakDataWithAuth();
      final lastAchieved = streakData?.lastAchievedMilestone;
      
      // 未達成のマイルストーンを取得（最後に達成したマイルストーンより大きいもの）
      final unachievedMilestones = milestoneList
          .where((milestone) => lastAchieved == null || milestone > lastAchieved)
          .toList();
      
      if (unachievedMilestones.isEmpty) {
        return null;
      }
      
      unachievedMilestones.sort();
      return unachievedMilestones.first;
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 次のマイルストーン取得エラー: $e');
      return null;
    }
  }

  /// 指定したマイルストーンの2つ先を取得
  /// 
  /// **パラメータ**:
  /// - `achievedMilestone`: 達成したマイルストーン日数
  /// 
  /// **戻り値**: 2つ先のマイルストーン日数（存在しない場合はnull）
  static Future<int?> getNextMilestoneAfter(int achievedMilestone) async {
    try {
      // マイルストーンリストを取得
      final milestoneList = await getMilestoneList();
      
      // 達成したマイルストーンより大きいマイルストーンを取得
      final futureMilestones = milestoneList
          .where((milestone) => milestone > achievedMilestone)
          .toList();
      
      if (futureMilestones.isEmpty) {
        return null;
      }
      
      futureMilestones.sort();
      
      // 2つ先のマイルストーンを返す（存在する場合）
      if (futureMilestones.length >= 2) {
        return futureMilestones[1];
      } else if (futureMilestones.length == 1) {
        // 1つしかない場合は、その次を生成（50日おきのパターンに従う）
        final next = futureMilestones[0] + 50;
        return next;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 2つ先のマイルストーン取得エラー: $e');
      return null;
    }
  }

  /// 達成したマイルストーンを一時保存（OKボタン押下時に表示するため）
  /// 
  /// **パラメータ**:
  /// - `milestone`: 達成したマイルストーン日数
  /// - `nextMilestone`: 次のマイルストーン日数（オプション）
  static Future<void> savePendingMilestone(int milestone, int? nextMilestone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pendingMilestoneKey, milestone);
      if (nextMilestone != null) {
        await prefs.setInt('${_pendingMilestoneKey}_next', nextMilestone);
      } else {
        await prefs.remove('${_pendingMilestoneKey}_next');
      }
      debugPrint('✅ [StreakMilestoneService] 達成マイルストーンを一時保存: $milestone日（次のマイルストーン: $nextMilestone日）');
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 達成マイルストーンの一時保存エラー: $e');
    }
  }

  /// 一時保存された達成マイルストーンを取得
  /// 
  /// **戻り値**: 達成したマイルストーン日数と次のマイルストーン日数のマップ（保存されていない場合はnull）
  static Future<Map<String, int?>?> getPendingMilestone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final milestone = prefs.getInt(_pendingMilestoneKey);
      
      if (milestone == null) {
        return null;
      }
      
      final nextMilestone = prefs.getInt('${_pendingMilestoneKey}_next');
      
      return {
        'milestone': milestone,
        'nextMilestone': nextMilestone,
      };
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 一時保存された達成マイルストーン取得エラー: $e');
      return null;
    }
  }

  /// 一時保存された達成マイルストーンを削除
  static Future<void> clearPendingMilestone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingMilestoneKey);
      await prefs.remove('${_pendingMilestoneKey}_next');
      debugPrint('✅ [StreakMilestoneService] 一時保存された達成マイルストーンを削除');
    } catch (e) {
      debugPrint('❌ [StreakMilestoneService] 一時保存された達成マイルストーンの削除エラー: $e');
    }
  }
}

