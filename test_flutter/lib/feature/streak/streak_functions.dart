// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/streak/streak_model.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';

part 'streak_functions.g.dart';

/// 連続継続日数機能用の関数群
/// 
/// Riverpod Generatorを使用して連続継続日数機能に特化した実装を提供します。
/// 
/// **提供機能**:
/// - 連続継続日数データ管理Provider（Notifier）
/// - トラッキングヘルパー関数
/// - 同期ヘルパー関数
/// - UIフィードバック

// ===== Providers (Riverpod Generator) =====

/// 連続継続日数データを管理するNotifier
/// 
/// Riverpod Generatorを使用してStreakDataモデルを管理します。
/// 
/// **使用方法**:
/// ```dart
/// final streakData = ref.watch(streakDataNotifierProvider);
/// ref.read(streakDataNotifierProvider.notifier).updateStreak(newData);
/// ```
@Riverpod(keepAlive: true)
class StreakDataNotifier extends _$StreakDataNotifier {
  @override
  StreakData build() {
    // 初期値を返す
    return StreakData(
      id: 'user_streak',
      currentStreak: 0,
      longestStreak: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  /// 連続継続日数データを更新
  void updateStreak(StreakData newData) {
    state = newData;
  }

  /// データをリセット
  void reset() {
    state = StreakData(
      id: 'user_streak',
      currentStreak: 0,
      longestStreak: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }
}

// ===== ヘルパー関数 =====

/// 連続継続日数データを読み込むヘルパー関数（Firestore優先）
/// 
/// Firestoreから最新データを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルまたはデフォルト値を使用します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 読み込んだ連続継続日数データ
/// 
/// **動作フロー**:
/// 1. Firestoreから取得を試みる（getStreakDataWithAuth使用）
/// 2. 取得成功時はProviderに反映
/// 3. 取得失敗時はローカルまたはデフォルト値を使用
/// 
/// **使用例**:
/// ```dart
/// await loadStreakDataHelper(ref);
/// ```
Future<StreakData> loadStreakDataHelper(dynamic ref) async {
  final manager = StreakDataManager();

  return await loadSingleDataHelper<StreakData>(
    ref: ref,
    manager: manager,
    getWithAuth: () => manager.getStreakDataWithAuth(),
    getDefault: () => manager.getStreakDataOrDefault(),
    updateProvider: (data) => ref.read(streakDataProvider.notifier).updateStreak(data),
    functionName: 'loadStreakDataHelper',
  );
}

/// 連続継続日数データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 読み込んだ連続継続日数データ（ローカルまたはデフォルト値）
/// 
/// **動作フロー**:
/// 1. ローカルまたはデフォルト値で即座に表示
/// 2. バックグラウンドでFirestoreから最新データを取得
/// 3. 取得成功時はローカルにも保存してProviderに反映
/// 4. 取得失敗時はローカルデータのまま
/// 
/// **使用例**:
/// ```dart
/// await loadStreakDataWithBackgroundRefreshHelper(ref);
/// ```
Future<StreakData> loadStreakDataWithBackgroundRefreshHelper(dynamic ref) async {
  final manager = StreakDataManager();

  return await loadSingleDataWithBackgroundRefreshHelper<StreakData>(
    ref: ref,
    manager: manager,
    getWithAuth: () => manager.getStreakDataWithAuth(),
    getLocal: () => manager.getLocalStreakData(),
    getDefault: () => manager.getStreakDataOrDefault(),
    saveLocal: (data) => manager.saveLocalStreakData(data),
    updateProvider: (data) => ref.read(streakDataProvider.notifier).updateStreak(data),
    functionName: 'loadStreakDataWithBackgroundRefreshHelper',
  );
}

/// 連続継続日数データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// Providerを最新の状態に更新します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 同期された連続継続日数データ
/// 
/// **使用例**:
/// ```dart
/// await syncStreakDataHelper(ref);
/// ```
Future<StreakData> syncStreakDataHelper(dynamic ref) async {
  final manager = StreakDataManager();

  return await syncSingleDataHelper<StreakData>(
    ref: ref,
    manager: manager,
    syncWithAuth: () => manager.syncStreakDataWithAuth(),
    getDefault: () => manager.getStreakDataOrDefault(),
    updateProvider: (data) => ref.read(streakDataProvider.notifier).updateStreak(data),
    functionName: 'syncStreakDataHelper',
  );
}
