// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';

part 'monthly_statistics_model.freezed.dart';
part 'monthly_statistics_model.g.dart';

/// 月次統計モデル
/// 
/// 1ヶ月分のトラッキング統計データを管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **注意**: personOnlyとnothingDetectedは集計に含まれません。
@freezed
abstract class MonthlyStatistics with _$MonthlyStatistics {
  /// MonthlyStatisticsモデルのコンストラクタ
  const factory MonthlyStatistics({
    /// 識別子（年月ベース、例: "2024-01"）
    required String id,
    
    /// 年
    required int year,
    
    /// 月（1-12）
    required int month,
    
    /// カテゴリ別の時間（秒単位）
    /// study, pc, smartphoneのみ（personOnlyとnothingDetectedは除外）
    required Map<String, int> categorySeconds,
    
    /// 作業時間合計（秒単位、pc + study）
    required int totalWorkTimeSeconds,
    
    /// 円グラフ用データ
    @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)
    PieChartDataModel? pieChartData,
    
    /// 日ごとのカテゴリ別秒数（月の日数分）
    /// キー: "1", "2", ..., "31" (日)
    /// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, smartphone: 600}
    @Default({}) Map<String, Map<String, int>> dailyCategorySeconds,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _MonthlyStatistics;

  /// プライベートコンストラクタ（getter用）
  const MonthlyStatistics._();

  /// JSONからMonthlyStatisticsモデルを生成
  factory MonthlyStatistics.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatisticsFromJson(json);

  /// FirestoreデータからMonthlyStatisticsモデルを生成
  factory MonthlyStatistics.fromFirestore(Map<String, dynamic> data) {
    PieChartDataModel? pieChartDataModel;
    if (data['pieChartData'] != null) {
      pieChartDataModel = PieChartDataModel.fromJson(
        data['pieChartData'] as Map<String, dynamic>,
      );
    }

    // dailyCategorySecondsの変換（後方互換性のためnullチェック）
    Map<String, Map<String, int>> dailyCategorySeconds = {};
    if (data['dailyCategorySeconds'] != null) {
      final dailyData = data['dailyCategorySeconds'] as Map<String, dynamic>;
      dailyCategorySeconds = dailyData.map(
        (key, value) => MapEntry(
          key,
          Map<String, int>.from(value as Map),
        ),
      );
    }

    return MonthlyStatistics(
      id: data['id'] as String,
      year: data['year'] as int,
      month: data['month'] as int,
      categorySeconds: Map<String, int>.from(data['categorySeconds'] as Map),
      totalWorkTimeSeconds: data['totalWorkTimeSeconds'] as int,
      pieChartData: pieChartDataModel,
      dailyCategorySeconds: dailyCategorySeconds,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'categorySeconds': categorySeconds,
      'totalWorkTimeSeconds': totalWorkTimeSeconds,
      'pieChartData': pieChartData?.toJson(),
      'dailyCategorySeconds': dailyCategorySeconds.map(
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

