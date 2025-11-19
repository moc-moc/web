/// トラッキング機能用のヘルパー関数
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/feature/tracking/detection/detection_processor.dart';
import 'package:test_flutter/feature/tracking/detection/detection_controller.dart';
import 'package:test_flutter/feature/tracking/detection/tflite_detection_service.dart';
import 'package:test_flutter/feature/tracking/detection/onnx_detection_service.dart';
import 'package:test_flutter/feature/tracking/detection/tfjs_detection_service.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 検出サービスの種類
enum DetectionServiceType {
  /// TensorFlow Lite（モバイル用）
  tflite,
  
  /// ONNX Runtime（YOLOv11/YOLOv8用）
  onnx,
  
  /// TensorFlow.js（Web用）
  tfjs,
  
  /// 自動選択（プラットフォームに応じて最適なものを選択）
  auto,
}

/// プラットフォームに応じた検出サービスを作成
/// 
/// **パラメータ**:
/// - `type`: 検出サービスの種類（デフォルト: auto）
/// 
/// **戻り値**: 検出サービスのインスタンス
DetectionService createDetectionService({
  DetectionServiceType type = DetectionServiceType.auto,
}) {
  // autoの場合、プラットフォームに応じて選択
  if (type == DetectionServiceType.auto) {
    // Web版とモバイル版の両方でONNX Runtime (YOLO11)を使用
    LogMk.logDebug(
      '${kIsWeb ? "Web" : "モバイル"}版のため、ONNX Runtime (YOLO11l)を使用します',
      tag: 'createDetectionService',
    );
    return ONNXDetectionService();
  }
  
  // 手動で指定された場合
  switch (type) {
    case DetectionServiceType.tflite:
      if (kIsWeb) {
        LogMk.logWarning(
          'Web版ではTensorFlow Liteは使用できません。TensorFlow.jsを使用します',
          tag: 'createDetectionService',
        );
        return TFJSDetectionService();
      }
      LogMk.logDebug(
        'TensorFlow Liteを使用します',
        tag: 'createDetectionService',
      );
      return TFLiteDetectionService();
    
    case DetectionServiceType.onnx:
      LogMk.logDebug(
        'ONNX Runtime (YOLO11l)を使用します',
        tag: 'createDetectionService',
      );
      return ONNXDetectionService();
    
    case DetectionServiceType.tfjs:
      LogMk.logDebug(
        'TensorFlow.jsを使用します',
        tag: 'createDetectionService',
      );
      return TFJSDetectionService();
    
    case DetectionServiceType.auto:
      // 上記で処理済み
      return ONNXDetectionService();
  }
}

/// 検出機能の初期化
/// 
/// カメラと検出サービスを初期化します
/// Web版とモバイル版の両方に対応
/// 
/// **パラメータ**:
/// - `detectionService`: 検出サービス（nullの場合は自動選択）
/// - `serviceType`: 検出サービスの種類（detectionServiceがnullの場合に使用）
/// 
/// **戻り値**: 初期化されたDetectionController（失敗時はnull）
Future<DetectionController?> initializeDetection({
  DetectionService? detectionService,
  DetectionServiceType serviceType = DetectionServiceType.auto,
}) async {
  try {
    LogMk.logDebug(
      '検出機能の初期化を開始',
      tag: 'initializeDetection',
    );
    
    // カメラマネージャーの初期化（プラットフォーム自動判定）
    final cameraManager = CameraManager.create();
    final cameraInitialized = await cameraManager.initialize();
    
    if (!cameraInitialized) {
      LogMk.logError(
        'カメラマネージャーの初期化に失敗',
        tag: 'initializeDetection',
      );
      return null;
    }

    // 検出サービスの初期化
    final service = detectionService ?? createDetectionService(type: serviceType);
    
    LogMk.logDebug(
      '検出サービスの初期化を開始: ${service.runtimeType}',
      tag: 'initializeDetection',
    );
    
    final serviceInitialized = await service.initialize();
    
    if (!serviceInitialized) {
      LogMk.logError(
        '検出サービスの初期化に失敗',
        tag: 'initializeDetection',
      );
      await cameraManager.dispose();
      return null;
    }

    // 検出プロセッサーの作成
    final processor = DetectionProcessor(
      detectionService: service,
      cameraManager: cameraManager,
    );

    // 検出コントローラーの作成
    final controller = DetectionController(
      processor: processor,
      cameraManager: cameraManager,
    );

    LogMk.logDebug(
      '検出機能の初期化完了',
      tag: 'initializeDetection',
    );

    return controller;
  } catch (e, stackTrace) {
    LogMk.logError(
      '検出機能の初期化エラー: $e',
      tag: 'initializeDetection',
      stackTrace: stackTrace,
    );
    return null;
  }
}

/// 時間入力値のバリデーション
/// 
/// 入力値が数値のみで、負の数でないかをチェックします。
/// 
/// [value] チェックする文字列
/// 戻り値: 有効な場合true、無効な場合false
bool validateTimeInput(String value) {
  if (value.isEmpty) {
    return true; // 空文字は許可（0として扱う）
  }
  
  final number = int.tryParse(value);
  if (number == null) {
    return false; // 数値に変換できない
  }
  
  if (number < 0) {
    return false; // 負の数は不可
  }
  
  return true;
}

/// 時間入力値をint型に変換
/// 
/// 文字列をint型に変換します。エラー時は0を返します。
/// 
/// [value] 変換する文字列
/// 戻り値: 変換された数値（エラー時は0）
int parseTimeInput(String value) {
  if (value.isEmpty) {
    return 0;
  }
  
  final number = int.tryParse(value);
  if (number == null || number < 0) {
    return 0;
  }
  
  return number;
}

