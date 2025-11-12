// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'countdowndata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Countdown {

 String get id; String get title; DateTime get targetDate; bool get isDeleted; DateTime get lastModified;
/// Create a copy of Countdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownCopyWith<Countdown> get copyWith => _$CountdownCopyWithImpl<Countdown>(this as Countdown, _$identity);

  /// Serializes this Countdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Countdown&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetDate,isDeleted,lastModified);

@override
String toString() {
  return 'Countdown(id: $id, title: $title, targetDate: $targetDate, isDeleted: $isDeleted, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $CountdownCopyWith<$Res>  {
  factory $CountdownCopyWith(Countdown value, $Res Function(Countdown) _then) = _$CountdownCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime targetDate, bool isDeleted, DateTime lastModified
});




}
/// @nodoc
class _$CountdownCopyWithImpl<$Res>
    implements $CountdownCopyWith<$Res> {
  _$CountdownCopyWithImpl(this._self, this._then);

  final Countdown _self;
  final $Res Function(Countdown) _then;

/// Create a copy of Countdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? targetDate = null,Object? isDeleted = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Countdown].
extension CountdownPatterns on Countdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Countdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Countdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Countdown value)  $default,){
final _that = this;
switch (_that) {
case _Countdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Countdown value)?  $default,){
final _that = this;
switch (_that) {
case _Countdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime targetDate,  bool isDeleted,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Countdown() when $default != null:
return $default(_that.id,_that.title,_that.targetDate,_that.isDeleted,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime targetDate,  bool isDeleted,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _Countdown():
return $default(_that.id,_that.title,_that.targetDate,_that.isDeleted,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime targetDate,  bool isDeleted,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _Countdown() when $default != null:
return $default(_that.id,_that.title,_that.targetDate,_that.isDeleted,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Countdown implements Countdown {
  const _Countdown({required this.id, required this.title, required this.targetDate, this.isDeleted = false, required this.lastModified});
  factory _Countdown.fromJson(Map<String, dynamic> json) => _$CountdownFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime targetDate;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime lastModified;

/// Create a copy of Countdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountdownCopyWith<_Countdown> get copyWith => __$CountdownCopyWithImpl<_Countdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Countdown&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetDate,isDeleted,lastModified);

@override
String toString() {
  return 'Countdown(id: $id, title: $title, targetDate: $targetDate, isDeleted: $isDeleted, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$CountdownCopyWith<$Res> implements $CountdownCopyWith<$Res> {
  factory _$CountdownCopyWith(_Countdown value, $Res Function(_Countdown) _then) = __$CountdownCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime targetDate, bool isDeleted, DateTime lastModified
});




}
/// @nodoc
class __$CountdownCopyWithImpl<$Res>
    implements _$CountdownCopyWith<$Res> {
  __$CountdownCopyWithImpl(this._self, this._then);

  final _Countdown _self;
  final $Res Function(_Countdown) _then;

/// Create a copy of Countdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? targetDate = null,Object? isDeleted = null,Object? lastModified = null,}) {
  return _then(_Countdown(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
