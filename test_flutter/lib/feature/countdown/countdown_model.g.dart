// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countdown_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Countdown _$CountdownFromJson(Map<String, dynamic> json) => _Countdown(
  id: json['id'] as String,
  title: json['title'] as String,
  targetDate: DateTime.parse(json['targetDate'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$CountdownToJson(_Countdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetDate': instance.targetDate.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'lastModified': instance.lastModified.toIso8601String(),
    };
