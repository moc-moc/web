import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';

part 'session_info_model.freezed.dart';
part 'session_info_model.g.dart';

/// セッション情報モデル
/// 
/// DailyStatisticsに保存するセッション情報を管理します。
/// TrackingSessionの主要情報を保持する軽量モデルです。
@freezed
abstract class SessionInfo with _$SessionInfo {
  const factory SessionInfo({
    /// セッションID
    required String id,
    
    /// セッション開始時刻
    required DateTime startTime,
    
    /// セッション終了時刻
    required DateTime endTime,
    
    /// カテゴリ別の時間（秒単位）
    required Map<String, int> categorySeconds,
    
    /// 検出期間のリスト（時系列データ）
    @Default([]) List<DetectionPeriod> detectionPeriods,
    
    /// 最終更新日時
    required DateTime lastModified,
  }) = _SessionInfo;

  /// プライベートコンストラクタ（カスタムメソッド用）
  const SessionInfo._();

  /// JSONからSessionInfoを生成
  factory SessionInfo.fromJson(Map<String, dynamic> json) =>
      _$SessionInfoFromJson(json);

  /// FirestoreデータからSessionInfoを生成
  factory SessionInfo.fromFirestore(Map<String, dynamic> data) {
    return SessionInfo(
      id: data['id'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      categorySeconds: Map<String, int>.from(data['categorySeconds'] as Map),
      detectionPeriods: (data['detectionPeriods'] as List<dynamic>?)
              ?.map((e) => DetectionPeriod.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'categorySeconds': categorySeconds,
      'detectionPeriods': detectionPeriods.map((e) => e.toFirestore()).toList(),
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  /// TrackingSessionからSessionInfoを生成
  factory SessionInfo.fromTrackingSession(TrackingSession session) {
    return SessionInfo(
      id: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      categorySeconds: Map<String, int>.from(session.categorySeconds),
      detectionPeriods: List<DetectionPeriod>.from(session.detectionPeriods),
      lastModified: session.lastModified,
    );
  }
}

