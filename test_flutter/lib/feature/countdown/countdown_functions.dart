// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/Countdown/countdowndata.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';

part 'countdown_functions.g.dart';

/// カウントダウン機能用の関数群
///
/// Riverpod Generatorを使用してカウントダウン機能に特化した実装を提供します。
///
/// **提供機能**:
/// - カウントダウンリスト管理Provider（Notifier）
/// - アプリ起動時刻管理Provider
/// - カウントダウン追加ヘルパー関数
/// - UIフィードバック

// ===== Providers (Riverpod Generator) =====

/// カウントダウンリストを管理するNotifier
///
/// Riverpod Generatorを使用してCountdownモデルのリストを管理します。
///
/// **使用方法**:
/// ```dart
/// final countdowns = ref.watch(countdownsListProvider);
/// ref.read(countdownsListProvider.notifier).addCountdown(countdown);
/// ```
@Riverpod(keepAlive: true)
class CountdownsList extends _$CountdownsList {
  @override
  List<Countdown> build() {
    debugPrint(
      '🔍 [CountdownsList.build] ★★★ Provider初期化実行（keepAlive: true）★★★',
    );
    debugPrint('🔍 [CountdownsList.build] スタックトレース:');
    debugPrint(StackTrace.current.toString().split('\n').take(5).join('\n'));
    return [];
  }

  /// リストにカウントダウンを追加
  void addCountdown(Countdown countdown) {
    state = [...state, countdown];
  }

  /// リスト全体を更新
  void updateList(List<Countdown> newList) {
    debugPrint(
      '🔍 [CountdownsList.updateList] 更新前: ${state.length}件 → 更新後: ${newList.length}件',
    );
    state = newList;
  }

