import 'package:freezed_annotation/freezed_annotation.dart';

part 'retry_item.freezed.dart';
part 'retry_item.g.dart';

/// 送信キューのアイテムタイプ
enum RetryType {
  add,      // 追加
  update,   // 更新
  delete,   // 削除
}

/// 送信キューのステータス
enum RetryStatus {
  pending,    // 送信待ち
  processing, // 送信中
  success,    // 送信成功
  failed,     // 送信失敗
}

/// 送信キューアイテム
@freezed
abstract class RetryItem with _$RetryItem {
  const factory RetryItem({
    required String id,
    required RetryType type,
    required String userId,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    @Default(0) int retryCount,
    @Default(RetryStatus.pending) RetryStatus status,
    String? errorMessage,
    DateTime? lastRetryAt,
  }) = _RetryItem;

  factory RetryItem.fromJson(Map<String, dynamic> json) => _$RetryItemFromJson(json);
}

/// 送信キューアイテムの拡張メソッド
extension RetryItemExtension on RetryItem {
  /// 再試行可能かどうか
  bool get canRetry {
    return status == RetryStatus.failed && retryCount < 5; // 最大5回まで再試行
  }

  /// 再試行までの待機時間（指数バックオフ）
  Duration get retryDelay {
    final exponentialDelay = Duration(seconds: 30 * (1 << retryCount));
    return exponentialDelay;
  }

  /// 次の再試行時刻
  DateTime get nextRetryAt {
    return (lastRetryAt ?? timestamp).add(retryDelay);
  }

  /// 再試行可能かどうか（時間ベース）
  bool get isReadyForRetry {
    return canRetry && DateTime.now().isAfter(nextRetryAt);
  }

  /// 失敗したアイテムを再試行用に更新
  RetryItem markForRetry() {
    return copyWith(
      status: RetryStatus.pending,
      retryCount: retryCount + 1,
      lastRetryAt: DateTime.now(),
      errorMessage: null,
    );
  }

  /// 送信開始をマーク
  RetryItem markAsProcessing() {
    return copyWith(
      status: RetryStatus.processing,
    );
  }

  /// 送信成功をマーク
  RetryItem markAsSuccess() {
    return copyWith(
      status: RetryStatus.success,
    );
  }

  /// 送信失敗をマーク
  RetryItem markAsFailed(String error) {
    return copyWith(
      status: RetryStatus.failed,
      errorMessage: error,
      lastRetryAt: DateTime.now(),
    );
  }
}
