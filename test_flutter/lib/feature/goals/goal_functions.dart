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
    filter: (g) => !g.isDeleted,
    functionName: 'loadGoalsHelper',
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

    // ローカルデータを処理（マージとフィルタリングを同時実行）
    for (final localGoal in localGoals) {
      final firestoreGoal = firestoreMap[localGoal.id];
      
      if (firestoreGoal != null) {
        // 両方に存在する場合、新しい方を採用
        final selectedGoal = localGoal.lastModified.isAfter(firestoreGoal.lastModified)
            ? localGoal
            : firestoreGoal;
        
        // アクティブな目標のみ追加（フィルタリングを同時実行）
        if (!selectedGoal.isDeleted) {
          mergedGoals.add(selectedGoal);
        }
      } else {
        // ローカルのみ、アクティブな目標のみ追加
        if (!localGoal.isDeleted) {
          mergedGoals.add(localGoal);
        }
      }
    }

    // Firestoreのみに存在するデータを追加（フィルタリングを同時実行）
    final localIds = localGoals.map((g) => g.id).toSet();
    for (final firestoreGoal in firestoreGoals) {
      if (!localIds.contains(firestoreGoal.id)) {
        // アクティブな目標のみ追加
        if (!firestoreGoal.isDeleted) {
          mergedGoals.add(firestoreGoal);
        }
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
    
    // エラー時はローカルデータを使用（1回の走査でフィルタリング）
    final localGoals = await manager.getLocalGoals();
    final activeGoals = <Goal>[];
    for (final goal in localGoals) {
      if (!goal.isDeleted) {
        activeGoals.add(goal);
      }
    }
    ref.read(goalsListProvider.notifier).updateList(activeGoals);
    return activeGoals;
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
    showSnackBarMessage(context, '目標を追加しました', mounted: mounted);
  } else {
    // 失敗: ローカルに保存
    final localGoals = await manager.getLocalGoals();
    await manager.saveLocalGoals([...localGoals, goal]);
    ref.read(goalsListProvider.notifier).addGoal(goal);
    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);
  }

  return true;
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
    
    final activeGoals = updatedGoals.where((g) => !g.isDeleted).toList();
    ref.read(goalsListProvider.notifier).updateList(activeGoals);
    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);
  }

  return true;
}

/// 目標を削除するヘルパー関数（論理削除）
Future<bool> deleteGoalHelper({
  required BuildContext context,
  required dynamic ref,
  required String goalId,
  required bool mounted,
}) async {
  final manager = GoalDataManager();

  // 論理削除を実行
  final success = await manager.softDeleteGoalWithAuth(goalId);

  if (success) {
    // Providerから削除
    ref.read(goalsListProvider.notifier).removeGoal(goalId);
    showSnackBarMessage(context, '目標を削除しました', mounted: mounted);
  } else {
    showSnackBarMessage(context, '削除に失敗しました', mounted: mounted);
  }

  return success;
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
