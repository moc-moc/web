// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotalData _$TotalDataFromJson(Map<String, dynamic> json) => _TotalData(
  id: json['id'] as String,
  totalWorkTimeMinutes: (json['totalWorkTimeMinutes'] as num).toInt(),
  lastTrackedDate: DateTime.parse(json['lastTrackedDate'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
  milestoneList:
      (json['milestoneList'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  lastAchievedMilestone: (json['lastAchievedMilestone'] as num?)?.toInt(),
);

Map<String, dynamic> _$TotalDataToJson(_TotalData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalWorkTimeMinutes': instance.totalWorkTimeMinutes,
      'lastTrackedDate': instance.lastTrackedDate.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
      'milestoneList': instance.milestoneList,
      'lastAchievedMilestone': instance.lastAchievedMilestone,
    };
