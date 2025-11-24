// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LevelingState {

/// Firestore上のドキュメントID（原則 `current_level` 固定）
 String get id;/// 対象期間ID（例: `2025-11`）
 String get periodId;/// 現在のレベル（整数）
 int get level;/// 小数を含む厳密なレベル
 double get exactLevel;/// 次のレベルまでの進捗率 (0-1)
 double get progressToNextLevel;/// 人が検出されていた累計秒数（当月）
 int get personSeconds;/// 次のレベル到達に必要な累計秒数
 int get requiredSecondsForNextLevel;/// 現在のランク
@JsonKey(unknownEnumValue: LevelRankTier.apprentice) LevelRankTier get rank;/// 月の開始日
 DateTime get periodStart;/// 月の終了日
 DateTime get periodEnd;/// 次回リセット日時（通常は periodEnd + 1日 0:00）
 DateTime get nextResetAt;/// 最終更新日時
 DateTime get lastUpdated;
/// Create a copy of LevelingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelingStateCopyWith<LevelingState> get copyWith => _$LevelingStateCopyWithImpl<LevelingState>(this as LevelingState, _$identity);

  /// Serializes this LevelingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelingState&&(identical(other.id, id) || other.id == id)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.level, level) || other.level == level)&&(identical(other.exactLevel, exactLevel) || other.exactLevel == exactLevel)&&(identical(other.progressToNextLevel, progressToNextLevel) || other.progressToNextLevel == progressToNextLevel)&&(identical(other.personSeconds, personSeconds) || other.personSeconds == personSeconds)&&(identical(other.requiredSecondsForNextLevel, requiredSecondsForNextLevel) || other.requiredSecondsForNextLevel == requiredSecondsForNextLevel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodId,level,exactLevel,progressToNextLevel,personSeconds,requiredSecondsForNextLevel,rank,periodStart,periodEnd,nextResetAt,lastUpdated);

