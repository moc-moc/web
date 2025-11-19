import 'package:test_flutter/feature/tracking/detection/detection_result.dart';

/// 安定化された計測結果
/// 
/// MeasurementStabilizerによって平滑化・補正された検出結果を表現するクラス
class StabilizedMeasurement {
  /// 安定化されたカテゴリ
  final DetectionCategory? category;
  
  /// 元の検出結果
  final DetectionResult originalResult;
  
  /// 安定化された時刻
  final DateTime timestamp;
  
  /// 信頼度（補正後の信頼度）
  final double confidence;
  
  /// 状態が確定したかどうか（保留中かどうか）
  final bool isConfirmed;
  
  /// 補正が適用されたかどうか
  final bool isCorrected;
  
  /// 補正の理由
  final String? correctionReason;

  const StabilizedMeasurement({
    required this.category,
    required this.originalResult,
    required this.timestamp,
    required this.confidence,
    this.isConfirmed = true,
    this.isCorrected = false,
    this.correctionReason,
  });

  /// カテゴリを文字列に変換
  String? get categoryString {
    switch (category) {
      case DetectionCategory.study:
        return 'study';
      case DetectionCategory.pc:
        return 'pc';
      case DetectionCategory.smartphone:
        return 'smartphone';
      case DetectionCategory.personOnly:
        return 'personOnly';
      case DetectionCategory.nothingDetected:
        return 'nothingDetected';
      case null:
        return null;
    }
  }
}

