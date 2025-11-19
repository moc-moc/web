// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';

part 'daily_statistics_model.freezed.dart';
part 'daily_statistics_model.g.dart';

/// 円グラフデータモデル
/// 
/// 円グラフ表示に必要なデータを保存します。
@freezed
abstract class PieChartDataModel with _$PieChartDataModel {
  const factory PieChartDataModel({
    /// 各カテゴリの秒数
    required Map<String, int> categorySeconds,
    
    /// 各カテゴリの割合（%）
    required Map<String, double> percentages,
    
    /// 各カテゴリの色（Colorのvalueをintで保存）
    required Map<String, int> colors,
    
    /// 合計秒数
    required int totalSeconds,
  }) = _PieChartDataModel;

  /// JSONからPieChartDataModelを生成
  factory PieChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$PieChartDataModelFromJson(json);
}

/// 日次統計モデル
/// 
/// 1日分のトラッキング統計データを管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
@freezed
abstract class DailyStatistics with _$DailyStatistics {
  /// DailyStatisticsモデルのコンストラクタ
  const factory DailyStatistics({
    /// 識別子（日付ベース、例: "2024-01-15"）
    required String id,
    
    /// 日付（時刻部分は00:00:00）
    required DateTime date,
    
    /// カテゴリ別の時間（秒単位）
    /// study, pc, smartphone, personOnly, nothingDetectedを含む
    required Map<String, int> categorySeconds,
    
    /// 作業時間合計（秒単位、pc + study）
    required int totalWorkTimeSeconds,
    
    /// 円グラフ用データ
    @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)
    PieChartDataModel? pieChartData,
    
    /// 時間ごとのカテゴリ別秒数（24時間分）
    /// キー: "0", "1", ..., "23" (時間)
    /// 値: カテゴリ別秒数のMap {study: 600, pc: 300, ...}
    @Default({}) Map<String, Map<String, int>> hourlyCategorySeconds,
    
    /// セッション情報のリスト
    /// その日のトラッキングセッションを保持
    @Default([]) @JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) List<SessionInfo> sessions,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _DailyStatistics;

  /// プライベートコンストラクタ（getter用）
  const DailyStatistics._();

  /// JSONからDailyStatisticsモデルを生成
  factory DailyStatistics.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsFromJson(json);

  /// FirestoreデータからDailyStatisticsモデルを生成
  factory DailyStatistics.fromFirestore(Map<String, dynamic> data) {
    PieChartDataModel? pieChartDataModel;
    if (data['pieChartData'] != null) {
      pieChartDataModel = PieChartDataModel.fromJson(
        data['pieChartData'] as Map<String, dynamic>,
      );
    }

    // hourlyCategorySecondsの変換（後方互換性のためnullチェック）
    Map<String, Map<String, int>> hourlyCategorySeconds = {};
    if (data['hourlyCategorySeconds'] != null) {
      final hourlyData = data['hourlyCategorySeconds'] as Map<String, dynamic>;
      hourlyCategorySeconds = hourlyData.map(
        (key, value) => MapEntry(
          key,
          Map<String, int>.from(value as Map),
        ),
      );
    }

    // sessionsの変換（後方互換性のためnullチェック）
    List<SessionInfo> sessions = [];
    if (data['sessions'] != null) {
      final sessionsData = data['sessions'] as List<dynamic>;
      sessions = sessionsData
          .map((e) => SessionInfo.fromFirestore(e as Map<String, dynamic>))
          .toList();
    }

    return DailyStatistics(
      id: data['id'] as String,
      date: (data['date'] as Timestamp).toDate(),
      categorySeconds: Map<String, int>.from(data['categorySeconds'] as Map),
      totalWorkTimeSeconds: data['totalWorkTimeSeconds'] as int,
      pieChartData: pieChartDataModel,
      hourlyCategorySeconds: hourlyCategorySeconds,
      sessions: sessions,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'categorySeconds': categorySeconds,
      'totalWorkTimeSeconds': totalWorkTimeSeconds,
      'pieChartData': pieChartData?.toJson(),
      'hourlyCategorySeconds': hourlyCategorySeconds.map(
        (key, value) => MapEntry(key, value),
      ),
      'sessions': sessions.map((s) => s.toFirestore()).toList(),
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

/// SessionInfoリストをJSONに変換するヘルパー関数
List<Map<String, dynamic>> _sessionsToJson(List<SessionInfo> sessions) =>
    sessions.map((s) => s.toFirestore()).toList();

/// JSONからSessionInfoリストを生成するヘルパー関数
List<SessionInfo> _sessionsFromJson(List<dynamic>? json) {
  if (json == null) return [];
  return json
      .map((e) => SessionInfo.fromFirestore(e as Map<String, dynamic>))
      .toList();
}

