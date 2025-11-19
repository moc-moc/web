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
  
  /// person以外のオブジェクトの信頼度閾値（低めに設定して重要視）
  static const double _nonPersonConfidenceThreshold = 0.5;

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
    const smartphoneLabels = [
      'smartphone',
      'phone',
      'mobile',
      'cell phone',
      'cellphone',
      'mobile phone',
    ];
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

  /// 複数の検出結果から最適なカテゴリを決定
  /// 
  /// person以外のオブジェクトが検出された場合、それを優先的に選択する
  /// personとcell phoneが両方検出された場合、smartphoneを優先する
  /// 
  /// **パラメータ**:
  /// - `results`: 検出結果のリスト
  /// 
  /// **戻り値**: 最適な検出結果
  DetectionResult? _selectBestCategory(List<DetectionResult> results) {
    if (results.isEmpty) {
      return null;
    }

    // 信頼度でソート（元のリストを変更しないようにコピーを作成）
    final sortedResults = List<DetectionResult>.from(results);
    sortedResults.sort((a, b) => b.confidence.compareTo(a.confidence));

    // person以外のオブジェクトのラベル定義
    const studyLabels = ['book', 'pen', 'notebook', 'paper'];
    const pcLabels = ['laptop', 'desktop', 'keyboard', 'mouse', 'computer'];
    const smartphoneLabels = [
      'smartphone',
      'phone',
      'mobile',
      'cell phone',
      'cellphone',
      'mobile phone',
    ];
    const personLabels = ['person', 'human'];

    // 信頼度閾値を超えた結果を収集
    final validResults = sortedResults.where((r) => 
      r.confidence >= _confidenceThreshold
    ).toList();

    // person以外のオブジェクトで、信頼度閾値を下げた結果も収集
    final nonPersonResults = sortedResults.where((r) {
      if (r.confidence < _nonPersonConfidenceThreshold) {
        return false;
      }
      final lowerLabels = r.detectedLabels.map((l) => l.toLowerCase()).toList();
      return lowerLabels.any((label) => 
        studyLabels.contains(label) ||
        pcLabels.contains(label) ||
        smartphoneLabels.contains(label)
      );
    }).toList();

    // personとcell phoneが両方検出されているかチェック
    bool hasPerson = false;
    bool hasCellPhone = false;
    DetectionResult? cellPhoneResult;
    List<String> combinedLabels = [];

    for (final result in sortedResults) {
      if (result.confidence < _nonPersonConfidenceThreshold) {
        continue;
      }
      final lowerLabels = result.detectedLabels.map((l) => l.toLowerCase()).toList();
      
      if (lowerLabels.any((label) => personLabels.contains(label))) {
        hasPerson = true;
        combinedLabels.addAll(result.detectedLabels);
      }
      if (lowerLabels.any((label) => smartphoneLabels.contains(label))) {
        hasCellPhone = true;
        cellPhoneResult = result;
        combinedLabels.addAll(result.detectedLabels);
      }
    }

    // personとcell phoneが両方検出された場合、smartphoneを優先
    if (hasPerson && hasCellPhone && cellPhoneResult != null) {
      // 重複を除去してラベルを結合
      final uniqueLabels = combinedLabels.toSet().toList();
      return DetectionResult(
        category: DetectionCategory.smartphone,
        confidence: cellPhoneResult.confidence,
        timestamp: cellPhoneResult.timestamp,
        detectedLabels: uniqueLabels,
      );
    }

    // person以外のオブジェクトが検出された場合、それを優先
    if (nonPersonResults.isNotEmpty) {
      // 信頼度が最も高いperson以外のオブジェクトを選択
      nonPersonResults.sort((a, b) => b.confidence.compareTo(a.confidence));
      final bestNonPerson = nonPersonResults.first;
      final category = _mapToCategory(bestNonPerson.detectedLabels);
      return DetectionResult(
        category: category,
        confidence: bestNonPerson.confidence,
        timestamp: bestNonPerson.timestamp,
        detectedLabels: bestNonPerson.detectedLabels,
      );
    }

    // 通常の信頼度閾値を超えた結果がある場合
    if (validResults.isNotEmpty) {
      final bestResult = validResults.first;
      final category = _mapToCategory(bestResult.detectedLabels);
      return DetectionResult(
        category: category,
        confidence: bestResult.confidence,
        timestamp: bestResult.timestamp,
        detectedLabels: bestResult.detectedLabels,
      );
    }

    // すべての結果が閾値を下回る場合
    final bestResult = sortedResults.first;
    return DetectionResult(
      category: DetectionCategory.nothingDetected,
      confidence: bestResult.confidence,
      timestamp: bestResult.timestamp,
      detectedLabels: bestResult.detectedLabels,
    );
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
        return DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: 0.0,
          timestamp: DateTime.now(),
          detectedLabels: [],
        );
      }

      // 複数の検出結果から最適なカテゴリを決定
      final bestResult = _selectBestCategory(results);
      
      if (bestResult == null) {
        LogMk.logDebug(
          '✅ [最終判定] nothingDetected (検出なし)',
          tag: 'DetectionProcessor.processImage',
        );
        return DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: 0.0,
          timestamp: DateTime.now(),
          detectedLabels: [],
        );
      }

      // 最終判定のログを出力
      final allLabels = results.expand((r) => r.detectedLabels).toSet().toList();
      LogMk.logDebug(
        '✅ [最終判定] ${bestResult.categoryString ?? 'nothingDetected'} (検出ラベル: ${allLabels.join(', ')})',
        tag: 'DetectionProcessor.processImage',
      );

      return bestResult;
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

