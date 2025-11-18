// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) => _SessionInfo(
  id: json['id'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  categorySeconds: Map<String, int>.from(json['categorySeconds'] as Map),
  detectionPeriods:
      (json['detectionPeriods'] as List<dynamic>?)
          ?.map((e) => DetectionPeriod.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$SessionInfoToJson(_SessionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'categorySeconds': instance.categorySeconds,
      'detectionPeriods': instance.detectionPeriods,
      'lastModified': instance.lastModified.toIso8601String(),
    };
