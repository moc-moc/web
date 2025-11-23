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
  periodEndDate: json['periodEndDate'] == null
      ? null
      : DateTime.parse(json['periodEndDate'] as String),
  targetSecondsPerDay: (json['targetSecondsPerDay'] as num?)?.toInt() ?? 0,
  consecutiveAchievements:
      (json['consecutiveAchievements'] as num?)?.toInt() ?? 0,
  consecutivePeriodAchievements:
      (json['consecutivePeriodAchievements'] as num?)?.toInt() ?? 0,
  achievedTime: (json['achievedTime'] as num?)?.toInt(),
  todayAchievedTime: (json['todayAchievedTime'] as num?)?.toInt(),
  lastResetDate: json['lastResetDate'] == null
      ? null
      : DateTime.parse(json['lastResetDate'] as String),
  lastAchievedEventShownAt: json['lastAchievedEventShownAt'] == null
      ? null
      : DateTime.parse(json['lastAchievedEventShownAt'] as String),
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
  'periodEndDate': instance.periodEndDate?.toIso8601String(),
  'targetSecondsPerDay': instance.targetSecondsPerDay,
  'consecutiveAchievements': instance.consecutiveAchievements,
  'consecutivePeriodAchievements': instance.consecutivePeriodAchievements,
  'achievedTime': instance.achievedTime,
  'todayAchievedTime': instance.todayAchievedTime,
  'lastResetDate': instance.lastResetDate?.toIso8601String(),
  'lastAchievedEventShownAt': instance.lastAchievedEventShownAt
      ?.toIso8601String(),
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
