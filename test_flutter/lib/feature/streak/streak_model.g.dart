// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakData _$StreakDataFromJson(Map<String, dynamic> json) => _StreakData(
  id: json['id'] as String,
  currentStreak: (json['currentStreak'] as num).toInt(),
  longestStreak: (json['longestStreak'] as num).toInt(),
  lastTrackedDate: DateTime.parse(json['lastTrackedDate'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$StreakDataToJson(_StreakData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastTrackedDate': instance.lastTrackedDate.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
    };
