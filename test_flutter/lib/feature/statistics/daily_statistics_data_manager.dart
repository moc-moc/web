import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';

/// 日次統計用データマネージャー
/// 
/// BaseDataManager<DailyStatistics>を継承して、日次統計データの管理を行います。
class DailyStatisticsDataManager extends BaseDataManager<DailyStatistics> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/daily_statistics';

  @override
  DailyStatistics convertFromFirestore(Map<String, dynamic> data) {
    return DailyStatistics.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(DailyStatistics item) {
    return item.toFirestore();
  }

  @override
  DailyStatistics convertFromJson(Map<String, dynamic> json) =>
      DailyStatistics.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(DailyStatistics item) => item.toJson();

  @override
  String get storageKey => 'daily_statistics';

  // ===== カスタム機能（日次統計特有） =====

  /// 指定日付の日次統計を取得（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `date`: 取得する日付（時刻部分は無視される）
  /// 
  /// **戻り値**: 該当日の統計データ、存在しない場合はnull
  Future<DailyStatistics?> getByDateWithAuth(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final id = _formatDateId(dateOnly);
      
      final allData = await getAllWithAuth();
      return allData.where((d) => d.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByDateWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 日次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあれば更新、なければ新規作成します。
  /// Firestoreに確実に保存するため、saveWithRetryAuthを使用します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する日次統計データ
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveOrUpdateWithAuth(DailyStatistics statistics) async {
    try {
      // saveWithRetryAuthはupsert（存在確認付き）なので、既存チェック不要
      return await manager.saveWithRetryAuth(statistics);
    } catch (e) {
      debugPrint('❌ [saveOrUpdateWithAuth] 保存エラー: $e');
      return false;
    }
  }

  /// 指定日付の日次統計をローカルから取得
  /// 
  /// **パラメータ**:
  /// - `date`: 取得する日付（時刻部分は無視される）
  /// 
  /// **戻り値**: 該当日の統計データ、存在しない場合はnull
  Future<DailyStatistics?> getByDateLocal(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final id = _formatDateId(dateOnly);
      
      final allData = await manager.getLocalAll();
      return allData.where((d) => d.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByDateLocal] 取得エラー: $e');
      return null;
    }
  }

  /// 日付をID形式に変換（例: "2024-01-15"）
  String _formatDateId(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

