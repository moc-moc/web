// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/base/base_list_notifier.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';

part 'goal_functions.g.dart';

/// 目標機能用の関数群
/// 
/// Riverpod Generatorを使用して目標機能に特化した実装を提供します。
/// 
// ===== Providers (Riverpod Generator) =====

/// 目標リストを管理するNotifier
/// 
/// Riverpod Generatorを使用してGoalモデルのリストを管理します。
@Riverpod(keepAlive: true)
class GoalsList extends _$GoalsList {
  @override
  List<Goal> build() {
    return [];
  }

  /// リストに目標を追加
  void addGoal(Goal goal) {
    BaseListNotifierHelper.addItem(this, goal);
  }

  /// リスト全体を更新
  void updateList(List<Goal> newList) {
    BaseListNotifierHelper.updateList(this, newList);
  }

  /// IDで目標を削除
  void removeGoal(String id) {
    BaseListNotifierHelper.removeById<Goal>(this, id, (g) => g.id);
  }

  /// リストをクリア
  void clear() {
    BaseListNotifierHelper.clear<Goal>(this);
  }
}

// ===== ヘルパー関数 =====

/// 目標リストを読み込むヘルパー関数（Firestore優先）
/// 
/// Firestoreから最新の目標リストを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルを使用します。
/// 
/// **動作フロー**:
/// 1. Firestoreから取得を試みる（getAllGoalsWithAuth使用）
/// 2. 取得成功時はローカルにも保存してProviderに反映
/// 3. 取得失敗時（オフライン等）はローカルを使用
Future<List<Goal>> loadGoalsHelper(dynamic ref) async {
  final manager = GoalDataManager();

  return await loadListDataHelper<Goal>(
    ref: ref,
    manager: manager,
    getAllWithAuth: () => manager.getAllGoalsWithAuth(),
    getLocalAll: () => manager.getLocalGoals(),
    saveLocal: (items) => manager.saveLocalGoals(items),
    updateProvider: (items) => ref.read(goalsListProvider.notifier).updateList(items),
    filter: (_) => true, // 物理削除のため、フィルタリング不要
    functionName: 'loadGoalsHelper',
  );
}

/// 目標をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルからデータを取得して即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **動作フロー**:
/// 1. ローカルからデータを取得して即座に表示
/// 2. バックグラウンドでFirestoreから最新データを取得
/// 3. 取得成功時はローカルにも保存してProviderに反映
/// 4. 取得失敗時はローカルデータのまま
Future<List<Goal>> loadGoalsWithBackgroundRefreshHelper(dynamic ref) async {
  final manager = GoalDataManager();

  return await loadListDataWithBackgroundRefreshHelper<Goal>(
    ref: ref,
    manager: manager,
    getAllWithAuth: () => manager.getAllGoalsWithAuth(),
    getLocalAll: () => manager.getLocalGoals(),
    saveLocal: (items) => manager.saveLocalGoals(items),
    updateProvider: (items) => ref.read(goalsListProvider.notifier).updateList(items),
    filter: (_) => true, // 物理削除のため、フィルタリング不要
    functionName: 'loadGoalsWithBackgroundRefreshHelper',
  );
}

