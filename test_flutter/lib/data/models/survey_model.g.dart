// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Survey _$SurveyFromJson(Map<String, dynamic> json) => _Survey(
  id: json['id'] as String,
  rating: (json['rating'] as num).toInt(),
  feedback: json['feedback'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SurveyToJson(_Survey instance) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'feedback': instance.feedback,
  'createdAt': instance.createdAt.toIso8601String(),
};
