import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';
import 'package:test_flutter/feature/total/total_model.dart';

/// 総時間マイルストーンマネージャー
/// 
/// 総時間のマイルストーンリストを管理します。
/// マイルストーンは時間単位（hours）で管理されます。
/// TotalDataとFirestoreを使用してマイルストーン情報を保存・管理します。
class TotalHoursMilestoneManager {
  
  // デフォルトのマイルストーンリスト（時間単位）
  // 最初は変則的、後半は100時間周期
  static const List<int> _defaultMilestones = [
    1,     // 1時間
    3,     // 3時間
    5,     // 5時間
    7,     // 7時間
    10,    // 10時間
    15,    // 15時間
    30,    // 30時間
    50,    // 50時間
    100,   // 100時間
    150,   // 150時間
    200,   // 200時間
    250,   // 250時間
    300,   // 300時間
    350,   // 350時間
    400,   // 400時間
    450,   // 450時間
    500,   // 500時間
    600,   // 600時間
    700,   // 700時間
    800,   // 800時間
    900,   // 900時間
    1000,  // 1000時間
  ];

  /// マイルストーンリストを取得
  /// 
  /// TotalDataからマイルストーンリストを取得します。
  /// TotalDataにリストが存在しない場合は、デフォルトのマイルストーンリストを返します。
  /// 1000時間以降は100時間周期で動的に生成します。
  /// 
  /// **戻り値**: マイルストーンリスト（時間単位、昇順でソート済み）
  Future<List<int>> getMilestones() async {
    try {
      final totalManager = TotalDataManager();
      final totalData = await totalManager.getTotalDataOrDefault();
      
      List<int> baseMilestones;
      
      // TotalDataにマイルストーンリストが存在する場合はそれを使用
      if (totalData.milestoneList.isNotEmpty) {
        baseMilestones = List<int>.from(totalData.milestoneList);
      } else {
        // TotalDataにリストが存在しない場合は、デフォルトリストを初期化
        baseMilestones = List<int>.from(_defaultMilestones);
        await _initializeMilestoneListInTotalData(totalManager, totalData, baseMilestones);
      }
      
      baseMilestones.sort();
      
      // 1000時間以降のマイルストーンを動的に生成（100時間周期）
      final extendedMilestones = _generateExtendedMilestones(baseMilestones);
      
      return extendedMilestones;
    } catch (e) {
      LogMk.logError(
        '❌ マイルストーンリスト取得エラー: $e',
        tag: 'TotalHoursMilestoneManager',
      );
      // エラー時はデフォルトリストを返す
      return List<int>.from(_defaultMilestones);
    }
  }
  
  /// 1000時間以降のマイルストーンを動的に生成（100時間周期）
  /// 
  /// **パラメータ**:
  /// - `baseMilestones`: ベースとなるマイルストーンリスト
  /// 
  /// **戻り値**: 拡張されたマイルストーンリスト
  List<int> _generateExtendedMilestones(List<int> baseMilestones) {
    if (baseMilestones.isEmpty) {
      return baseMilestones;
    }
    
    final maxBaseMilestone = baseMilestones.last;
    
    // 1000時間未満の場合はそのまま返す
    if (maxBaseMilestone < 1000) {
      return baseMilestones;
    }
    
    // 1000時間以降は100時間周期で生成（最大5000時間まで）
    final extended = List<int>.from(baseMilestones);
    int current = 1000;
    while (current <= 5000) {
      if (!extended.contains(current)) {
        extended.add(current);
      }
      current += 100;
    }
    
    extended.sort();
    return extended;
  }
  
