// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_count_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackingCount _$TrackingCountFromJson(Map<String, dynamic> json) =>
    _TrackingCount(
      id: json['id'] as String,
      count: (json['count'] as num).toInt(),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$TrackingCountToJson(_TrackingCount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'lastModified': instance.lastModified.toIso8601String(),
    };
