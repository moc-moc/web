// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_flag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyFlag _$SurveyFlagFromJson(Map<String, dynamic> json) => _SurveyFlag(
  id: json['id'] as String,
  hasShownFirstSurvey: json['hasShownFirstSurvey'] as bool,
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$SurveyFlagToJson(_SurveyFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hasShownFirstSurvey': instance.hasShownFirstSurvey,
      'lastModified': instance.lastModified.toIso8601String(),
    };
