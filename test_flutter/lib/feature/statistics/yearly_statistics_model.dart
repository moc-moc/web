// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';

part 'yearly_statistics_model.freezed.dart';
part 'yearly_statistics_model.g.dart';

/// 年次統計モデル
/// 
/// 1年分のトラッキング統計データを管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **注意**: personOnlyとnothingDetectedは集計に含まれません。
@freezed
abstract class YearlyStatistics with _$YearlyStatistics {
  /// YearlyStatisticsモデルのコンストラクタ
  const factory YearlyStatistics({
    /// 識別子（年ベース、例: "2024"）
    required String id,
    
    /// 年
    required int year,
    
    /// カテゴリ別の時間（秒単位）
    /// study, pc, smartphoneのみ（personOnlyとnothingDetectedは除外）
    required Map<String, int> categorySeconds,
    
    /// 作業時間合計（秒単位、pc + study）
    required int totalWorkTimeSeconds,
    
    /// 円グラフ用データ
    @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)
    PieChartDataModel? pieChartData,
    
    /// 月ごとのカテゴリ別秒数（12ヶ月分）
    /// キー: "1", "2", ..., "12" (月)
    /// 値: カテゴリ別秒数のMap {study: 36000, pc: 18000, smartphone: 6000}
    @Default({}) Map<String, Map<String, int>> monthlyCategorySeconds,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _YearlyStatistics;

  /// プライベートコンストラクタ（getter用）
  const YearlyStatistics._();

  /// JSONからYearlyStatisticsモデルを生成
  factory YearlyStatistics.fromJson(Map<String, dynamic> json) =>
      _$YearlyStatisticsFromJson(json);

  /// FirestoreデータからYearlyStatisticsモデルを生成
  factory YearlyStatistics.fromFirestore(Map<String, dynamic> data) {
    PieChartDataModel? pieChartDataModel;
    if (data['pieChartData'] != null) {
      pieChartDataModel = PieChartDataModel.fromJson(
        data['pieChartData'] as Map<String, dynamic>,
      );
    }

    // monthlyCategorySecondsの変換（後方互換性のためnullチェック）
    Map<String, Map<String, int>> monthlyCategorySeconds = {};
    if (data['monthlyCategorySeconds'] != null) {
      final monthlyData = data['monthlyCategorySeconds'] as Map<String, dynamic>;
      monthlyCategorySeconds = monthlyData.map(
        (key, value) => MapEntry(
          key,
          Map<String, int>.from(value as Map),
        ),
      );
    }

    return YearlyStatistics(
      id: data['id'] as String,
      year: data['year'] as int,
      categorySeconds: Map<String, int>.from(data['categorySeconds'] as Map),
      totalWorkTimeSeconds: data['totalWorkTimeSeconds'] as int,
      pieChartData: pieChartDataModel,
      monthlyCategorySeconds: monthlyCategorySeconds,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'year': year,
      'categorySeconds': categorySeconds,
      'totalWorkTimeSeconds': totalWorkTimeSeconds,
      'pieChartData': pieChartData?.toJson(),
      'monthlyCategorySeconds': monthlyCategorySeconds.map(
        (key, value) => MapEntry(key, value),
      ),
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

/// PieChartDataModelをJSONに変換するヘルパー関数
Map<String, dynamic>? _pieChartDataToJson(PieChartDataModel? instance) =>
    instance?.toJson();

/// JSONからPieChartDataModelを生成するヘルパー関数
PieChartDataModel? _pieChartDataFromJson(Map<String, dynamic>? json) =>
    json != null ? PieChartDataModel.fromJson(json) : null;

