// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/Streak/streak_data_manager.dart';

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
    debugPrint('🔍 [StreakDataNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    debugPrint('🔍 [StreakDataNotifier.build] スタックトレース:');
    debugPrint(StackTrace.current.toString().split('\n').take(5).join('\n'));
    
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
    debugPrint('🔍 [StreakDataNotifier.updateStreak] 更新: ${newData.currentStreak}日連続');
    state = newData;
  }

  /// データをリセット
  void reset() {
    debugPrint('🔍 [StreakDataNotifier.reset] リセット実行');
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
  debugPrint('🔍 [loadStreakDataHelper] 開始');
  
  final manager = StreakDataManager();

  // Firestoreから取得を試みる（Firestore優先）
  final streakData = await manager.getStreakDataWithAuth();
  
  if (streakData != null) {
    debugPrint('🔍 [loadStreakDataHelper] Firestoreから取得: ${streakData.currentStreak}日連続');
  } else {
    // Firestoreから取得できない場合はデフォルト値
    final defaultData = await manager.getStreakDataOrDefault();
    debugPrint('🔍 [loadStreakDataHelper] デフォルト値を使用: ${defaultData.currentStreak}日連続');
    
    // Notifierを使用してProviderを更新
    ref.read(streakDataProvider.notifier).updateStreak(defaultData);
    debugPrint('🔍 [loadStreakDataHelper] Provider更新完了');
    
    return defaultData;
  }

  // Notifierを使用してProviderを更新
  ref.read(streakDataProvider.notifier).updateStreak(streakData);
  debugPrint('🔍 [loadStreakDataHelper] Provider更新完了');
  
  // 更新後の状態を確認
  final updatedState = ref.read(streakDataProvider);
  debugPrint('🔍 [loadStreakDataHelper] Provider更新後の状態: ${updatedState.currentStreak}日連続');

  return streakData;
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
  debugPrint('🔍 [syncStreakDataHelper] 開始');
  
  final manager = StreakDataManager();

  // Firestoreと同期（認証自動取得版）
  final syncedList = await manager.syncStreakDataWithAuth();
  debugPrint('🔍 [syncStreakDataHelper] 同期で取得: ${syncedList.length}件');

  // Streakは1つだけなので、リストから取得またはデフォルト値
  final streakData = syncedList.isNotEmpty 
      ? syncedList.first 
      : await manager.getStreakDataOrDefault();
  
  debugPrint('🔍 [syncStreakDataHelper] 最終データ: ${streakData.currentStreak}日連続');

  // Notifierを使用してProviderを更新
  ref.read(streakDataProvider.notifier).updateStreak(streakData);
  debugPrint('🔍 [syncStreakDataHelper] Provider更新完了');
  
  // 更新後の状態を確認
  final updatedState = ref.read(streakDataProvider);
  debugPrint('🔍 [syncStreakDataHelper] Provider更新後の状態: ${updatedState.currentStreak}日連続');

  return streakData;
}
