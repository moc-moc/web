// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountSettings {

/// 固定ID（'account_settings'）
 String get id;/// アカウント名
 String get accountName;/// アバターの色（'blue', 'red', 'green', 'purple', 'orange', 'pink'）
 String get avatarColor;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of AccountSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountSettingsCopyWith<AccountSettings> get copyWith => _$AccountSettingsCopyWithImpl<AccountSettings>(this as AccountSettings, _$identity);

  /// Serializes this AccountSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName,avatarColor,lastModified);

@override
String toString() {
  return 'AccountSettings(id: $id, accountName: $accountName, avatarColor: $avatarColor, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $AccountSettingsCopyWith<$Res>  {
  factory $AccountSettingsCopyWith(AccountSettings value, $Res Function(AccountSettings) _then) = _$AccountSettingsCopyWithImpl;
@useResult
$Res call({
 String id, String accountName, String avatarColor, DateTime lastModified
});




}
/// @nodoc
class _$AccountSettingsCopyWithImpl<$Res>
    implements $AccountSettingsCopyWith<$Res> {
  _$AccountSettingsCopyWithImpl(this._self, this._then);

  final AccountSettings _self;
  final $Res Function(AccountSettings) _then;

/// Create a copy of AccountSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountName = null,Object? avatarColor = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountSettings].
extension AccountSettingsPatterns on AccountSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountSettings value)  $default,){
final _that = this;
switch (_that) {
case _AccountSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AccountSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountName,  String avatarColor,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountSettings() when $default != null:
return $default(_that.id,_that.accountName,_that.avatarColor,_that.lastModified);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountName,  String avatarColor,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _AccountSettings():
return $default(_that.id,_that.accountName,_that.avatarColor,_that.lastModified);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountName,  String avatarColor,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _AccountSettings() when $default != null:
return $default(_that.id,_that.accountName,_that.avatarColor,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountSettings extends AccountSettings {
  const _AccountSettings({required this.id, required this.accountName, required this.avatarColor, required this.lastModified}): super._();
  factory _AccountSettings.fromJson(Map<String, dynamic> json) => _$AccountSettingsFromJson(json);

/// 固定ID（'account_settings'）
@override final  String id;
/// アカウント名
@override final  String accountName;
/// アバターの色（'blue', 'red', 'green', 'purple', 'orange', 'pink'）
@override final  String avatarColor;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of AccountSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountSettingsCopyWith<_AccountSettings> get copyWith => __$AccountSettingsCopyWithImpl<_AccountSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName,avatarColor,lastModified);

@override
String toString() {
  return 'AccountSettings(id: $id, accountName: $accountName, avatarColor: $avatarColor, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$AccountSettingsCopyWith<$Res> implements $AccountSettingsCopyWith<$Res> {
  factory _$AccountSettingsCopyWith(_AccountSettings value, $Res Function(_AccountSettings) _then) = __$AccountSettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountName, String avatarColor, DateTime lastModified
});




}
/// @nodoc
class __$AccountSettingsCopyWithImpl<$Res>
    implements _$AccountSettingsCopyWith<$Res> {
  __$AccountSettingsCopyWithImpl(this._self, this._then);

  final _AccountSettings _self;
  final $Res Function(_AccountSettings) _then;

/// Create a copy of AccountSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountName = null,Object? avatarColor = null,Object? lastModified = null,}) {
  return _then(_AccountSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

/// 固定ID（'notification_settings'）
 String get id;/// カウントダウン通知
 bool get countdownNotification;/// 目標期限通知
 bool get goalDeadlineNotification;/// 継続日数途切れ通知
 bool get streakBreakNotification;/// 昨日の報告通知
 bool get dailyReportNotification;/// 通知回数（'both', 'morning', 'evening'）
 String get notificationFrequency;/// 朝の通知時間（例: '08:30'）
 String get morningTime;/// 夜の通知時間（例: '22:00'）
 String get eveningTime;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.countdownNotification, countdownNotification) || other.countdownNotification == countdownNotification)&&(identical(other.goalDeadlineNotification, goalDeadlineNotification) || other.goalDeadlineNotification == goalDeadlineNotification)&&(identical(other.streakBreakNotification, streakBreakNotification) || other.streakBreakNotification == streakBreakNotification)&&(identical(other.dailyReportNotification, dailyReportNotification) || other.dailyReportNotification == dailyReportNotification)&&(identical(other.notificationFrequency, notificationFrequency) || other.notificationFrequency == notificationFrequency)&&(identical(other.morningTime, morningTime) || other.morningTime == morningTime)&&(identical(other.eveningTime, eveningTime) || other.eveningTime == eveningTime)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countdownNotification,goalDeadlineNotification,streakBreakNotification,dailyReportNotification,notificationFrequency,morningTime,eveningTime,lastModified);

