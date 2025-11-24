// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/base/base_list_notifier.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';

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
/// 4. リセットチェックを実行
Future<List<Goal>> loadGoalsHelper(dynamic ref) async {
  final manager = GoalDataManager();
  final goalsNotifier = ref.read(goalsListProvider.notifier);

  final goals = await loadListDataHelper<Goal>(
    ref: ref,
    manager: manager,
    getAllWithAuth: () => manager.getAllGoalsWithAuth(),
    getLocalAll: () => manager.getLocalGoals(),
    saveLocal: (items) => manager.saveLocalGoals(items),
    updateProvider: goalsNotifier.updateList,
    filter: (_) => true, // 物理削除のため、フィルタリング不要
    functionName: 'loadGoalsHelper',
  );

  // リセットチェックを実行（内部でローカルデータも更新される）
  await manager.resetTodayAchievedTimeIfNeeded(goals);

  // リセット後のローカルデータを取得してProviderを更新
  // （Firestoreへの更新は非同期で実行されるため、ローカルデータを使用）
  final updatedGoals = await manager.getLocalGoals();
  goalsNotifier.updateList(updatedGoals);

  return updatedGoals;
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
/// 5. リセットチェックを実行
Future<List<Goal>> loadGoalsWithBackgroundRefreshHelper(dynamic ref) async {
  final manager = GoalDataManager();
  final goalsNotifier = ref.read(goalsListProvider.notifier);

  final goals = await loadListDataWithBackgroundRefreshHelper<Goal>(
    ref: ref,
    manager: manager,
    getAllWithAuth: () => manager.getAllGoalsWithAuth(),
    getLocalAll: () => manager.getLocalGoals(),
    saveLocal: (items) => manager.saveLocalGoals(items),
    updateProvider: goalsNotifier.updateList,
    filter: (_) => true, // 物理削除のため、フィルタリング不要
    functionName: 'loadGoalsWithBackgroundRefreshHelper',
  );

  // リセットチェックを実行（バックグラウンドで実行）
  manager.resetTodayAchievedTimeIfNeeded(goals).then((_) {
    // リセット後のローカルデータを取得してProviderを更新
    // （Firestoreへの更新は非同期で実行されるため、ローカルデータを使用）
    manager.getLocalGoals().then((updatedGoals) {
      goalsNotifier.updateList(updatedGoals);
    });
  });

  return goals;
}

/// 目標を同期するヘルパー関数
///
/// Firestoreとローカルストレージを同期し、Providerを最新の状態に更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
Future<List<Goal>> syncGoalsHelper(dynamic ref) async {
  final manager = GoalDataManager();
  final goalsNotifier = ref.read(goalsListProvider.notifier);

  final goals = await syncListDataHelper<Goal>(
    ref: ref,
    manager: manager,
    syncWithAuth: () => manager.syncGoalsWithAuth(),
    getLocalAll: () => manager.getLocalGoals(),
    updateProvider: goalsNotifier.updateList,
    filter: (_) => true, // 物理削除のため、フィルタリング不要
    functionName: 'syncGoalsHelper',
  );

  // リセットチェックを実行（内部でローカルデータも更新される）
  await manager.resetTodayAchievedTimeIfNeeded(goals);

  // リセット後のローカルデータを取得してProviderを更新
  // （Firestoreへの更新は非同期で実行されるため、ローカルデータを使用）
  final updatedGoals = await manager.getLocalGoals();
  goalsNotifier.updateList(updatedGoals);

  return updatedGoals;
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

    // イベント画面に遷移
    if (mounted) {
      await _navigateToGoalSetEvent(context, goal);
    }
  } else {
    // 失敗: ローカルに保存
    final localGoals = await manager.getLocalGoals();
    await manager.saveLocalGoals([...localGoals, goal]);
    ref.read(goalsListProvider.notifier).addGoal(goal);

    // 選択された目標がない場合、自動選択を更新
    await _updateSelectedGoalAfterAddition(ref, goal);

    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);

    // イベント画面に遷移
    if (mounted) {
      await _navigateToGoalSetEvent(context, goal);
    }
  }

  triggerGoalChanged(ref);
  return true;
}

