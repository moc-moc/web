// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetectionPeriod {

/// 検出開始時刻
 DateTime get startTime;/// 検出終了時刻
 DateTime get endTime;/// 検出されたカテゴリ
 String get category;/// 信頼度
 double get confidence;
/// Create a copy of DetectionPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectionPeriodCopyWith<DetectionPeriod> get copyWith => _$DetectionPeriodCopyWithImpl<DetectionPeriod>(this as DetectionPeriod, _$identity);

  /// Serializes this DetectionPeriod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectionPeriod&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,category,confidence);

@override
String toString() {
  return 'DetectionPeriod(startTime: $startTime, endTime: $endTime, category: $category, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $DetectionPeriodCopyWith<$Res>  {
  factory $DetectionPeriodCopyWith(DetectionPeriod value, $Res Function(DetectionPeriod) _then) = _$DetectionPeriodCopyWithImpl;
@useResult
$Res call({
 DateTime startTime, DateTime endTime, String category, double confidence
});




}
/// @nodoc
class _$DetectionPeriodCopyWithImpl<$Res>
    implements $DetectionPeriodCopyWith<$Res> {
  _$DetectionPeriodCopyWithImpl(this._self, this._then);

  final DetectionPeriod _self;
  final $Res Function(DetectionPeriod) _then;

/// Create a copy of DetectionPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startTime = null,Object? endTime = null,Object? category = null,Object? confidence = null,}) {
  return _then(_self.copyWith(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectionPeriod].
extension DetectionPeriodPatterns on DetectionPeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectionPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectionPeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectionPeriod value)  $default,){
final _that = this;
switch (_that) {
case _DetectionPeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectionPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _DetectionPeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startTime,  DateTime endTime,  String category,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectionPeriod() when $default != null:
return $default(_that.startTime,_that.endTime,_that.category,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startTime,  DateTime endTime,  String category,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _DetectionPeriod():
return $default(_that.startTime,_that.endTime,_that.category,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startTime,  DateTime endTime,  String category,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _DetectionPeriod() when $default != null:
return $default(_that.startTime,_that.endTime,_that.category,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetectionPeriod extends DetectionPeriod {
  const _DetectionPeriod({required this.startTime, required this.endTime, required this.category, required this.confidence}): super._();
  factory _DetectionPeriod.fromJson(Map<String, dynamic> json) => _$DetectionPeriodFromJson(json);

/// 検出開始時刻
@override final  DateTime startTime;
/// 検出終了時刻
@override final  DateTime endTime;
/// 検出されたカテゴリ
@override final  String category;
/// 信頼度
@override final  double confidence;

/// Create a copy of DetectionPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectionPeriodCopyWith<_DetectionPeriod> get copyWith => __$DetectionPeriodCopyWithImpl<_DetectionPeriod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetectionPeriodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectionPeriod&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,category,confidence);

@override
String toString() {
  return 'DetectionPeriod(startTime: $startTime, endTime: $endTime, category: $category, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$DetectionPeriodCopyWith<$Res> implements $DetectionPeriodCopyWith<$Res> {
  factory _$DetectionPeriodCopyWith(_DetectionPeriod value, $Res Function(_DetectionPeriod) _then) = __$DetectionPeriodCopyWithImpl;
@override @useResult
$Res call({
 DateTime startTime, DateTime endTime, String category, double confidence
});




}
/// @nodoc
class __$DetectionPeriodCopyWithImpl<$Res>
    implements _$DetectionPeriodCopyWith<$Res> {
  __$DetectionPeriodCopyWithImpl(this._self, this._then);

  final _DetectionPeriod _self;
  final $Res Function(_DetectionPeriod) _then;

/// Create a copy of DetectionPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startTime = null,Object? endTime = null,Object? category = null,Object? confidence = null,}) {
  return _then(_DetectionPeriod(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TrackingSession {

/// セッションID（自動生成）
 String get id;/// セッション開始時刻
 DateTime get startTime;/// セッション終了時刻
 DateTime get endTime;/// カテゴリ別の時間（秒単位）
 Map<String, int> get categorySeconds;/// 検出期間のリスト（時系列データ）
 List<DetectionPeriod> get detectionPeriods;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of TrackingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingSessionCopyWith<TrackingSession> get copyWith => _$TrackingSessionCopyWithImpl<TrackingSession>(this as TrackingSession, _$identity);

  /// Serializes this TrackingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&const DeepCollectionEquality().equals(other.detectionPeriods, detectionPeriods)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,const DeepCollectionEquality().hash(categorySeconds),const DeepCollectionEquality().hash(detectionPeriods),lastModified);

@override
String toString() {
  return 'TrackingSession(id: $id, startTime: $startTime, endTime: $endTime, categorySeconds: $categorySeconds, detectionPeriods: $detectionPeriods, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $TrackingSessionCopyWith<$Res>  {
  factory $TrackingSessionCopyWith(TrackingSession value, $Res Function(TrackingSession) _then) = _$TrackingSessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startTime, DateTime endTime, Map<String, int> categorySeconds, List<DetectionPeriod> detectionPeriods, DateTime lastModified
});




}
/// @nodoc
class _$TrackingSessionCopyWithImpl<$Res>
    implements $TrackingSessionCopyWith<$Res> {
  _$TrackingSessionCopyWithImpl(this._self, this._then);

  final TrackingSession _self;
  final $Res Function(TrackingSession) _then;

/// Create a copy of TrackingSession
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


/// Adds pattern-matching-related methods to [TrackingSession].
extension TrackingSessionPatterns on TrackingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingSession value)  $default,){
final _that = this;
switch (_that) {
case _TrackingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingSession value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingSession() when $default != null:
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
case _TrackingSession() when $default != null:
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
case _TrackingSession():
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
case _TrackingSession() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.categorySeconds,_that.detectionPeriods,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingSession extends TrackingSession {
  const _TrackingSession({required this.id, required this.startTime, required this.endTime, required final  Map<String, int> categorySeconds, final  List<DetectionPeriod> detectionPeriods = const [], required this.lastModified}): _categorySeconds = categorySeconds,_detectionPeriods = detectionPeriods,super._();
  factory _TrackingSession.fromJson(Map<String, dynamic> json) => _$TrackingSessionFromJson(json);

/// セッションID（自動生成）
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

/// Create a copy of TrackingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingSessionCopyWith<_TrackingSession> get copyWith => __$TrackingSessionCopyWithImpl<_TrackingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&const DeepCollectionEquality().equals(other._detectionPeriods, _detectionPeriods)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,const DeepCollectionEquality().hash(_categorySeconds),const DeepCollectionEquality().hash(_detectionPeriods),lastModified);

@override
String toString() {
  return 'TrackingSession(id: $id, startTime: $startTime, endTime: $endTime, categorySeconds: $categorySeconds, detectionPeriods: $detectionPeriods, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$TrackingSessionCopyWith<$Res> implements $TrackingSessionCopyWith<$Res> {
  factory _$TrackingSessionCopyWith(_TrackingSession value, $Res Function(_TrackingSession) _then) = __$TrackingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startTime, DateTime endTime, Map<String, int> categorySeconds, List<DetectionPeriod> detectionPeriods, DateTime lastModified
});




}
/// @nodoc
class __$TrackingSessionCopyWithImpl<$Res>
    implements _$TrackingSessionCopyWith<$Res> {
  __$TrackingSessionCopyWithImpl(this._self, this._then);

  final _TrackingSession _self;
  final $Res Function(_TrackingSession) _then;

/// Create a copy of TrackingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startTime = null,Object? endTime = null,Object? categorySeconds = null,Object? detectionPeriods = null,Object? lastModified = null,}) {
  return _then(_TrackingSession(
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
