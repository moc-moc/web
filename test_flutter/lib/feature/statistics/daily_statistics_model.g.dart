// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieChartDataModel _$PieChartDataModelFromJson(Map<String, dynamic> json) =>
    _PieChartDataModel(
      categorySeconds: Map<String, int>.from(json['categorySeconds'] as Map),
      percentages: (json['percentages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      colors: Map<String, int>.from(json['colors'] as Map),
      totalSeconds: (json['totalSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$PieChartDataModelToJson(_PieChartDataModel instance) =>
    <String, dynamic>{
      'categorySeconds': instance.categorySeconds,
      'percentages': instance.percentages,
      'colors': instance.colors,
      'totalSeconds': instance.totalSeconds,
    };

_DailyStatistics _$DailyStatisticsFromJson(Map<String, dynamic> json) =>
    _DailyStatistics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      categorySeconds: Map<String, int>.from(json['categorySeconds'] as Map),
      totalWorkTimeSeconds: (json['totalWorkTimeSeconds'] as num).toInt(),
      pieChartData: _pieChartDataFromJson(
        json['pieChartData'] as Map<String, dynamic>?,
      ),
      hourlyCategorySeconds:
          (json['hourlyCategorySeconds'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
          ) ??
          const {},
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$DailyStatisticsToJson(_DailyStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'categorySeconds': instance.categorySeconds,
      'totalWorkTimeSeconds': instance.totalWorkTimeSeconds,
      'pieChartData': _pieChartDataToJson(instance.pieChartData),
      'hourlyCategorySeconds': instance.hourlyCategorySeconds,
      'lastModified': instance.lastModified.toIso8601String(),
    };
