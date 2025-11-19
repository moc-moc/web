// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Goal {

 String get id; String get tag; String get title; int get targetTime; ComparisonType get comparisonType; DetectionItem get detectionItem; DateTime get startDate; int get durationDays; int get targetSecondsPerDay; int get consecutiveAchievements; int? get achievedTime; bool get isDeleted; DateTime get lastModified;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);

  /// Serializes this Goal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetTime, targetTime) || other.targetTime == targetTime)&&(identical(other.comparisonType, comparisonType) || other.comparisonType == comparisonType)&&(identical(other.detectionItem, detectionItem) || other.detectionItem == detectionItem)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.targetSecondsPerDay, targetSecondsPerDay) || other.targetSecondsPerDay == targetSecondsPerDay)&&(identical(other.consecutiveAchievements, consecutiveAchievements) || other.consecutiveAchievements == consecutiveAchievements)&&(identical(other.achievedTime, achievedTime) || other.achievedTime == achievedTime)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tag,title,targetTime,comparisonType,detectionItem,startDate,durationDays,targetSecondsPerDay,consecutiveAchievements,achievedTime,isDeleted,lastModified);

@override
String toString() {
  return 'Goal(id: $id, tag: $tag, title: $title, targetTime: $targetTime, comparisonType: $comparisonType, detectionItem: $detectionItem, startDate: $startDate, durationDays: $durationDays, targetSecondsPerDay: $targetSecondsPerDay, consecutiveAchievements: $consecutiveAchievements, achievedTime: $achievedTime, isDeleted: $isDeleted, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 String id, String tag, String title, int targetTime, ComparisonType comparisonType, DetectionItem detectionItem, DateTime startDate, int durationDays, int targetSecondsPerDay, int consecutiveAchievements, int? achievedTime, bool isDeleted, DateTime lastModified
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tag = null,Object? title = null,Object? targetTime = null,Object? comparisonType = null,Object? detectionItem = null,Object? startDate = null,Object? durationDays = null,Object? targetSecondsPerDay = null,Object? consecutiveAchievements = null,Object? achievedTime = freezed,Object? isDeleted = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetTime: null == targetTime ? _self.targetTime : targetTime // ignore: cast_nullable_to_non_nullable
as int,comparisonType: null == comparisonType ? _self.comparisonType : comparisonType // ignore: cast_nullable_to_non_nullable
as ComparisonType,detectionItem: null == detectionItem ? _self.detectionItem : detectionItem // ignore: cast_nullable_to_non_nullable
as DetectionItem,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,targetSecondsPerDay: null == targetSecondsPerDay ? _self.targetSecondsPerDay : targetSecondsPerDay // ignore: cast_nullable_to_non_nullable
as int,consecutiveAchievements: null == consecutiveAchievements ? _self.consecutiveAchievements : consecutiveAchievements // ignore: cast_nullable_to_non_nullable
as int,achievedTime: freezed == achievedTime ? _self.achievedTime : achievedTime // ignore: cast_nullable_to_non_nullable
as int?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tag,  String title,  int targetTime,  ComparisonType comparisonType,  DetectionItem detectionItem,  DateTime startDate,  int durationDays,  int targetSecondsPerDay,  int consecutiveAchievements,  int? achievedTime,  bool isDeleted,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.tag,_that.title,_that.targetTime,_that.comparisonType,_that.detectionItem,_that.startDate,_that.durationDays,_that.targetSecondsPerDay,_that.consecutiveAchievements,_that.achievedTime,_that.isDeleted,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tag,  String title,  int targetTime,  ComparisonType comparisonType,  DetectionItem detectionItem,  DateTime startDate,  int durationDays,  int targetSecondsPerDay,  int consecutiveAchievements,  int? achievedTime,  bool isDeleted,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.tag,_that.title,_that.targetTime,_that.comparisonType,_that.detectionItem,_that.startDate,_that.durationDays,_that.targetSecondsPerDay,_that.consecutiveAchievements,_that.achievedTime,_that.isDeleted,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tag,  String title,  int targetTime,  ComparisonType comparisonType,  DetectionItem detectionItem,  DateTime startDate,  int durationDays,  int targetSecondsPerDay,  int consecutiveAchievements,  int? achievedTime,  bool isDeleted,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.tag,_that.title,_that.targetTime,_that.comparisonType,_that.detectionItem,_that.startDate,_that.durationDays,_that.targetSecondsPerDay,_that.consecutiveAchievements,_that.achievedTime,_that.isDeleted,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Goal implements Goal {
  const _Goal({required this.id, required this.tag, required this.title, required this.targetTime, required this.comparisonType, required this.detectionItem, required this.startDate, required this.durationDays, this.targetSecondsPerDay = 0, this.consecutiveAchievements = 0, this.achievedTime, this.isDeleted = false, required this.lastModified});
  factory _Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

@override final  String id;
@override final  String tag;
@override final  String title;
@override final  int targetTime;
@override final  ComparisonType comparisonType;
@override final  DetectionItem detectionItem;
@override final  DateTime startDate;
@override final  int durationDays;
@override@JsonKey() final  int targetSecondsPerDay;
@override@JsonKey() final  int consecutiveAchievements;
@override final  int? achievedTime;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime lastModified;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetTime, targetTime) || other.targetTime == targetTime)&&(identical(other.comparisonType, comparisonType) || other.comparisonType == comparisonType)&&(identical(other.detectionItem, detectionItem) || other.detectionItem == detectionItem)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.targetSecondsPerDay, targetSecondsPerDay) || other.targetSecondsPerDay == targetSecondsPerDay)&&(identical(other.consecutiveAchievements, consecutiveAchievements) || other.consecutiveAchievements == consecutiveAchievements)&&(identical(other.achievedTime, achievedTime) || other.achievedTime == achievedTime)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tag,title,targetTime,comparisonType,detectionItem,startDate,durationDays,targetSecondsPerDay,consecutiveAchievements,achievedTime,isDeleted,lastModified);

