import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';

/// モバイル向けONNX検出サービス（バックグラウンドIsolate実行）
class ONNXDetectionService implements DetectionService {
  Isolate? _worker;
  SendPort? _workerPort;
  bool _isInitialized = false;
  bool _initialPowerSavingMode = false;
  bool _lastRequestedPowerSavingMode = false;

  Future<void> _ensureWorker() async {
    if (_workerPort != null) {
      return;
    }

    final readyPort = ReceivePort();
    final rootToken = RootIsolateToken.instance;

    _worker = await Isolate.spawn<_WorkerBootstrapData>(
      _onnxWorkerEntryPoint,
      _WorkerBootstrapData(
        sendPort: readyPort.sendPort,
        rootIsolateToken: rootToken,
      ),
      debugName: 'onnx-detection-worker',
      errorsAreFatal: true,
    );

    _workerPort = await readyPort.first as SendPort;
    readyPort.close();
  }

  Future<Map<String, dynamic>> _sendRequest(
    String type, {
    Map<String, dynamic>? payload,
    TransferableTypedData? data,
  }) async {
    final port = _workerPort;
    if (port == null) {
      throw StateError('ONNX detection worker is not running');
    }

    final responsePort = ReceivePort();
    port.send(<String, dynamic>{
      'type': type,
      'payload': payload,
      'data': data,
      'replyPort': responsePort.sendPort,
    });

    final response = await responsePort.first as Map<String, dynamic>;
    responsePort.close();
    return response;
  }

