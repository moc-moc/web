// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklyStatistics _$WeeklyStatisticsFromJson(Map<String, dynamic> json) =>
    _WeeklyStatistics(
      id: json['id'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
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

Map<String, dynamic> _$WeeklyStatisticsToJson(_WeeklyStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weekStart': instance.weekStart.toIso8601String(),
      'categorySeconds': instance.categorySeconds,
      'totalWorkTimeSeconds': instance.totalWorkTimeSeconds,
      'pieChartData': _pieChartDataToJson(instance.pieChartData),
      'dailyCategorySeconds': instance.dailyCategorySeconds,
      'lastModified': instance.lastModified.toIso8601String(),
    };