/// 目標設定イベント画面に遷移
Future<void> _navigateToGoalSetEvent(BuildContext context, Goal goal) async {
  try {
    // 連続日数を取得
    final streakManager = StreakDataManager();
    final streakData = await streakManager.getStreakDataOrDefault();
    final consecutiveDays = streakData.currentStreak;

    // イベント画面に遷移
    await NavigationHelper.push(
      context,
      AppRoutes.goalSetEvent,
      arguments: {
        'goalTitle': goal.title,
        'targetTime': goal.targetTime,
        'consecutiveDays': consecutiveDays,
        'durationDays': goal.durationDays,
        'consecutivePeriodAchievements': goal.consecutivePeriodAchievements,
        'detectionItem': goal.detectionItem.name,
      },
    );
  } catch (e) {
    debugPrint('❌ [addGoalHelper] イベント画面遷移エラー: $e');
    // エラーが発生しても目標追加は成功しているので、エラーを無視
  }
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
      selectedStudyGoalId: newGoal.detectionItem == DetectionItem.book
          ? newSelectedId
          : settings.selectedStudyGoalId,
      selectedPcGoalId: newGoal.detectionItem == DetectionItem.pc
          ? newSelectedId
          : settings.selectedPcGoalId,
      selectedSmartphoneGoalId:
          newGoal.detectionItem == DetectionItem.smartphone
          ? newSelectedId
          : settings.selectedSmartphoneGoalId,
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

  // オプティミスティック更新: まずローカルとProviderを更新（即座に反映）
  final localGoals = await manager.getLocalGoals();
  final updatedGoals = localGoals
      .map((g) => g.id == goal.id ? goal : g)
      .toList();
  await manager.saveLocalGoals(updatedGoals);
  ref.read(goalsListProvider.notifier).updateList(updatedGoals);

  // Firestoreを更新（リトライ機能付き）
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    showSnackBarMessage(context, '認証エラーが発生しました', mounted: mounted);
    return false;
  }

  // updateWithRetryを使用してリトライキューに対応
  final success = await manager.updateWithRetry(currentUser.uid, goal);

  if (success) {
    // 成功時: ローカルデータは既に更新済み（updateWithRetry内で更新される）
    // 念のため、最新のローカルデータでProviderを更新
    final latestLocalGoals = await manager.getLocalGoals();
    ref.read(goalsListProvider.notifier).updateList(latestLocalGoals);
    showSnackBarMessage(context, '目標を更新しました', mounted: mounted);
    triggerGoalChanged(ref);
  } else {
    // 失敗: リトライキューに追加済み（updateWithRetry内で処理）
    // オプティミスティック更新は既に反映されているため、そのまま維持
    showSnackBarMessage(context, 'オフラインのため、後で同期します', mounted: mounted);
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
    triggerGoalChanged(ref);
  } else {
    showSnackBarMessage(context, '削除に失敗しました', mounted: mounted);
  }

  return success;
}

/// 目標削除後の選択目標を自動更新
Future<void> _updateSelectedGoalAfterDeletion(
  dynamic ref,
  Goal deletedGoal,
) async {
  final settings = ref.read(trackingSettingsProvider);
  final goals = ref.read(goalsListProvider);

  String? newSelectedId;
  bool needsUpdate = false;

  // 削除された目標のカテゴリーを判定
  switch (deletedGoal.detectionItem) {
    case DetectionItem.book:
      if (settings.selectedStudyGoalId == deletedGoal.id) {
        final studyGoals = goals
            .where((g) => g.detectionItem == DetectionItem.book)
            .toList();
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
        final pcGoals = goals
            .where((g) => g.detectionItem == DetectionItem.pc)
            .toList();
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
        final smartphoneGoals = goals
            .where((g) => g.detectionItem == DetectionItem.smartphone)
            .toList();
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
      selectedStudyGoalId: deletedGoal.detectionItem == DetectionItem.book
          ? newSelectedId
          : settings.selectedStudyGoalId,
      selectedPcGoalId: deletedGoal.detectionItem == DetectionItem.pc
          ? newSelectedId
          : settings.selectedPcGoalId,
      selectedSmartphoneGoalId:
          deletedGoal.detectionItem == DetectionItem.smartphone
          ? newSelectedId
          : settings.selectedSmartphoneGoalId,
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

  // 現在の目標を取得
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    showSnackBarMessage(context, '認証エラーが発生しました', mounted: mounted);
    return false;
  }

  final goal = await manager.manager.getById(currentUser.uid, goalId);
  if (goal == null) {
    showSnackBarMessage(context, '目標が見つかりません', mounted: mounted);
    return false;
  }

  // 連続達成回数をインクリメント
  final updatedGoal = goal.copyWith(
    consecutiveAchievements: goal.consecutiveAchievements + 1,
    achievedTime: achievedTime,
    lastModified: DateTime.now(),
  );

  // オプティミスティック更新: まずローカルとProviderを更新（即座に反映）
  final localGoals = await manager.getLocalGoals();
  final updatedGoals = localGoals
      .map((g) => g.id == goalId ? updatedGoal : g)
      .toList();
  await manager.saveLocalGoals(updatedGoals);
  ref.read(goalsListProvider.notifier).updateList(updatedGoals);

  // Firestoreを更新（リトライ機能付き）
  final success = await manager.updateWithRetry(currentUser.uid, updatedGoal);

  if (success) {
    // 成功時: ローカルデータは既に更新済み（updateWithRetry内で更新される）
    // 念のため、最新のローカルデータでProviderを更新
    final latestLocalGoals = await manager.getLocalGoals();
    ref.read(goalsListProvider.notifier).updateList(latestLocalGoals);
    showSnackBarMessage(context, '達成を記録しました', mounted: mounted);
  } else {
    // 失敗: リトライキューに追加済み（updateWithRetry内で処理）
    // オプティミスティック更新は既に反映されているため、そのまま維持
    showSnackBarMessage(context, 'オフラインのため、後で同期します', mounted: mounted);
  }

  return success;
}
