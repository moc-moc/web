// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountSettings _$AccountSettingsFromJson(Map<String, dynamic> json) =>
    _AccountSettings(
      id: json['id'] as String,
      accountName: json['accountName'] as String,
      avatarColor: json['avatarColor'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$AccountSettingsToJson(_AccountSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountName': instance.accountName,
      'avatarColor': instance.avatarColor,
      'lastModified': instance.lastModified.toIso8601String(),
    };

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  id: json['id'] as String,
  countdownNotification: json['countdownNotification'] as bool,
  goalDeadlineNotification: json['goalDeadlineNotification'] as bool,
  streakBreakNotification: json['streakBreakNotification'] as bool,
  dailyReportNotification: json['dailyReportNotification'] as bool,
  notificationFrequency: json['notificationFrequency'] as String,
  morningTime: json['morningTime'] as String,
  eveningTime: json['eveningTime'] as String,
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'id': instance.id,
  'countdownNotification': instance.countdownNotification,
  'goalDeadlineNotification': instance.goalDeadlineNotification,
  'streakBreakNotification': instance.streakBreakNotification,
  'dailyReportNotification': instance.dailyReportNotification,
  'notificationFrequency': instance.notificationFrequency,
  'morningTime': instance.morningTime,
  'eveningTime': instance.eveningTime,
  'lastModified': instance.lastModified.toIso8601String(),
};

_DisplaySettings _$DisplaySettingsFromJson(Map<String, dynamic> json) =>
    _DisplaySettings(
      id: json['id'] as String,
      category1Name: json['category1Name'] as String,
      category2Name: json['category2Name'] as String,
      category3Name: json['category3Name'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$DisplaySettingsToJson(_DisplaySettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category1Name': instance.category1Name,
      'category2Name': instance.category2Name,
      'category3Name': instance.category3Name,
      'lastModified': instance.lastModified.toIso8601String(),
    };

_TimeSettings _$TimeSettingsFromJson(Map<String, dynamic> json) =>
    _TimeSettings(
      id: json['id'] as String,
      dayBoundaryTime: json['dayBoundaryTime'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$TimeSettingsToJson(_TimeSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayBoundaryTime': instance.dayBoundaryTime,
      'lastModified': instance.lastModified.toIso8601String(),
    };

_TrackingSettings _$TrackingSettingsFromJson(Map<String, dynamic> json) =>
    _TrackingSettings(
      id: json['id'] as String,
      isCameraOn: json['isCameraOn'] as bool,
      isPowerSavingMode: json['isPowerSavingMode'] as bool,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$TrackingSettingsToJson(_TrackingSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isCameraOn': instance.isCameraOn,
      'isPowerSavingMode': instance.isPowerSavingMode,
      'lastModified': instance.lastModified.toIso8601String(),
    };
