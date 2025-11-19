// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_statistics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyStatistics {

/// 識別子（年月ベース、例: "2024-01"）
 String get id;/// 年
 int get year;/// 月（1-12）
 int get month;/// カテゴリ別の時間（秒単位）
/// study, pc, smartphoneのみ（personOnlyとnothingDetectedは除外）
 Map<String, int> get categorySeconds;/// 作業時間合計（秒単位、pc + study）
 int get totalWorkTimeSeconds;/// 円グラフ用データ
@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? get pieChartData;/// 日ごとのカテゴリ別秒数（月の日数分）
/// キー: "1", "2", ..., "31" (日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, smartphone: 600}
 Map<String, Map<String, int>> get dailyCategorySeconds;/// 最終更新日時
 DateTime get lastModified;
/// Create a copy of MonthlyStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyStatisticsCopyWith<MonthlyStatistics> get copyWith => _$MonthlyStatisticsCopyWithImpl<MonthlyStatistics>(this as MonthlyStatistics, _$identity);

  /// Serializes this MonthlyStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other.categorySeconds, categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other.dailyCategorySeconds, dailyCategorySeconds)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,month,const DeepCollectionEquality().hash(categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(dailyCategorySeconds),lastModified);

@override
String toString() {
  return 'MonthlyStatistics(id: $id, year: $year, month: $month, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, dailyCategorySeconds: $dailyCategorySeconds, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $MonthlyStatisticsCopyWith<$Res>  {
  factory $MonthlyStatisticsCopyWith(MonthlyStatistics value, $Res Function(MonthlyStatistics) _then) = _$MonthlyStatisticsCopyWithImpl;
@useResult
$Res call({
 String id, int year, int month, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> dailyCategorySeconds, DateTime lastModified
});


$PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class _$MonthlyStatisticsCopyWithImpl<$Res>
    implements $MonthlyStatisticsCopyWith<$Res> {
  _$MonthlyStatisticsCopyWithImpl(this._self, this._then);

  final MonthlyStatistics _self;
  final $Res Function(MonthlyStatistics) _then;

/// Create a copy of MonthlyStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? year = null,Object? month = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? dailyCategorySeconds = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,categorySeconds: null == categorySeconds ? _self.categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,dailyCategorySeconds: null == dailyCategorySeconds ? _self.dailyCategorySeconds : dailyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MonthlyStatistics
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


/// Adds pattern-matching-related methods to [MonthlyStatistics].
extension MonthlyStatisticsPatterns on MonthlyStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyStatistics value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int year,  int month,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyStatistics() when $default != null:
return $default(_that.id,_that.year,_that.month,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int year,  int month,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _MonthlyStatistics():
return $default(_that.id,_that.year,_that.month,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int year,  int month,  Map<String, int> categorySeconds,  int totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson)  PieChartDataModel? pieChartData,  Map<String, Map<String, int>> dailyCategorySeconds,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyStatistics() when $default != null:
return $default(_that.id,_that.year,_that.month,_that.categorySeconds,_that.totalWorkTimeSeconds,_that.pieChartData,_that.dailyCategorySeconds,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyStatistics extends MonthlyStatistics {
  const _MonthlyStatistics({required this.id, required this.year, required this.month, required final  Map<String, int> categorySeconds, required this.totalWorkTimeSeconds, @JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) this.pieChartData, final  Map<String, Map<String, int>> dailyCategorySeconds = const {}, required this.lastModified}): _categorySeconds = categorySeconds,_dailyCategorySeconds = dailyCategorySeconds,super._();
  factory _MonthlyStatistics.fromJson(Map<String, dynamic> json) => _$MonthlyStatisticsFromJson(json);

/// 識別子（年月ベース、例: "2024-01"）
@override final  String id;
/// 年
@override final  int year;
/// 月（1-12）
@override final  int month;
/// カテゴリ別の時間（秒単位）
/// study, pc, smartphoneのみ（personOnlyとnothingDetectedは除外）
 final  Map<String, int> _categorySeconds;
/// カテゴリ別の時間（秒単位）
/// study, pc, smartphoneのみ（personOnlyとnothingDetectedは除外）
@override Map<String, int> get categorySeconds {
  if (_categorySeconds is EqualUnmodifiableMapView) return _categorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySeconds);
}

/// 作業時間合計（秒単位、pc + study）
@override final  int totalWorkTimeSeconds;
/// 円グラフ用データ
@override@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) final  PieChartDataModel? pieChartData;
/// 日ごとのカテゴリ別秒数（月の日数分）
/// キー: "1", "2", ..., "31" (日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, smartphone: 600}
 final  Map<String, Map<String, int>> _dailyCategorySeconds;
/// 日ごとのカテゴリ別秒数（月の日数分）
/// キー: "1", "2", ..., "31" (日)
/// 値: カテゴリ別秒数のMap {study: 3600, pc: 1800, smartphone: 600}
@override@JsonKey() Map<String, Map<String, int>> get dailyCategorySeconds {
  if (_dailyCategorySeconds is EqualUnmodifiableMapView) return _dailyCategorySeconds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dailyCategorySeconds);
}

/// 最終更新日時
@override final  DateTime lastModified;

/// Create a copy of MonthlyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyStatisticsCopyWith<_MonthlyStatistics> get copyWith => __$MonthlyStatisticsCopyWithImpl<_MonthlyStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyStatistics&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other._categorySeconds, _categorySeconds)&&(identical(other.totalWorkTimeSeconds, totalWorkTimeSeconds) || other.totalWorkTimeSeconds == totalWorkTimeSeconds)&&(identical(other.pieChartData, pieChartData) || other.pieChartData == pieChartData)&&const DeepCollectionEquality().equals(other._dailyCategorySeconds, _dailyCategorySeconds)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,month,const DeepCollectionEquality().hash(_categorySeconds),totalWorkTimeSeconds,pieChartData,const DeepCollectionEquality().hash(_dailyCategorySeconds),lastModified);

@override
String toString() {
  return 'MonthlyStatistics(id: $id, year: $year, month: $month, categorySeconds: $categorySeconds, totalWorkTimeSeconds: $totalWorkTimeSeconds, pieChartData: $pieChartData, dailyCategorySeconds: $dailyCategorySeconds, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$MonthlyStatisticsCopyWith<$Res> implements $MonthlyStatisticsCopyWith<$Res> {
  factory _$MonthlyStatisticsCopyWith(_MonthlyStatistics value, $Res Function(_MonthlyStatistics) _then) = __$MonthlyStatisticsCopyWithImpl;
@override @useResult
$Res call({
 String id, int year, int month, Map<String, int> categorySeconds, int totalWorkTimeSeconds,@JsonKey(toJson: _pieChartDataToJson, fromJson: _pieChartDataFromJson) PieChartDataModel? pieChartData, Map<String, Map<String, int>> dailyCategorySeconds, DateTime lastModified
});


@override $PieChartDataModelCopyWith<$Res>? get pieChartData;

}
/// @nodoc
class __$MonthlyStatisticsCopyWithImpl<$Res>
    implements _$MonthlyStatisticsCopyWith<$Res> {
  __$MonthlyStatisticsCopyWithImpl(this._self, this._then);

  final _MonthlyStatistics _self;
  final $Res Function(_MonthlyStatistics) _then;

/// Create a copy of MonthlyStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? year = null,Object? month = null,Object? categorySeconds = null,Object? totalWorkTimeSeconds = null,Object? pieChartData = freezed,Object? dailyCategorySeconds = null,Object? lastModified = null,}) {
  return _then(_MonthlyStatistics(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,categorySeconds: null == categorySeconds ? _self._categorySeconds : categorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalWorkTimeSeconds: null == totalWorkTimeSeconds ? _self.totalWorkTimeSeconds : totalWorkTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,pieChartData: freezed == pieChartData ? _self.pieChartData : pieChartData // ignore: cast_nullable_to_non_nullable
as PieChartDataModel?,dailyCategorySeconds: null == dailyCategorySeconds ? _self._dailyCategorySeconds : dailyCategorySeconds // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MonthlyStatistics
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
