// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_statistics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyStatistics {

/// 識別子（週開始日ベース、例: "2024-01-15"）
 String get id;/// 週の開始日（月曜日、時刻部分は00:00:00）
 DateTime get weekStart;/// カテゴリ別の時間（秒単位）
/// study, pc, smartphone, personOnly, nothingDetectedを含む
 Map<String, int> get categorySeconds;/// 作業時間合計（秒単位、pc + study）
 int get totalWorkTimeSeconds;/// 円グラフ用データ
@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? get pieChartData;/// 日ごとのカテゴリ別秒数（7日分）
/// キー: "0", "1", ..., "6" (月曜日から日曜日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, ...}
 Map<String, Map<String, int>> get dailyCategorySeconds;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of WeeklyStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyStatisticsCopyWith<WeeklyStatistics> get copyWith => _$WeeklyStatisticsCopyWithImpl<WeeklyStatistics>(this as WeeklyStatistics, _$identity);

  /// Serializes this WeeklyStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other.dailyCategorySeconds, dailyCategorySeconds)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,weekStart,const DeepCollectionEquality().hash(categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(dailyCategorySeconds),lastModified);

@override
String toString() {
  return 'WeeklyStatistics(id: $id, weekStart: $weekStart, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, dailyCategorySeconds: $dailyCategorySeconds, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $WeeklyStatisticsCopyWith<$Res>  {
  factory $WeeklyStatisticsCopyWith(WeeklyStatistics value, $Res Function(WeeklyStatistics) _then) = _$WeeklyStatisticsCopyWithImpl;
@useResult
$Res call({
 String id, DateTime weekStart, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> dailyCategorySeconds, DateTime lastModified
});


$PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class _$WeeklyStatisticsCopyWithImpl<$Res>
    implements $WeeklyStatisticsCopyWith<$Res> {
  _$WeeklyStatisticsCopyWithImpl(this._self, this._then);

  final WeeklyStatistics _self;
  final $Res Function(WeeklyStatistics) _then;

/// Create a copy of WeeklyStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? weekStart = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? dailyCategorySeconds = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self.categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,dailyCategorySeconds: null == dailyCategorySeconds ? _self.dailyCategorySeconds : dailyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of WeeklyStatistics
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


/// Adds pattern-matching-related methods to [WeeklyStatistics].
extension WeeklyStatisticsPatterns on WeeklyStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyStatistics value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime weekStart,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyStatistics() when $default != null:
return $default(_that.id,_that.weekStart,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime weekStart,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _WeeklyStatistics():
return $default(_that.id,_that.weekStart,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime weekStart,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyStatistics() when $default != null:
return $default(_that.id,_that.weekStart,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyStatistics extends WeeklyStatistics {
  const _WeeklyStatistics({required this.id, required this.weekStart, required final  Map<String, int> categorySeconds, required this.totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) this.pieChartData, final  Map<String, Map<String, int>> dailyCategorySeconds = const {}, required this.lastModified}): _categorySeconds = categorySeconds,_dailyCategorySeconds = dailyCategorySeconds,super._();
  factory _WeeklyStatistics.fromJson(Map<String, dynamic> json) => _$WeeklyStatisticsFromJson(json);

/// 識別子（週開始日ベース、例: "2024-01-15"）
@override final  String id;
/// 週の開始日（月曜日、時刻部分は00:00:00）
@override final  DateTime weekStart;
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
/// 日ごとのカテゴリ別秒数（7日分）
/// キー: "0", "1", ..., "6" (月曜日から日曜日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, ...}
 final  Map<String, Map<String, int>> _dailyCategorySeconds;
/// 日ごとのカテゴリ別秒数（7日分）
/// キー: "0", "1", ..., "6" (月曜日から日曜日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, ...}
@override@JsonKey() Map<String, Map<String, int>> get dailyCategorySeconds {
  if (_dailyCategorySeconds is EqualUnmodifiableMapView) return _dailyCategorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dailyCategorySeconds);
}

/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of WeeklyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyStatisticsCopyWith<_WeeklyStatistics> get copyWith => __$WeeklyStatisticsCopyWithImpl<_WeeklyStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other._dailyCategorySeconds, _dailyCategorySeconds)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,weekStart,const DeepCollectionEquality().hash(_categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(_dailyCategorySeconds),lastModified);

@override
String toString() {
  return 'WeeklyStatistics(id: $id, weekStart: $weekStart, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, dailyCategorySeconds: $dailyCategorySeconds, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$WeeklyStatisticsCopyWith<$Res> implements $WeeklyStatisticsCopyWith<$Res> {
  factory _$WeeklyStatisticsCopyWith(_WeeklyStatistics value, $Res Function(_WeeklyStatistics) _then) = __$WeeklyStatisticsCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime weekStart, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> dailyCategorySeconds, DateTime lastModified
});


@override $PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class __$WeeklyStatisticsCopyWithImpl<$Res>
    implements _$WeeklyStatisticsCopyWith<$Res> {
  __$WeeklyStatisticsCopyWithImpl(this._self, this._then);

  final _WeeklyStatistics _self;
  final $Res Function(_WeeklyStatistics) _then;

/// Create a copy of WeeklyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? weekStart = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? dailyCategorySeconds = null,Object? lastModified = null,}) {
  return _then(_WeeklyStatistics(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,categorySeconds: null == categorySeconds ? _self._categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,dailyCategorySeconds: null == dailyCategorySeconds ? _self._dailyCategorySeconds : dailyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of WeeklyStatistics
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
