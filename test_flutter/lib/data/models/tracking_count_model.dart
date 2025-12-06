import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking_count_model.freezed.dart';
part 'tracking_count_model.g.dart';

/// トラッキング回数モデル
/// 
/// 日付ごとのトラッキング回数を管理します。
@freezed
abstract class TrackingCount with _$TrackingCount {
  const TrackingCount._();

  const factory TrackingCount({
    /// 日付（YYYY-MM-DD形式）
    required String id,
    /// トラッキング回数
    required int count,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _TrackingCount;

  /// JSON形式から生成
  factory TrackingCount.fromJson(Map<String, dynamic> json) =>
      _$TrackingCountFromJson(json);

  /// Firestoreデータから生成
  factory TrackingCount.fromFirestore(Map<String, dynamic> data) {
    return TrackingCount(
      id: data['id'] as String? ?? '',
      count: data['count'] as int? ?? 0,
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': this.id,
      'count': this.count,
      'lastModified': Timestamp.fromDate(this.lastModified),
    };
  }
}

