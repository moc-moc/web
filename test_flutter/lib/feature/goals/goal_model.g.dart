// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: json['id'] as String,
  tag: json['tag'] as String,
  title: json['title'] as String,
  targetTime: (json['targetTime'] as num).toInt(),
  comparisonType: $enumDecode(_$ComparisonTypeEnumMap, json['comparisonType']),
  detectionItem: $enumDecode(_$DetectionItemEnumMap, json['detectionItem']),
  startDate: DateTime.parse(json['startDate'] as String),
  durationDays: (json['durationDays'] as num).toInt(),
  consecutiveAchievements:
      (json['consecutiveAchievements'] as num?)?.toInt() ?? 0,
  achievedTime: (json['achievedTime'] as num?)?.toInt(),
  isDeleted: json['isDeleted'] as bool? ?? false,
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'tag': instance.tag,
  'title': instance.title,
  'targetTime': instance.targetTime,
  'comparisonType': _$ComparisonTypeEnumMap[instance.comparisonType]!,
  'detectionItem': _$DetectionItemEnumMap[instance.detectionItem]!,
  'startDate': instance.startDate.toIso8601String(),
  'durationDays': instance.durationDays,
  'consecutiveAchievements': instance.consecutiveAchievements,
  'achievedTime': instance.achievedTime,
  'isDeleted': instance.isDeleted,
  'lastModified': instance.lastModified.toIso8601String(),
};

const _$ComparisonTypeEnumMap = {
  ComparisonType.above: 'above',
  ComparisonType.below: 'below',
};

const _$DetectionItemEnumMap = {
  DetectionItem.book: 'book',
  DetectionItem.smartphone: 'smartphone',
  DetectionItem.pc: 'pc',
};
