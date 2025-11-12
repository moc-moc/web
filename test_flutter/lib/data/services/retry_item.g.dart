// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RetryItem _$RetryItemFromJson(Map<String, dynamic> json) => _RetryItem(
  id: json['id'] as String,
  type: $enumDecode(_$RetryTypeEnumMap, json['type']),
  userId: json['userId'] as String,
  data: json['data'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
  retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$RetryStatusEnumMap, json['status']) ??
      RetryStatus.pending,
  errorMessage: json['errorMessage'] as String?,
  lastRetryAt: json['lastRetryAt'] == null
      ? null
      : DateTime.parse(json['lastRetryAt'] as String),
);

Map<String, dynamic> _$RetryItemToJson(_RetryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RetryTypeEnumMap[instance.type]!,
      'userId': instance.userId,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'retryCount': instance.retryCount,
      'status': _$RetryStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'lastRetryAt': instance.lastRetryAt?.toIso8601String(),
    };

const _$RetryTypeEnumMap = {
  RetryType.add: 'add',
  RetryType.update: 'update',
  RetryType.delete: 'delete',
};

const _$RetryStatusEnumMap = {
  RetryStatus.pending: 'pending',
  RetryStatus.processing: 'processing',
  RetryStatus.success: 'success',
  RetryStatus.failed: 'failed',
};
