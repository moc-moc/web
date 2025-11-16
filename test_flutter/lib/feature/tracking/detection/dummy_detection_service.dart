import 'dart:typed_data';
import 'dart:math';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// ダミー検出サービス
/// 
/// 実際のAIモデルが統合されるまでの間、動作確認用に使用
/// ランダムな検出結果を返す
class DummyDetectionService implements DetectionService {
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    LogMk.logDebug(
      'ダミー検出サービス初期化完了',
      tag: 'DummyDetectionService.initialize',
    );
    return true;
  }

  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (!_isInitialized) {
      LogMk.logError(
        '検出サービスが初期化されていません',
        tag: 'DummyDetectionService.detect',
      );
      return [];
    }

    // ダミー: ランダムな検出結果を生成
    await Future.delayed(const Duration(milliseconds: 100));

    final results = <DetectionResult>[];

    // 80%の確率で何か検出
    if (_random.nextDouble() < 0.8) {
      final categories = [
        DetectionCategory.study,
        DetectionCategory.pc,
        DetectionCategory.smartphone,
        DetectionCategory.personOnly,
      ];
      
      final category = categories[_random.nextInt(categories.length)];
      final confidence = 0.7 + (_random.nextDouble() * 0.3); // 0.7〜1.0

      results.add(DetectionResult(
        category: category,
        confidence: confidence,
        timestamp: DateTime.now(),
        detectedLabels: _getLabelsForCategory(category),
      ));
    } else {
      // 20%の確率で検出なし
      results.add(DetectionResult(
        category: DetectionCategory.nothingDetected,
        confidence: _random.nextDouble() * 0.7, // 0.0〜0.7
        timestamp: DateTime.now(),
        detectedLabels: [],
      ));
    }

    return results;
  }

  /// カテゴリに対応するラベルを取得
  List<String> _getLabelsForCategory(DetectionCategory category) {
    switch (category) {
      case DetectionCategory.study:
        return ['book', 'pen', 'notebook'];
      case DetectionCategory.pc:
        return ['laptop', 'keyboard', 'mouse'];
      case DetectionCategory.smartphone:
        return ['smartphone'];
      case DetectionCategory.personOnly:
        return ['person'];
      case DetectionCategory.nothingDetected:
        return [];
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    LogMk.logDebug(
      'ダミー検出サービスリソース解放完了',
      tag: 'DummyDetectionService.dispose',
    );
  }
}

