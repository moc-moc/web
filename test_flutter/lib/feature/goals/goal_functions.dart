// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
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
    debugPrint('🔍 [GoalsList.build] Provider初期化');
    return [];
  }

  /// リストに目標を追加
  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  /// リスト全体を更新
  void updateList(List<Goal> newList) {
    debugPrint('🔍 [GoalsList.updateList] 更新: ${state.length}件 → ${newList.length}件');
    state = newList;
  }

  /// IDで目標を削除
  void removeGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  /// リストをクリア
  void clear() {
    state = [];
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
  debugPrint('🔍 [loadGoalsHelper] 開始');
  
  final manager = GoalDataManager();

  // Firestoreから取得を試みる（Firestore優先）
  try {
    final goals = await manager.getAllGoalsWithAuth();
    if (goals.isNotEmpty || goals.isEmpty) {  // Firestoreから取得成功（空リストも含む）
      debugPrint('🔍 [loadGoalsHelper] Firestoreから取得: ${goals.length}件');
      
      // ローカルにも保存
      await manager.saveLocalGoals(goals);
      debugPrint('✅ [loadGoalsHelper] ローカルに保存完了');
      
      // アクティブな目標のみをフィルタリング
      final activeGoals = goals.where((g) => !g.isDeleted).toList();
      debugPrint('🔍 [loadGoalsHelper] フィルタ後: ${activeGoals.length}件');

      // Providerを更新
      ref.read(goalsListProvider.notifier).updateList(activeGoals);
      debugPrint('🔍 [loadGoalsHelper] Provider更新完了');

      return activeGoals;
    }
  } catch (e) {
    debugPrint('⚠️ [loadGoalsHelper] Firestore取得失敗（オフライン？）: $e');
  }

  // Firestoreから取得できない場合はローカルを使用
  debugPrint('📱 [loadGoalsHelper] ローカルデータを使用');
  final goals = await manager.getLocalGoals();
  debugPrint('🔍 [loadGoalsHelper] ローカルから取得: ${goals.length}件');

  // アクティブな目標のみをフィルタリング
  final activeGoals = goals.where((g) => !g.isDeleted).toList();
  debugPrint('🔍 [loadGoalsHelper] フィルタ後: ${activeGoals.length}件');

  // Providerを更新
  ref.read(goalsListProvider.notifier).updateList(activeGoals);
  debugPrint('🔍 [loadGoalsHelper] Provider更新完了');

  return activeGoals;
}

/// 目標を同期するヘルパー関数
/// 
/// ローカルとFirestoreのデータを比較し、新しい方を採用します。
/// 古いデータでの上書きを防ぎます。
Future<List<Goal>> syncGoalsHelper(dynamic ref) async {
  debugPrint('🔍 [syncGoalsHelper] 開始');
  
  final manager = GoalDataManager();

  try {
    // 1. ローカルデータを取得
    final localGoals = await manager.getLocalGoals();
    debugPrint('🔍 [syncGoalsHelper] ローカルデータ: ${localGoals.length}件');

    // 2. Firestoreデータを直接取得
    final firestoreGoals = await manager.getGoalsFromFirestoreWithAuth();
    debugPrint('🔍 [syncGoalsHelper] Firestoreデータ: ${firestoreGoals.length}件');

    // 3. マージ（lastModifiedで比較）
    final mergedGoals = <Goal>[];
    final processedIds = <String>{};

    // ローカルとFirestoreを比較してマージ
    for (final localGoal in localGoals) {
      final firestoreGoal = firestoreGoals.firstWhere(
        (g) => g.id == localGoal.id,
        orElse: () => localGoal,
      );

      if (firestoreGoal.id == localGoal.id) {
        // 両方に存在する場合、新しい方を採用
        if (localGoal.lastModified.isAfter(firestoreGoal.lastModified)) {
          mergedGoals.add(localGoal);
          debugPrint('  ローカル採用: ${localGoal.title}');
        } else {
          mergedGoals.add(firestoreGoal);
          debugPrint('  Firestore採用: ${firestoreGoal.title}');
        }
      } else {
        // ローカルのみ
        mergedGoals.add(localGoal);
        debugPrint('  ローカルのみ: ${localGoal.title}');
      }
      processedIds.add(localGoal.id);
    }

    // Firestoreのみに存在するデータを追加
    for (final firestoreGoal in firestoreGoals) {
      if (!processedIds.contains(firestoreGoal.id)) {
        mergedGoals.add(firestoreGoal);
        debugPrint('  Firestoreのみ: ${firestoreGoal.title}');
      }
    }

    // 4. ローカルに保存
    await manager.saveLocalGoals(mergedGoals);
    debugPrint('✅ [syncGoalsHelper] ローカル保存完了: ${mergedGoals.length}件');

    // 5. アクティブな目標のみをフィルタ
    final activeGoals = mergedGoals.where((g) => !g.isDeleted).toList();
    debugPrint('🔍 [syncGoalsHelper] アクティブな目標: ${activeGoals.length}件');

    // 6. Providerを更新
    ref.read(goalsListProvider.notifier).updateList(activeGoals);
    debugPrint('🔍 [syncGoalsHelper] Provider更新完了');

    return activeGoals;
    
  } catch (e) {
    debugPrint('❌ [syncGoalsHelper] エラー: $e');
    
    // エラー時はローカルデータを使用
    final localGoals = await manager.getLocalGoals();
    final activeGoals = localGoals.where((g) => !g.isDeleted).toList();
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