  /// IDでカウントダウンを削除
  void removeCountdown(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  /// リストをクリア
  void clear() {
    state = [];
  }
}

/// アプリ起動時刻を記録するProvider
///
/// アプリが起動した日時を保持します。
/// 各種時間計算や統計情報で使用されます。
///
/// **使用方法**:
/// ```dart
/// final startTime = ref.watch(appStartTimeProvider);
/// ```
@riverpod
DateTime appStartTime(Ref ref) {
  return DateTime.now();
}

// ===== ヘルパー関数 =====

/// カウントダウンを追加するヘルパー関数
///
/// UIから簡単にカウントダウンを追加できるヘルパー関数です。
/// func_mkの汎用関数を利用してバリデーション、追加処理、UIフィードバックを行います。
///
/// **処理の流れ**:
/// 1. タイトルのバリデーション
/// 2. Countdownモデルの作成
/// 3. Firestoreへの追加（オンライン時）
/// 4. ローカルストレージへの保存（オフライン時）
/// 5. Providerの更新
/// 6. UIフィードバック
///
Future<bool> addCountdownHelper({
  required BuildContext context,
  required dynamic ref,
  required String title,
  required DateTime targetDate,
  required bool mounted,
}) async {
  // タイトルのバリデーション（func_mkの汎用関数を使用）
  if (!validateNonEmptyString(title)) {
    showSnackBarMessage(context, 'タイトルを入力してください', mounted: mounted);
    return false;
  }

  // 新しいカウントダウンを作成
  final countdown = Countdown(
    id: const Uuid().v4(),
    title: title.trim(),
    targetDate: targetDate,
    isDeleted: false,
    lastModified: DateTime.now(),
  );

  // CountdownDataManagerのインスタンスを作成（DataUS層を使用）
  final manager = CountdownDataManager();

  // Firestoreに追加（認証自動取得版）
  final success = await manager.addCountdownWithAuth(countdown);

  if (success) {
    // 成功: Firestoreに追加された場合
    // Notifierを使用してProviderを更新
    ref.read(countdownsListProvider.notifier).addCountdown(countdown);

    // func_mkの汎用関数でメッセージ表示
    showSnackBarMessage(context, 'カウントダウンを追加しました', mounted: mounted);
  } else {
    // 失敗: オフライン時はローカルに保存
    final localCountdowns = await manager.getLocalCountdowns();
    await manager.saveLocalCountdowns([...localCountdowns, countdown]);

    // Notifierを使用してProviderを更新
    ref.read(countdownsListProvider.notifier).updateList([
      ...localCountdowns,
      countdown,
    ]);

    // func_mkの汎用関数でメッセージ表示
    showSnackBarMessage(context, 'オフラインのため、ローカルに保存しました', mounted: mounted);
  }

  return true;
}

/// カウントダウンリストを読み込むヘルパー関数（Firestore優先）
///
/// Firestoreから最新のカウントダウンリストを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルを使用します。
///
/// **動作フロー**:
/// 1. Firestoreから取得を試みる（getAllCountdownsWithAuth使用）
/// 2. 取得成功時はローカルにも保存してProviderに反映
/// 3. 取得失敗時（オフライン等）はローカルを使用
Future<List<Countdown>> loadCountdownsHelper(dynamic ref) async {
  debugPrint('🔍 [loadCountdownsHelper] 開始');

  // CountdownDataManagerのインスタンスを作成（DataUS層を使用）
  final manager = CountdownDataManager();

  // Firestoreから取得を試みる（Firestore優先）
  try {
    final countdowns = await manager.getAllCountdownsWithAuth();
    if (countdowns.isNotEmpty || countdowns.isEmpty) {
      // Firestoreから取得成功（空リストも含む）
      debugPrint(
        '🔍 [loadCountdownsHelper] Firestoreから取得: ${countdowns.length}件',
      );

      // ローカルにも保存
      await manager.saveLocalCountdowns(countdowns);
      debugPrint('✅ [loadCountdownsHelper] ローカルに保存完了');

      // アクティブなカウントダウンのみをフィルタリング
      final activeCountdowns = countdowns.where((c) => !c.isDeleted).toList();
      debugPrint(
        '🔍 [loadCountdownsHelper] フィルタ後: ${activeCountdowns.length}件',
      );

      // Notifierを使用してProviderを更新
      ref.read(countdownsListProvider.notifier).updateList(activeCountdowns);
      debugPrint('🔍 [loadCountdownsHelper] Provider更新完了');

      // 更新後の状態を確認
      final updatedState = ref.read(countdownsListProvider);
      debugPrint(
        '🔍 [loadCountdownsHelper] Provider更新後の状態: ${updatedState.length}件',
      );

      return activeCountdowns;
    }
  } catch (e) {
    debugPrint('⚠️ [loadCountdownsHelper] Firestore取得失敗（オフライン？）: $e');
  }

  // Firestoreから取得できない場合はローカルを使用
  debugPrint('📱 [loadCountdownsHelper] ローカルデータを使用');
  final countdowns = await manager.getLocalCountdowns();
  debugPrint('🔍 [loadCountdownsHelper] ローカルから取得: ${countdowns.length}件');

  // アクティブなカウントダウンのみをフィルタリング
  final activeCountdowns = countdowns.where((c) => !c.isDeleted).toList();
  debugPrint('🔍 [loadCountdownsHelper] フィルタ後: ${activeCountdowns.length}件');

  // Notifierを使用してProviderを更新
  ref.read(countdownsListProvider.notifier).updateList(activeCountdowns);
  debugPrint('🔍 [loadCountdownsHelper] Provider更新完了');

  // 更新後の状態を確認
  final updatedState = ref.read(countdownsListProvider);
  debugPrint(
    '🔍 [loadCountdownsHelper] Provider更新後の状態: ${updatedState.length}件',
  );

  return activeCountdowns;
}

/// カウントダウンを同期するヘルパー関数
///
/// FirestoreとSharedPreferencesを同期し、
/// Providerを最新の状態に更新します。
///
Future<List<Countdown>> syncCountdownsHelper(dynamic ref) async {
  debugPrint('🔍 [syncCountdownsHelper] 開始');

  // CountdownDataManagerのインスタンスを作成（DataUS層を使用）
  final manager = CountdownDataManager();

  // Firestoreと同期（認証自動取得版）
  final countdowns = await manager.syncCountdownsWithAuth();
  debugPrint('🔍 [syncCountdownsHelper] 同期で取得: ${countdowns.length}件');

  // アクティブなカウントダウンのみをフィルタリング
  final activeCountdowns = countdowns.where((c) => !c.isDeleted).toList();
  debugPrint('🔍 [syncCountdownsHelper] フィルタ後: ${activeCountdowns.length}件');
  if (activeCountdowns.isNotEmpty) {
    for (var i = 0; i < activeCountdowns.length; i++) {
      debugPrint('  [$i] ${activeCountdowns[i].title}');
    }
  }

  // Notifierを使用してProviderを更新
  ref.read(countdownsListProvider.notifier).updateList(activeCountdowns);
  debugPrint('🔍 [syncCountdownsHelper] Provider更新完了');

  // 更新後の状態を確認
  final updatedState = ref.read(countdownsListProvider);
  debugPrint(
    '🔍 [syncCountdownsHelper] Provider更新後の状態: ${updatedState.length}件',
  );

  return activeCountdowns;
}

/// カウントダウンを削除するヘルパー関数（論理削除）
///
/// カウントダウンを論理削除し、Providerから除外します。
///
Future<bool> deleteCountdownHelper({
  required BuildContext context,
  required dynamic ref,
  required String countdownId,
  required bool mounted,
}) async {
  // CountdownDataManagerのインスタンスを作成（DataUS層を使用）
  final manager = CountdownDataManager();

  // 論理削除を実行（認証自動取得版）
  final success = await manager.softDeleteCountdownWithAuth(countdownId);

  if (success) {
    // Notifierを使用してProviderから削除
    ref.read(countdownsListProvider.notifier).removeCountdown(countdownId);

    // func_mkの汎用関数でメッセージ表示
    showSnackBarMessage(context, 'カウントダウンを削除しました', mounted: mounted);
  } else {
    // func_mkの汎用関数でメッセージ表示
    showSnackBarMessage(context, '削除に失敗しました', mounted: mounted);
  }

  return success;
}

/// 期限切れカウントダウンを削除するヘルパー関数
///
/// 現在時刻より前の targetDate を持つカウントダウンを物理削除します。
/// Goal画面の表示時に自動的に呼び出されます。
///
/// **処理の流れ**:
/// 1. Providerから現在のカウントダウンリストを取得
/// 2. 期限切れ（targetDate < DateTime.now()）をフィルタリング
/// 3. 各期限切れアイテムを物理削除（Firestoreから完全に削除）
/// 4. Providerから削除
/// 5. ローカルストレージを更新
///
/// **戻り値**: 削除されたカウントダウンの件数
Future<int> deleteExpiredCountdownsHelper(dynamic ref) async {
  debugPrint('🔍 [deleteExpiredCountdownsHelper] 期限切れチェック開始');

  // 現在のカウントダウンリストを取得（型を明示的にキャスト）
  final List<Countdown> countdowns =
      ref.read(countdownsListProvider) as List<Countdown>;
  final now = DateTime.now();

  // 期限切れのカウントダウンをフィルタリング
  final expiredCountdowns = countdowns.where((countdown) {
    return countdown.targetDate.isBefore(now);
  }).toList();

  debugPrint(
    '🔍 [deleteExpiredCountdownsHelper] 期限切れ: ${expiredCountdowns.length}件',
  );

  if (expiredCountdowns.isEmpty) {
    return 0;
  }

  // CountdownDataManagerのインスタンスを作成
  final manager = CountdownDataManager();

  int deletedCount = 0;

  // 各期限切れカウントダウンを物理削除
  for (final countdown in expiredCountdowns) {
    debugPrint('  物理削除中: ${countdown.title} (期限: ${countdown.targetDate})');

    // 物理削除を実行（Firestoreから完全に削除）
    final success = await manager.deleteCountdownWithAuth(countdown.id);

    if (success) {
      // Providerから削除
      ref.read(countdownsListProvider.notifier).removeCountdown(countdown.id);
      deletedCount++;
    }
  }

  // ローカルストレージを更新（削除後の状態を保存）
  if (deletedCount > 0) {
    final remainingCountdowns = ref.read(countdownsListProvider);
    await manager.saveLocalCountdowns(remainingCountdowns);
    debugPrint(
      '🔍 [deleteExpiredCountdownsHelper] ローカルストレージ更新: ${remainingCountdowns.length}件',
    );
  }

  debugPrint('🔍 [deleteExpiredCountdownsHelper] 物理削除完了: $deletedCount件');

  return deletedCount;
}
