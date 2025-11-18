// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyStatistics _$MonthlyStatisticsFromJson(Map<String, dynamic> json) =>
    _MonthlyStatistics(
      id: json['id'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      categorySeconds: Map<String, int>.from(json['categorySeconds'] as Map),
      totalWorkTimeSeconds: (json['totalWorkTimeSeconds'] as num).toInt(),
      pieChartData: _pieChartDataFromJson(
        json['pieChartData'] as Map<String, dynamic>?,
      ),
      dailyCategorySeconds:
          (json['dailyCategorySeconds'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
          ) ??
          const {},
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$MonthlyStatisticsToJson(_MonthlyStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'categorySeconds': instance.categorySeconds,
      'totalWorkTimeSeconds': instance.totalWorkTimeSeconds,
      'pieChartData': _pieChartDataToJson(instance.pieChartData),
      'dailyCategorySeconds': instance.dailyCategorySeconds,
      'lastModified': instance.lastModified.toIso8601String(),
    };
