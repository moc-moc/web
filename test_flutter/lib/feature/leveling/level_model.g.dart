// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LevelingState _$LevelingStateFromJson(Map<String, dynamic> json) =>
    _LevelingState(
      id: json['id'] as String,
      periodId: json['periodId'] as String,
      level: (json['level'] as num).toInt(),
      exactLevel: (json['exactLevel'] as num).toDouble(),
      progressToNextLevel: (json['progressToNextLevel'] as num).toDouble(),
      personSeconds: (json['personSeconds'] as num?)?.toInt() ?? 0,
      requiredSecondsForNextLevel: (json['requiredSecondsForNextLevel'] as num)
          .toInt(),
      rank: $enumDecode(
        _$LevelRankTierEnumMap,
        json['rank'],
        unknownValue: LevelRankTier.apprentice,
      ),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      nextResetAt: DateTime.parse(json['nextResetAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$LevelingStateToJson(_LevelingState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'periodId': instance.periodId,
      'level': instance.level,
      'exactLevel': instance.exactLevel,
      'progressToNextLevel': instance.progressToNextLevel,
      'personSeconds': instance.personSeconds,
      'requiredSecondsForNextLevel': instance.requiredSecondsForNextLevel,
      'rank': _$LevelRankTierEnumMap[instance.rank]!,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'nextResetAt': instance.nextResetAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$LevelRankTierEnumMap = {
  LevelRankTier.apprentice: 'apprentice',
  LevelRankTier.bronze: 'bronze',
  LevelRankTier.silver: 'silver',
  LevelRankTier.gold: 'gold',
  LevelRankTier.platinum: 'platinum',
  LevelRankTier.diamond: 'diamond',
};

_LevelSnapshot _$LevelSnapshotFromJson(Map<String, dynamic> json) =>
    _LevelSnapshot(
      level: (json['level'] as num).toInt(),
      exactLevel: (json['exactLevel'] as num).toDouble(),
      rank: $enumDecode(_$LevelRankTierEnumMap, json['rank']),
      personSeconds: (json['personSeconds'] as num).toInt(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );

Map<String, dynamic> _$LevelSnapshotToJson(_LevelSnapshot instance) =>
    <String, dynamic>{
      'level': instance.level,
      'exactLevel': instance.exactLevel,
      'rank': _$LevelRankTierEnumMap[instance.rank]!,
      'personSeconds': instance.personSeconds,
      'capturedAt': instance.capturedAt.toIso8601String(),
    };
