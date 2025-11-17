import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// ONNX Runtimeを使った物体検出サービス（モバイル版）
/// 
/// YOLOv11またはYOLOv8モデルを使用して物体検出を実行
class ONNXDetectionService implements DetectionService {
  OrtSession? _session;
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
        'ONNX Runtimeモデルの初期化を開始',
        tag: 'ONNXDetectionService.initialize',
      );
      
      // ONNX Runtimeの初期化
      OrtEnv.instance.init();
      
      // モデルファイルの読み込み（優先順位: medium → large → nano）
      final modelPaths = [
        'assets/models/yolo11m.onnx',  // YOLO11m（推奨：精度とスピードのバランス）
        'assets/models/yolo11l.onnx',  // YOLO11l（高精度）
        'assets/models/yolo11n.onnx',  // YOLO11n（軽量版）
      ];
      
      late File modelFile;
      bool modelLoaded = false;
      String? loadedModelPath;
      
      for (final modelPath in modelPaths) {
        try {
          LogMk.logDebug(
            'モデル読み込み試行: $modelPath',
            tag: 'ONNXDetectionService.initialize',
          );
          
          modelFile = await _loadModelFromAsset(modelPath);
          final sessionOptions = OrtSessionOptions();
          _session = OrtSession.fromFile(modelFile, sessionOptions);
          
          loadedModelPath = modelPath;
          modelLoaded = true;
          
          LogMk.logDebug(
            'モデル読み込み成功: $modelPath',
            tag: 'ONNXDetectionService.initialize',
          );
          break;
        } catch (e) {
          LogMk.logDebug(
            'モデル読み込み失敗、次を試行: $modelPath - $e',
            tag: 'ONNXDetectionService.initialize',
          );
          continue;
        }
      }
      
      if (!modelLoaded) {
        LogMk.logError(
          'すべてのモデルの読み込みに失敗',
          tag: 'ONNXDetectionService.initialize',
        );
        return false;
      }
      
      // ラベルファイルの読み込み
      _labels = await _loadLabels();
      
      if (_labels == null || _labels!.isEmpty) {
        LogMk.logError(
          'ラベルファイルの読み込みに失敗',
          tag: 'ONNXDetectionService.initialize',
        );
        return false;
      }
      
      // 使用モデル名を抽出して表示
      final modelName = loadedModelPath?.split('/').last.replaceAll('.onnx', '') ?? 'unknown';
      LogMk.logDebug(
        'ONNX Runtime初期化完了 (モデル: $modelName, ラベル数: ${_labels!.length})',
        tag: 'ONNXDetectionService.initialize',
      );
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'ONNX Runtime初期化エラー: $e',
        tag: 'ONNXDetectionService.initialize',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// assetからモデルファイルを一時ファイルにコピー
  Future<File> _loadModelFromAsset(String assetPath) async {
    try {
      // assetからバイトデータを読み込み
      final byteData = await rootBundle.load(assetPath);
      
      // 一時ディレクトリにファイルを作成
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      
      // バイトデータをファイルに書き込み
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      rethrow;
    }
  }
  
  /// ラベルファイルを読み込み
  Future<List<String>> _loadLabels() async {
    try {
      // COCOデータセットの標準ラベル（80クラス）
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
        tag: 'ONNXDetectionService._loadLabels',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (_session == null || _labels == null) {
      LogMk.logError(
        'モデルまたはラベルが初期化されていません',
        tag: 'ONNXDetectionService.detect',
      );
      return [];
    }
    
    try {
      // 画像をデコード
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        LogMk.logError(
          '画像のデコードに失敗',
          tag: 'ONNXDetectionService.detect',
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
        tag: 'ONNXDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// 画像を前処理（リサイズ＋正規化）
  OrtValueTensor _preprocessImage(img.Image image) {
    // 画像をリサイズ
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    
    // 正規化（0-255 → 0.0-1.0）してFloat32配列に変換
    final inputData = Float32List(_inputSize * _inputSize * 3);
    int pixelIndex = 0;
    
    // YOLOの入力形式: [1, 3, 640, 640] (NCHW形式)
    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          double value;
          if (c == 0) {
            value = pixel.r / 255.0;
          } else if (c == 1) {
            value = pixel.g / 255.0;
          } else {
            value = pixel.b / 255.0;
          }
          inputData[pixelIndex++] = value;
        }
      }
    }
    
    return OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, _inputSize, _inputSize],
    );
  }
  
  /// 推論を実行
  List<OrtValue?> _runInference(OrtValueTensor input) {
    final inputName = _session!.inputNames.first;
    final outputs = _session!.run(
      OrtRunOptions(),
      {inputName: input},
    );
    
    return outputs;
  }
  
  /// 検出結果を解析
  List<Detection> _parseOutputs(List<OrtValue?> outputs) {
    if (outputs.isEmpty || outputs.first == null) {
      return [];
    }
    
    final output = outputs.first as OrtValueTensor;
    final outputData = output.value as List;
    
    final detections = <Detection>[];
    
    // YOLOv8/YOLOv11の出力形式を解析
    // output shape: [1, 84, 8400]
    // - 1: バッチサイズ
    // - 84: [x, y, w, h, class0_conf, class1_conf, ..., class79_conf]
    // - 8400: 検出候補数
    
    final batch = outputData[0];
    final numDetections = batch[0].length; // 8400
    
    for (int i = 0; i < numDetections; i++) {
      // バウンディングボックス座標
      final x = batch[0][i] as double;
      final y = batch[1][i] as double;
      final w = batch[2][i] as double;
      final h = batch[3][i] as double;
      
      // クラススコアを取得（4番目以降の80クラス分）
      final classScores = <double>[];
      for (int classIdx = 0; classIdx < 80; classIdx++) {
        classScores.add(batch[4 + classIdx][i] as double);
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
    
    // 検出結果のサマリーをログ出力
    LogMk.logDebug(
      '✅ [ONNXDetectionService] 検出完了: 候補数 → NMS後${filteredDetections.length}個',
      tag: 'ONNXDetectionService._parseOutputs',
    );
    
    // NMS後の各検出結果をログ出力（デバッグ用）
    if (filteredDetections.isNotEmpty) {
      LogMk.logDebug(
        '🔍 [ONNXDetectionService] NMS後の検出結果一覧:',
        tag: 'ONNXDetectionService._parseOutputs',
      );
      for (int i = 0; i < filteredDetections.length; i++) {
        final det = filteredDetections[i];
        LogMk.logDebug(
          '  #${i + 1}: ${det.label} (信頼度: ${det.confidence.toStringAsFixed(3)})',
          tag: 'ONNXDetectionService._parseOutputs',
        );
      }
    }
    
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
    
    // すべての検出結果をログに出力（省電力モード用）
    LogMk.logDebug(
      '🔍 [ONNXDetectionService] ===== 検出結果詳細 =====',
      tag: 'ONNXDetectionService._mapToDetectionResults',
    );
    LogMk.logDebug(
      '🔍 [ONNXDetectionService] 検出数: ${detections.length}個 (NMS後)',
      tag: 'ONNXDetectionService._mapToDetectionResults',
    );
    
    // すべての検出結果を信頼度順にログ出力
    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      LogMk.logDebug(
        '🔍 [ONNXDetectionService] #${i + 1}: ${detection.label} (信頼度: ${detection.confidence.toStringAsFixed(3)}, バウンディングボックス: [${detection.boundingBox[0].toStringAsFixed(1)}, ${detection.boundingBox[1].toStringAsFixed(1)}, ${detection.boundingBox[2].toStringAsFixed(1)}, ${detection.boundingBox[3].toStringAsFixed(1)}])',
        tag: 'ONNXDetectionService._mapToDetectionResults',
      );
    }
    
    LogMk.logDebug(
      '🔍 [ONNXDetectionService] 検出ラベル一覧: ${detectedLabels.join(", ")}',
      tag: 'ONNXDetectionService._mapToDetectionResults',
    );
    
    // 最も信頼度の高い検出結果を返す
    final bestDetection = detections.first;
    
    LogMk.logDebug(
      '🔍 [ONNXDetectionService] 選択された検出: ${bestDetection.label} (信頼度: ${bestDetection.confidence.toStringAsFixed(3)})',
      tag: 'ONNXDetectionService._mapToDetectionResults',
    );
    LogMk.logDebug(
      '🔍 [ONNXDetectionService] ========================',
      tag: 'ONNXDetectionService._mapToDetectionResults',
    );
    
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
  Future<bool> switchModel({required bool powerSavingMode}) async {
    try {
      LogMk.logDebug(
        '🔄 [ONNXDetectionService] モデル切り替え開始 (省電力モード: $powerSavingMode)',
        tag: 'ONNXDetectionService.switchModel',
      );
      
      // 現在のセッションを解放
      _session?.release();
      _session = null;
      
      // 省電力モードに応じてモデルを選択
      // 省電力ON（10秒間隔）→ yolo11l（高精度、時間的余裕あり）
      // 省電力OFF（3秒間隔）→ yolo11m（バランス、閾値0.7で高精度化）
      final modelPaths = powerSavingMode
          ? [
              'assets/models/yolo11l.onnx',  // 高精度版（省電力モード用）
              'assets/models/yolo11m.onnx',  // フォールバック
            ]
          : [
              'assets/models/yolo11m.onnx',  // バランス版（通常モード用）
              'assets/models/yolo11l.onnx',  // フォールバック
            ];
      
      late File modelFile;
      bool modelLoaded = false;
      String? loadedModelPath;
      
      for (final modelPath in modelPaths) {
        try {
          LogMk.logDebug(
            'モデル読み込み試行: $modelPath',
            tag: 'ONNXDetectionService.switchModel',
          );
          
          final loadStartTime = DateTime.now();
          modelFile = await _loadModelFromAsset(modelPath);
          final sessionOptions = OrtSessionOptions();
          _session = OrtSession.fromFile(modelFile, sessionOptions);
          final loadDuration = DateTime.now().difference(loadStartTime).inMilliseconds;
          
          loadedModelPath = modelPath;
          modelLoaded = true;
          
          final modelName = modelPath.split('/').last.replaceAll('.onnx', '');
          LogMk.logDebug(
            '✅ モデル切り替え成功: $modelName (所要時間: ${loadDuration}ms, 省電力モード: $powerSavingMode)',
            tag: 'ONNXDetectionService.switchModel',
          );
          break;
        } catch (e) {
          LogMk.logDebug(
            'モデル読み込み失敗、次を試行: $modelPath - $e',
            tag: 'ONNXDetectionService.switchModel',
          );
          continue;
        }
      }
      
      if (!modelLoaded) {
        LogMk.logError(
          'すべてのモデルの読み込みに失敗',
          tag: 'ONNXDetectionService.switchModel',
        );
        return false;
      }
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'モデル切り替えエラー: $e',
        tag: 'ONNXDetectionService.switchModel',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _session?.release();
    _session = null;
    _labels = null;
    
    LogMk.logDebug(
      'ONNX Runtimeリソース解放完了',
      tag: 'ONNXDetectionService.dispose',
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

