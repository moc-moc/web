import 'dart:async';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 検出プロセッサー
/// 
/// 検出結果の処理、信頼度フィルタリング、カテゴリマッピングを担当
class DetectionProcessor {
  final DetectionService _detectionService;
  
  /// 信頼度の閾値（0.7以上で有効）
  static const double _confidenceThreshold = 0.7;

  /// 検出サービスを取得（モデル切り替え用）
  DetectionService get detectionService => _detectionService;

  DetectionProcessor({
    required DetectionService detectionService,
    required CameraManager cameraManager, // 将来の拡張用に保持
  }) : _detectionService = detectionService;

  /// 検出結果をカテゴリにマッピング
  /// 
  /// **パラメータ**:
  /// - `detectedLabels`: 検出されたラベルのリスト
  /// 
  /// **戻り値**: マッピングされたカテゴリ（検出なしの場合はnull）
  DetectionCategory? _mapToCategory(List<String> detectedLabels) {
    if (detectedLabels.isEmpty) {
      return DetectionCategory.nothingDetected;
    }

    // 優先順位: 勉強 > パソコン > スマホ
    // 勉強カテゴリのラベル
    const studyLabels = ['book', 'pen', 'notebook', 'paper'];
    // PCカテゴリのラベル
    const pcLabels = ['laptop', 'desktop', 'keyboard', 'mouse', 'computer'];
    // スマホカテゴリのラベル
    const smartphoneLabels = ['smartphone', 'phone', 'mobile'];
    // 人のラベル
    const personLabels = ['person', 'human'];

    // 検出されたラベルを小文字に変換してチェック
    final lowerLabels = detectedLabels.map((label) => label.toLowerCase()).toList();

    // 優先順位に基づいてカテゴリを決定
    if (lowerLabels.any((label) => studyLabels.contains(label))) {
      return DetectionCategory.study;
    }
    if (lowerLabels.any((label) => pcLabels.contains(label))) {
      return DetectionCategory.pc;
    }
    if (lowerLabels.any((label) => smartphoneLabels.contains(label))) {
      return DetectionCategory.smartphone;
    }
    if (lowerLabels.any((label) => personLabels.contains(label))) {
      return DetectionCategory.personOnly;
    }

    return DetectionCategory.nothingDetected;
  }

  /// 画像から検出を実行
  /// 
  /// **パラメータ**:
  /// - `image`: 検出対象のカメラ画像データ
  /// 
  /// **戻り値**: 検出結果（信頼度フィルタリング済み）
  Future<DetectionResult?> processImage(CameraImageData image) async {
    try {
      // CameraImageDataをUint8Listに変換
      final imageBytes = await image.toBytes();
      
      // 検出実行
      final results = await _detectionService.detect(imageBytes);
      
      if (results.isEmpty) {
        LogMk.logDebug(
          '🔍 [DetectionProcessor] 検出結果なし',
          tag: 'DetectionProcessor.processImage',
        );
        return DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: 0.0,
          timestamp: DateTime.now(),
          detectedLabels: [],
        );
      }

      // 信頼度が最も高い結果を取得
      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      final bestResult = results.first;

      // 検出結果の詳細をログ出力
      LogMk.logDebug(
        '🔍 [DetectionProcessor] 検出結果: ${bestResult.categoryString} '
        '(信頼度: ${bestResult.confidence.toStringAsFixed(3)}, '
        '検出ラベル: ${bestResult.detectedLabels.join(", ")})',
        tag: 'DetectionProcessor.processImage',
      );

      // 信頼度フィルタリング
      if (bestResult.confidence < _confidenceThreshold) {
        LogMk.logDebug(
          '⚠️ [DetectionProcessor] 信頼度が閾値未満のため無効化 '
          '(信頼度: ${bestResult.confidence.toStringAsFixed(3)} < $_confidenceThreshold)',
          tag: 'DetectionProcessor.processImage',
        );
        return DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: bestResult.confidence,
          timestamp: DateTime.now(),
          detectedLabels: bestResult.detectedLabels,
        );
      }

      // カテゴリマッピング
      final category = _mapToCategory(bestResult.detectedLabels);

      LogMk.logDebug(
        '✅ [DetectionProcessor] 最終結果: $category '
        '(信頼度: ${bestResult.confidence.toStringAsFixed(3)}, '
        '検出ラベル: ${bestResult.detectedLabels.join(", ")})',
        tag: 'DetectionProcessor.processImage',
      );

      return DetectionResult(
        category: category,
        confidence: bestResult.confidence,
        timestamp: DateTime.now(),
        detectedLabels: bestResult.detectedLabels,
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '画像処理エラー: $e',
        tag: 'DetectionProcessor.processImage',
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