@override
String toString() {
  return 'NotificationSettings(id: $id, countdownNotification: $countdownNotification, goalDeadlineNotification: $goalDeadlineNotification, streakBreakNotification: $streakBreakNotification, dailyReportNotification: $dailyReportNotification, notificationFrequency: $notificationFrequency, morningTime: $morningTime, eveningTime: $eveningTime, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 String id, bool countdownNotification, bool goalDeadlineNotification, bool streakBreakNotification, bool dailyReportNotification, String notificationFrequency, String morningTime, String eveningTime, DateTime lastModified
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? countdownNotification = null,Object? goalDeadlineNotification = null,Object? streakBreakNotification = null,Object? dailyReportNotification = null,Object? notificationFrequency = null,Object? morningTime = null,Object? eveningTime = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countdownNotification: null == countdownNotification ? _self.countdownNotification : countdownNotification // ignore: cast_nullable_to_non_nullable
as bool,goalDeadlineNotification: null == goalDeadlineNotification ? _self.goalDeadlineNotification : goalDeadlineNotification // ignore: cast_nullable_to_non_nullable
as bool,streakBreakNotification: null == streakBreakNotification ? _self.streakBreakNotification : streakBreakNotification // ignore: cast_nullable_to_non_nullable
as bool,dailyReportNotification: null == dailyReportNotification ? _self.dailyReportNotification : dailyReportNotification // ignore: cast_nullable_to_non_nullable
as bool,notificationFrequency: null == notificationFrequency ? _self.notificationFrequency : notificationFrequency // ignore: cast_nullable_to_non_nullable
as String,morningTime: null == morningTime ? _self.morningTime : morningTime // ignore: cast_nullable_to_non_nullable
as String,eveningTime: null == eveningTime ? _self.eveningTime : eveningTime // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool countdownNotification,  bool goalDeadlineNotification,  bool streakBreakNotification,  bool dailyReportNotification,  String notificationFrequency,  String morningTime,  String eveningTime,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.id,_that.countdownNotification,_that.goalDeadlineNotification,_that.streakBreakNotification,_that.dailyReportNotification,_that.notificationFrequency,_that.morningTime,_that.eveningTime,_that.lastModified);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool countdownNotification,  bool goalDeadlineNotification,  bool streakBreakNotification,  bool dailyReportNotification,  String notificationFrequency,  String morningTime,  String eveningTime,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.id,_that.countdownNotification,_that.goalDeadlineNotification,_that.streakBreakNotification,_that.dailyReportNotification,_that.notificationFrequency,_that.morningTime,_that.eveningTime,_that.lastModified);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool countdownNotification,  bool goalDeadlineNotification,  bool streakBreakNotification,  bool dailyReportNotification,  String notificationFrequency,  String morningTime,  String eveningTime,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.id,_that.countdownNotification,_that.goalDeadlineNotification,_that.streakBreakNotification,_that.dailyReportNotification,_that.notificationFrequency,_that.morningTime,_that.eveningTime,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings extends NotificationSettings {
  const _NotificationSettings({required this.id, required this.countdownNotification, required this.goalDeadlineNotification, required this.streakBreakNotification, required this.dailyReportNotification, required this.notificationFrequency, required this.morningTime, required this.eveningTime, required this.lastModified}): super._();
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

/// 固定ID（'notification_settings'）
@override final  String id;
/// カウントダウン通知
@override final  bool countdownNotification;
/// 目標期限通知
@override final  bool goalDeadlineNotification;
/// 継続日数途切れ通知
@override final  bool streakBreakNotification;
/// 昨日の報告通知
@override final  bool dailyReportNotification;
/// 通知回数（'both', 'morning', 'evening'）
@override final  String notificationFrequency;
/// 朝の通知時間（例: '08:30'）
@override final  String morningTime;
/// 夜の通知時間（例: '22:00'）
@override final  String eveningTime;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.countdownNotification, countdownNotification) || other.countdownNotification == countdownNotification)&&(identical(other.goalDeadlineNotification, goalDeadlineNotification) || other.goalDeadlineNotification == goalDeadlineNotification)&&(identical(other.streakBreakNotification, streakBreakNotification) || other.streakBreakNotification == streakBreakNotification)&&(identical(other.dailyReportNotification, dailyReportNotification) || other.dailyReportNotification == dailyReportNotification)&&(identical(other.notificationFrequency, notificationFrequency) || other.notificationFrequency == notificationFrequency)&&(identical(other.morningTime, morningTime) || other.morningTime == morningTime)&&(identical(other.eveningTime, eveningTime) || other.eveningTime == eveningTime)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countdownNotification,goalDeadlineNotification,streakBreakNotification,dailyReportNotification,notificationFrequency,morningTime,eveningTime,lastModified);

