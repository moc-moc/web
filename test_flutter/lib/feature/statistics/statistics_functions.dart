import 'package:flutter/foundation.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_data_manager.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_model.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_data_manager.dart';

/// 統計データ機能用の関数群
/// 
/// 日次、週次、月次、年次の統計データの同期機能を提供します。

// ===== ヘルパー関数 =====

/// 日次統計データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルからデータを取得して即座に返し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **戻り値**: 読み込んだ日次統計データのリスト（ローカルデータ）
/// 
/// **使用例**:
/// ```dart
/// await loadDailyStatisticsWithBackgroundRefreshHelper();
/// ```
Future<List<DailyStatistics>> loadDailyStatisticsWithBackgroundRefreshHelper() async {
  final manager = DailyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await loadListDataWithBackgroundRefreshHelper<DailyStatistics>(
    ref: dummyRef,
    manager: manager,
    getAllWithAuth: () => manager.getAllWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    saveLocal: (items) => manager.saveLocal(items),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'loadDailyStatisticsWithBackgroundRefreshHelper',
  );
}

/// 週次統計データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルからデータを取得して即座に返し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **戻り値**: 読み込んだ週次統計データのリスト（ローカルデータ）
/// 
/// **使用例**:
/// ```dart
/// await loadWeeklyStatisticsWithBackgroundRefreshHelper();
/// ```
Future<List<WeeklyStatistics>> loadWeeklyStatisticsWithBackgroundRefreshHelper() async {
  final manager = WeeklyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await loadListDataWithBackgroundRefreshHelper<WeeklyStatistics>(
    ref: dummyRef,
    manager: manager,
    getAllWithAuth: () => manager.getAllWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    saveLocal: (items) => manager.saveLocal(items),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'loadWeeklyStatisticsWithBackgroundRefreshHelper',
  );
}

/// 月次統計データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルからデータを取得して即座に返し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **戻り値**: 読み込んだ月次統計データのリスト（ローカルデータ）
/// 
/// **使用例**:
/// ```dart
/// await loadMonthlyStatisticsWithBackgroundRefreshHelper();
/// ```
Future<List<MonthlyStatistics>> loadMonthlyStatisticsWithBackgroundRefreshHelper() async {
  final manager = MonthlyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await loadListDataWithBackgroundRefreshHelper<MonthlyStatistics>(
    ref: dummyRef,
    manager: manager,
    getAllWithAuth: () => manager.getAllWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    saveLocal: (items) => manager.saveLocal(items),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'loadMonthlyStatisticsWithBackgroundRefreshHelper',
  );
}

/// 年次統計データをバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルからデータを取得して即座に返し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **戻り値**: 読み込んだ年次統計データのリスト（ローカルデータ）
/// 
/// **使用例**:
/// ```dart
/// await loadYearlyStatisticsWithBackgroundRefreshHelper();
/// ```
Future<List<YearlyStatistics>> loadYearlyStatisticsWithBackgroundRefreshHelper() async {
  final manager = YearlyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await loadListDataWithBackgroundRefreshHelper<YearlyStatistics>(
    ref: dummyRef,
    manager: manager,
    getAllWithAuth: () => manager.getAllWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    saveLocal: (items) => manager.saveLocal(items),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'loadYearlyStatisticsWithBackgroundRefreshHelper',
  );
}

/// 日次統計データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// 最新の状態に更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// 
/// **戻り値**: 同期された日次統計データのリスト
/// 
/// **使用例**:
/// ```dart
/// await syncDailyStatisticsHelper();
/// ```
Future<List<DailyStatistics>> syncDailyStatisticsHelper() async {
  final manager = DailyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await syncListDataHelper<DailyStatistics>(
    ref: dummyRef,
    manager: manager,
    syncWithAuth: () => manager.syncWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'syncDailyStatisticsHelper',
  );
}

/// 週次統計データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// 最新の状態に更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// 
/// **戻り値**: 同期された週次統計データのリスト
/// 
/// **使用例**:
/// ```dart
/// await syncWeeklyStatisticsHelper();
/// ```
Future<List<WeeklyStatistics>> syncWeeklyStatisticsHelper() async {
  final manager = WeeklyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await syncListDataHelper<WeeklyStatistics>(
    ref: dummyRef,
    manager: manager,
    syncWithAuth: () => manager.syncWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'syncWeeklyStatisticsHelper',
  );
}

