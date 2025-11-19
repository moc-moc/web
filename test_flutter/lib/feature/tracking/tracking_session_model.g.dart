// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetectionPeriod _$DetectionPeriodFromJson(Map<String, dynamic> json) =>
    _DetectionPeriod(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$DetectionPeriodToJson(_DetectionPeriod instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'category': instance.category,
      'confidence': instance.confidence,
    };

_TrackingSession _$TrackingSessionFromJson(Map<String, dynamic> json) =>
    _TrackingSession(
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

Map<String, dynamic> _$TrackingSessionToJson(_TrackingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'categorySeconds': instance.categorySeconds,
      'detectionPeriods': instance.detectionPeriods,
      'lastModified': instance.lastModified.toIso8601String(),
    };
