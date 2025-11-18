import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_model.dart';

/// 月次統計用データマネージャー
/// 
/// BaseDataManager<MonthlyStatistics>を継承して、月次統計データの管理を行います。
class MonthlyStatisticsDataManager extends BaseDataManager<MonthlyStatistics> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/monthly_statistics';

  @override
  MonthlyStatistics convertFromFirestore(Map<String, dynamic> data) {
    return MonthlyStatistics.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(MonthlyStatistics item) {
    return item.toFirestore();
  }

  @override
  MonthlyStatistics convertFromJson(Map<String, dynamic> json) =>
      MonthlyStatistics.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(MonthlyStatistics item) => item.toJson();

  @override
  String get storageKey => 'monthly_statistics';

  // ===== カスタム機能（月次統計特有） =====

  /// 指定年月の月次統計を取得（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `year`: 年
  /// - `month`: 月（1-12）
  /// 
  /// **戻り値**: 該当月の統計データ、存在しない場合はnull
  Future<MonthlyStatistics?> getByMonthWithAuth(int year, int month) async {
    try {
      final id = _formatMonthId(year, month);
      
      final allData = await getAllWithAuth();
      return allData.where((m) => m.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByMonthWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 月次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあれば更新、なければ新規作成します。
  /// Firestoreに確実に保存するため、saveWithRetryAuthを使用します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する月次統計データ
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveOrUpdateWithAuth(MonthlyStatistics statistics) async {
    try {
      // saveWithRetryAuthはupsert（存在確認付き）なので、既存チェック不要
      return await manager.saveWithRetryAuth(statistics);
    } catch (e) {
      debugPrint('❌ [saveOrUpdateWithAuth] 保存エラー: $e');
      return false;
    }
  }

  /// 年月をID形式に変換（例: "2024-01"）
  String _formatMonthId(int year, int month) {
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');
    return '$yearStr-$monthStr';
  }
}