/// 月次統計データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// 最新の状態に更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// 
/// **戻り値**: 同期された月次統計データのリスト
/// 
/// **使用例**:
/// ```dart
/// await syncMonthlyStatisticsHelper();
/// ```
Future<List<MonthlyStatistics>> syncMonthlyStatisticsHelper() async {
  final manager = MonthlyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await syncListDataHelper<MonthlyStatistics>(
    ref: dummyRef,
    manager: manager,
    syncWithAuth: () => manager.syncWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'syncMonthlyStatisticsHelper',
  );
}

/// 年次統計データを同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、
/// 最新の状態に更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// 
/// **戻り値**: 同期された年次統計データのリスト
/// 
/// **使用例**:
/// ```dart
/// await syncYearlyStatisticsHelper();
/// ```
Future<List<YearlyStatistics>> syncYearlyStatisticsHelper() async {
  final manager = YearlyStatisticsDataManager();
  final dummyRef = Object(); // Provider更新不要のためダミーRef

  return await syncListDataHelper<YearlyStatistics>(
    ref: dummyRef,
    manager: manager,
    syncWithAuth: () => manager.syncWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    updateProvider: (_) {}, // 統計データはProviderを使用しないため空関数
    filter: (_) => true, // フィルタリング不要
    functionName: 'syncYearlyStatisticsHelper',
  );
}

/// すべての統計データを同期するヘルパー関数
/// 
/// 日次、週次、月次、年次の統計データをすべて同期します。
/// 
/// **戻り値**: 同期結果のマップ
/// 
/// **使用例**:
/// ```dart
/// await syncAllStatisticsHelper();
/// ```
Future<Map<String, bool>> syncAllStatisticsHelper() async {
  final results = <String, bool>{};
  
  try {
    await syncDailyStatisticsHelper();
    results['daily'] = true;
  } catch (e) {
    debugPrint('❌ 日次統計の同期に失敗: $e');
    results['daily'] = false;
  }
  
  try {
    await syncWeeklyStatisticsHelper();
    results['weekly'] = true;
  } catch (e) {
    debugPrint('❌ 週次統計の同期に失敗: $e');
    results['weekly'] = false;
  }
  
  try {
    await syncMonthlyStatisticsHelper();
    results['monthly'] = true;
  } catch (e) {
    debugPrint('❌ 月次統計の同期に失敗: $e');
    results['monthly'] = false;
  }
  
  try {
    await syncYearlyStatisticsHelper();
    results['yearly'] = true;
  } catch (e) {
    debugPrint('❌ 年次統計の同期に失敗: $e');
    results['yearly'] = false;
  }
  
  return results;
}

/// 古い統計データを削除するヘルパー関数
/// 
/// 各統計データの古いデータを削除します。
/// - daily_statistics: 90日以上経過したデータを削除
/// - weekly_statistics: 6ヶ月（約26週）以上経過したデータを削除
/// - monthly_statistics: 3年（36ヶ月）以上経過したデータを削除
/// - yearly_statistics: 永久保持（削除しない）
/// 
/// **戻り値**: 削除結果のマップ
/// 
/// **使用例**:
/// ```dart
/// await deleteOldStatisticsDataHelper();
/// ```
Future<Map<String, int>> deleteOldStatisticsDataHelper() async {
  final results = <String, int>{};
  
  try {
    final dailyManager = DailyStatisticsDataManager();
    results['daily'] = await dailyManager.deleteOldData();
  } catch (e) {
    debugPrint('❌ 日次統計の古いデータ削除に失敗: $e');
    results['daily'] = 0;
  }
  
  try {
    final weeklyManager = WeeklyStatisticsDataManager();
    results['weekly'] = await weeklyManager.deleteOldData();
  } catch (e) {
    debugPrint('❌ 週次統計の古いデータ削除に失敗: $e');
    results['weekly'] = 0;
  }
  
  try {
    final monthlyManager = MonthlyStatisticsDataManager();
    results['monthly'] = await monthlyManager.deleteOldData();
  } catch (e) {
    debugPrint('❌ 月次統計の古いデータ削除に失敗: $e');
    results['monthly'] = 0;
  }
  
  // yearly_statisticsは永久保持のため削除しない
  
  return results;
}