@override
String toString() {
  return 'LevelingState(id: $id, periodId: $periodId, level: $level, exactLevel: $exactLevel, progressToNextLevel: $progressToNextLevel, personSeconds: $personSeconds, requiredSecondsForNextLevel: $requiredSecondsForNextLevel, rank: $rank, periodStart: $periodStart, periodEnd: $periodEnd, nextResetAt: $nextResetAt, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $LevelingStateCopyWith<$Res>  {
  factory $LevelingStateCopyWith(LevelingState value, $Res Function(LevelingState) _then) = _$LevelingStateCopyWithImpl;
@useResult
$Res call({
 String id, String periodId, int level, double exactLevel, double progressToNextLevel, int personSeconds, int requiredSecondsForNextLevel,@JsonKey(unknownEnumValue: LevelRankTier.apprentice) LevelRankTier rank, DateTime periodStart, DateTime periodEnd, DateTime nextResetAt, DateTime lastUpdated
});




}
/// @nodoc
class _$LevelingStateCopyWithImpl<$Res>
    implements $LevelingStateCopyWith<$Res> {
  _$LevelingStateCopyWithImpl(this._self, this._then);

  final LevelingState _self;
  final $Res Function(LevelingState) _then;

/// Create a copy of LevelingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodId = null,Object? level = null,Object? exactLevel = null,Object? progressToNextLevel = null,Object? personSeconds = null,Object? requiredSecondsForNextLevel = null,Object? rank = null,Object? periodStart = null,Object? periodEnd = null,Object? nextResetAt = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,exactLevel: null == exactLevel ? _self.exactLevel : exactLevel // ignore: cast_nullable_to_non_nullable
as double,progressToNextLevel: null == progressToNextLevel ? _self.progressToNextLevel : progressToNextLevel // ignore: cast_nullable_to_non_nullable
as double,personSeconds: null == personSeconds ? _self.personSeconds : personSeconds // ignore: cast_nullable_to_non_nullable
as int,requiredSecondsForNextLevel: null == requiredSecondsForNextLevel ? _self.requiredSecondsForNextLevel : requiredSecondsForNextLevel // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as LevelRankTier,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,nextResetAt: null == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelingState].
extension LevelingStatePatterns on LevelingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelingState value)  $default,){
final _that = this;
switch (_that) {
case _LevelingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelingState value)?  $default,){
final _that = this;
switch (_that) {
case _LevelingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String periodId,  int level,  double exactLevel,  double progressToNextLevel,  int personSeconds,  int requiredSecondsForNextLevel, @JsonKey(unknownEnumValue: LevelRankTier.apprentice)  LevelRankTier rank,  DateTime periodStart,  DateTime periodEnd,  DateTime nextResetAt,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelingState() when $default != null:
return $default(_that.id,_that.periodId,_that.level,_that.exactLevel,_that.progressToNextLevel,_that.personSeconds,_that.requiredSecondsForNextLevel,_that.rank,_that.periodStart,_that.periodEnd,_that.nextResetAt,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String periodId,  int level,  double exactLevel,  double progressToNextLevel,  int personSeconds,  int requiredSecondsForNextLevel, @JsonKey(unknownEnumValue: LevelRankTier.apprentice)  LevelRankTier rank,  DateTime periodStart,  DateTime periodEnd,  DateTime nextResetAt,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _LevelingState():
return $default(_that.id,_that.periodId,_that.level,_that.exactLevel,_that.progressToNextLevel,_that.personSeconds,_that.requiredSecondsForNextLevel,_that.rank,_that.periodStart,_that.periodEnd,_that.nextResetAt,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String periodId,  int level,  double exactLevel,  double progressToNextLevel,  int personSeconds,  int requiredSecondsForNextLevel, @JsonKey(unknownEnumValue: LevelRankTier.apprentice)  LevelRankTier rank,  DateTime periodStart,  DateTime periodEnd,  DateTime nextResetAt,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _LevelingState() when $default != null:
return $default(_that.id,_that.periodId,_that.level,_that.exactLevel,_that.progressToNextLevel,_that.personSeconds,_that.requiredSecondsForNextLevel,_that.rank,_that.periodStart,_that.periodEnd,_that.nextResetAt,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LevelingState extends LevelingState {
  const _LevelingState({required this.id, required this.periodId, required this.level, required this.exactLevel, required this.progressToNextLevel, this.personSeconds = 0, required this.requiredSecondsForNextLevel, @JsonKey(unknownEnumValue: LevelRankTier.apprentice) required this.rank, required this.periodStart, required this.periodEnd, required this.nextResetAt, required this.lastUpdated}): super._();
  factory _LevelingState.fromJson(Map<String, dynamic> json) => _$LevelingStateFromJson(json);

/// Firestore上のドキュメントID（原則 `current_level` 固定）
@override final  String id;
/// 対象期間ID（例: `2025-11`）
@override final  String periodId;
/// 現在のレベル（整数）
@override final  int level;
/// 小数を含む厳密なレベル
@override final  double exactLevel;
/// 次のレベルまでの進捗率 (0-1)
@override final  double progressToNextLevel;
/// 人が検出されていた累計秒数（当月）
@override@JsonKey() final  int personSeconds;
/// 次のレベル到達に必要な累計秒数
@override final  int requiredSecondsForNextLevel;
/// 現在のランク
@override@JsonKey(unknownEnumValue: LevelRankTier.apprentice) final  LevelRankTier rank;
/// 月の開始日
@override final  DateTime periodStart;
/// 月の終了日
@override final  DateTime periodEnd;
/// 次回リセット日時（通常は periodEnd + 1日 0:00）
@override final  DateTime nextResetAt;
/// 最終更新日時
@override final  DateTime lastUpdated;

/// Create a copy of LevelingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelingStateCopyWith<_LevelingState> get copyWith => __$LevelingStateCopyWithImpl<_LevelingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LevelingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelingState&&(identical(other.id, id) || other.id == id)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.level, level) || other.level == level)&&(identical(other.exactLevel, exactLevel) || other.exactLevel == exactLevel)&&(identical(other.progressToNextLevel, progressToNextLevel) || other.progressToNextLevel == progressToNextLevel)&&(identical(other.personSeconds, personSeconds) || other.personSeconds == personSeconds)&&(identical(other.requiredSecondsForNextLevel, requiredSecondsForNextLevel) || other.requiredSecondsForNextLevel == requiredSecondsForNextLevel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodId,level,exactLevel,progressToNextLevel,personSeconds,requiredSecondsForNextLevel,rank,periodStart,periodEnd,nextResetAt,lastUpdated);

@override
String toString() {
  return 'LevelingState(id: $id, periodId: $periodId, level: $level, exactLevel: $exactLevel, progressToNextLevel: $progressToNextLevel, personSeconds: $personSeconds, requiredSecondsForNextLevel: $requiredSecondsForNextLevel, rank: $rank, periodStart: $periodStart, periodEnd: $periodEnd, nextResetAt: $nextResetAt, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$LevelingStateCopyWith<$Res> implements $LevelingStateCopyWith<$Res> {
  factory _$LevelingStateCopyWith(_LevelingState value, $Res Function(_LevelingState) _then) = __$LevelingStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String periodId, int level, double exactLevel, double progressToNextLevel, int personSeconds, int requiredSecondsForNextLevel,@JsonKey(unknownEnumValue: LevelRankTier.apprentice) LevelRankTier rank, DateTime periodStart, DateTime periodEnd, DateTime nextResetAt, DateTime lastUpdated
});




}
/// @nodoc
class __$LevelingStateCopyWithImpl<$Res>
    implements _$LevelingStateCopyWith<$Res> {
  __$LevelingStateCopyWithImpl(this._self, this._then);

  final _LevelingState _self;
  final $Res Function(_LevelingState) _then;

/// Create a copy of LevelingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodId = null,Object? level = null,Object? exactLevel = null,Object? progressToNextLevel = null,Object? personSeconds = null,Object? requiredSecondsForNextLevel = null,Object? rank = null,Object? periodStart = null,Object? periodEnd = null,Object? nextResetAt = null,Object? lastUpdated = null,}) {
  return _then(_LevelingState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,exactLevel: null == exactLevel ? _self.exactLevel : exactLevel // ignore: cast_nullable_to_non_nullable
as double,progressToNextLevel: null == progressToNextLevel ? _self.progressToNextLevel : progressToNextLevel // ignore: cast_nullable_to_non_nullable
as double,personSeconds: null == personSeconds ? _self.personSeconds : personSeconds // ignore: cast_nullable_to_non_nullable
as int,requiredSecondsForNextLevel: null == requiredSecondsForNextLevel ? _self.requiredSecondsForNextLevel : requiredSecondsForNextLevel // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as LevelRankTier,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,nextResetAt: null == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LevelSnapshot {

 int get level; double get exactLevel; LevelRankTier get rank; int get personSeconds; DateTime get capturedAt;
/// Create a copy of LevelSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelSnapshotCopyWith<LevelSnapshot> get copyWith => _$LevelSnapshotCopyWithImpl<LevelSnapshot>(this as LevelSnapshot, _$identity);

  /// Serializes this LevelSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelSnapshot&&(identical(other.level, level) || other.level == level)&&(identical(other.exactLevel, exactLevel) || other.exactLevel == exactLevel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.personSeconds, personSeconds) || other.personSeconds == personSeconds)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,exactLevel,rank,personSeconds,capturedAt);

@override
String toString() {
  return 'LevelSnapshot(level: $level, exactLevel: $exactLevel, rank: $rank, personSeconds: $personSeconds, capturedAt: $capturedAt)';
}


}

/// @nodoc
abstract mixin class $LevelSnapshotCopyWith<$Res>  {
  factory $LevelSnapshotCopyWith(LevelSnapshot value, $Res Function(LevelSnapshot) _then) = _$LevelSnapshotCopyWithImpl;
@useResult
$Res call({
 int level, double exactLevel, LevelRankTier rank, int personSeconds, DateTime capturedAt
});




}
/// @nodoc
class _$LevelSnapshotCopyWithImpl<$Res>
    implements $LevelSnapshotCopyWith<$Res> {
  _$LevelSnapshotCopyWithImpl(this._self, this._then);

  final LevelSnapshot _self;
  final $Res Function(LevelSnapshot) _then;

/// Create a copy of LevelSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? exactLevel = null,Object? rank = null,Object? personSeconds = null,Object? capturedAt = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,exactLevel: null == exactLevel ? _self.exactLevel : exactLevel // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as LevelRankTier,personSeconds: null == personSeconds ? _self.personSeconds : personSeconds // ignore: cast_nullable_to_non_nullable
as int,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelSnapshot].
extension LevelSnapshotPatterns on LevelSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _LevelSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _LevelSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int level,  double exactLevel,  LevelRankTier rank,  int personSeconds,  DateTime capturedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelSnapshot() when $default != null:
return $default(_that.level,_that.exactLevel,_that.rank,_that.personSeconds,_that.capturedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int level,  double exactLevel,  LevelRankTier rank,  int personSeconds,  DateTime capturedAt)  $default,) {final _that = this;
switch (_that) {
case _LevelSnapshot():
return $default(_that.level,_that.exactLevel,_that.rank,_that.personSeconds,_that.capturedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int level,  double exactLevel,  LevelRankTier rank,  int personSeconds,  DateTime capturedAt)?  $default,) {final _that = this;
switch (_that) {
case _LevelSnapshot() when $default != null:
return $default(_that.level,_that.exactLevel,_that.rank,_that.personSeconds,_that.capturedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LevelSnapshot implements LevelSnapshot {
  const _LevelSnapshot({required this.level, required this.exactLevel, required this.rank, required this.personSeconds, required this.capturedAt});
  factory _LevelSnapshot.fromJson(Map<String, dynamic> json) => _$LevelSnapshotFromJson(json);

@override final  int level;
@override final  double exactLevel;
@override final  LevelRankTier rank;
@override final  int personSeconds;
@override final  DateTime capturedAt;

/// Create a copy of LevelSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelSnapshotCopyWith<_LevelSnapshot> get copyWith => __$LevelSnapshotCopyWithImpl<_LevelSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LevelSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelSnapshot&&(identical(other.level, level) || other.level == level)&&(identical(other.exactLevel, exactLevel) || other.exactLevel == exactLevel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.personSeconds, personSeconds) || other.personSeconds == personSeconds)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,exactLevel,rank,personSeconds,capturedAt);

@override
String toString() {
  return 'LevelSnapshot(level: $level, exactLevel: $exactLevel, rank: $rank, personSeconds: $personSeconds, capturedAt: $capturedAt)';
}


}

/// @nodoc
abstract mixin class _$LevelSnapshotCopyWith<$Res> implements $LevelSnapshotCopyWith<$Res> {
  factory _$LevelSnapshotCopyWith(_LevelSnapshot value, $Res Function(_LevelSnapshot) _then) = __$LevelSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int level, double exactLevel, LevelRankTier rank, int personSeconds, DateTime capturedAt
});




}
/// @nodoc
class __$LevelSnapshotCopyWithImpl<$Res>
    implements _$LevelSnapshotCopyWith<$Res> {
  __$LevelSnapshotCopyWithImpl(this._self, this._then);

  final _LevelSnapshot _self;
  final $Res Function(_LevelSnapshot) _then;

/// Create a copy of LevelSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? exactLevel = null,Object? rank = null,Object? personSeconds = null,Object? capturedAt = null,}) {
  return _then(_LevelSnapshot(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,exactLevel: null == exactLevel ? _self.exactLevel : exactLevel // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as LevelRankTier,personSeconds: null == personSeconds ? _self.personSeconds : personSeconds // ignore: cast_nullable_to_non_nullable
as int,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
