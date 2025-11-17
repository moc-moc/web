import 'dart:typed_data';
import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// TensorFlow.jsを使った物体検出サービス（Web版）
/// 
/// Web版でCOCO-SSD、YOLO、またはEfficientDetモデルを使用して物体検出を実行
class TFJSDetectionService implements DetectionService {
  dynamic _model;
  bool _isInitialized = false;
  
  /// 信頼度の閾値
  static const double _confidenceThreshold = 0.7;
  
  @override
  Future<bool> initialize() async {
    try {
      LogMk.logDebug(
        'TensorFlow.jsモデルの初期化を開始',
        tag: 'TFJSDetectionService.initialize',
      );
      
      // TensorFlow.jsが利用可能かチェック
      if (!_isTensorFlowJSAvailable()) {
        LogMk.logError(
          'TensorFlow.jsが読み込まれていません。index.htmlにスクリプトタグを追加してください。',
          tag: 'TFJSDetectionService.initialize',
        );
        return false;
      }
      
      // COCO-SSDモデルを読み込み（軽量で高速）
      // 注: index.htmlに以下のスクリプトタグが必要
      // <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs"></script>
      // <script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd"></script>
      try {
        _model = await _loadCocoSsdModel();
      } catch (e) {
        LogMk.logError(
          'COCO-SSDモデルの読み込みに失敗: $e',
          tag: 'TFJSDetectionService.initialize',
        );
        return false;
      }
      
      _isInitialized = true;
      
      LogMk.logDebug(
        'TensorFlow.js初期化完了',
        tag: 'TFJSDetectionService.initialize',
      );
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'TensorFlow.js初期化エラー: $e',
        tag: 'TFJSDetectionService.initialize',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// TensorFlow.jsが利用可能かチェック
  bool _isTensorFlowJSAvailable() {
    try {
      return js.context['tf'] != null && js.context['cocoSsd'] != null;
    } catch (e) {
      return false;
    }
  }
  
  /// JavaScriptのPromiseをDartのFutureに変換
  Future<dynamic> _promiseToFuture(dynamic jsPromise) {
    final completer = Completer<dynamic>();
    
    // JSのPromiseを処理
    jsPromise.callMethod('then', [
      (result) => completer.complete(result),
    ]).callMethod('catch', [
      (error) => completer.completeError(error),
    ]);
    
    return completer.future;
  }
  
  /// COCO-SSDモデルを読み込み
  Future<dynamic> _loadCocoSsdModel() async {
    try {
      final cocoSsd = js.context['cocoSsd'];
      final loadPromise = cocoSsd.callMethod('load');
      
      // JavaScriptのPromiseをDartのFutureに変換
      final model = await _promiseToFuture(loadPromise);
      
      return model;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (!_isInitialized || _model == null) {
      LogMk.logError(
        'モデルが初期化されていません',
        tag: 'TFJSDetectionService.detect',
      );
      return [];
    }
    
    try {
      // 画像をHTMLImageElementに変換
      final imageElement = await _createImageElement(imageBytes);
      
      // 検出を実行
      final detectPromise = _model.callMethod('detect', [imageElement]);
      final predictions = await _promiseToFuture(detectPromise);
      
      // 検出結果を解析
      final results = _parsePredictions(predictions);
      
      // 画像要素を破棄
      imageElement.remove();
      
      return results;
    } catch (e, stackTrace) {
      LogMk.logError(
        '検出処理エラー: $e',
        tag: 'TFJSDetectionService.detect',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// 画像バイトからHTMLImageElementを作成
  Future<html.ImageElement> _createImageElement(Uint8List imageBytes) async {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final img = html.ImageElement();
    img.src = url;
    
    // 画像の読み込みを待つ
    await img.onLoad.first;
    
    html.Url.revokeObjectUrl(url);
    
    return img;
  }
  
  /// 検出結果を解析
  List<DetectionResult> _parsePredictions(dynamic predictions) {
    try {
      final List<dynamic> predictionList = js.JsObject.fromBrowserObject(predictions) as List;
      
      if (predictionList.isEmpty) {
        return [
          DetectionResult(
            category: DetectionCategory.nothingDetected,
            confidence: 0.0,
            timestamp: DateTime.now(),
            detectedLabels: [],
          ),
        ];
      }
      
      // 信頼度でフィルタリング
      final filteredPredictions = predictionList.where((pred) {
        final score = pred['score'] as double;
        return score >= _confidenceThreshold;
      }).toList();
      
      if (filteredPredictions.isEmpty) {
        return [
          DetectionResult(
            category: DetectionCategory.nothingDetected,
            confidence: 0.0,
            timestamp: DateTime.now(),
            detectedLabels: [],
          ),
        ];
      }
      
      // ラベルを収集
      final detectedLabels = filteredPredictions
          .map((pred) => pred['class'] as String)
          .toList();
      
      // 最も信頼度の高い予測を取得
      filteredPredictions.sort((a, b) {
        final scoreA = a['score'] as double;
        final scoreB = b['score'] as double;
        return scoreB.compareTo(scoreA);
      });
      
      final bestPrediction = filteredPredictions.first;
      final bestScore = bestPrediction['score'] as double;
      
      // カテゴリを推定
      final category = _inferCategory(detectedLabels);
      
      return [
        DetectionResult(
          category: category,
          confidence: bestScore,
          timestamp: DateTime.now(),
          detectedLabels: detectedLabels,
        ),
      ];
    } catch (e, stackTrace) {
      LogMk.logError(
        '検出結果の解析エラー: $e',
        tag: 'TFJSDetectionService._parsePredictions',
        stackTrace: stackTrace,
      );
      return [];
    }
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
    // TFJSDetectionServiceはモデル切り替えをサポートしていません
    // 常に同じモデル（COCO-SSD）を使用します
    LogMk.logDebug(
      'TFJS検出サービス: モデル切り替えはサポートされていません (省電力モード: $powerSavingMode)',
      tag: 'TFJSDetectionService.switchModel',
    );
    return true;
  }

  @override
  Future<void> dispose() async {
    if (_model != null) {
      try {
        _model.callMethod('dispose');
      } catch (e) {
        LogMk.logDebug(
          'モデルの破棄時にエラー: $e',
          tag: 'TFJSDetectionService.dispose',
        );
      }
      _model = null;
    }
    
    _isInitialized = false;
    
    LogMk.logDebug(
      'TensorFlow.jsリソース解放完了',
      tag: 'TFJSDetectionService.dispose',
    );
  }
}

