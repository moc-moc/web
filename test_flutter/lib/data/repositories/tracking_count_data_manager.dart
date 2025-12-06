import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/models/tracking_count_model.dart';

/// トラッキング回数用データマネージャー
/// 
/// BaseDataManager<TrackingCount>を継承して、トラッキング回数データの管理を行います。
class TrackingCountDataManager extends BaseDataManager<TrackingCount> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/tracking_counts';

  @override
  TrackingCount convertFromFirestore(Map<String, dynamic> data) {
    return TrackingCount.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(TrackingCount item) {
    return item.toFirestore();
  }

  @override
  TrackingCount convertFromJson(Map<String, dynamic> json) {
    return TrackingCount.fromJson(json);
  }

  @override
  Map<String, dynamic> convertToJson(TrackingCount item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'tracking_counts';
}

/// グローバルインスタンス
final trackingCountDataManager = TrackingCountDataManager();

