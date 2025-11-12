// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_data_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotalData _$TotalDataFromJson(Map<String, dynamic> json) => _TotalData(
  id: json['id'] as String,
  totalLoginDays: (json['totalLoginDays'] as num).toInt(),
  totalWorkTimeMinutes: (json['totalWorkTimeMinutes'] as num).toInt(),
  lastTrackedDate: DateTime.parse(json['lastTrackedDate'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$TotalDataToJson(_TotalData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalLoginDays': instance.totalLoginDays,
      'totalWorkTimeMinutes': instance.totalWorkTimeMinutes,
      'lastTrackedDate': instance.lastTrackedDate.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
    };
