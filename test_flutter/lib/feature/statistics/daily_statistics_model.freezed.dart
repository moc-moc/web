// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_statistics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieChartDataModel {

/// 各カテゴリの秒数
 Map<String, int> get categorySeconds;/// 各カテゴリの割合（%）
 Map<String, double> get percentages;/// 各カテゴリの色（Colorのvalueをintで保存）
 Map<String, int> get colors;/// 合計秒数
 int get totalSeconds;
/// Create a copy of PieChartDataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieChartDataModelCopyWith<PieChartDataModel> get copyWith => _$PieChartDataModelCopyWithImpl<PieChartDataModel>(this as PieChartDataModel, _$identity);

  /// Serializes this PieChartDataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieChartDataModel&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&const DeepCollectionEquality().equals(other.percentages, percentages)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categorySeconds),const DeepCollectionEquality().hash(percentages),const DeepCollectionEquality().hash(colors),totalSeconds);

@override
String toString() {
  return 'PieChartDataModel(categorySeconds: $categorySeconds, percentages: $percentages, colors: $colors, totalSeconds: $totalSeconds)';
}


}

/// @nodoc
abstract mixin class $PieChartDataModelCopyWith<$Res>  {
  factory $PieChartDataModelCopyWith(PieChartDataModel value, $Res Function(PieChartDataModel) _then) = _$PieChartDataModelCopyWithImpl;
@useResult
$Res call({
 Map<String, int> categorySeconds, Map<String, double> percentages, Map<String, int> colors, int totalSeconds
});




}
/// @nodoc
class _$PieChartDataModelCopyWithImpl<$Res>
    implements $PieChartDataModelCopyWith<$Res> {
  _$PieChartDataModelCopyWithImpl(this._self, this._then);

  final PieChartDataModel _self;
  final $Res Function(PieChartDataModel) _then;

/// Create a copy of PieChartDataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categorySeconds = null,Object? percentages = null,Object? colors = null,Object? totalSeconds = null,}) {
  return _then(_self.copyWith(
categorySeconds: null == categorySeconds ? _self.categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,percentages: null == percentages ? _self.percentages : percentages // ignore: cast_nullable_to_non_nullable
as Map<String, double>,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PieChartDataModel].
extension PieChartDataModelPatterns on PieChartDataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieChartDataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieChartDataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieChartDataModel value)  $default,){
final _that = this;
switch (_that) {
case _PieChartDataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieChartDataModel value)?  $default,){
final _that = this;
switch (_that) {
case _PieChartDataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> categorySeconds,  Map<String, double> percentages,  Map<String, int> colors,  int totalSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieChartDataModel() when $default != null:
return $default(_that.categorySeconds,_that.percentages,_that.colors,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> categorySeconds,  Map<String, double> percentages,  Map<String, int> colors,  int totalSeconds)  $default,) {final _that = this;
switch (_that) {
case _PieChartDataModel():
return $default(_that.categorySeconds,_that.percentages,_that.colors,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> categorySeconds,  Map<String, double> percentages,  Map<String, int> colors,  int totalSeconds)?  $default,) {final _that = this;
switch (_that) {
case _PieChartDataModel() when $default != null:
return $default(_that.categorySeconds,_that.percentages,_that.colors,_that.totalSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieChartDataModel implements PieChartDataModel {
  const _PieChartDataModel({required final  Map<String, int> categorySeconds, required final  Map<String, double> percentages, required final  Map<String, int> colors, required this.totalSeconds}): _categorySeconds = categorySeconds,_percentages = percentages,_colors = colors;
  factory _PieChartDataModel.fromJson(Map<String, dynamic> json) => _$PieChartDataModelFromJson(json);

/// 各カテゴリの秒数
 final  Map<String, int> _categorySeconds;
/// 各カテゴリの秒数
@override Map<String, int> get categorySeconds {
  if (_categorySeconds is EqualUnmodifiableMapView) return _categorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySeconds);
}

/// 各カテゴリの割合（%）
 final  Map<String, double> _percentages;
/// 各カテゴリの割合（%）
@override Map<String, double> get percentages {
  if (_percentages is EqualUnmodifiableMapView) return _percentages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_percentages);
}

/// 各カテゴリの色（Colorのvalueをintで保存）
 final  Map<String, int> _colors;
/// 各カテゴリの色（Colorのvalueをintで保存）
@override Map<String, int> get colors {
  if (_colors is EqualUnmodifiableMapView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_colors);
}

/// 合計秒数
@override final  int totalSeconds;

/// Create a copy of PieChartDataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieChartDataModelCopyWith<_PieChartDataModel> get copyWith => __$PieChartDataModelCopyWithImpl<_PieChartDataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieChartDataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieChartDataModel&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&const DeepCollectionEquality().equals(other._percentages, _percentages)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categorySeconds),const DeepCollectionEquality().hash(_percentages),const DeepCollectionEquality().hash(_colors),totalSeconds);

@override
String toString() {
  return 'PieChartDataModel(categorySeconds: $categorySeconds, percentages: $percentages, colors: $colors, totalSeconds: $totalSeconds)';
}


}

/// @nodoc
abstract mixin class _$PieChartDataModelCopyWith<$Res> implements $PieChartDataModelCopyWith<$Res> {
  factory _$PieChartDataModelCopyWith(_PieChartDataModel value, $Res Function(_PieChartDataModel) _then) = __$PieChartDataModelCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> categorySeconds, Map<String, double> percentages, Map<String, int> colors, int totalSeconds
});




}
/// @nodoc
class __$PieChartDataModelCopyWithImpl<$Res>
    implements _$PieChartDataModelCopyWith<$Res> {
  __$PieChartDataModelCopyWithImpl(this._self, this._then);

  final _PieChartDataModel _self;
  final $Res Function(_PieChartDataModel) _then;

/// Create a copy of PieChartDataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categorySeconds = null,Object? percentages = null,Object? colors = null,Object? totalSeconds = null,}) {
  return _then(_PieChartDataModel(
categorySeconds: null == categorySeconds ? _self._categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,percentages: null == percentages ? _self._percentages : percentages // ignore: cast_nullable_to_non_nullable
as Map<String, double>,colors: null == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DailyStatistics {

/// 識別子（日付ベース、例: "2024-01-15"）
 String get id;/// 日付（時刻部分は00:00:00）
 DateTime get date;/// カテゴリ別の時間（秒単位）
/// study, pc, smartphone, personOnly, nothingDetectedを含む
 Map<String, int> get categorySeconds;/// 作業時間合計（秒単位、pc + study）
 int get totalWorkTimeSeconds;/// 円グラフ用データ
@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? get pieChartData;/// 時間ごとのカテゴリ別秒数（24時間分）
/// キー: "0", "1", ..., "23" (時間)
/// 値: カテゴリ別秒数のMap {study: 600, pc: 300, ...}
 Map<String, Map<String, int>> get hourlyCategorySeconds;/// セッション情報のリスト
/// その日のトラッキングセッションを保持
@JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) List<SessionInfo> get sessions;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStatisticsCopyWith<DailyStatistics> get copyWith => _$DailyStatisticsCopyWithImpl<DailyStatistics>(this as DailyStatistics, _$identity);

  /// Serializes this DailyStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other.hourlyCategorySeconds, hourlyCategorySeconds)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(hourlyCategorySeconds),const DeepCollectionEquality().hash(sessions),lastModified);

@override
String toString() {
  return 'DailyStatistics(id: $id, date: $date, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, hourlyCategorySeconds: $hourlyCategorySeconds, sessions: $sessions, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $DailyStatisticsCopyWith<$Res>  {
  factory $DailyStatisticsCopyWith(DailyStatistics value, $Res Function(DailyStatistics) _then) = _$DailyStatisticsCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> hourlyCategorySeconds,@JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) List<SessionInfo> sessions, DateTime lastModified
});


$PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class _$DailyStatisticsCopyWithImpl<$Res>
    implements $DailyStatisticsCopyWith<$Res> {
  _$DailyStatisticsCopyWithImpl(this._self, this._then);

  final DailyStatistics _self;
  final $Res Function(DailyStatistics) _then;

/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? hourlyCategorySeconds = null,Object? sessions = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self.categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,hourlyCategorySeconds: null == hourlyCategorySeconds ? _self.hourlyCategorySeconds : hourlyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SessionInfo>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieChartDataModelCopyWith<$Res>? get pieChartData {
    if (_self.pieChartData == null) {
    return null;
  }

  return $PieChartDataModelCopyWith<$Res>(_self.pieChartData!, (value) {
    return _then(_self.copyWith(pieChartData: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyStatistics].
extension DailyStatisticsPatterns on DailyStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyStatistics value)  $default,){
final _that = this;
switch (_that) {
case _DailyStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _DailyStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> hourlyCategorySeconds, @JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson)  List<SessionInfo> sessions,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyStatistics() when $default != null:
return $default(_that.id,_that.date,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.hourlyCategorySeconds,_that.sessions,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> hourlyCategorySeconds, @JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson)  List<SessionInfo> sessions,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _DailyStatistics():
return $default(_that.id,_that.date,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.hourlyCategorySeconds,_that.sessions,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> hourlyCategorySeconds, @JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson)  List<SessionInfo> sessions,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _DailyStatistics() when $default != null:
return $default(_that.id,_that.date,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.hourlyCategorySeconds,_that.sessions,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyStatistics extends DailyStatistics {
  const _DailyStatistics({required this.id, required this.date, required final  Map<String, int> categorySeconds, required this.totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) this.pieChartData, final  Map<String, Map<String, int>> hourlyCategorySeconds = const {}, @JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) final  List<SessionInfo> sessions = const [], required this.lastModified}): _categorySeconds = categorySeconds,_hourlyCategorySeconds = hourlyCategorySeconds,_sessions = sessions,super._();
  factory _DailyStatistics.fromJson(Map<String, dynamic> json) => _$DailyStatisticsFromJson(json);

/// 識別子（日付ベース、例: "2024-01-15"）
@override final  String id;
/// 日付（時刻部分は00:00:00）
@override final  DateTime date;
/// カテゴリ別の時間（秒単位）
/// study, pc, smartphone, personOnly, nothingDetectedを含む
 final  Map<String, int> _categorySeconds;
/// カテゴリ別の時間（秒単位）
/// study, pc, smartphone, personOnly, nothingDetectedを含む
@override Map<String, int> get categorySeconds {
  if (_categorySeconds is EqualUnmodifiableMapView) return _categorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySeconds);
}

/// 作業時間合計（秒単位、pc + study）
@override final  int totalWorkTimeSeconds;
/// 円グラフ用データ
@override@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) final  PieChartDataModel? pieChartData;
/// 時間ごとのカテゴリ別秒数（24時間分）
/// キー: "0", "1", ..., "23" (時間)
/// 値: カテゴリ別秒数のMap {study: 600, pc: 300, ...}
 final  Map<String, Map<String, int>> _hourlyCategorySeconds;
/// 時間ごとのカテゴリ別秒数（24時間分）
/// キー: "0", "1", ..., "23" (時間)
/// 値: カテゴリ別秒数のMap {study: 600, pc: 300, ...}
@override@JsonKey() Map<String, Map<String, int>> get hourlyCategorySeconds {
  if (_hourlyCategorySeconds is EqualUnmodifiableMapView) return _hourlyCategorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hourlyCategorySeconds);
}

/// セッション情報のリスト
/// その日のトラッキングセッションを保持
 final  List<SessionInfo> _sessions;
/// セッション情報のリスト
/// その日のトラッキングセッションを保持
@override@JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) List<SessionInfo> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStatisticsCopyWith<_DailyStatistics> get copyWith => __$DailyStatisticsCopyWithImpl<_DailyStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other._hourlyCategorySeconds, _hourlyCategorySeconds)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(_categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(_hourlyCategorySeconds),const DeepCollectionEquality().hash(_sessions),lastModified);

@override
String toString() {
  return 'DailyStatistics(id: $id, date: $date, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, hourlyCategorySeconds: $hourlyCategorySeconds, sessions: $sessions, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$DailyStatisticsCopyWith<$Res> implements $DailyStatisticsCopyWith<$Res> {
  factory _$DailyStatisticsCopyWith(_DailyStatistics value, $Res Function(_DailyStatistics) _then) = __$DailyStatisticsCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> hourlyCategorySeconds,@JsonKey(toJson: _sessionsToJson, fromJson: _sessionsFromJson) List<SessionInfo> sessions, DateTime lastModified
});


@override $PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class __$DailyStatisticsCopyWithImpl<$Res>
    implements _$DailyStatisticsCopyWith<$Res> {
  __$DailyStatisticsCopyWithImpl(this._self, this._then);

  final _DailyStatistics _self;
  final $Res Function(_DailyStatistics) _then;

/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? hourlyCategorySeconds = null,Object? sessions = null,Object? lastModified = null,}) {
  return _then(_DailyStatistics(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self._categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,hourlyCategorySeconds: null == hourlyCategorySeconds ? _self._hourlyCategorySeconds : hourlyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SessionInfo>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of DailyStatistics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieChartDataModelCopyWith<$Res>? get pieChartData {
    if (_self.pieChartData == null) {
    return null;
  }

  return $PieChartDataModelCopyWith<$Res>(_self.pieChartData!, (value) {
    return _then(_self.copyWith(pieChartData: value));
  });
}
}

// dart format on