  @override
  Future<bool> initialize() async {
    try {
      // メインIsolateでモデルファイルを準備
      final modelPath = _initialPowerSavingMode 
          ? 'assets/models/yolo11l.onnx' 
          : 'assets/models/yolo11m.onnx';
      
      LogMk.logDebug(
        'メインIsolateでモデルファイルを読み込み中: $modelPath',
        tag: 'ONNXDetectionService.initialize',
      );
      
      // メインIsolateでアセットをロードして一時ファイルに保存
      final modelFile = await _loadModelFromAssetOnMain(modelPath);
      
      LogMk.logDebug(
        'モデルファイルを一時ディレクトリに保存: ${modelFile.path}',
        tag: 'ONNXDetectionService.initialize',
      );
      
      // Isolateを起動
      await _ensureWorker();
      
      // Isolateにファイルパスを渡して初期化
      final response = await _sendRequest('init', payload: {
        'powerSavingMode': _initialPowerSavingMode,
        'modelFilePath': modelFile.path,
      });
      
      _isInitialized = response['success'] == true;
      if (_isInitialized) {
        _lastRequestedPowerSavingMode = _initialPowerSavingMode;
        LogMk.logDebug(
          'ONNXDetectionService initialized (powerSaving: $_initialPowerSavingMode)',
          tag: 'ONNXDetectionService.initialize',
        );
      } else {
        LogMk.logError(
          'ONNX worker initialisation failed: ${response['error'] ?? 'unknown'}',
          tag: 'ONNXDetectionService.initialize',
        );
      }
      return _isInitialized;
    } catch (e, stackTrace) {
      LogMk.logError(
        'ONNXDetectionService initialization error: $e',
        tag: 'ONNXDetectionService.initialize',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// メインIsolateでアセットを読み込む
  Future<File> _loadModelFromAssetOnMain(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      
      // ファイルが既に存在する場合はスキップ
      if (await file.exists()) {
        LogMk.logDebug(
          'モデルファイルは既に存在します: ${file.path}',
          tag: 'ONNXDetectionService._loadModelFromAssetOnMain',
        );
        return file;
      }
      
      await file.writeAsBytes(byteData.buffer.asUint8List());
      LogMk.logDebug(
        'モデルファイルを保存しました: ${file.path} (${byteData.lengthInBytes} bytes)',
        tag: 'ONNXDetectionService._loadModelFromAssetOnMain',
      );
      return file;
    } catch (e) {
      LogMk.logError(
        'Failed to load model from asset on main isolate: $assetPath, error: $e',
        tag: 'ONNXDetectionService._loadModelFromAssetOnMain',
      );
      rethrow;
    }
  }

  @override
  void applyInitialPowerSavingMode(bool powerSavingMode) {
    _initialPowerSavingMode = powerSavingMode;
    _lastRequestedPowerSavingMode = powerSavingMode;
  }

  @override
  bool? get currentPowerSavingMode => _lastRequestedPowerSavingMode;

  @override
  Future<void> prefetchModel({required bool powerSavingMode}) async {
    applyInitialPowerSavingMode(powerSavingMode);
  }

  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    LogMk.logDebug(
      '🔍 [ONNX Mobile] 検出処理開始（画像サイズ: ${imageBytes.length} bytes）',
      tag: 'ONNXDetectionService.detect',
    );

    if (!_isInitialized) {
      LogMk.logWarning(
        '⚠️ [ONNX Mobile] モデルが初期化されていないため、初期化を試みます',
        tag: 'ONNXDetectionService.detect',
      );
      final ok = await initialize();
      if (!ok) {
        LogMk.logError(
          '❌ [ONNX Mobile] モデル初期化に失敗しました',
          tag: 'ONNXDetectionService.detect',
        );
        return [];
      }
    }

    try {
      LogMk.logDebug(
        '📤 [ONNX Mobile] Isolateに検出リクエストを送信中...',
        tag: 'ONNXDetectionService.detect',
      );

      final response = await _sendRequest(
        'detect',
        data: TransferableTypedData.fromList([imageBytes]),
      );

      if (response['success'] != true) {
        LogMk.logError(
          '❌ [ONNX Mobile] Isolateからエラー応答: ${response['error'] ?? 'unknown'}',
          tag: 'ONNXDetectionService.detect',
        );
        return [];
      }

      final List<dynamic> rawResults = response['results'] as List<dynamic>? ?? [];
      final results = rawResults
          .whereType<Map>()
          .map((dynamic raw) => Map<String, dynamic>.from(raw as Map))
          .map(_deserializeDetectionResult)
          .toList();

      LogMk.logDebug(
        '✅ [ONNX Mobile] 検出完了（結果数: ${results.length}）',
        tag: 'ONNXDetectionService.detect',
      );

      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNX Mobile] 検出処理中に例外が発生: $e',
        tag: 'ONNXDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  DetectionResult _deserializeDetectionResult(Map<String, dynamic> raw) {
    final categoryIndex = raw['category'] as int?;
    final category =
        (categoryIndex != null && categoryIndex >= 0 && categoryIndex < DetectionCategory.values.length)
            ? DetectionCategory.values[categoryIndex]
            : null;
    return DetectionResult(
      category: category,
      confidence: (raw['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(raw['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      detectedLabels: (raw['labels'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  @override
  Future<bool> switchModel({required bool powerSavingMode}) async {
    if (_workerPort == null) {
      return false;
    }

    final response = await _sendRequest('switchModel', payload: {
      'powerSavingMode': powerSavingMode,
    });

    if (response['success'] != true) {
      LogMk.logError(
        'ONNX worker switchModel failed: ${response['error'] ?? 'unknown'}',
        tag: 'ONNXDetectionService.switchModel',
      );
      return false;
    }

    _lastRequestedPowerSavingMode = powerSavingMode;
    return true;
  }

  @override
  Future<void> dispose() async {
    if (_workerPort == null) {
      return;
    }
    await _sendRequest('dispose');
    _workerPort = null;
    _worker?.kill(priority: Isolate.immediate);
    _worker = null;
    _isInitialized = false;
  }
}

class _WorkerBootstrapData {
  final SendPort sendPort;
  final RootIsolateToken? rootIsolateToken;

  const _WorkerBootstrapData({
    required this.sendPort,
    required this.rootIsolateToken,
  });
}

void _onnxWorkerEntryPoint(_WorkerBootstrapData data) async {
  if (data.rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken!);
  }

  final receivePort = ReceivePort();
  data.sendPort.send(receivePort.sendPort);

  final worker = _OnnxRuntimeWorker();

  await for (final message in receivePort) {
    if (message is! Map<String, dynamic>) {
      continue;
    }
    final type = message['type'] as String? ?? '';
    final SendPort replyPort = message['replyPort'] as SendPort;
    try {
      switch (type) {
        case 'init':
          final payload = (message['payload'] as Map?)?.cast<String, dynamic>();
          final success = await worker.initialize(
            powerSavingMode: payload?['powerSavingMode'] as bool? ?? false,
            modelFilePath: payload?['modelFilePath'] as String?,
          );
          replyPort.send({'success': success});
          break;
        case 'detect':
          final TransferableTypedData transferable = message['data'] as TransferableTypedData;
          final bytes = transferable.materialize().asUint8List();
          final results = await worker.detect(bytes);
          replyPort.send({
            'success': true,
            'results': results,
          });
          break;
        case 'switchModel':
          final payload = (message['payload'] as Map?)?.cast<String, dynamic>();
          final success = await worker.switchModel(payload?['powerSavingMode'] as bool? ?? false);
          replyPort.send({'success': success});
          break;
        case 'dispose':
          await worker.dispose();
          replyPort.send({'success': true});
          receivePort.close();
          return;
        default:
          replyPort.send({'success': false, 'error': 'unknown_command'});
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        'ONNX worker error: $e',
        tag: 'ONNXDetectionService.worker',
        stackTrace: stackTrace,
      );
      replyPort.send({'success': false, 'error': e.toString()});
    }
  }
}

class _OnnxRuntimeWorker {
  OrtSession? _session;
  List<String>? _labels;
  bool _powerSavingMode = false;

  static const int _inputSize = 640;
  static const double _confidenceThreshold = 0.7;
  static const double _iouThreshold = 0.5;

  Future<bool> initialize({
    required bool powerSavingMode,
    String? modelFilePath,
  }) async {
    try {
      _powerSavingMode = powerSavingMode;
      OrtEnv.instance.init();
      
      // モデルファイルパスが渡された場合は、それを直接使用
      if (modelFilePath != null) {
        final file = File(modelFilePath);
        if (!await file.exists()) {
          throw Exception('Model file not found: $modelFilePath');
        }
        
        final sessionOptions = OrtSessionOptions();
        _session = OrtSession.fromFile(file, sessionOptions);
        _labels = await _loadLabels();
        
        LogMk.logDebug(
          'ONNX worker loaded model from file: $modelFilePath',
          tag: 'ONNXDetectionService.worker',
        );
        return true;
      }
      
      // フォールバック: アセットから読み込む（旧方式）
      return await _loadModel(_powerSavingMode);
    } catch (e, stackTrace) {
      LogMk.logError(
        'ONNX worker init error: $e',
        tag: 'ONNXDetectionService.worker.init',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> detect(Uint8List imageBytes) async {
    if (_session == null || _labels == null) {
      LogMk.logError(
        '❌ [ONNX Worker] セッションまたはラベルがnullです（session: ${_session != null}, labels: ${_labels != null}）',
        tag: 'ONNXDetectionService.worker.detect',
      );
      return [];
    }

    try {
      LogMk.logDebug(
        '🔍 [ONNX Worker] 画像デコード中... (${imageBytes.length} bytes)',
        tag: 'ONNXDetectionService.worker.detect',
      );
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        LogMk.logError(
          '❌ [ONNX Worker] 画像のデコードに失敗しました',
          tag: 'ONNXDetectionService.worker.detect',
        );
        return [];
      }
      
      LogMk.logDebug(
        '🔍 [ONNX Worker] 画像前処理中... (サイズ: ${image.width}x${image.height})',
        tag: 'ONNXDetectionService.worker.detect',
      );
      final inputTensor = _preprocessImage(image);
      
      LogMk.logDebug(
        '🔍 [ONNX Worker] 推論実行中...',
        tag: 'ONNXDetectionService.worker.detect',
      );
      final outputs = _runInference(inputTensor);
      
      LogMk.logDebug(
        '🔍 [ONNX Worker] 出力解析中...',
        tag: 'ONNXDetectionService.worker.detect',
      );
      final detections = _parseOutputs(outputs);
      
      LogMk.logDebug(
        '🔍 [ONNX Worker] 検出結果マッピング中... (検出数: ${detections.length})',
        tag: 'ONNXDetectionService.worker.detect',
      );
      final results = _mapToDetectionResults(detections);
      
      LogMk.logDebug(
        '✅ [ONNX Worker] 検出完了 (結果数: ${results.length})',
        tag: 'ONNXDetectionService.worker.detect',
      );
      return results.map(_serializeDetectionResult).toList();
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNX Worker] 検出エラー: $e',
        tag: 'ONNXDetectionService.worker.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<bool> switchModel(bool powerSavingMode) async {
    _powerSavingMode = powerSavingMode;
    return await _loadModel(powerSavingMode);
  }

  Future<void> dispose() async {
    _session?.release();
    _session = null;
    _labels = null;
  }

  Future<bool> _loadModel(bool powerSavingMode) async {
    _session?.release();
    _session = null;

    final modelCandidates = powerSavingMode
        ? [
            'assets/models/yolo11l.onnx',
            'assets/models/yolo11m.onnx',
          ]
        : [
            'assets/models/yolo11m.onnx',
            'assets/models/yolo11l.onnx',
          ];

    for (final modelPath in modelCandidates) {
      try {
        final modelFile = await _loadModelFromAsset(modelPath);
        final sessionOptions = OrtSessionOptions();
        _session = OrtSession.fromFile(modelFile, sessionOptions);
        LogMk.logDebug(
          'ONNX worker loaded model: $modelPath',
          tag: 'ONNXDetectionService.worker',
        );
        _labels ??= await _loadLabels();
        return true;
      } catch (e) {
        LogMk.logWarning(
          'Failed to load model $modelPath: $e',
          tag: 'ONNXDetectionService.worker',
        );
      }
    }

    LogMk.logError(
      'All ONNX models failed to load',
      tag: 'ONNXDetectionService.worker',
    );
    return false;
  }

  Future<File> _loadModelFromAsset(String assetPath) async {
    try {
      // Isolate内でrootBundleを使用するには、
      // BackgroundIsolateBinaryMessengerを使用する必要がある
      final messenger = ServicesBinding.instance.defaultBinaryMessenger;
      
      // アセットキーをエンコード
      final assetKey = Uint8List.fromList(utf8.encode(assetPath));
      
      // メッセンジャーを使用してアセットを読み込む
      final ByteData? response = await messenger.send(
        'flutter/assets',
        assetKey.buffer.asByteData(),
      );
      
      if (response == null) {
        throw Exception('Asset not found: $assetPath');
      }
      
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.buffer.asUint8List());
      return file;
    } catch (e) {
      LogMk.logError(
        'Failed to load model from asset: $assetPath, error: $e',
        tag: 'ONNXDetectionService._loadModelFromAsset',
      );
      rethrow;
    }
  }

  Future<List<String>> _loadLabels() async {
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
  }

  OrtValueTensor _preprocessImage(img.Image image) {
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    final inputData = Float32List(_inputSize * _inputSize * 3);
    int pixelIndex = 0;

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

  List<OrtValue?> _runInference(OrtValueTensor input) {
    final inputName = _session!.inputNames.first;
    return _session!.run(
      OrtRunOptions(),
      {inputName: input},
    );
  }

  List<_Detection> _parseOutputs(List<OrtValue?> outputs) {
    if (outputs.isEmpty || outputs.first == null) {
      return [];
    }

    final output = outputs.first as OrtValueTensor;
    final outputData = output.value as List;
    final detections = <_Detection>[];
    final batch = outputData[0];
    final numDetections = batch[0].length;

    for (int i = 0; i < numDetections; i++) {
      final x = batch[0][i] as double;
      final y = batch[1][i] as double;
      final w = batch[2][i] as double;
      final h = batch[3][i] as double;

      double maxScore = 0.0;
      int maxClassIdx = 0;
      for (int classIdx = 0; classIdx < 80; classIdx++) {
        final score = batch[4 + classIdx][i] as double;
        if (score > maxScore) {
          maxScore = score;
          maxClassIdx = classIdx;
        }
      }

      if (maxScore >= _confidenceThreshold) {
        detections.add(_Detection(
          label: _labels![maxClassIdx],
          confidence: maxScore,
          boundingBox: [x, y, w, h],
        ));
      }
    }

    return _applyNms(detections);
  }

  List<_Detection> _applyNms(List<_Detection> detections) {
    if (detections.isEmpty) {
      return [];
    }

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <_Detection>[];
    final suppressed = List<bool>.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      selected.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        final iou = _calculateIoU(detections[i].boundingBox, detections[j].boundingBox);
        if (iou > _iouThreshold) {
          suppressed[j] = true;
        }
      }
    }

    return selected;
  }

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

    if (unionArea == 0) {
      return 0;
    }
    return intersectionArea / unionArea;
  }

  List<DetectionResult> _mapToDetectionResults(List<_Detection> detections) {
    if (detections.isEmpty) {
      return [
        DetectionResult(
          category: DetectionCategory.nothingDetected,
          confidence: 0.0,
          timestamp: DateTime.now(),
          detectedLabels: const <String>[],
        ),
      ];
    }

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final detectedLabels = detections.map((d) => d.label).toList();
    return [
      DetectionResult(
        category: _inferCategory(detectedLabels),
        confidence: detections.first.confidence,
        timestamp: DateTime.now(),
        detectedLabels: detectedLabels,
      ),
    ];
  }

  Map<String, dynamic> _serializeDetectionResult(DetectionResult result) {
    return {
      'category': result.category?.index,
      'confidence': result.confidence,
      'timestamp': result.timestamp.millisecondsSinceEpoch,
      'labels': result.detectedLabels,
    };
  }

  DetectionCategory _inferCategory(List<String> labels) {
    const studyLabels = ['book', 'pen', 'notebook', 'paper'];
    const pcLabels = ['laptop', 'keyboard', 'mouse', 'computer', 'tv'];
    const smartphoneLabels = ['cell phone', 'phone', 'mobile'];
    const personLabels = ['person', 'human'];

    final lowerLabels = labels.map((label) => label.toLowerCase()).toList();

    if (lowerLabels.any(studyLabels.contains)) return DetectionCategory.study;
    if (lowerLabels.any(pcLabels.contains)) return DetectionCategory.pc;
    if (lowerLabels.any(smartphoneLabels.contains)) return DetectionCategory.smartphone;
    if (lowerLabels.any(personLabels.contains)) return DetectionCategory.personOnly;

    return DetectionCategory.nothingDetected;
  }
}

class _Detection {
  final String label;
  final double confidence;
  final List<double> boundingBox;

  _Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}