@override
String toString() {
  return 'NotificationSettings(id: $id, countdownNotification: $countdownNotification, goalDeadlineNotification: $goalDeadlineNotification, streakBreakNotification: $streakBreakNotification, dailyReportNotification: $dailyReportNotification, notificationFrequency: $notificationFrequency, morningTime: $morningTime, eveningTime: $eveningTime, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, bool countdownNotification, bool goalDeadlineNotification, bool streakBreakNotification, bool dailyReportNotification, String notificationFrequency, String morningTime, String eveningTime, DateTime lastModified
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? countdownNotification = null,Object? goalDeadlineNotification = null,Object? streakBreakNotification = null,Object? dailyReportNotification = null,Object? notificationFrequency = null,Object? morningTime = null,Object? eveningTime = null,Object? lastModified = null,}) {
  return _then(_NotificationSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countdownNotification: null == countdownNotification ? _self.countdownNotification : countdownNotification // ignore: cast_nullable_to_non_nullable
as bool,goalDeadlineNotification: null == goalDeadlineNotification ? _self.goalDeadlineNotification : goalDeadlineNotification // ignore: cast_nullable_to_non_nullable
as bool,streakBreakNotification: null == streakBreakNotification ? _self.streakBreakNotification : streakBreakNotification // ignore: cast_nullable_to_non_nullable
as bool,dailyReportNotification: null == dailyReportNotification ? _self.dailyReportNotification : dailyReportNotification // ignore: cast_nullable_to_non_nullable
as bool,notificationFrequency: null == notificationFrequency ? _self.notificationFrequency : notificationFrequency // ignore: cast_nullable_to_non_nullable
as String,morningTime: null == morningTime ? _self.morningTime : morningTime // ignore: cast_nullable_to_non_nullable
as String,eveningTime: null == eveningTime ? _self.eveningTime : eveningTime // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$DisplaySettings {

/// 固定ID（'display_settings'）
 String get id;/// カテゴリ1の名前
 String get category1Name;/// カテゴリ2の名前
 String get category2Name;/// カテゴリ3の名前
 String get category3Name;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of DisplaySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplaySettingsCopyWith<DisplaySettings> get copyWith => _$DisplaySettingsCopyWithImpl<DisplaySettings>(this as DisplaySettings, _$identity);

  /// Serializes this DisplaySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplaySettings&&(identical(other.id, id) || other.id == id)&&(identical(other.category1Name, category1Name) || other.category1Name == category1Name)&&(identical(other.category2Name, category2Name) || other.category2Name == category2Name)&&(identical(other.category3Name, category3Name) || other.category3Name == category3Name)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category1Name,category2Name,category3Name,lastModified);

@override
String toString() {
  return 'DisplaySettings(id: $id, category1Name: $category1Name, category2Name: $category2Name, category3Name: $category3Name, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $DisplaySettingsCopyWith<$Res>  {
  factory $DisplaySettingsCopyWith(DisplaySettings value, $Res Function(DisplaySettings) _then) = _$DisplaySettingsCopyWithImpl;
@useResult
$Res call({
 String id, String category1Name, String category2Name, String category3Name, DateTime lastModified
});




}
/// @nodoc
class _$DisplaySettingsCopyWithImpl<$Res>
    implements $DisplaySettingsCopyWith<$Res> {
  _$DisplaySettingsCopyWithImpl(this._self, this._then);

  final DisplaySettings _self;
  final $Res Function(DisplaySettings) _then;

/// Create a copy of DisplaySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category1Name = null,Object? category2Name = null,Object? category3Name = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category1Name: null == category1Name ? _self.category1Name : category1Name // ignore: cast_nullable_to_non_nullable
as String,category2Name: null == category2Name ? _self.category2Name : category2Name // ignore: cast_nullable_to_non_nullable
as String,category3Name: null == category3Name ? _self.category3Name : category3Name // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplaySettings].
extension DisplaySettingsPatterns on DisplaySettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplaySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplaySettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplaySettings value)  $default,){
final _that = this;
switch (_that) {
case _DisplaySettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplaySettings value)?  $default,){
final _that = this;
switch (_that) {
case _DisplaySettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category1Name,  String category2Name,  String category3Name,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplaySettings() when $default != null:
return $default(_that.id,_that.category1Name,_that.category2Name,_that.category3Name,_that.lastModified);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category1Name,  String category2Name,  String category3Name,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _DisplaySettings():
return $default(_that.id,_that.category1Name,_that.category2Name,_that.category3Name,_that.lastModified);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category1Name,  String category2Name,  String category3Name,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _DisplaySettings() when $default != null:
return $default(_that.id,_that.category1Name,_that.category2Name,_that.category3Name,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplaySettings extends DisplaySettings {
  const _DisplaySettings({required this.id, required this.category1Name, required this.category2Name, required this.category3Name, required this.lastModified}): super._();
  factory _DisplaySettings.fromJson(Map<String, dynamic> json) => _$DisplaySettingsFromJson(json);

/// 固定ID（'display_settings'）
@override final  String id;
/// カテゴリ1の名前
@override final  String category1Name;
/// カテゴリ2の名前
@override final  String category2Name;
/// カテゴリ3の名前
@override final  String category3Name;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of DisplaySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplaySettingsCopyWith<_DisplaySettings> get copyWith => __$DisplaySettingsCopyWithImpl<_DisplaySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplaySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplaySettings&&(identical(other.id, id) || other.id == id)&&(identical(other.category1Name, category1Name) || other.category1Name == category1Name)&&(identical(other.category2Name, category2Name) || other.category2Name == category2Name)&&(identical(other.category3Name, category3Name) || other.category3Name == category3Name)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category1Name,category2Name,category3Name,lastModified);

@override
String toString() {
  return 'DisplaySettings(id: $id, category1Name: $category1Name, category2Name: $category2Name, category3Name: $category3Name, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$DisplaySettingsCopyWith<$Res> implements $DisplaySettingsCopyWith<$Res> {
  factory _$DisplaySettingsCopyWith(_DisplaySettings value, $Res Function(_DisplaySettings) _then) = __$DisplaySettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, String category1Name, String category2Name, String category3Name, DateTime lastModified
});




}
/// @nodoc
class __$DisplaySettingsCopyWithImpl<$Res>
    implements _$DisplaySettingsCopyWith<$Res> {
  __$DisplaySettingsCopyWithImpl(this._self, this._then);

  final _DisplaySettings _self;
  final $Res Function(_DisplaySettings) _then;

/// Create a copy of DisplaySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category1Name = null,Object? category2Name = null,Object? category3Name = null,Object? lastModified = null,}) {
  return _then(_DisplaySettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category1Name: null == category1Name ? _self.category1Name : category1Name // ignore: cast_nullable_to_non_nullable
as String,category2Name: null == category2Name ? _self.category2Name : category2Name // ignore: cast_nullable_to_non_nullable
as String,category3Name: null == category3Name ? _self.category3Name : category3Name // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$TimeSettings {

/// 固定ID（'time_settings'）
 String get id;/// 一日の区切り時刻（例: '24:00', '00:00', '04:00'）
 String get dayBoundaryTime;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of TimeSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeSettingsCopyWith<TimeSettings> get copyWith => _$TimeSettingsCopyWithImpl<TimeSettings>(this as TimeSettings, _$identity);

  /// Serializes this TimeSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.dayBoundaryTime, dayBoundaryTime) || other.dayBoundaryTime == dayBoundaryTime)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayBoundaryTime,lastModified);

@override
String toString() {
  return 'TimeSettings(id: $id, dayBoundaryTime: $dayBoundaryTime, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $TimeSettingsCopyWith<$Res>  {
  factory $TimeSettingsCopyWith(TimeSettings value, $Res Function(TimeSettings) _then) = _$TimeSettingsCopyWithImpl;
@useResult
$Res call({
 String id, String dayBoundaryTime, DateTime lastModified
});




}
/// @nodoc
class _$TimeSettingsCopyWithImpl<$Res>
    implements $TimeSettingsCopyWith<$Res> {
  _$TimeSettingsCopyWithImpl(this._self, this._then);

  final TimeSettings _self;
  final $Res Function(TimeSettings) _then;

/// Create a copy of TimeSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayBoundaryTime = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryTime: null == dayBoundaryTime ? _self.dayBoundaryTime : dayBoundaryTime // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeSettings].
extension TimeSettingsPatterns on TimeSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeSettings value)  $default,){
final _that = this;
switch (_that) {
case _TimeSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TimeSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String dayBoundaryTime,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeSettings() when $default != null:
return $default(_that.id,_that.dayBoundaryTime,_that.lastModified);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String dayBoundaryTime,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _TimeSettings():
return $default(_that.id,_that.dayBoundaryTime,_that.lastModified);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String dayBoundaryTime,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _TimeSettings() when $default != null:
return $default(_that.id,_that.dayBoundaryTime,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeSettings extends TimeSettings {
  const _TimeSettings({required this.id, required this.dayBoundaryTime, required this.lastModified}): super._();
  factory _TimeSettings.fromJson(Map<String, dynamic> json) => _$TimeSettingsFromJson(json);

/// 固定ID（'time_settings'）
@override final  String id;
/// 一日の区切り時刻（例: '24:00', '00:00', '04:00'）
@override final  String dayBoundaryTime;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of TimeSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeSettingsCopyWith<_TimeSettings> get copyWith => __$TimeSettingsCopyWithImpl<_TimeSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.dayBoundaryTime, dayBoundaryTime) || other.dayBoundaryTime == dayBoundaryTime)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayBoundaryTime,lastModified);

@override
String toString() {
  return 'TimeSettings(id: $id, dayBoundaryTime: $dayBoundaryTime, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$TimeSettingsCopyWith<$Res> implements $TimeSettingsCopyWith<$Res> {
  factory _$TimeSettingsCopyWith(_TimeSettings value, $Res Function(_TimeSettings) _then) = __$TimeSettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, String dayBoundaryTime, DateTime lastModified
});




}
/// @nodoc
class __$TimeSettingsCopyWithImpl<$Res>
    implements _$TimeSettingsCopyWith<$Res> {
  __$TimeSettingsCopyWithImpl(this._self, this._then);

  final _TimeSettings _self;
  final $Res Function(_TimeSettings) _then;

/// Create a copy of TimeSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayBoundaryTime = null,Object? lastModified = null,}) {
  return _then(_TimeSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryTime: null == dayBoundaryTime ? _self.dayBoundaryTime : dayBoundaryTime // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
