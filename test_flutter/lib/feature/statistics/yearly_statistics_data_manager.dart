import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/statistics/yearly_statistics_model.dart';

/// 年次統計用データマネージャー
/// 
/// BaseDataManager<YearlyStatistics>を継承して、年次統計データの管理を行います。
class YearlyStatisticsDataManager extends BaseDataManager<YearlyStatistics> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/yearly_statistics';

  @override
  YearlyStatistics convertFromFirestore(Map<String, dynamic> data) {
    return YearlyStatistics.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(YearlyStatistics item) {
    return item.toFirestore();
  }

  @override
  YearlyStatistics convertFromJson(Map<String, dynamic> json) =>
      YearlyStatistics.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(YearlyStatistics item) => item.toJson();

  @override
  String get storageKey => 'yearly_statistics';

  // ===== カスタム機能（年次統計特有） =====

  /// 指定年の年次統計を取得（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `year`: 年
  /// 
  /// **戻り値**: 該当年の統計データ、存在しない場合はnull
  Future<YearlyStatistics?> getByYearWithAuth(int year) async {
    try {
      final id = year.toString();
      
      final allData = await getAllWithAuth();
      return allData.where((y) => y.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByYearWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 年次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあれば更新、なければ新規作成します。
  /// Firestoreに確実に保存するため、saveWithRetryAuthを使用します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する年次統計データ
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveOrUpdateWithAuth(YearlyStatistics statistics) async {
    try {
      // saveWithRetryAuthはupsert（存在確認付き）なので、既存チェック不要
      return await manager.saveWithRetryAuth(statistics);
    } catch (e) {
      debugPrint('❌ [saveOrUpdateWithAuth] 保存エラー: $e');
      return false;
    }
  }
}

