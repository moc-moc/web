/// 検出結果のモデル
/// 
/// AI検出によって得られた結果を表現するクラス
library;

/// 検出された物体のカテゴリ
enum DetectionCategory {
  /// 本、ペン、ノート
  study,
  
  /// PC、デスクトップ、キーボード、マウス
  pc,
  
  /// スマホ
  smartphone,
  
  /// 人のみ検出
  personOnly,
  
  /// 検出なし
  nothingDetected,
}

/// 検出結果
class DetectionResult {
  /// 検出されたカテゴリ
  final DetectionCategory? category;
  
  /// 信頼度（0.0〜1.0）
  final double confidence;
  
  /// 検出時刻
  final DateTime timestamp;
  
  /// 検出されたラベル（複数検出時は優先順位に基づく）
  final List<String> detectedLabels;

  const DetectionResult({
    required this.category,
    required this.confidence,
    required this.timestamp,
    required this.detectedLabels,
  });

  /// 有効な検出結果かどうか（信頼度0.7以上）
  bool get isValid => confidence >= 0.7 && category != null;

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

