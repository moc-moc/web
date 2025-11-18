import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/statistics/weekly_statistics_model.dart';

/// 週次統計用データマネージャー
/// 
/// BaseDataManager<WeeklyStatistics>を継承して、週次統計データの管理を行います。
class WeeklyStatisticsDataManager extends BaseDataManager<WeeklyStatistics> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/weekly_statistics';

  @override
  WeeklyStatistics convertFromFirestore(Map<String, dynamic> data) {
    return WeeklyStatistics.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(WeeklyStatistics item) {
    return item.toFirestore();
  }

  @override
  WeeklyStatistics convertFromJson(Map<String, dynamic> json) =>
      WeeklyStatistics.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(WeeklyStatistics item) => item.toJson();

  @override
  String get storageKey => 'weekly_statistics';

  // ===== カスタム機能（週次統計特有） =====

  /// 指定日付が含まれる週の週次統計を取得（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `date`: 週内の任意の日付
  /// 
  /// **戻り値**: 該当週の統計データ、存在しない場合はnull
  Future<WeeklyStatistics?> getByWeekWithAuth(DateTime date) async {
    try {
      final weekStart = _getWeekStart(date);
      final id = _formatDateId(weekStart);
      
      final allData = await getAllWithAuth();
      return allData.where((w) => w.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByWeekWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 週次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあれば更新、なければ新規作成します。
  /// Firestoreに確実に保存するため、saveWithRetryAuthを使用します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する週次統計データ
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveOrUpdateWithAuth(WeeklyStatistics statistics) async {
    try {
      // saveWithRetryAuthはupsert（存在確認付き）なので、既存チェック不要
      return await manager.saveWithRetryAuth(statistics);
    } catch (e) {
      debugPrint('❌ [saveOrUpdateWithAuth] 保存エラー: $e');
      return false;
    }
  }

  /// 指定日付が含まれる週の開始日（月曜日）を取得
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1=月曜日, 7=日曜日
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// 日付をID形式に変換（例: "2024-01-15"）
  String _formatDateId(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

