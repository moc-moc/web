// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_flag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurveyFlag {

/// 固定ID（'survey_flag'）
 String get id;/// 初回アンケートを実施済みかどうか
 bool get hasShownFirstSurvey;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of SurveyFlag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurveyFlagCopyWith<SurveyFlag> get copyWith => _$SurveyFlagCopyWithImpl<SurveyFlag>(this as SurveyFlag, _$identity);

  /// Serializes this SurveyFlag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurveyFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.hasShownFirstSurvey, hasShownFirstSurvey) || other.hasShownFirstSurvey == hasShownFirstSurvey)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hasShownFirstSurvey,lastModified);

@override
String toString() {
  return 'SurveyFlag(id: $id, hasShownFirstSurvey: $hasShownFirstSurvey, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $SurveyFlagCopyWith<$Res>  {
  factory $SurveyFlagCopyWith(SurveyFlag value, $Res Function(SurveyFlag) _then) = _$SurveyFlagCopyWithImpl;
@useResult
$Res call({
 String id, bool hasShownFirstSurvey, DateTime lastModified
});




}
/// @nodoc
class _$SurveyFlagCopyWithImpl<$Res>
    implements $SurveyFlagCopyWith<$Res> {
  _$SurveyFlagCopyWithImpl(this._self, this._then);

  final SurveyFlag _self;
  final $Res Function(SurveyFlag) _then;

/// Create a copy of SurveyFlag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hasShownFirstSurvey = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hasShownFirstSurvey: null == hasShownFirstSurvey ? _self.hasShownFirstSurvey : hasShownFirstSurvey // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SurveyFlag].
extension SurveyFlagPatterns on SurveyFlag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurveyFlag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurveyFlag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurveyFlag value)  $default,){
final _that = this;
switch (_that) {
case _SurveyFlag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurveyFlag value)?  $default,){
final _that = this;
switch (_that) {
case _SurveyFlag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool hasShownFirstSurvey,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurveyFlag() when $default != null:
return $default(_that.id,_that.hasShownFirstSurvey,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool hasShownFirstSurvey,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _SurveyFlag():
return $default(_that.id,_that.hasShownFirstSurvey,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool hasShownFirstSurvey,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _SurveyFlag() when $default != null:
return $default(_that.id,_that.hasShownFirstSurvey,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurveyFlag extends SurveyFlag {
  const _SurveyFlag({required this.id, required this.hasShownFirstSurvey, required this.lastModified}): super._();
  factory _SurveyFlag.fromJson(Map<String, dynamic> json) => _$SurveyFlagFromJson(json);

/// 固定ID（'survey_flag'）
@override final  String id;
/// 初回アンケートを実施済みかどうか
@override final  bool hasShownFirstSurvey;
/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of SurveyFlag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurveyFlagCopyWith<_SurveyFlag> get copyWith => __$SurveyFlagCopyWithImpl<_SurveyFlag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurveyFlagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurveyFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.hasShownFirstSurvey, hasShownFirstSurvey) || other.hasShownFirstSurvey == hasShownFirstSurvey)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hasShownFirstSurvey,lastModified);

@override
String toString() {
  return 'SurveyFlag(id: $id, hasShownFirstSurvey: $hasShownFirstSurvey, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$SurveyFlagCopyWith<$Res> implements $SurveyFlagCopyWith<$Res> {
  factory _$SurveyFlagCopyWith(_SurveyFlag value, $Res Function(_SurveyFlag) _then) = __$SurveyFlagCopyWithImpl;
@override @useResult
$Res call({
 String id, bool hasShownFirstSurvey, DateTime lastModified
});




}
/// @nodoc
class __$SurveyFlagCopyWithImpl<$Res>
    implements _$SurveyFlagCopyWith<$Res> {
  __$SurveyFlagCopyWithImpl(this._self, this._then);

  final _SurveyFlag _self;
  final $Res Function(_SurveyFlag) _then;

/// Create a copy of SurveyFlag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hasShownFirstSurvey = null,Object? lastModified = null,}) {
  return _then(_SurveyFlag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hasShownFirstSurvey: null == hasShownFirstSurvey ? _self.hasShownFirstSurvey : hasShownFirstSurvey // ignore: cast_nullable_to_non_nullable
as bool,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