@override
String toString() {
  return 'Goal(id: $id, tag: $tag, title: $title, targetTime: $targetTime, comparisonType: $comparisonType, detectionItem: $detectionItem, startDate: $startDate, durationDays: $durationDays, targetSecondsPerDay: $targetSecondsPerDay, consecutiveAchievements: $consecutiveAchievements, achievedTime: $achievedTime, isDeleted: $isDeleted, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String tag, String title, int targetTime, ComparisonType comparisonType, DetectionItem detectionItem, DateTime startDate, int durationDays, int targetSecondsPerDay, int consecutiveAchievements, int? achievedTime, bool isDeleted, DateTime lastModified
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tag = null,Object? title = null,Object? targetTime = null,Object? comparisonType = null,Object? detectionItem = null,Object? startDate = null,Object? durationDays = null,Object? targetSecondsPerDay = null,Object? consecutiveAchievements = null,Object? achievedTime = freezed,Object? isDeleted = null,Object? lastModified = null,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetTime: null == targetTime ? _self.targetTime : targetTime // ignore: cast_nullable_to_non_nullable
as int,comparisonType: null == comparisonType ? _self.comparisonType : comparisonType // ignore: cast_nullable_to_non_nullable
as ComparisonType,detectionItem: null == detectionItem ? _self.detectionItem : detectionItem // ignore: cast_nullable_to_non_nullable
as DetectionItem,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,targetSecondsPerDay: null == targetSecondsPerDay ? _self.targetSecondsPerDay : targetSecondsPerDay // ignore: cast_nullable_to_non_nullable
as int,consecutiveAchievements: null == consecutiveAchievements ? _self.consecutiveAchievements : consecutiveAchievements // ignore: cast_nullable_to_non_nullable
as int,achievedTime: freezed == achievedTime ? _self.achievedTime : achievedTime // ignore: cast_nullable_to_non_nullable
as int?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
