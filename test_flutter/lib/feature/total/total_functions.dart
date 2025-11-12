// Flutterライブラリ
import 'package:flutter/material.dart';

// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/Total/total_data_manager.dart';

part 'total_functions.g.dart';

/// 累計データ機能用の関数群
/// 
/// Riverpod Generatorを使用して累計データ機能に特化した実装を提供します。
/// 
/// **提供機能**:
/// - 累計データ管理Provider（Notifier）
/// - 同期ヘルパー関数
/// - ローカル読み込みヘルパー関数

// ===== Providers (Riverpod Generator) =====

/// 累計データを管理するNotifier
/// 
/// Riverpod Generatorを使用してTotalDataモデルを管理します。
/// 
/// **使用方法**:
/// ```dart
/// final totalData = ref.watch(totalDataNotifierProvider);
/// ref.read(totalDataNotifierProvider.notifier).updateTotal(newData);
/// ```
@Riverpod(keepAlive: true)
class TotalDataNotifier extends _$TotalDataNotifier {
  @override
  TotalData build() {
    debugPrint('🔍 [TotalDataNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    debugPrint('🔍 [TotalDataNotifier.build] スタックトレース:');
    debugPrint(StackTrace.current.toString().split('\n').take(5).join('\n'));
    
    // 初期値を返す
    return TotalData(
      id: 'user_total',
      totalLoginDays: 0,
      totalWorkTimeMinutes: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  /// 累計データを更新
  void updateTotal(TotalData newData) {
    debugPrint('🔍 [TotalDataNotifier.updateTotal] 更新: ${newData.totalLoginDays}日、${newData.totalWorkTimeMinutes}分');
    state = newData;
  }

  /// データをリセット
  void reset() {
    debugPrint('🔍 [TotalDataNotifier.reset] リセット実行');
    state = TotalData(
      id: 'user_total',
      totalLoginDays: 0,
      totalWorkTimeMinutes: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }
}

// ===== ヘルパー関数 =====

/// 累計データを読み込むヘルパー関数（Firestore優先）
/// 
/// Firestoreから最新データを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルまたはデフォルト値を使用します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 読み込んだ累計データ
/// 
/// **動作フロー**:
/// 1. Firestoreから取得を試みる（getTotalDataWithAuth使用）
/// 2. 取得成功時はProviderに反映
/// 3. 取得失敗時はローカルまたはデフォルト値を使用
/// 
/// **使用例**:
/// ```dart
/// await loadTotalDataHelper(ref);
/// ```
Future<TotalData> loadTotalDataHelper(dynamic ref) async {
  debugPrint('🔍 [loadTotalDataHelper] 開始');
  
  final manager = TotalDataManager();

  // Firestoreから取得を試みる（Firestore優先）
  final totalData = await manager.getTotalDataWithAuth();
  
  if (totalData != null) {
    debugPrint('🔍 [loadTotalDataHelper] Firestoreから取得: ${totalData.totalLoginDays}日、${totalData.totalWorkTimeMinutes}分');
  } else {
    // Firestoreから取得できない場合はデフォルト値
    final defaultData = await manager.getTotalDataOrDefault();
    debugPrint('🔍 [loadTotalDataHelper] デフォルト値を使用: ${defaultData.totalLoginDays}日、${defaultData.totalWorkTimeMinutes}分');
    
    // Notifierを使用してProviderを更新
    ref.read(totalDataProvider.notifier).updateTotal(defaultData);
    debugPrint('🔍 [loadTotalDataHelper] Provider更新完了');
    
    return defaultData;
  }

  // Notifierを使用してProviderを更新
  ref.read(totalDataProvider.notifier).updateTotal(totalData);
  debugPrint('🔍 [loadTotalDataHelper] Provider更新完了');
  
  // 更新後の状態を確認
  final updatedState = ref.read(totalDataProvider);
  debugPrint('🔍 [loadTotalDataHelper] Provider更新後の状態: ${updatedState.totalLoginDays}日、${updatedState.totalWorkTimeMinutes}分');

  return totalData;
}

/// 累計データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// Providerを最新の状態に更新します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 同期された累計データ
/// 
/// **使用例**:
/// ```dart
/// await syncTotalDataHelper(ref);
/// ```
Future<TotalData> syncTotalDataHelper(dynamic ref) async {
  debugPrint('🔍 [syncTotalDataHelper] 開始');
  
  final manager = TotalDataManager();

  // Firestoreと同期（認証自動取得版）
  final syncedList = await manager.syncTotalDataWithAuth();
  debugPrint('🔍 [syncTotalDataHelper] 同期で取得: ${syncedList.length}件');

  // Totalは1つだけなので、リストから取得またはデフォルト値
  final totalData = syncedList.isNotEmpty 
      ? syncedList.first 
      : await manager.getTotalDataOrDefault();
  
  debugPrint('🔍 [syncTotalDataHelper] 最終データ: ${totalData.totalLoginDays}日、${totalData.totalWorkTimeMinutes}分');

  // Notifierを使用してProviderを更新
  ref.read(totalDataProvider.notifier).updateTotal(totalData);
  debugPrint('🔍 [syncTotalDataHelper] Provider更新完了');
  
  // 更新後の状態を確認
  final updatedState = ref.read(totalDataProvider);
  debugPrint('🔍 [syncTotalDataHelper] Provider更新後の状態: ${updatedState.totalLoginDays}日、${updatedState.totalWorkTimeMinutes}分');

  return totalData;
}

