import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'goal_memo_notifier.g.dart';

/// 目標メモを管理するNotifier
/// 
/// 目標メモ（自分を鼓舞するためのメモ）を管理します。
/// 
/// **使用方法**:
/// ```dart
/// final memo = ref.watch(goalMemoProvider);
/// ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
/// ```
@Riverpod(keepAlive: true)
class GoalMemoNotifier extends _$GoalMemoNotifier {
  @override
  GoalMemo build() {
    return GoalMemo.defaultMemo();
  }

  /// メモを更新
  void updateMemo(GoalMemo memo) {
    state = memo;
  }
}

/// 目標メモをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだ目標メモ（ローカルまたはデフォルト値）
Future<GoalMemo> loadGoalMemoWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー
  final goalMemoNotifier = ref.read(goalMemoProvider.notifier);

  return await loadSingleDataWithBackgroundRefreshHelper<GoalMemo>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final memoList = await goalMemoManager.getAllWithAuth();
        try {
          return memoList.firstWhere((m) => m.id == 'goal_memo');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await goalMemoManager.getLocalById('goal_memo');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => GoalMemo.defaultMemo(),
    saveLocal: (memo) async {
      try {
        await goalMemoManager.addLocal(memo);
      } catch (e) {
        // 既に存在する場合は更新
        await goalMemoManager.updateLocal(memo);
      }
    },
    updateProvider: goalMemoNotifier.updateMemo,
    functionName: 'loadGoalMemoWithBackgroundRefreshHelper',
  );
}

/// 目標メモを保存するヘルパー関数
/// 
/// 目標メモを保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `memo`: 保存する目標メモ
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveGoalMemoHelper(dynamic ref, GoalMemo memo) async {
  try {
    final userId = AuthMk.getCurrentUserId();
    final goalMemoNotifier = ref.read(goalMemoProvider.notifier);
    
    // 最終更新日時を更新
    final updatedMemo = memo.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await goalMemoManager.saveWithRetry(userId, updatedMemo);
    
    if (success) {
      // Notifierを使用してProviderを更新
      goalMemoNotifier.updateMemo(updatedMemo);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveGoalMemoHelper] エラー: $e');
    return false;
  }
}

