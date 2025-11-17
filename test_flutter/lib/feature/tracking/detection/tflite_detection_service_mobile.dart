import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// TensorFlow Liteを使った物体検出サービス（モバイル用）
/// 
/// EfficientDet-Lite2またはYOLOv8/YOLOv11モデルを使用して物体検出を実行
class TFLiteDetectionService implements DetectionService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  /// モデルの入力サイズ
  static const int _inputSize = 640; // YOLO標準サイズ
  
  /// 信頼度の閾値
  static const double _confidenceThreshold = 0.7;
  
  /// IoU閾値（重複検出の除去用）
  static const double _iouThreshold = 0.5;
  
  @override
  Future<bool> initialize() async {
    try {
      LogMk.logDebug(
        'TensorFlow Liteモデルの初期化を開始',
        tag: 'TFLiteDetectionService.initialize',
      );
      
      // モデルファイルの読み込み
      // ONNX版のyolo11l.onnxがある場合、TFLite版は不要な可能性が高い
      // TFLite版を使用する場合は、ONNX版をTFLiteに変換する必要があります
      try {
        _interpreter = await Interpreter.fromAsset('assets/models/yolo11l.tflite');
      } catch (e) {
        LogMk.logDebug(
          'YOLO11l（large）モデルが見つかりません。他のバリエーションを試行します: $e',
          tag: 'TFLiteDetectionService.initialize',
        );
        // フォールバック: nano版を試行（軽量版）
        try {
          _interpreter = await Interpreter.fromAsset('assets/models/yolo11n.tflite');
        } catch (e) {
          // 最後の手段: EfficientDet-Lite2
          try {
            _interpreter = await Interpreter.fromAsset('assets/models/efficientdet_lite2.tflite');
          } catch (e) {
            LogMk.logError(
              'モデルファイルの読み込みに失敗: $e',
              tag: 'TFLiteDetectionService.initialize',
            );
            return false;
          }
        }
      }
      
      // ラベルファイルの読み込み
      _labels = await _loadLabels();
      
      if (_labels == null || _labels!.isEmpty) {
        LogMk.logError(
          'ラベルファイルの読み込みに失敗',
          tag: 'TFLiteDetectionService.initialize',
        );
        return false;
      }
      
      LogMk.logDebug(
        'TensorFlow Lite初期化完了 (ラベル数: ${_labels!.length})',
        tag: 'TFLiteDetectionService.initialize',
      );
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'TensorFlow Lite初期化エラー: $e',
        tag: 'TFLiteDetectionService.initialize',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// ラベルファイルを読み込み
  Future<List<String>> _loadLabels() async {
    try {
      // COCOデータセットの標準ラベル（80クラス）
      // 実際のアプリでは、assets/models/labels.txtから読み込むべき
      return [
        'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat',
        'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat',
        'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
        'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball',
        'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
        'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
        'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair',
        'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse',
        'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator',
        'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'
      ];
    } catch (e, stackTrace) {
      LogMk.logError(
        'ラベル読み込みエラー: $e',
        tag: 'TFLiteDetectionService._loadLabels',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (_interpreter == null || _labels == null) {
      LogMk.logError(
        'モデルまたはラベルが初期化されていません',
        tag: 'TFLiteDetectionService.detect',
      );
      return [];
    }
    
    try {
      // 画像をデコード
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        LogMk.logError(
          '画像のデコードに失敗',
          tag: 'TFLiteDetectionService.detect',
        );
        return [];
      }
      
      // 画像を前処理（リサイズ＋正規化）
      final inputTensor = _preprocessImage(image);
      
      // 推論実行
      final outputs = _runInference(inputTensor);
      
      // 検出結果を解析
      final detections = _parseOutputs(outputs);
      
      // 検出されたラベルをカテゴリにマッピング
      final results = _mapToDetectionResults(detections);
      
      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '検出処理エラー: $e',
        tag: 'TFLiteDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// 画像を前処理（リサイズ＋正規化）
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // 画像をリサイズ
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    
    // 正規化（0-255 → 0.0-1.0）
    final input = List.generate(
      1,
      (batch) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    
    return input;
  }
  
  /// 推論を実行
  Map<int, Object> _runInference(List<List<List<List<double>>>> input) {
    // YOLOv8/YOLOv11の出力形式: [1, 84, 8400]
    // - 1: バッチサイズ
    // - 84: [x, y, w, h, class0_conf, class1_conf, ..., class79_conf]
    // - 8400: 検出候補数（80x80 + 40x40 + 20x20 = 8400）
    
    final output = List.filled(1 * 84 * 8400, 0.0).reshape([1, 84, 8400]);
    
    _interpreter!.run(input, output);
    
    return {0: output};
  }
  
  /// 検出結果を解析
  List<Detection> _parseOutputs(Map<int, Object> outputs) {
    final output = outputs[0] as List;
    final detections = <Detection>[];
    
    // YOLOv8/YOLOv11の出力形式を解析
    // output[0][84][8400]
    final batch = output[0];
    final numDetections = batch[0].length; // 8400
    
    for (int i = 0; i < numDetections; i++) {
      // バウンディングボックス座標
      final x = batch[0][i];
      final y = batch[1][i];
      final w = batch[2][i];
      final h = batch[3][i];
      
      // クラススコアを取得（4番目以降の80クラス分）
      final classScores = <double>[];
      for (int classIdx = 0; classIdx < 80; classIdx++) {
        classScores.add(batch[4 + classIdx][i]);
      }
      
      // 最も高いスコアのクラスを取得
      double maxScore = 0.0;
      int maxClassIdx = 0;
      for (int j = 0; j < classScores.length; j++) {
        if (classScores[j] > maxScore) {
          maxScore = classScores[j];
          maxClassIdx = j;
        }
      }
      
      // 信頼度が閾値以上の場合のみ追加
      if (maxScore >= _confidenceThreshold) {
        detections.add(Detection(
          label: _labels![maxClassIdx],
          confidence: maxScore,
          boundingBox: [x, y, w, h],
        ));
      }
    }
    
    // NMS（Non-Maximum Suppression）で重複を除去
    final filteredDetections = _applyNMS(detections);
    
    return filteredDetections;
  }
  
  /// Non-Maximum Suppression（重複検出の除去）
  List<Detection> _applyNMS(List<Detection> detections) {
    if (detections.isEmpty) return [];
    
    // 信頼度でソート（降順）
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    final selected = <Detection>[];
    final suppressed = <bool>[];
    
    for (int i = 0; i < detections.length; i++) {
      suppressed.add(false);
    }
    
    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      
      selected.add(detections[i]);
      
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        
        final iou = _calculateIoU(
          detections[i].boundingBox,
          detections[j].boundingBox,
        );
        
        if (iou > _iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    
    return selected;
  }
  
  /// IoU（Intersection over Union）を計算
  double _calculateIoU(List<double> box1, List<double> box2) {
    final x1 = box1[0] - box1[2] / 2;
    final y1 = box1[1] - box1[3] / 2;
    final x2 = box1[0] + box1[2] / 2;
    final y2 = box1[1] + box1[3] / 2;
    
    final x1_ = box2[0] - box2[2] / 2;
    final y1_ = box2[1] - box2[3] / 2;
    final x2_ = box2[0] + box2[2] / 2;
    final y2_ = box2[1] + box2[3] / 2;
    
    final intersectionX1 = x1 > x1_ ? x1 : x1_;
    final intersectionY1 = y1 > y1_ ? y1 : y1_;
    final intersectionX2 = x2 < x2_ ? x2 : x2_;
    final intersectionY2 = y2 < y2_ ? y2 : y2_;
    
    final intersectionWidth = (intersectionX2 - intersectionX1).clamp(0.0, double.infinity);
    final intersectionHeight = (intersectionY2 - intersectionY1).clamp(0.0, double.infinity);
    final intersectionArea = intersectionWidth * intersectionHeight;
    
    final box1Area = box1[2] * box1[3];
    final box2Area = box2[2] * box2[3];
    final unionArea = box1Area + box2Area - intersectionArea;
    
    return intersectionArea / unionArea;
  }
  
  /// 検出結果をDetectionResultにマッピング
  List<DetectionResult> _mapToDetectionResults(List<Detection> detections) {
    if (detections.isEmpty) {
      return [
        DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: 0.0,
          timestamp: DateTime.now(),
          detectedLabels: [],
        ),
      ];
    }
    
    // 検出されたラベルを集約
    final detectedLabels = detections.map((d) => d.label).toList();
    
    // 最も信頼度の高い検出結果を返す
    final bestDetection = detections.first;
    
    return [
      DetectionResult(
        category: _inferCategory(detectedLabels),
        confidence: bestDetection.confidence,
        timestamp: DateTime.now(),
        detectedLabels: detectedLabels,
      ),
    ];
  }
  
  /// ラベルからカテゴリを推定
  DetectionCategory _inferCategory(List<String> labels) {
    // 優先順位: 勉強 > パソコン > スマホ > 人
    const studyLabels = ['book', 'pen', 'notebook', 'paper'];
    const pcLabels = ['laptop', 'keyboard', 'mouse', 'computer', 'tv'];
    const smartphoneLabels = ['cell phone', 'phone', 'mobile'];
    const personLabels = ['person', 'human'];
    
    final lowerLabels = labels.map((l) => l.toLowerCase()).toList();
    
    if (lowerLabels.any((l) => studyLabels.contains(l))) {
      return DetectionCategory.study;
    }
    if (lowerLabels.any((l) => pcLabels.contains(l))) {
      return DetectionCategory.pc;
    }
    if (lowerLabels.any((l) => smartphoneLabels.contains(l))) {
      return DetectionCategory.smartphone;
    }
    if (lowerLabels.any((l) => personLabels.contains(l))) {
      return DetectionCategory.personOnly;
    }
    
    return DetectionCategory.nothingDetected;
  }
  
  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    
    LogMk.logDebug(
      'TensorFlow Liteリソース解放完了',
      tag: 'TFLiteDetectionService.dispose',
    );
  }
}

/// 検出結果（内部データ構造）
class Detection {
  final String label;
  final double confidence;
  final List<double> boundingBox; // [x, y, width, height]
  
  Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}

