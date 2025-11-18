// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionInfo {

/// セッションID
 String get id;/// セッション開始時刻
 DateTime get startTime;/// セッション終了時刻
 DateTime get endTime;/// カテゴリ別の時間（秒単位）
 Map<String, int> get categorySeconds;/// 検出期間のリスト（時系列データ）
 List<DetectionPeriod> get detectionPeriods;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionInfoCopyWith<SessionInfo> get copyWith => _$SessionInfoCopyWithImpl<SessionInfo>(this as SessionInfo, _$identity);

  /// Serializes this SessionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&const DeepCollectionEquality().equals(other.detectionPeriods, detectionPeriods)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,const DeepCollectionEquality().hash(categorySeconds),const DeepCollectionEquality().hash(detectionPeriods),lastModified);

@override
String toString() {
  return 'SessionInfo(id: $id, startTime: $startTime, endTime: $endTime, categorySeconds: $categorySeconds, detectionPeriods: $detectionPeriods, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $SessionInfoCopyWith<$Res>  {
  factory $SessionInfoCopyWith(SessionInfo value, $Res Function(SessionInfo) _then) = _$SessionInfoCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startTime, DateTime endTime, Map<String, int> categorySeconds, List<DetectionPeriod> detectionPeriods, DateTime lastModified
});




}
/// @nodoc
class _$SessionInfoCopyWithImpl<$Res>
    implements $SessionInfoCopyWith<$Res> {
  _$SessionInfoCopyWithImpl(this._self, this._then);

  final SessionInfo _self;
  final $Res Function(SessionInfo) _then;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startTime = null,Object? endTime = null,Object? categorySeconds = null,Object? detectionPeriods = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self.categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,detectionPeriods: null == detectionPeriods ? _self.detectionPeriods : detectionPeriods // ignore: cast_nullable_to_non_nullable
as List<DetectionPeriod>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionInfo].
extension SessionInfoPatterns on SessionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SessionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startTime,  DateTime endTime,  Map<String, int> categorySeconds,  List<DetectionPeriod> detectionPeriods,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.categorySeconds,_that.detectionPeriods,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startTime,  DateTime endTime,  Map<String, int> categorySeconds,  List<DetectionPeriod> detectionPeriods,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _SessionInfo():
return $default(_that.id,_that.startTime,_that.endTime,_that.categorySeconds,_that.detectionPeriods,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startTime,  DateTime endTime,  Map<String, int> categorySeconds,  List<DetectionPeriod> detectionPeriods,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _SessionInfo() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.categorySeconds,_that.detectionPeriods,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionInfo extends SessionInfo {
  const _SessionInfo({required this.id, required this.startTime, required this.endTime, required final  Map<String, int> categorySeconds, final  List<DetectionPeriod> detectionPeriods = const [], required this.lastModified}): _categorySeconds = categorySeconds,_detectionPeriods = detectionPeriods,super._();
  factory _SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);

/// セッションID
@override final  String id;
/// セッション開始時刻
@override final  DateTime startTime;
/// セッション終了時刻
@override final  DateTime endTime;
/// カテゴリ別の時間（秒単位）
 final  Map<String, int> _categorySeconds;
/// カテゴリ別の時間（秒単位）
@override Map<String, int> get categorySeconds {
  if (_categorySeconds is EqualUnmodifiableMapView) return _categorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySeconds);
}

/// 検出期間のリスト（時系列データ）
 final  List<DetectionPeriod> _detectionPeriods;
/// 検出期間のリスト（時系列データ）
@override@JsonKey() List<DetectionPeriod> get detectionPeriods {
  if (_detectionPeriods is EqualUnmodifiableListView) return _detectionPeriods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detectionPeriods);
}

/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionInfoCopyWith<_SessionInfo> get copyWith => __$SessionInfoCopyWithImpl<_SessionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&const DeepCollectionEquality().equals(other._detectionPeriods, _detectionPeriods)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,const DeepCollectionEquality().hash(_categorySeconds),const DeepCollectionEquality().hash(_detectionPeriods),lastModified);

@override
String toString() {
  return 'SessionInfo(id: $id, startTime: $startTime, endTime: $endTime, categorySeconds: $categorySeconds, detectionPeriods: $detectionPeriods, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$SessionInfoCopyWith<$Res> implements $SessionInfoCopyWith<$Res> {
  factory _$SessionInfoCopyWith(_SessionInfo value, $Res Function(_SessionInfo) _then) = __$SessionInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startTime, DateTime endTime, Map<String, int> categorySeconds, List<DetectionPeriod> detectionPeriods, DateTime lastModified
});




}
/// @nodoc
class __$SessionInfoCopyWithImpl<$Res>
    implements _$SessionInfoCopyWith<$Res> {
  __$SessionInfoCopyWithImpl(this._self, this._then);

  final _SessionInfo _self;
  final $Res Function(_SessionInfo) _then;

/// Create a copy of SessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startTime = null,Object? endTime = null,Object? categorySeconds = null,Object? detectionPeriods = null,Object? lastModified = null,}) {
  return _then(_SessionInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self._categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,detectionPeriods: null == detectionPeriods ? _self._detectionPeriods : detectionPeriods // ignore: cast_nullable_to_non_nullable
as List<DetectionPeriod>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
