// 外部パッケージ
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 内部パッケージ（プロジェクト内）
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/total/total_model.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';

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
    // 初期値を返す
    return TotalData(
      id: 'user_total',
      totalWorkTimeMinutes: 0,
      lastTrackedDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  /// 累計データを更新
  void updateTotal(TotalData newData) {
    state = newData;
  }

  /// データをリセット
  void reset() {
    state = TotalData(
      id: 'user_total',
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
  final manager = TotalDataManager();

  return await loadSingleDataHelper<TotalData>(
    ref: ref,
    manager: manager,
    getWithAuth: () => manager.getTotalDataWithAuth(),
    getDefault: () => manager.getTotalDataOrDefault(),
    updateProvider: (data) => ref.read(totalDataProvider.notifier).updateTotal(data),
    functionName: 'loadTotalDataHelper',
  );
}

/// 累計データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: Ref（Provider操作用）
/// 
/// **戻り値**: 読み込んだ累計データ（ローカルまたはデフォルト値）
/// 
/// **動作フロー**:
/// 1. ローカルまたはデフォルト値で即座に表示
/// 2. バックグラウンドでFirestoreから最新データを取得
/// 3. 取得成功時はローカルにも保存してProviderに反映
/// 4. 取得失敗時はローカルデータのまま
/// 
/// **使用例**:
/// ```dart
/// await loadTotalDataWithBackgroundRefreshHelper(ref);
/// ```
Future<TotalData> loadTotalDataWithBackgroundRefreshHelper(dynamic ref) async {
  final manager = TotalDataManager();

  return await loadSingleDataWithBackgroundRefreshHelper<TotalData>(
    ref: ref,
    manager: manager,
    getWithAuth: () => manager.getTotalDataWithAuth(),
    getLocal: () => manager.getLocalTotalData(),
    getDefault: () => manager.getTotalDataOrDefault(),
    saveLocal: (data) => manager.saveLocalTotalData(data),
    updateProvider: (data) => ref.read(totalDataProvider.notifier).updateTotal(data),
    functionName: 'loadTotalDataWithBackgroundRefreshHelper',
  );
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
  final manager = TotalDataManager();

  return await syncSingleDataHelper<TotalData>(
    ref: ref,
    manager: manager,
    syncWithAuth: () => manager.syncTotalDataWithAuth(),
    getDefault: () => manager.getTotalDataOrDefault(),
    updateProvider: (data) => ref.read(totalDataProvider.notifier).updateTotal(data),
    functionName: 'syncTotalDataHelper',
  );
}