/// 目標を同期するヘルパー関数
/// 
/// ローカルとFirestoreのデータを比較し、新しい方を採用します。
/// 古いデータでの上書きを防ぎます。
Future<List<Goal>> syncGoalsHelper(dynamic ref) async {
  final manager = GoalDataManager();

  try {
    // 1. ローカルデータを取得
    final localGoals = await manager.getLocalGoals();

    // 2. Firestoreデータを直接取得
    final firestoreGoals = await manager.getGoalsFromFirestoreWithAuth();

    // 3. マージ（lastModifiedで比較）とフィルタリングを1回のループで実行
    final mergedGoals = <Goal>[];
    final firestoreMap = <String, Goal>{};
    
    // FirestoreデータをMapに変換（O(1)アクセス用）
    for (final firestoreGoal in firestoreGoals) {
      firestoreMap[firestoreGoal.id] = firestoreGoal;
    }

    // ローカルデータを処理（マージ）
    for (final localGoal in localGoals) {
      final firestoreGoal = firestoreMap[localGoal.id];
      
      if (firestoreGoal != null) {
        // 両方に存在する場合、新しい方を採用
        final selectedGoal = localGoal.lastModified.isAfter(firestoreGoal.lastModified)
            ? localGoal
            : firestoreGoal;
        mergedGoals.add(selectedGoal);
      } else {
        // ローカルのみ
        mergedGoals.add(localGoal);
      }
    }

    // Firestoreのみに存在するデータを追加
    final localIds = localGoals.map((g) => g.id).toSet();
    for (final firestoreGoal in firestoreGoals) {
      if (!localIds.contains(firestoreGoal.id)) {
        mergedGoals.add(firestoreGoal);
      }
    }

    // 4. ローカルに保存（全データを保存するため、マージ済みデータを再構築）
    final allMergedGoals = <Goal>[];
    final processedIds = <String>{};
    
    // ローカルとFirestoreの全データをマージ（削除済みも含む）
    for (final localGoal in localGoals) {
      final firestoreGoal = firestoreMap[localGoal.id];
      if (firestoreGoal != null) {
        allMergedGoals.add(
          localGoal.lastModified.isAfter(firestoreGoal.lastModified)
              ? localGoal
              : firestoreGoal
        );
      } else {
        allMergedGoals.add(localGoal);
      }
      processedIds.add(localGoal.id);
    }
    
    // Firestoreのみに存在するデータを追加
    for (final firestoreGoal in firestoreGoals) {
      if (!processedIds.contains(firestoreGoal.id)) {
        allMergedGoals.add(firestoreGoal);
      }
    }
    
    await manager.saveLocalGoals(allMergedGoals);

    // 5. Providerを更新（既にフィルタリング済み）
    ref.read(goalsListProvider.notifier).updateList(mergedGoals);

    return mergedGoals;
    
  } catch (e) {
    debugPrint('❌ [syncGoalsHelper] エラー: $e');
    
    // エラー時はローカルデータを使用
    final localGoals = await manager.getLocalGoals();
    ref.read(goalsListProvider.notifier).updateList(localGoals);
    return localGoals;
  }
}

/// 目標を追加するヘルパー関数
Future<bool> addGoalHelper({
  required BuildContext context,
  required dynamic ref,
  required Goal goal,
  required bool mounted,
}) async {
  final manager = GoalDataManager();

  // Firestoreに追加
  final success = await manager.addGoalWithAuth(goal);

  if (success) {
    // 成功: Providerを更新
    ref.read(goalsListProvider.notifier).addGoal(goal);
    
    // 選択された目標がない場合、自動選択を更新
    await _updateSelectedGoalAfterAddition(ref, goal);
    
    showSnackBarMessage(context, '目標を追加しました', mounted: mounted);
  } else {
    // 失敗: ローカルに保存
    final localGoals = await manager.getLocalGoals();
    await manager.saveLocalGoals([...localGoals, goal]);
    ref.read(goalsListProvider.notifier).addGoal(goal);
    
    // 選択された目標がない場合、自動選択を更新
    await _updateSelectedGoalAfterAddition(ref, goal);
    
    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);
  }

  return true;
}

/// 目標追加後の選択目標を自動更新
Future<void> _updateSelectedGoalAfterAddition(dynamic ref, Goal newGoal) async {
  final settings = ref.read(trackingSettingsProvider);
  
  bool needsUpdate = false;
  String? newSelectedId;
  
  // 追加された目標のカテゴリーを判定
  switch (newGoal.detectionItem) {
    case DetectionItem.book:
      if (settings.selectedStudyGoalId == null) {
        newSelectedId = newGoal.id;
        needsUpdate = true;
      }
      break;
    case DetectionItem.pc:
      if (settings.selectedPcGoalId == null) {
        newSelectedId = newGoal.id;
        needsUpdate = true;
      }
      break;
    case DetectionItem.smartphone:
      if (settings.selectedSmartphoneGoalId == null) {
        newSelectedId = newGoal.id;
        needsUpdate = true;
      }
      break;
  }
  
  if (needsUpdate) {
    final updatedSettings = settings.copyWith(
      selectedStudyGoalId: newGoal.detectionItem == DetectionItem.book ? newSelectedId : settings.selectedStudyGoalId,
      selectedPcGoalId: newGoal.detectionItem == DetectionItem.pc ? newSelectedId : settings.selectedPcGoalId,
      selectedSmartphoneGoalId: newGoal.detectionItem == DetectionItem.smartphone ? newSelectedId : settings.selectedSmartphoneGoalId,
    );
    
    await saveTrackingSettingsHelper(ref, updatedSettings);
  }
}

