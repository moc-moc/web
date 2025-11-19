// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'total_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TotalData {

 String get id; int get totalWorkTimeMinutes; DateTime get lastTrackedDate; DateTime get lastModified;
/// Create a copy of TotalData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TotalDataCopyWith<TotalData> get copyWith => _$TotalDataCopyWithImpl<TotalData>(this as TotalData, _$identity);

  /// Serializes this TotalData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TotalData&&(identical(other.id, id) || other.id == id)&&(identical(other.totalWorkTimeMinutes, totalWorkTimeMinutes) || other.totalWorkTimeMinutes == totalWorkTimeMinutes)&&(identical(other.lastTrackedDate, lastTrackedDate) || other.lastTrackedDate == lastTrackedDate)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,totalWorkTimeMinutes,lastTrackedDate,lastModified);

@override
String toString() {
  return 'TotalData(id: $id, totalWorkTimeMinutes: $totalWorkTimeMinutes, lastTrackedDate: $lastTrackedDate, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $TotalDataCopyWith<$Res>  {
  factory $TotalDataCopyWith(TotalData value, $Res Function(TotalData) _then) = _$TotalDataCopyWithImpl;
@useResult
$Res call({
 String id, int totalWorkTimeMinutes, DateTime lastTrackedDate, DateTime lastModified
});




}
/// @nodoc
class _$TotalDataCopyWithImpl<$Res>
    implements $TotalDataCopyWith<$Res> {
  _$TotalDataCopyWithImpl(this._self, this._then);

  final TotalData _self;
  final $Res Function(TotalData) _then;

/// Create a copy of TotalData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? totalWorkTimeMinutes = null,Object? lastTrackedDate = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,totalWorkTimeMinutes: null == totalWorkTimeMinutes ? _self.totalWorkTimeMinutes : totalWorkTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,lastTrackedDate: null == lastTrackedDate ? _self.lastTrackedDate : lastTrackedDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TotalData].
extension TotalDataPatterns on TotalData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TotalData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TotalData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TotalData value)  $default,){
final _that = this;
switch (_that) {
case _TotalData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TotalData value)?  $default,){
final _that = this;
switch (_that) {
case _TotalData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int totalWorkTimeMinutes,  DateTime lastTrackedDate,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TotalData() when $default != null:
return $default(_that.id,_that.totalWorkTimeMinutes,_that.lastTrackedDate,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int totalWorkTimeMinutes,  DateTime lastTrackedDate,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _TotalData():
return $default(_that.id,_that.totalWorkTimeMinutes,_that.lastTrackedDate,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int totalWorkTimeMinutes,  DateTime lastTrackedDate,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _TotalData() when $default != null:
return $default(_that.id,_that.totalWorkTimeMinutes,_that.lastTrackedDate,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TotalData implements TotalData {
  const _TotalData({required this.id, required this.totalWorkTimeMinutes, required this.lastTrackedDate, required this.lastModified});
  factory _TotalData.fromJson(Map<String, dynamic> json) => _$TotalDataFromJson(json);

@override final  String id;
@override final  int totalWorkTimeMinutes;
@override final  DateTime lastTrackedDate;
@override final  DateTime lastModified;

/// Create a copy of TotalData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TotalDataCopyWith<_TotalData> get copyWith => __$TotalDataCopyWithImpl<_TotalData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TotalDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TotalData&&(identical(other.id, id) || other.id == id)&&(identical(other.totalWorkTimeMinutes, totalWorkTimeMinutes) || other.totalWorkTimeMinutes == totalWorkTimeMinutes)&&(identical(other.lastTrackedDate, lastTrackedDate) || other.lastTrackedDate == lastTrackedDate)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,totalWorkTimeMinutes,lastTrackedDate,lastModified);

@override
String toString() {
  return 'TotalData(id: $id, totalWorkTimeMinutes: $totalWorkTimeMinutes, lastTrackedDate: $lastTrackedDate, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$TotalDataCopyWith<$Res> implements $TotalDataCopyWith<$Res> {
  factory _$TotalDataCopyWith(_TotalData value, $Res Function(_TotalData) _then) = __$TotalDataCopyWithImpl;
@override @useResult
$Res call({
 String id, int totalWorkTimeMinutes, DateTime lastTrackedDate, DateTime lastModified
});




}
/// @nodoc
class __$TotalDataCopyWithImpl<$Res>
    implements _$TotalDataCopyWith<$Res> {
  __$TotalDataCopyWithImpl(this._self, this._then);

  final _TotalData _self;
  final $Res Function(_TotalData) _then;

/// Create a copy of TotalData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? totalWorkTimeMinutes = null,Object? lastTrackedDate = null,Object? lastModified = null,}) {
  return _then(_TotalData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,totalWorkTimeMinutes: null == totalWorkTimeMinutes ? _self.totalWorkTimeMinutes : totalWorkTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,lastTrackedDate: null == lastTrackedDate ? _self.lastTrackedDate : lastTrackedDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
