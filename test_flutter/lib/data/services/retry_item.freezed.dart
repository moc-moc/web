// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RetryItem {

 String get id; RetryType get type; String get userId; Map<String, dynamic> get data; DateTime get timestamp; int get retryCount; RetryStatus get status; String? get errorMessage; DateTime? get lastRetryAt;
/// Create a copy of RetryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetryItemCopyWith<RetryItem> get copyWith => _$RetryItemCopyWithImpl<RetryItem>(this as RetryItem, _$identity);

  /// Serializes this RetryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastRetryAt, lastRetryAt) || other.lastRetryAt == lastRetryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,userId,const DeepCollectionEquality().hash(data),timestamp,retryCount,status,errorMessage,lastRetryAt);

@override
String toString() {
  return 'RetryItem(id: $id, type: $type, userId: $userId, data: $data, timestamp: $timestamp, retryCount: $retryCount, status: $status, errorMessage: $errorMessage, lastRetryAt: $lastRetryAt)';
}


}

/// @nodoc
abstract mixin class $RetryItemCopyWith<$Res>  {
  factory $RetryItemCopyWith(RetryItem value, $Res Function(RetryItem) _then) = _$RetryItemCopyWithImpl;
@useResult
$Res call({
 String id, RetryType type, String userId, Map<String, dynamic> data, DateTime timestamp, int retryCount, RetryStatus status, String? errorMessage, DateTime? lastRetryAt
});




}
/// @nodoc
class _$RetryItemCopyWithImpl<$Res>
    implements $RetryItemCopyWith<$Res> {
  _$RetryItemCopyWithImpl(this._self, this._then);

  final RetryItem _self;
  final $Res Function(RetryItem) _then;

/// Create a copy of RetryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? userId = null,Object? data = null,Object? timestamp = null,Object? retryCount = null,Object? status = null,Object? errorMessage = freezed,Object? lastRetryAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RetryType,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RetryStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastRetryAt: freezed == lastRetryAt ? _self.lastRetryAt : lastRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RetryItem].
extension RetryItemPatterns on RetryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RetryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RetryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RetryItem value)  $default,){
final _that = this;
switch (_that) {
case _RetryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RetryItem value)?  $default,){
final _that = this;
switch (_that) {
case _RetryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RetryType type,  String userId,  Map<String, dynamic> data,  DateTime timestamp,  int retryCount,  RetryStatus status,  String? errorMessage,  DateTime? lastRetryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RetryItem() when $default != null:
return $default(_that.id,_that.type,_that.userId,_that.data,_that.timestamp,_that.retryCount,_that.status,_that.errorMessage,_that.lastRetryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RetryType type,  String userId,  Map<String, dynamic> data,  DateTime timestamp,  int retryCount,  RetryStatus status,  String? errorMessage,  DateTime? lastRetryAt)  $default,) {final _that = this;
switch (_that) {
case _RetryItem():
return $default(_that.id,_that.type,_that.userId,_that.data,_that.timestamp,_that.retryCount,_that.status,_that.errorMessage,_that.lastRetryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RetryType type,  String userId,  Map<String, dynamic> data,  DateTime timestamp,  int retryCount,  RetryStatus status,  String? errorMessage,  DateTime? lastRetryAt)?  $default,) {final _that = this;
switch (_that) {
case _RetryItem() when $default != null:
return $default(_that.id,_that.type,_that.userId,_that.data,_that.timestamp,_that.retryCount,_that.status,_that.errorMessage,_that.lastRetryAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RetryItem implements RetryItem {
  const _RetryItem({required this.id, required this.type, required this.userId, required final  Map<String, dynamic> data, required this.timestamp, this.retryCount = 0, this.status = RetryStatus.pending, this.errorMessage, this.lastRetryAt}): _data = data;
  factory _RetryItem.fromJson(Map<String, dynamic> json) => _$RetryItemFromJson(json);

@override final  String id;
@override final  RetryType type;
@override final  String userId;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override final  DateTime timestamp;
@override@JsonKey() final  int retryCount;
@override@JsonKey() final  RetryStatus status;
@override final  String? errorMessage;
@override final  DateTime? lastRetryAt;

/// Create a copy of RetryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RetryItemCopyWith<_RetryItem> get copyWith => __$RetryItemCopyWithImpl<_RetryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RetryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RetryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastRetryAt, lastRetryAt) || other.lastRetryAt == lastRetryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,userId,const DeepCollectionEquality().hash(_data),timestamp,retryCount,status,errorMessage,lastRetryAt);

@override
String toString() {
  return 'RetryItem(id: $id, type: $type, userId: $userId, data: $data, timestamp: $timestamp, retryCount: $retryCount, status: $status, errorMessage: $errorMessage, lastRetryAt: $lastRetryAt)';
}


}

/// @nodoc
abstract mixin class _$RetryItemCopyWith<$Res> implements $RetryItemCopyWith<$Res> {
  factory _$RetryItemCopyWith(_RetryItem value, $Res Function(_RetryItem) _then) = __$RetryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, RetryType type, String userId, Map<String, dynamic> data, DateTime timestamp, int retryCount, RetryStatus status, String? errorMessage, DateTime? lastRetryAt
});




}
/// @nodoc
class __$RetryItemCopyWithImpl<$Res>
    implements _$RetryItemCopyWith<$Res> {
  __$RetryItemCopyWithImpl(this._self, this._then);

  final _RetryItem _self;
  final $Res Function(_RetryItem) _then;

/// Create a copy of RetryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? userId = null,Object? data = null,Object? timestamp = null,Object? retryCount = null,Object? status = null,Object? errorMessage = freezed,Object? lastRetryAt = freezed,}) {
  return _then(_RetryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RetryType,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RetryStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastRetryAt: freezed == lastRetryAt ? _self.lastRetryAt : lastRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
