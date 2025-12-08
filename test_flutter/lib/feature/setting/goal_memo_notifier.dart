import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
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
  final goalMemoNotifier = ref.read(goalMemoProvider.notifier);

  debugPrint('🔄 [loadGoalMemoWithBackgroundRefreshHelper] 読み込み開始');

  // 1. まずローカルから読み込んで即座に表示
  GoalMemo? localMemo;
  try {
    localMemo = await goalMemoManager.getLocalGoalMemo();
    debugPrint('   - ローカルから読み込み: ${localMemo != null ? "success" : "null"}');
    if (localMemo != null) {
      goalMemoNotifier.updateMemo(localMemo);
    }
  } catch (e) {
    debugPrint('   - ローカル読み込みエラー: $e');
  }

  // 2. デフォルト値を設定（ローカルがない場合）
  if (localMemo == null) {
    localMemo = GoalMemo.defaultMemo();
    goalMemoNotifier.updateMemo(localMemo);
    debugPrint('   - デフォルト値を使用');
  }

  // 3. バックグラウンドでFirestoreから最新データを取得
  debugPrint('🔄 [loadGoalMemoWithBackgroundRefreshHelper] バックグラウンド同期開始');
  goalMemoManager.syncGoalMemoWithAuth().then((remoteMemo) {
    debugPrint('   - 同期結果: ${remoteMemo != null ? "success (content: \"${remoteMemo.content}\")" : "null"}');
    if (remoteMemo != null) {
      // Providerを更新
      goalMemoNotifier.updateMemo(remoteMemo);
      debugPrint('✅ [loadGoalMemoWithBackgroundRefreshHelper] Provider更新完了: "${remoteMemo.content}"');
    } else {
      debugPrint('⚠️ [loadGoalMemoWithBackgroundRefreshHelper] リモートデータなし（デフォルト値のまま）');
    }
  }).catchError((e, stackTrace) {
    debugPrint('❌ [loadGoalMemoWithBackgroundRefreshHelper] バックグラウンド同期エラー: $e');
    debugPrint('   - スタックトレース: $stackTrace');
  });

  return localMemo;
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
    
    debugPrint('🔄 [saveGoalMemoHelper] 保存開始');
    debugPrint('   - userId: $userId');
    debugPrint('   - memo.id: ${memo.id}');
    debugPrint('   - memo.content length: ${memo.content.length}');
    
    // 最終更新日時を更新
    final updatedMemo = memo.copyWith(lastModified: DateTime.now());
    
    debugPrint('🔄 [saveGoalMemoHelper] saveWithRetry呼び出し');
    // データマネージャーで保存
    final success = await goalMemoManager.saveWithRetry(userId, updatedMemo);
    
    debugPrint('   - saveWithRetry結果: $success');
    
    if (success) {
      debugPrint('✅ [saveGoalMemoHelper] Firestore保存成功');
      // ローカルにも保存
      await goalMemoManager.saveLocalGoalMemo(updatedMemo);
      debugPrint('   - ローカル保存完了');
      // Providerを更新
      goalMemoNotifier.updateMemo(updatedMemo);
      debugPrint('   - Provider更新完了');
    } else {
      debugPrint('⚠️ [saveGoalMemoHelper] Firestore保存失敗、ローカルのみ保存');
      // 失敗時もローカルには保存
      await goalMemoManager.saveLocalGoalMemo(updatedMemo);
      // Providerは更新
      goalMemoNotifier.updateMemo(updatedMemo);
    }
    
    return success;
  } catch (e, stackTrace) {
    debugPrint('❌ [saveGoalMemoHelper] エラー: $e');
    debugPrint('   - スタックトレース: $stackTrace');
    return false;
  }
}

