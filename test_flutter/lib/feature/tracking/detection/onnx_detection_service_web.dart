import 'dart:typed_data';
import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:math' as math;
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
  bool _isInferencing = false; // 推論実行中フラグ（並行実行防止）
  bool _powerSavingMode = false; // 現在の省電力モード状態
  String? _currentModelName; // 現在使用中のモデル名

  /// モデルの入力サイズ
  static const int _inputSize = 640; // YOLO標準サイズ

  /// 基本の信頼度閾値（通常モード・省電力モード共通）
  static const double _baseConfidenceThreshold = 0.6;

  /// IoU閾値（重複検出の除去用）
  static const double _iouThreshold = 0.5;

  /// NMSに渡す前に許容する最大検出候補数
  static const int _maxDetectionsBeforeNms = 2000;

  /// 検出対象クラスのリスト
  ///
  /// 学習関連、PC関連、スマホ関連、人関連のクラスのみを検出対象とする
  static const List<String> _targetLabels = [
    // 学習関連
    'book',
    'pen', // 注意: COCOデータセットには'pen'がないため、実際には検出されない可能性があります
    'toothbrush',
    'scissors',
    // PC関連
    'laptop',
    'keyboard',
    'mouse',
    'tv',
    'microwave',
    // スマホ関連
    'cell phone',
    // 人関連
    'person',
  ];

  /// 対象クラスのインデックスリスト（初期化時に設定）
  List<int>? _targetClassIndices;

  /// 現在のモードに応じたログ用ラベル
  String _describeMode(bool powerSavingMode) {
    return powerSavingMode ? '省電力モード (10秒間隔)' : '通常モード (3秒間隔)';
  }

  double get _activeConfidenceThreshold => _baseConfidenceThreshold;

  /// モードに応じたモデルを読み込み
  Future<bool> _loadModelForMode(bool powerSavingMode) async {
    final modeLabel = _describeMode(powerSavingMode);
    LogMk.logDebug(
      '🤖 [ONNXDetectionService] モデル読み込み開始（$modeLabel）',
      tag: 'ONNXDetectionService._loadModelForMode',
    );

    final modelPaths = powerSavingMode
        ? [
            'assets/models/yolo11l.onnx', // 高精度版（省電力モード用）
            'assets/models/yolo11m.onnx', // フォールバック
          ]
        : [
            'assets/models/yolo11m.onnx', // バランス（通常モード用）
            'assets/models/yolo11l.onnx', // フォールバック
          ];

    bool modelLoaded = false;
    String? loadedModelPath;

    for (final modelPath in modelPaths) {
      try {
        LogMk.logDebug(
          '🤖 [ONNXDetectionService] モデル読み込み試行: $modelPath',
          tag: 'ONNXDetectionService._loadModelForMode',
        );

        final loadStartTime = DateTime.now();
        _session = await _loadOnnxModel(modelPath);
        final loadDuration = DateTime.now()
            .difference(loadStartTime)
            .inMilliseconds;

        loadedModelPath = modelPath;
        modelLoaded = true;

        LogMk.logDebug(
          '✅ [ONNXDetectionService] モデル読み込み成功: $modelPath (所要時間: ${loadDuration}ms, $modeLabel)',
          tag: 'ONNXDetectionService._loadModelForMode',
        );
        break;
      } catch (e, stackTrace) {
        LogMk.logWarning(
          '⚠️ [ONNXDetectionService] モデル読み込み失敗、次を試行: $modelPath - $e\nスタックトレース: $stackTrace',
          tag: 'ONNXDetectionService._loadModelForMode',
        );
        continue;
      }
    }

    if (!modelLoaded) {
      LogMk.logError(
        '❌ [ONNXDetectionService] $modeLabel のモデル読み込みに失敗しました',
        tag: 'ONNXDetectionService._loadModelForMode',
      );
      return false;
    }

    _powerSavingMode = powerSavingMode;
    _currentModelName = loadedModelPath
        ?.split('/')
        .last
        .replaceAll('.onnx', '');

    LogMk.logDebug(
      '✅ [ONNXDetectionService] モデル準備完了（${_currentModelName ?? "unknown"} / $modeLabel, 閾値=${_activeConfidenceThreshold.toStringAsFixed(2)}）',
      tag: 'ONNXDetectionService._loadModelForMode',
    );

    return true;
  }

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

      final modelLoaded = await _loadModelForMode(_powerSavingMode);
      if (!modelLoaded) {
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

      // 対象クラスのインデックスを設定
      _targetClassIndices = [];
      final foundLabels = <String>[];
      final notFoundLabels = <String>[];

      for (final targetLabel in _targetLabels) {
        final index = _labels!.indexOf(targetLabel);
        if (index >= 0) {
          _targetClassIndices!.add(index);
          foundLabels.add(targetLabel);
        } else {
          notFoundLabels.add(targetLabel);
        }
      }

      if (notFoundLabels.isNotEmpty) {
        LogMk.logWarning(
          '⚠️ [ONNXDetectionService] 以下のラベルが見つかりませんでした: ${notFoundLabels.join(", ")}',
          tag: 'ONNXDetectionService.initialize',
        );
      }

      LogMk.logDebug(
        '✅ [ONNXDetectionService] 対象クラス設定完了: ${foundLabels.length}個 (${foundLabels.join(", ")})',
        tag: 'ONNXDetectionService.initialize',
      );

      _isInitialized = true;

      LogMk.logDebug(
        '✅ [ONNXDetectionService] ONNX Runtime Web 初期化完了 (モデル: ${_currentModelName ?? "unknown"}, ラベル数: ${_labels!.length})',
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
    jsPromise
        .callMethod('then', [
          allowInterop((result) {
            completer.complete(result);
          }),
        ])
        .callMethod('catch', [
          allowInterop((error) {
            completer.completeError(error);
          }),
        ]);

    return completer.future;
  }

  // allowInteropのヘルパー関数（dart:jsから直接使用）
  dynamic allowInterop(Function f) {
    return js.context
        .callMethod('eval', [
          '(function(f) { return function() { return f.apply(null, arguments); }; })',
        ])
        .callMethod('call', [null, f]);
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

      // WebGPUバックエンドを有効化するセッションオプションを作成
      final sessionOptions = js.JsObject.jsify({
        'executionProviders': [
          'webgpu', // WebGPU（最優先、利用可能な場合）
          'wasm', // WebAssembly（フォールバック）
        ],
      });

      // JavaScriptの関数を呼び出す
      // createMethod.apply(InferenceSession, [modelUrl, sessionOptions]) の形式
      LogMk.logDebug(
        '🤖 [ONNXDetectionService] WebGPUバックエンドを有効化してInferenceSession.create()呼び出し開始',
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
        js.JsArray.from([modelUrl, sessionOptions]),
      ]);

      LogMk.logDebug(
        '🤖 [ONNXDetectionService] Promise取得成功、待機中...',
        tag: 'ONNXDetectionService._loadOnnxModel',
      );

      final promiseStartTime = DateTime.now();
      final session = await _promiseToFuture(sessionPromise);
      final promiseDuration = DateTime.now()
          .difference(promiseStartTime)
          .inMilliseconds;

      LogMk.logDebug(
        '✅ [ONNXDetectionService] セッション作成成功 (所要時間: ${promiseDuration}ms, WebGPU有効)',
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

        // バックエンド情報の取得を試みる（利用可能な場合のみ）
        try {
          final backend = session['backend'];
          if (backend != null) {
            LogMk.logDebug(
              '🚀 [ONNXDetectionService] 使用バックエンド: $backend',
              tag: 'ONNXDetectionService._loadOnnxModel',
            );
          }
        } catch (_) {
          // バックエンド情報が取得できない場合は無視
        }
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
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic light',
      'fire hydrant',
      'stop sign',
      'parking meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports ball',
      'kite',
      'baseball bat',
      'baseball glove',
      'skateboard',
      'surfboard',
      'tennis racket',
      'bottle',
      'wine glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted plant',
      'bed',
      'dining table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy bear',
      'hair drier',
      'toothbrush',
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

    // 並行実行チェック：既に推論実行中の場合はスキップ
    if (_isInferencing) {
      return [];
    }

    // 推論実行中フラグをセット
    _isInferencing = true;

    try {
      // 画像をHTMLImageElementに変換
      final imageElement = await _createImageElement(imageBytes);

      // 画像を前処理（リサイズ＋正規化）
      final inputTensor = await _preprocessImage(imageElement);

      // 推論実行
      final inferenceStartTime = DateTime.now();
      final outputs = await _runInference(inputTensor);
      final inferenceDuration = DateTime.now()
          .difference(inferenceStartTime)
          .inMilliseconds;

      // 検出結果を解析
      final detections = _parseOutputs(outputs);

      // 画像要素を破棄
      imageElement.remove();

      // 検出されたラベルをカテゴリにマッピング
      final results = _mapToDetectionResults(detections);

      // 検出ログを出力（複数物体対応）
      if (detections.isEmpty) {
        LogMk.logDebug(
          '🔍 [検出結果] 検出なし → 最終判定: nothingDetected (${inferenceDuration}ms)',
          tag: 'ONNXDetectionService.detect',
        );
      } else {
        // 各検出物体の情報をログに出力
        final detectionDetails = detections.map((d) => 
          '${d.label} (信頼度: ${d.confidence.toStringAsFixed(2)})'
        ).join(', ');
        
        LogMk.logDebug(
          '🔍 [検出物体] $detectionDetails (${inferenceDuration}ms)',
          tag: 'ONNXDetectionService.detect',
        );
        
        // 検出されたラベルのみをログに出力（最終判定はDetectionProcessorで行う）
      }

      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] 検出処理エラー: $e',
        tag: 'ONNXDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    } finally {
      // 推論実行中フラグを解除（必ず実行）
      _isInferencing = false;
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
        0,
        0,
        image.width!,
        image.height!,
        0,
        0,
        _inputSize,
        _inputSize,
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

      final tensorData = js.context['Float32Array'].callMethod('from', [
        float32Data,
      ]);
      final tensor = js.JsObject(Tensor, [
        'float32',
        tensorData,
        js.JsArray.from([1, 3, _inputSize, _inputSize]),
      ]);

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

      int? asInt(dynamic value) {
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        if (value is String) {
          return int.tryParse(value);
        }
        return null;
      }

      final expectedFeatureCount = 4 + (_labels?.length ?? 0);

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

      List<int>? tensorDims;
      // テンソルの形状を確認（可能な場合）
      try {
        final dims = outputTensor['dims'];
        if (dims != null && dims is List) {
          tensorDims = dims.map(asInt).whereType<int>().toList();
        }
      } catch (e) {
        // 無視
      }

      if (_targetClassIndices == null || _targetClassIndices!.isEmpty) {
        LogMk.logError(
          '❌ [ONNXDetectionService] 対象クラスが設定されていません',
          tag: 'ONNXDetectionService._parseOutputs',
        );
        return [];
      }

      final detections = <Detection>[];

      final layout = _inferOutputLayout(
        tensorDims: tensorDims,
        dataLength: dataList.length,
        expectedFeatureCount: expectedFeatureCount,
      );
      final numDetections = layout.detectionCount;
      final featureCount = layout.featureCount;
      final isFeatureMajorLayout = layout.isFeatureMajor;
      final expectedDataLength = featureCount * numDetections;
      if (dataList.length < expectedDataLength) {
        LogMk.logWarning(
          '⚠️ [ONNXDetectionService] 出力データ長 (${dataList.length}) が期待値 ($expectedDataLength) を下回っています。パース結果が不完全になる可能性があります。',
          tag: 'ONNXDetectionService._parseOutputs',
        );
      }

      int validDetections = 0;
      int debugCount = 0;

      // Sigmoid関数（ロジット値を確率に変換）
      double sigmoid(double x) {
        if (x >= 0) {
          final z = math.exp(-x);
          return 1.0 / (1.0 + z);
        } else {
          final z = math.exp(x);
          return z / (1.0 + z);
        }
      }

      final confidenceThreshold = _activeConfidenceThreshold;

      final inputSizeAsDouble = _inputSize.toDouble();

      double? readValue(int detectionIndex, int featureIndex) {
        if (detectionIndex < 0 || detectionIndex >= numDetections) {
          return null;
        }
        if (featureIndex < 0 || featureIndex >= featureCount) {
          return null;
        }
        final flatIndex = isFeatureMajorLayout
            ? featureIndex * numDetections + detectionIndex
            : detectionIndex * featureCount + featureIndex;
        if (flatIndex < 0 || flatIndex >= dataList.length) {
          return null;
        }
        final value = dataList[flatIndex];
        if (value is num) {
          final doubleValue = value.toDouble();
          if (!doubleValue.isFinite) {
            return null;
          }
          return doubleValue;
        }
        if (value is String) {
          return double.tryParse(value);
        }
        return null;
      }

      for (int i = 0; i < numDetections; i++) {
        try {
          // バウンディングボックス座標（feature0-3）
          final rawX = readValue(i, 0);
          final rawY = readValue(i, 1);
          final rawW = readValue(i, 2);
          final rawH = readValue(i, 3);

          if (rawX == null ||
              rawY == null ||
              rawW == null ||
              rawH == null ||
              !rawX.isFinite ||
              !rawY.isFinite ||
              !rawW.isFinite ||
              !rawH.isFinite ||
              rawW <= 0 ||
              rawH <= 0) {
            continue;
          }

          // YOLOv11の出力 (x, y, w, h) は640スケール（ピクセル単位）のため、0-1に正規化する
          double normalize(double value) {
            final normalized = value / inputSizeAsDouble;
            if (normalized.isNaN) {
              return 0.0;
            }
            return normalized.clamp(0.0, 1.0);
          }

          final x = normalize(rawX);
          final y = normalize(rawY);
          final w = normalize(rawW);
          final h = normalize(rawH);

          // 正規化後に極端に小さい/大きい場合はスキップ
          if (w <= 0 || h <= 0) {
            continue;
          }

          int? bestClassIdx;
          double bestScore = 0.0;
          for (final classIdx in _targetClassIndices!) {
            final featureIdx = 4 + classIdx;
            final logit = readValue(i, featureIdx);
            if (logit == null) {
              continue;
            }
            final score = sigmoid(logit);
            if (score > bestScore) {
              bestScore = score;
              bestClassIdx = classIdx;
            }
          }

          if (bestClassIdx == null || bestScore < confidenceThreshold) {
            continue;
          }

          validDetections++;

          final label = _labels![bestClassIdx];

          detections.add(
            Detection(
              label: label,
              confidence: bestScore,
              boundingBox: [x, y, w, h],
            ),
          );

          if (validDetections >= _maxDetectionsBeforeNms) {
            break;
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
      // 注意: 同じクラス内での重複除去のみ（異なるクラスは重複しても除去しない）
      final filteredDetections = _applyNMS(detections);

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

  static _YoloOutputLayout _inferOutputLayout({
    required List<int>? tensorDims,
    required int dataLength,
    required int expectedFeatureCount,
  }) {
    const defaultDetectionCount = 8400;
    final fallbackFeatureCount = expectedFeatureCount > 0
        ? expectedFeatureCount
        : 84;
    int featureCount = fallbackFeatureCount;
    int detectionCount = defaultDetectionCount;
    bool isFeatureMajor = true;

    if (tensorDims != null && tensorDims.length >= 3) {
      final second = tensorDims[1];
      final third = tensorDims[2];
      final secondLooksLikeFeature = second == expectedFeatureCount;
      final thirdLooksLikeFeature = third == expectedFeatureCount;

      if (thirdLooksLikeFeature && !secondLooksLikeFeature) {
        featureCount = third;
        detectionCount = second;
        isFeatureMajor = false;
      } else if (secondLooksLikeFeature && !thirdLooksLikeFeature) {
        featureCount = second;
        detectionCount = third;
        isFeatureMajor = true;
      } else if (third < second) {
        featureCount = third;
        detectionCount = second;
        isFeatureMajor = false;
      } else {
        featureCount = second;
        detectionCount = third;
        isFeatureMajor = true;
      }
    } else if (fallbackFeatureCount > 0 &&
        dataLength >= fallbackFeatureCount &&
        dataLength % fallbackFeatureCount == 0) {
      featureCount = fallbackFeatureCount;
      detectionCount = dataLength ~/ fallbackFeatureCount;
      isFeatureMajor = false;
    } else if (dataLength > 0) {
      detectionCount = math.max(1, (dataLength / fallbackFeatureCount).floor());
      featureCount = fallbackFeatureCount;
      isFeatureMajor = false;
    }

    if (featureCount <= 0) {
      featureCount = fallbackFeatureCount;
    }
    if (detectionCount <= 0) {
      detectionCount = defaultDetectionCount;
    }

    return _YoloOutputLayout(
      featureCount: featureCount,
      detectionCount: detectionCount,
      isFeatureMajor: isFeatureMajor,
    );
  }

  /// Non-Maximum Suppression（重複検出の除去）
  ///
  /// クラスを考慮したNMS（Class-Aware NMS）を実装
  /// 同じクラスの検出同士のみでIoUを計算し、異なるクラスは重複しても除去しない
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

        // クラスを考慮: 同じクラスの場合のみIoUを計算
        if (detections[i].label == detections[j].label) {
          final iou = _calculateIoU(
            detections[i].boundingBox,
            detections[j].boundingBox,
          );

          if (iou > _iouThreshold) {
            suppressed[j] = true;
          }
        }
        // 異なるクラスの場合は重複していても除去しない
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

    final intersectionWidth = (intersectionX2 - intersectionX1).clamp(
      0.0,
      double.infinity,
    );
    final intersectionHeight = (intersectionY2 - intersectionY1).clamp(
      0.0,
      double.infinity,
    );
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

    // 優先順位を解除：検出されたラベルをそのままカテゴリにマッピング
    final inferredCategory = _inferCategoryWithoutPriority(
      detectedLabels,
      bestDetection.label,
    );

    return [
      DetectionResult(
        category: inferredCategory,
        confidence: bestDetection.confidence,
        timestamp: DateTime.now(),
        detectedLabels: detectedLabels,
      ),
    ];
  }

  /// ラベルからカテゴリを推定（優先順位解除：最高信頼度の検出ラベルを直接使用）
  DetectionCategory _inferCategoryWithoutPriority(
    List<String> labels,
    String primaryLabel,
  ) {
    // 優先順位を解除：最高信頼度の検出ラベルを直接マッピング
    const studyLabels = ['book', 'pen', 'notebook', 'paper'];
    const pcLabels = [
      'laptop',
      'keyboard',
      'mouse',
      'computer',
      'tv',
      'desktop',
    ];
    const smartphoneLabels = ['cell phone', 'phone', 'mobile', 'smartphone'];
    const personLabels = ['person', 'human'];

    final lowerPrimaryLabel = primaryLabel.toLowerCase();

    // 最高信頼度の検出ラベルを直接チェック
    if (studyLabels.contains(lowerPrimaryLabel)) {
      return DetectionCategory.study;
    }
    if (pcLabels.contains(lowerPrimaryLabel)) {
      return DetectionCategory.pc;
    }
    if (smartphoneLabels.contains(lowerPrimaryLabel)) {
      return DetectionCategory.smartphone;
    }
    if (personLabels.contains(lowerPrimaryLabel)) {
      return DetectionCategory.personOnly;
    }

    // 最高信頼度のラベルがマッピングに含まれない場合、他の検出ラベルをチェック（優先順位なし）
    final lowerLabels = labels.map((l) => l.toLowerCase()).toList();

    // 検出された順序で最初に見つかったカテゴリを返す（優先順位なし）
    for (final label in lowerLabels) {
      if (studyLabels.contains(label)) {
        return DetectionCategory.study;
      }
      if (pcLabels.contains(label)) {
        return DetectionCategory.pc;
      }
      if (smartphoneLabels.contains(label)) {
        return DetectionCategory.smartphone;
      }
      if (personLabels.contains(label)) {
        return DetectionCategory.personOnly;
      }
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

      if (_isInitialized &&
          _session != null &&
          _powerSavingMode == powerSavingMode) {
        LogMk.logDebug(
          'ℹ️ [ONNXDetectionService] 要求されたモードと現在のモードが同一のため、切り替えをスキップします',
          tag: 'ONNXDetectionService.switchModel',
        );
        return true;
      }

      // 現在のセッションを破棄
      if (_session != null) {
        try {
          LogMk.logDebug(
            '🤖 [ONNXDetectionService] 既存セッションを破棄して新しいモデルに切り替えます',
            tag: 'ONNXDetectionService.switchModel',
          );
          try {
            _session!.callMethod('dispose');
            LogMk.logDebug(
              '✅ [ONNXDetectionService] 既存セッションのdispose()を実行しました',
              tag: 'ONNXDetectionService.switchModel',
            );
          } catch (_) {
            LogMk.logDebug(
              'ℹ️ [ONNXDetectionService] dispose()メソッドが提供されていないためスキップします',
              tag: 'ONNXDetectionService.switchModel',
            );
          }
        } catch (e) {
          LogMk.logError(
            '❌ [ONNXDetectionService] 既存セッションの破棄時にエラー: $e',
            tag: 'ONNXDetectionService.switchModel',
          );
        } finally {
          _session = null;
        }
      }

      _isInitialized = false;

      final modelLoaded = await _loadModelForMode(powerSavingMode);
      if (!modelLoaded) {
        return false;
      }

      _isInitialized = true;

      LogMk.logDebug(
        '✅ [ONNXDetectionService] モデル切り替え完了 (モード: ${powerSavingMode ? "省電力" : "通常"}, モデル: ${_currentModelName ?? "unknown"})',
        tag: 'ONNXDetectionService.switchModel',
      );

      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [ONNXDetectionService] モデル切り替えエラー: $e',
        tag: 'ONNXDetectionService.switchModel',
        stackTrace: stackTrace,
      );
      return false;
    }
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

        try {
          _session!.callMethod('dispose');
          LogMk.logDebug(
            '✅ [ONNXDetectionService] セッション破棄成功',
            tag: 'ONNXDetectionService.dispose',
          );
        } catch (_) {
          LogMk.logDebug(
            'ℹ️ [ONNXDetectionService] dispose()メソッドが提供されていないためスキップします',
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
    _targetClassIndices = null;
    _currentModelName = null;
    _powerSavingMode = false;

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

class _YoloOutputLayout {
  final int featureCount;
  final int detectionCount;
  final bool isFeatureMajor;

  const _YoloOutputLayout({
    required this.featureCount,
    required this.detectionCount,
    required this.isFeatureMajor,
  });
}
