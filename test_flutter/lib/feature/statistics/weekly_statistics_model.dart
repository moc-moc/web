// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';

part 'weekly_statistics_model.freezed.dart';
part 'weekly_statistics_model.g.dart';

/// 週次統計モデル
/// 
/// 1週間分のトラッキング統計データを管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
@freezed
abstract class WeeklyStatistics with _$WeeklyStatistics {
  /// WeeklyStatisticsモデルのコンストラクタ
  const factory WeeklyStatistics({
    /// 識別子（週開始日ベース、例: "2024-01-15"）
    required String id,
    
    /// 週の開始日（月曜日、時刻部分は00:00:00）
    required DateTime weekStart,
    
    /// カテゴリ別の時間（秒単位）
    /// study, pc, smartphone, personOnly, nothingDetectedを含む
    required Map<String, int> categorySeconds,
    
    /// 作業時間合計（秒単位、pc + study）
    required int totalWorkTimeSeconds,
    
    /// 円グラフ用データ
    @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)
    PieChartDataModel? pieChartData,
    
    /// 日ごとのカテゴリ別秒数（7日分）
    /// キー: "0", "1", ..., "6" (月曜日から日曜日)
    /// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, ...}
    @Default({}) Map<String, Map<String, int>> dailyCategorySeconds,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _WeeklyStatistics;

  /// プライベートコンストラクタ（getter用）
  const WeeklyStatistics._();

  /// JSONからWeeklyStatisticsモデルを生成
  factory WeeklyStatistics.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatisticsFromJson(json);

  /// FirestoreデータからWeeklyStatisticsモデルを生成
  factory WeeklyStatistics.fromFirestore(Map<String, dynamic> data) {
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

    return WeeklyStatistics(
      id: data['id'] as String,
      weekStart: (data['weekStart'] as Timestamp).toDate(),
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
      'weekStart': Timestamp.fromDate(weekStart),
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

