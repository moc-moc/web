import 'dart:typed_data';
import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// ONNX Runtime Webを使った物体検出サービス（Web版）
/// 
/// Web版でYOLO11モデルを使用して物体検出を実行
class ONNXDetectionService implements DetectionService {
  dynamic _session;
  List<String>? _labels;
  bool _isInitialized = false;
  
  /// モデルの入力サイズ
  static const int _inputSize = 640; // YOLO標準サイズ
  
  /// 信頼度の閾値
  static const double _confidenceThreshold = 0.7;
  
  /// IoU閾値（重複検出の除去用）
  static const double _iouThreshold = 0.5;
  
  /// 検出候補のログ出力制御用（最初の検出時のみ）
  static int _parseCallCount = 0;
  
  @override
  Future<bool> initialize() async {
    try {
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] モデル初期化開始',
        tag: 'ONNXDetectionService.initialize',
      );
      
      // ONNX Runtime Webが利用可能かチェック
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] ONNX Runtime Web利用可能性チェック中...',
        tag: 'ONNXDetectionService.initialize',
      );
      
      if (!_isOnnxRuntimeAvailable()) {
        LogMk.logError(
          '❌ [ONNXDetectionService] ONNX Runtime Webが読み込まれていません。index.htmlにスクリプトタグを追加してください。',
          tag: 'ONNXDetectionService.initialize',
        );
        return false;
      }
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] ONNX Runtime Web利用可能',
        tag: 'ONNXDetectionService.initialize',
      );
      
      // YOLO11モデルを読み込み
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] YOLO11lモデル読み込み開始: assets/models/yolo11l.onnx',
        tag: 'ONNXDetectionService.initialize',
      );
      
      try {
        final loadStartTime = DateTime.now();
        _session = await _loadOnnxModel('assets/models/yolo11l.onnx');
        final loadDuration = DateTime.now().difference(loadStartTime).inMilliseconds;
        
        LogMk.logDebug(
          '✅ [ONNXDetectionService] YOLO11lモデル読み込み成功 (所要時間: ${loadDuration}ms)',
          tag: 'ONNXDetectionService.initialize',
        );
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ [ONNXDetectionService] YOLO11lモデルの読み込みに失敗: $e',
          tag: 'ONNXDetectionService.initialize',
          stackTrace: stackTrace,
        );
        return false;
      }
      
      // ラベルファイルの読み込み
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] ラベルファイル読み込み開始',
        tag: 'ONNXDetectionService.initialize',
      );
      
      _labels = _loadLabels();
      
      if (_labels == null || _labels!.isEmpty) {
        LogMk.logError(
          '❌ [ONNXDetectionService] ラベルファイルの読み込みに失敗',
          tag: 'ONNXDetectionService.initialize',
        );
        return false;
      }
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] ラベルファイル読み込み成功 (ラベル数: ${_labels!.length})',
        tag: 'ONNXDetectionService.initialize',
      );
      
      _isInitialized = true;
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] ONNX Runtime Web 初期化完了 (ラベル数: ${_labels!.length})',
        tag: 'ONNXDetectionService.initialize',
      );
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] ONNX Runtime Web 初期化エラー: $e',
        tag: 'ONNXDetectionService.initialize',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// ONNX Runtime Webが利用可能かチェック
  bool _isOnnxRuntimeAvailable() {
    try {
      final ort = js.context['ort'];
      final isAvailable = ort != null;
      
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] ONNX Runtime Webチェック: ${isAvailable ? "利用可能" : "利用不可"}',
        tag: 'ONNXDetectionService._isOnnxRuntimeAvailable',
      );
      
      if (isAvailable) {
        // 詳細情報をログ出力
        try {
          final InferenceSession = ort['InferenceSession'];
          LogMk.logDebug(
            '🤖 [ONNXDetectionService] InferenceSession: ${InferenceSession != null ? "存在" : "不存在"}',
            tag: 'ONNXDetectionService._isOnnxRuntimeAvailable',
          );
        } catch (e) {
          LogMk.logWarning(
            '⚠️ [ONNXDetectionService] InferenceSession確認エラー: $e',
            tag: 'ONNXDetectionService._isOnnxRuntimeAvailable',
          );
        }
      }
      
      return isAvailable;
    } catch (e) {
      LogMk.logError(
        '❌ [ONNXDetectionService] ONNX Runtime Webチェックエラー: $e',
        tag: 'ONNXDetectionService._isOnnxRuntimeAvailable',
      );
      return false;
    }
  }
  
  /// JavaScriptのPromiseをDartのFutureに変換
  Future<dynamic> _promiseToFuture(dynamic jsPromise) {
    final completer = Completer<dynamic>();
    
    // JavaScriptのPromiseを処理
    // allowInteropはdart:jsから直接使用
    jsPromise.callMethod('then', [
      allowInterop((result) {
        completer.complete(result);
      }),
    ]).callMethod('catch', [
      allowInterop((error) {
        completer.completeError(error);
      }),
    ]);
    
    return completer.future;
  }
  
  // allowInteropのヘルパー関数（dart:jsから直接使用）
  dynamic allowInterop(Function f) {
    return js.context.callMethod('eval', [
      '(function(f) { return function() { return f.apply(null, arguments); }; })'
    ]).callMethod('call', [null, f]);
  }
  
  /// ONNXモデルを読み込み
  Future<dynamic> _loadOnnxModel(String modelPath) async {
    try {
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] モデル読み込み開始: $modelPath',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      final ort = js.context['ort'];
      
      if (ort == null) {
        LogMk.logError(
          '❌ [ONNXDetectionService] ONNX Runtime Webが読み込まれていません',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
        throw Exception('ONNX Runtime Webが読み込まれていません');
      }
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] ortオブジェクト取得成功',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      // InferenceSessionを取得
      final InferenceSession = ort['InferenceSession'];
      if (InferenceSession == null) {
        LogMk.logError(
          '❌ [ONNXDetectionService] InferenceSessionが見つかりません',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
        throw Exception('InferenceSessionが見つかりません');
      }
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] InferenceSession取得成功',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      // モデルファイルのURLを取得（Flutter Webのassetsパス）
      // 注意: Flutter Webでは、assetsは /assets/ パスでアクセス可能
      // modelPathが既に 'assets/' で始まっている場合は削除
      String cleanPath = modelPath;
      if (cleanPath.startsWith('assets/')) {
        cleanPath = cleanPath.substring('assets/'.length);
      }
      final modelUrl = '/assets/$cleanPath';
      
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] モデルURL: $modelUrl',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      // InferenceSession.create()を呼び出し
      // ort.InferenceSession.create(modelUrl) を実行
      final createMethod = InferenceSession['create'];
      if (createMethod == null) {
        LogMk.logError(
          '❌ [ONNXDetectionService] InferenceSession.createが見つかりません',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
        throw Exception('InferenceSession.createが見つかりません');
      }
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] createメソッド取得成功',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      // JavaScriptの関数を呼び出す
      // createMethod.apply(InferenceSession, [modelUrl]) の形式
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] InferenceSession.create()呼び出し開始',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      final applyMethod = js.context['Function']['prototype']['apply'];
      if (applyMethod == null) {
        LogMk.logError(
          '❌ [ONNXDetectionService] Function.prototype.applyが見つかりません',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
        throw Exception('Function.prototype.applyが見つかりません');
      }
      
      final sessionPromise = applyMethod.callMethod('call', [
        createMethod,
        InferenceSession,
        js.JsArray.from([modelUrl]),
      ]);
      
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] Promise取得成功、待機中...',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      final promiseStartTime = DateTime.now();
      final session = await _promiseToFuture(sessionPromise);
      final promiseDuration = DateTime.now().difference(promiseStartTime).inMilliseconds;
      
      LogMk.logDebug(
        '✅ [ONNXDetectionService] セッション作成成功 (所要時間: ${promiseDuration}ms)',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );
      
      // セッション情報をログ出力
      try {
        final inputNames = session['inputNames'];
        final outputNames = session['outputNames'];
        LogMk.logDebug(
          '🤖 [ONNXDetectionService] 入力名: $inputNames, 出力名: $outputNames',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
      } catch (e) {
        LogMk.logWarning(
          '⚠️ [ONNXDetectionService] セッション情報取得エラー: $e',
          tag: 'ONNXDetectionService._loadOnnxModel',
        );
      }
      
      return session;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] モデル読み込みエラー: $e',
        tag: 'ONNXDetectionService._loadOnnxModel',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// ラベルファイルを読み込み
  List<String> _loadLabels() {
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
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (!_isInitialized || _session == null) {
      LogMk.logError(
        '❌ [ONNXDetectionService] モデルが初期化されていません (isInitialized: $_isInitialized, session: ${_session != null})',
        tag: 'ONNXDetectionService.detect',
      );
      return [];
    }
    
    try {
      final detectStartTime = DateTime.now();
      
      // 画像をHTMLImageElementに変換
      final imageElement = await _createImageElement(imageBytes);
      
      // 画像を前処理（リサイズ＋正規化）
      final inputTensor = await _preprocessImage(imageElement);
      
      // 推論実行
      final inferenceStartTime = DateTime.now();
      final outputs = await _runInference(inputTensor);
      final inferenceDuration = DateTime.now().difference(inferenceStartTime).inMilliseconds;
      
      // 検出結果を解析
      final detections = _parseOutputs(outputs);
      
      // 画像要素を破棄
      imageElement.remove();
      
      // 検出されたラベルをカテゴリにマッピング
      final results = _mapToDetectionResults(detections);
      
      final totalDuration = DateTime.now().difference(detectStartTime).inMilliseconds;
      
      if (results.isNotEmpty) {
        final result = results.first;
        LogMk.logDebug(
          '✅ [ONNXDetectionService] 検出完了: ${result.categoryString} (信頼度: ${result.confidence.toStringAsFixed(2)}, 推論: ${inferenceDuration}ms, 合計: ${totalDuration}ms)',
          tag: 'ONNXDetectionService.detect',
        );
      } else {
        LogMk.logDebug(
          '✅ [ONNXDetectionService] 検出完了: 検出なし (推論: ${inferenceDuration}ms, 合計: ${totalDuration}ms)',
          tag: 'ONNXDetectionService.detect',
        );
      }
      
      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 検出処理エラー: $e',
        tag: 'ONNXDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// 画像バイトからHTMLImageElementを作成
  Future<html.ImageElement> _createImageElement(Uint8List imageBytes) async {
    try {
      final blob = html.Blob([imageBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final img = html.ImageElement();
      img.src = url;
      
      // 画像の読み込みを待つ
      await img.onLoad.first;
      
      html.Url.revokeObjectUrl(url);
      
      return img;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 画像要素作成エラー: $e',
        tag: 'ONNXDetectionService._createImageElement',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// 画像を前処理（リサイズ＋正規化）
  Future<dynamic> _preprocessImage(html.ImageElement image) async {
    try {
      // Canvasを使用して画像をリサイズ＋正規化
      final canvas = html.CanvasElement(width: _inputSize, height: _inputSize);
      final ctx = canvas.context2D;
      
      // 画像を640x640にリサイズして描画
      ctx.drawImageScaledFromSource(
        image,
        0, 0, image.width!, image.height!,
        0, 0, _inputSize, _inputSize,
      );
      
      // ピクセルデータを取得
      final imageData = ctx.getImageData(0, 0, _inputSize, _inputSize);
      final data = imageData.data;
      
      // Float32Arrayに変換（NCHW形式: [1, 3, 640, 640]）
      final float32Data = Float32List(_inputSize * _inputSize * 3);
      
      int pixelIndex = 0;
      // CHW形式に変換（R, G, Bの順）
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            final idx = (y * _inputSize + x) * 4;
            double value;
            if (c == 0) {
              value = data[idx] / 255.0; // R
            } else if (c == 1) {
              value = data[idx + 1] / 255.0; // G
            } else {
              value = data[idx + 2] / 255.0; // B
            }
            float32Data[pixelIndex++] = value;
          }
        }
      }
      
      // ONNX Runtime Web用のTensorを作成
      final ort = js.context['ort'];
      if (ort == null) {
        throw Exception('ortオブジェクトが見つかりません');
      }
      
      final Tensor = ort['Tensor'];
      if (Tensor == null) {
        throw Exception('Tensorクラスが見つかりません');
      }
      
      final tensorData = js.context['Float32Array'].callMethod('from', [float32Data]);
      final tensor = js.JsObject(
        Tensor,
        ['float32', tensorData, js.JsArray.from([1, 3, _inputSize, _inputSize])],
      );
      
      return tensor;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 画像前処理エラー: $e',
        tag: 'ONNXDetectionService._preprocessImage',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// 推論を実行
  Future<dynamic> _runInference(dynamic inputTensor) async {
    try {
      // 入力名を取得（通常は 'images' または 'input'）
      String inputName = 'images';
      try {
        final inputNames = _session['inputNames'];
        if (inputNames != null && inputNames is List && inputNames.isNotEmpty) {
          inputName = inputNames[0] as String;
        }
      } catch (e) {
        // デフォルトの 'images' を使用
      }
      
      final feeds = js.JsObject.jsify({inputName: inputTensor});
      
      // 推論実行
      final runPromise = _session.callMethod('run', [feeds]);
      final results = await _promiseToFuture(runPromise);
      
      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 推論実行エラー: $e',
        tag: 'ONNXDetectionService._runInference',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// 検出結果を解析
  List<Detection> _parseOutputs(dynamic outputs) {
    try {
      
      // YOLO11の出力は通常 'output0' という名前
      dynamic outputTensor;
      String outputKey = 'output0';
      
      try {
        outputTensor = outputs[outputKey];
        if (outputTensor == null) {
          // 他のキーを試す
          if (outputs['output'] != null) {
            outputKey = 'output';
            outputTensor = outputs[outputKey];
          } else if (outputs.keys.length > 0) {
            outputKey = outputs.keys.first;
            outputTensor = outputs[outputKey];
            LogMk.logDebug(
              '🤖 [ONNXDetectionService] 出力キーを変更: $outputKey',
              tag: 'ONNXDetectionService._parseOutputs',
            );
          }
        }
      } catch (e) {
        LogMk.logError(
          '❌ [ONNXDetectionService] 出力テンソル取得エラー: $e',
          tag: 'ONNXDetectionService._parseOutputs',
        );
        return [];
      }
      
      if (outputTensor == null) {
        LogMk.logError(
          '❌ [ONNXDetectionService] 出力テンソルが見つかりません (キー: $outputKey)',
          tag: 'ONNXDetectionService._parseOutputs',
        );
        return [];
      }
      
      // データを取得
      dynamic outputData;
      try {
        outputData = outputTensor['data'];
        if (outputData == null) {
          // データが直接テンソルにある場合
          outputData = outputTensor;
        }
      } catch (e) {
        LogMk.logError(
          '❌ [ONNXDetectionService] データ取得エラー: $e',
          tag: 'ONNXDetectionService._parseOutputs',
        );
        return [];
      }
      
      if (outputData is! List) {
        LogMk.logError(
          '❌ [ONNXDetectionService] 出力データがList型ではありません (型: ${outputData.runtimeType})',
          tag: 'ONNXDetectionService._parseOutputs',
        );
        return [];
      }
      
      final dataList = outputData;
      final detections = <Detection>[];
      
      // YOLOv8/YOLOv11の出力形式: [1, 84, 8400]
      // 84 = [x, y, w, h] + 80クラスの信頼度
      final numDetections = 8400;
      
      int validDetections = 0;
      int debugCount = 0;
      double maxOverallScore = 0.0;
      
      // YOLO11の出力形式: [1, 84, 8400]
      // データは1次元配列としてフラット化されている: [detection0の84要素, detection1の84要素, ...]
      // 各検出候補は84次元: [x, y, w, h, class0_score, class1_score, ..., class79_score]
      const int featuresPerDetection = 84; // x, y, w, h + 80クラス
      
      for (int i = 0; i < numDetections; i++) {
        try {
          final baseIndex = i * featuresPerDetection;
          
          // バウンディングボックス座標（最初の4要素）
          final x = dataList[baseIndex + 0] as double;
          final y = dataList[baseIndex + 1] as double;
          final w = dataList[baseIndex + 2] as double;
          final h = dataList[baseIndex + 3] as double;
          
          // クラススコアを取得（5番目以降の80クラス分）
          double maxScore = 0.0;
          int maxClassIdx = 0;
          
          for (int classIdx = 0; classIdx < 80; classIdx++) {
            final score = dataList[baseIndex + 4 + classIdx] as double;
            if (score > maxScore) {
              maxScore = score;
              maxClassIdx = classIdx;
            }
          }
          
          // デバッグ用: 最初の検出時のみ、サンプルとして3個の検出候補をログ出力
          _parseCallCount++;
          if (_parseCallCount == 1 && debugCount < 3) {
            LogMk.logDebug(
              '🔍 [ONNXDetectionService] 検出候補サンプル #$i: maxScore=$maxScore, class=${_labels![maxClassIdx]}',
              tag: 'ONNXDetectionService._parseOutputs',
            );
            debugCount++;
          }
          
          if (maxScore > maxOverallScore) {
            maxOverallScore = maxScore;
          }
          
          // 信頼度が閾値以上の場合のみ追加
          if (maxScore >= _confidenceThreshold) {
            validDetections++;
            detections.add(Detection(
              label: _labels![maxClassIdx],
              confidence: maxScore,
              boundingBox: [x, y, w, h],
            ));
          }
        } catch (e) {
          // 個別の検出候補の解析エラーはログ出力
          if (debugCount < 5) {
            LogMk.logWarning(
              '⚠️ [ONNXDetectionService] 検出候補 #$i の解析エラー: $e',
              tag: 'ONNXDetectionService._parseOutputs',
            );
            debugCount++;
          }
          continue;
        }
      }
      
      // NMS（Non-Maximum Suppression）で重複を除去
      final filteredDetections = _applyNMS(detections);
      
      // 検出結果のサマリーのみログ出力
      LogMk.logDebug(
        '✅ [ONNXDetectionService] 検出完了: 候補${validDetections}個 → NMS後${filteredDetections.length}個 (最大信頼度: ${maxOverallScore.toStringAsFixed(2)})',
        tag: 'ONNXDetectionService._parseOutputs',
      );
      
      return filteredDetections;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 検出結果の解析エラー: $e',
        tag: 'ONNXDetectionService._parseOutputs',
        stackTrace: stackTrace,
      );
      return [];
    }
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
    LogMk.logDebug(
      '🤖 [ONNXDetectionService] dispose呼び出し',
      tag: 'ONNXDetectionService.dispose',
    );
    
    if (_session != null) {
      try {
        LogMk.logDebug(
          '🤖 [ONNXDetectionService] セッション破棄開始',
          tag: 'ONNXDetectionService.dispose',
        );
        
        // ONNX Runtime Webのセッションを破棄
        // 注: dispose()メソッドが存在しない場合もあるため、try-catchで囲む
        try {
          _session.callMethod('dispose');
          LogMk.logDebug(
            '✅ [ONNXDetectionService] セッション破棄成功',
            tag: 'ONNXDetectionService.dispose',
          );
        } catch (e) {
          LogMk.logWarning(
            '⚠️ [ONNXDetectionService] セッションのdispose()メソッドが存在しません: $e',
            tag: 'ONNXDetectionService.dispose',
          );
        }
      } catch (e) {
        LogMk.logError(
          '❌ [ONNXDetectionService] セッションの破棄時にエラー: $e',
          tag: 'ONNXDetectionService.dispose',
        );
      }
      _session = null;
    }
    
    _isInitialized = false;
    _labels = null;
    
    LogMk.logDebug(
      '✅ [ONNXDetectionService] ONNX Runtime Web リソース解放完了',
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

