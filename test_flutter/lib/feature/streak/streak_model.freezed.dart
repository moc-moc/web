// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakData {

 String get id; int get currentStreak; int get longestStreak; DateTime get lastTrackedDate; DateTime get lastModified;
/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakDataCopyWith<StreakData> get copyWith => _$StreakDataCopyWithImpl<StreakData>(this as StreakData, _$identity);

  /// Serializes this StreakData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakData&&(identical(other.id, id) || other.id == id)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastTrackedDate, lastTrackedDate) || other.lastTrackedDate == lastTrackedDate)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currentStreak,longestStreak,lastTrackedDate,lastModified);

@override
String toString() {
  return 'StreakData(id: $id, currentStreak: $currentStreak, longestStreak: $longestStreak, lastTrackedDate: $lastTrackedDate, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $StreakDataCopyWith<$Res>  {
  factory $StreakDataCopyWith(StreakData value, $Res Function(StreakData) _then) = _$StreakDataCopyWithImpl;
@useResult
$Res call({
 String id, int currentStreak, int longestStreak, DateTime lastTrackedDate, DateTime lastModified
});




}
/// @nodoc
class _$StreakDataCopyWithImpl<$Res>
    implements $StreakDataCopyWith<$Res> {
  _$StreakDataCopyWithImpl(this._self, this._then);

  final StreakData _self;
  final $Res Function(StreakData) _then;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastTrackedDate = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastTrackedDate: null == lastTrackedDate ? _self.lastTrackedDate : lastTrackedDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakData].
extension StreakDataPatterns on StreakData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakData value)  $default,){
final _that = this;
switch (_that) {
case _StreakData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakData value)?  $default,){
final _that = this;
switch (_that) {
case _StreakData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int currentStreak,  int longestStreak,  DateTime lastTrackedDate,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakData() when $default != null:
return $default(_that.id,_that.currentStreak,_that.longestStreak,_that.lastTrackedDate,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int currentStreak,  int longestStreak,  DateTime lastTrackedDate,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _StreakData():
return $default(_that.id,_that.currentStreak,_that.longestStreak,_that.lastTrackedDate,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int currentStreak,  int longestStreak,  DateTime lastTrackedDate,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _StreakData() when $default != null:
return $default(_that.id,_that.currentStreak,_that.longestStreak,_that.lastTrackedDate,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakData implements StreakData {
  const _StreakData({required this.id, required this.currentStreak, required this.longestStreak, required this.lastTrackedDate, required this.lastModified});
  factory _StreakData.fromJson(Map<String, dynamic> json) => _$StreakDataFromJson(json);

@override final  String id;
@override final  int currentStreak;
@override final  int longestStreak;
@override final  DateTime lastTrackedDate;
@override final  DateTime lastModified;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakDataCopyWith<_StreakData> get copyWith => __$StreakDataCopyWithImpl<_StreakData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakData&&(identical(other.id, id) || other.id == id)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastTrackedDate, lastTrackedDate) || other.lastTrackedDate == lastTrackedDate)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currentStreak,longestStreak,lastTrackedDate,lastModified);

@override
String toString() {
  return 'StreakData(id: $id, currentStreak: $currentStreak, longestStreak: $longestStreak, lastTrackedDate: $lastTrackedDate, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$StreakDataCopyWith<$Res> implements $StreakDataCopyWith<$Res> {
  factory _$StreakDataCopyWith(_StreakData value, $Res Function(_StreakData) _then) = __$StreakDataCopyWithImpl;
@override @useResult
$Res call({
 String id, int currentStreak, int longestStreak, DateTime lastTrackedDate, DateTime lastModified
});




}
/// @nodoc
class __$StreakDataCopyWithImpl<$Res>
    implements _$StreakDataCopyWith<$Res> {
  __$StreakDataCopyWithImpl(this._self, this._then);

  final _StreakData _self;
  final $Res Function(_StreakData) _then;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastTrackedDate = null,Object? lastModified = null,}) {
  return _then(_StreakData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastTrackedDate: null == lastTrackedDate ? _self.lastTrackedDate : lastTrackedDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
