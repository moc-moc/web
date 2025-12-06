// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_count_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackingCount {

/// 日付（YYYY-MM-DD形式）
 String get id;/// トラッキング回数
 int get count;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of TrackingCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingCountCopyWith<TrackingCount> get copyWith => _$TrackingCountCopyWithImpl<TrackingCount>(this as TrackingCount, _$identity);

  /// Serializes this TrackingCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingCount&&(identical(other.id, id) || other.id == id)&&(identical(other.count, count) || other.count == count)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,count,lastModified);

@override
String toString() {
  return 'TrackingCount(id: $id, count: $count, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $TrackingCountCopyWith<$Res>  {
  factory $TrackingCountCopyWith(TrackingCount value, $Res Function(TrackingCount) _then) = _$TrackingCountCopyWithImpl;
@useResult
$Res call({
 String id, int count, DateTime lastModified
});




}
/// @nodoc
class _$TrackingCountCopyWithImpl<$Res>
    implements $TrackingCountCopyWith<$Res> {
  _$TrackingCountCopyWithImpl(this._self, this._then);

  final TrackingCount _self;
  final $Res Function(TrackingCount) _then;

/// Create a copy of TrackingCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? count = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingCount].
extension TrackingCountPatterns on TrackingCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingCount value)  $default,){
final _that = this;
switch (_that) {
case _TrackingCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingCount value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int count,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingCount() when $default != null:
return $default(_that.id,_that.count,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int count,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _TrackingCount():
return $default(_that.id,_that.count,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int count,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _TrackingCount() when $default != null:
return $default(_that.id,_that.count,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingCount extends TrackingCount {
  const _TrackingCount({required this.id, required this.count, required this.lastModified}): super._();
  factory _TrackingCount.fromJson(Map<String, dynamic> json) => _$TrackingCountFromJson(json);

/// 日付（YYYY-MM-DD形式）
@override final  String id;
/// トラッキング回数
@override final  int count;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of TrackingCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingCountCopyWith<_TrackingCount> get copyWith => __$TrackingCountCopyWithImpl<_TrackingCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingCount&&(identical(other.id, id) || other.id == id)&&(identical(other.count, count) || other.count == count)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,count,lastModified);

@override
String toString() {
  return 'TrackingCount(id: $id, count: $count, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$TrackingCountCopyWith<$Res> implements $TrackingCountCopyWith<$Res> {
  factory _$TrackingCountCopyWith(_TrackingCount value, $Res Function(_TrackingCount) _then) = __$TrackingCountCopyWithImpl;
@override @useResult
$Res call({
 String id, int count, DateTime lastModified
});




}
/// @nodoc
class __$TrackingCountCopyWithImpl<$Res>
    implements _$TrackingCountCopyWith<$Res> {
  __$TrackingCountCopyWithImpl(this._self, this._then);

  final _TrackingCount _self;
  final $Res Function(_TrackingCount) _then;

/// Create a copy of TrackingCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? count = null,Object? lastModified = null,}) {
  return _then(_TrackingCount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