/// 目標を更新するヘルパー関数
Future<bool> updateGoalHelper({
  required BuildContext context,
  required dynamic ref,
  required Goal goal,
  required bool mounted,
}) async {
  final manager = GoalDataManager();

  // Firestoreを更新
  final success = await manager.updateGoalWithAuth(goal);

  if (success) {
    // 成功: リストを再読み込み
    await syncGoalsHelper(ref);
    showSnackBarMessage(context, '目標を更新しました', mounted: mounted);
  } else {
    // 失敗: ローカルを更新
    final localGoals = await manager.getLocalGoals();
    final updatedGoals = localGoals.map((g) => g.id == goal.id ? goal : g).toList();
    await manager.saveLocalGoals(updatedGoals);
    
    ref.read(goalsListProvider.notifier).updateList(updatedGoals);
    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);
  }

  return true;
}

/// 目標を削除するヘルパー関数（物理削除）
Future<bool> deleteGoalHelper({
  required BuildContext context,
  required dynamic ref,
  required String goalId,
  required bool mounted,
}) async {
  final manager = GoalDataManager();

  // 削除前の目標を取得（カテゴリー判定用）
  final goals = ref.read(goalsListProvider);
  final deletedGoal = goals.firstWhere(
    (g) => g.id == goalId,
    orElse: () => throw Exception('Goal not found'),
  );

  // 物理削除を実行
  final success = await manager.deleteGoalWithAuth(goalId);

  if (success) {
    // Providerから削除
    ref.read(goalsListProvider.notifier).removeGoal(goalId);
    
    // 選択された目標が削除された場合、自動選択を更新
    await _updateSelectedGoalAfterDeletion(ref, deletedGoal);
    
    showSnackBarMessage(context, '目標を削除しました', mounted: mounted);
  } else {
    showSnackBarMessage(context, '削除に失敗しました', mounted: mounted);
  }

  return success;
}

/// 目標削除後の選択目標を自動更新
Future<void> _updateSelectedGoalAfterDeletion(dynamic ref, Goal deletedGoal) async {
  final settings = ref.read(trackingSettingsProvider);
  final goals = ref.read(goalsListProvider);
  
  String? newSelectedId;
  bool needsUpdate = false;
  
  // 削除された目標のカテゴリーを判定
  switch (deletedGoal.detectionItem) {
    case DetectionItem.book:
      if (settings.selectedStudyGoalId == deletedGoal.id) {
        final studyGoals = goals.where((g) => g.detectionItem == DetectionItem.book).toList();
        if (studyGoals.isNotEmpty) {
          newSelectedId = studyGoals[0].id;
          needsUpdate = true;
        } else {
          newSelectedId = null;
          needsUpdate = true;
        }
      }
      break;
    case DetectionItem.pc:
      if (settings.selectedPcGoalId == deletedGoal.id) {
        final pcGoals = goals.where((g) => g.detectionItem == DetectionItem.pc).toList();
        if (pcGoals.isNotEmpty) {
          newSelectedId = pcGoals[0].id;
          needsUpdate = true;
        } else {
          newSelectedId = null;
          needsUpdate = true;
        }
      }
      break;
    case DetectionItem.smartphone:
      if (settings.selectedSmartphoneGoalId == deletedGoal.id) {
        final smartphoneGoals = goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList();
        if (smartphoneGoals.isNotEmpty) {
          newSelectedId = smartphoneGoals[0].id;
          needsUpdate = true;
        } else {
          newSelectedId = null;
          needsUpdate = true;
        }
      }
      break;
  }
  
  if (needsUpdate) {
    final updatedSettings = settings.copyWith(
      selectedStudyGoalId: deletedGoal.detectionItem == DetectionItem.book ? newSelectedId : settings.selectedStudyGoalId,
      selectedPcGoalId: deletedGoal.detectionItem == DetectionItem.pc ? newSelectedId : settings.selectedPcGoalId,
      selectedSmartphoneGoalId: deletedGoal.detectionItem == DetectionItem.smartphone ? newSelectedId : settings.selectedSmartphoneGoalId,
    );
    
    await saveTrackingSettingsHelper(ref, updatedSettings);
  }
}

/// 達成を記録するヘルパー関数
Future<bool> recordAchievementHelper({
  required BuildContext context,
  required dynamic ref,
  required String goalId,
  required int achievedTime,
  required bool mounted,
}) async {
  final manager = GoalDataManager();

  // 達成記録を更新
  final success = await manager.recordAchievementWithAuth(goalId, achievedTime);

  if (success) {
    // リストを再読み込み
    await syncGoalsHelper(ref);
    showSnackBarMessage(context, '達成を記録しました', mounted: mounted);
  } else {
    showSnackBarMessage(context, '記録に失敗しました', mounted: mounted);
  }

  return success;
}