  /// TotalDataにマイルストーンリストを初期化
  Future<void> _initializeMilestoneListInTotalData(
    TotalDataManager totalManager,
    TotalData totalData,
    List<int> milestoneList,
  ) async {
    try {
      final updatedData = totalData.copyWith(
        milestoneList: milestoneList,
        lastModified: DateTime.now(),
      );
      
      await totalManager.updateLocalTotalData(updatedData);
      
      // Firestoreにも保存
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await totalManager.manager.saveWithRetry(currentUser.uid, updatedData);
        } catch (e) {
          LogMk.logWarning(
            '⚠️ マイルストーンリストのFirestore保存に失敗しました: $e',
            tag: 'TotalHoursMilestoneManager',
          );
        }
      }
    } catch (e) {
      LogMk.logError(
        '❌ マイルストーンリスト初期化エラー: $e',
        tag: 'TotalHoursMilestoneManager',
      );
    }
  }


  /// 達成したマイルストーンをチェック
  /// 
  /// 総時間がマイルストーンリストのいずれかを上回っている場合、
  /// 達成した最小のマイルストーンを返します（既に達成済みのマイルストーンは除外）。
  /// 
  /// **パラメータ**:
  /// - `totalHours`: 総時間（時間単位）
  /// 
  /// **戻り値**: 達成したマイルストーン（時間単位）。達成していない場合はnull。
  Future<int?> checkMilestone(int totalHours) async {
    try {
      final totalManager = TotalDataManager();
      final totalData = await totalManager.getTotalDataOrDefault();
      final milestones = await getMilestones();
      final lastAchieved = totalData.lastAchievedMilestone;
      
      LogMk.logDebug(
        '🔍 マイルストーンチェック: 総時間=$totalHours時間, マイルストーンリスト=$milestones, 最後に達成したマイルストーン=$lastAchieved',
        tag: 'TotalHoursMilestoneManager',
      );
      
      if (milestones.isEmpty) {
        LogMk.logWarning(
          '⚠️ マイルストーンリストが空です',
          tag: 'TotalHoursMilestoneManager',
        );
        return null;
      }
      
      // 総時間が上回っている最小のマイルストーンを探す（既に達成済みのものは除外）
      for (final milestone in milestones) {
        // 既に達成済みのマイルストーンはスキップ
        if (lastAchieved != null && milestone <= lastAchieved) {
          continue;
        }
        
        if (totalHours >= milestone) {
          LogMk.logDebug(
            '🎉 マイルストーン達成: $milestone時間（現在: $totalHours時間）',
            tag: 'TotalHoursMilestoneManager',
          );
          return milestone;
        }
      }
      
      LogMk.logDebug(
        'ℹ️ マイルストーン未達成: 総時間=$totalHours時間',
        tag: 'TotalHoursMilestoneManager',
      );
      
      return null;
    } catch (e) {
      LogMk.logError(
        '❌ マイルストーンチェックエラー: $e',
        tag: 'TotalHoursMilestoneManager',
      );
      return null;
    }
  }

  /// 達成したマイルストーンを記録（Firestoreに保存）
  /// 
  /// TotalDataのlastAchievedMilestoneを更新してFirestoreに保存します。
  /// 
  /// **パラメータ**:
  /// - `milestone`: 達成したマイルストーン（時間単位）
  Future<void> recordAchievedMilestone(int milestone) async {
    try {
      final totalManager = TotalDataManager();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        LogMk.logWarning(
          '⚠️ ユーザー未認証のため、マイルストーン記録をスキップ',
          tag: 'TotalHoursMilestoneManager',
        );
        return;
      }
      
      // 現在のTotalDataを取得
      TotalData? totalData = await totalManager.getTotalDataWithAuth();
      
      // マイルストーンリストを取得（なければデフォルトを生成）
      List<int> milestoneList;
      if (totalData != null && totalData.milestoneList.isNotEmpty) {
        milestoneList = totalData.milestoneList;
      } else {
        milestoneList = List<int>.from(_defaultMilestones);
      }
      
      // TotalDataが存在しない場合は初期データを作成
      if (totalData == null) {
        totalData = TotalData(
          id: 'user_total',
          totalWorkTimeMinutes: 0,
          lastTrackedDate: DateTime.now(),
          lastModified: DateTime.now(),
          milestoneList: milestoneList,
          lastAchievedMilestone: milestone,
        );
      } else {
        // 既存のデータを更新
        totalData = totalData.copyWith(
          lastAchievedMilestone: milestone,
          milestoneList: milestoneList,
          lastModified: DateTime.now(),
        );
      }
      
      // ローカルに保存
      await totalManager.updateLocalTotalData(totalData);
      
      // Firestoreに保存
      final userId = currentUser.uid;
      final success = await totalManager.manager.saveWithRetry(userId, totalData);
      
      if (success) {
        LogMk.logDebug(
          '✅ マイルストーンを記録しました: $milestone時間',
          tag: 'TotalHoursMilestoneManager',
        );
      } else {
        LogMk.logWarning(
          '⚠️ マイルストーンのFirestore保存に失敗しました（リトライキューに追加された可能性）',
          tag: 'TotalHoursMilestoneManager',
        );
      }
    } catch (e) {
      LogMk.logError(
        '❌ マイルストーン記録エラー: $e',
        tag: 'TotalHoursMilestoneManager',
      );
    }
  }

  /// 次のマイルストーンを取得
  /// 
  /// 総時間を超える最小のマイルストーンを返します（既に達成済みのマイルストーンは除外）。
  /// 
  /// **パラメータ**:
  /// - `totalHours`: 総時間（時間単位）
  /// 
  /// **戻り値**: 次のマイルストーン（時間単位）。存在しない場合はnull。
  Future<int?> getNextMilestone(int totalHours) async {
    try {
      final totalManager = TotalDataManager();
      final totalData = await totalManager.getTotalDataOrDefault();
      final milestones = await getMilestones();
      final lastAchieved = totalData.lastAchievedMilestone;
      
      if (milestones.isEmpty) {
        return null;
      }
      
      // 総時間を超える最小のマイルストーンを探す（既に達成済みのものは除外）
      for (final milestone in milestones) {
        // 既に達成済みのマイルストーンはスキップ
        if (lastAchieved != null && milestone <= lastAchieved) {
          continue;
        }
        
        if (totalHours < milestone) {
          return milestone;
        }
      }
      
      return null;
    } catch (e) {
      LogMk.logError(
        '❌ 次のマイルストーン取得エラー: $e',
        tag: 'TotalHoursMilestoneManager',
      );
      return null;
    }
  }

  /// マイルストーンリストをリセット
  /// 
  /// マイルストーンリストをデフォルト値にリセットします。
  Future<void> resetMilestones() async {
    final totalManager = TotalDataManager();
    final totalData = await totalManager.getTotalDataOrDefault();
    await _initializeMilestoneListInTotalData(
      totalManager,
      totalData,
      List<int>.from(_defaultMilestones),
    );
    
    LogMk.logDebug(
      '✅ マイルストーンリストをリセットしました',
      tag: 'TotalHoursMilestoneManager',
    );
  }
}

