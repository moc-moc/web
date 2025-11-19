// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yearly_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_YearlyStatistics _$YearlyStatisticsFromJson(Map<String, dynamic> json) =>
    _YearlyStatistics(
      id: json['id'] as String,
      year: (json['year'] as num).toInt(),
      categorySeconds: Map<String, int>.from(json['categorySeconds'] as Map),
      totalWorkTimeSeconds: (json['totalWorkTimeSeconds'] as num).toInt(),
      pieChartData: _pieChartDataFromJson(
        json['pieChartData'] as Map<String, dynamic>?,
      ),
      monthlyCategorySeconds:
          (json['monthlyCategorySeconds'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
          ) ??
          const {},
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$YearlyStatisticsToJson(_YearlyStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'categorySeconds': instance.categorySeconds,
      'totalWorkTimeSeconds': instance.totalWorkTimeSeconds,
      'pieChartData': _pieChartDataToJson(instance.pieChartData),
      'monthlyCategorySeconds': instance.monthlyCategorySeconds,
      'lastModified': instance.lastModified.toIso8601String(),
    };
