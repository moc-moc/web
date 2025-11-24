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

DetectionService? _cachedDetectionService;
bool _cachedDetectionServiceInitialized = false;

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

/// 初期化ステージ
enum DetectionInitStage {
  camera,
  ai,
}

/// 初期化ステージの進行状況
enum DetectionInitStatus {
  pending,
  inProgress,
  success,
  failure,
}

typedef DetectionInitStageCallback = void Function(
  DetectionInitStage stage,
  DetectionInitStatus status,
);

/// 検出初期化時の追加オプション
class DetectionInitOptions {
  final bool powerSavingMode;
  final DetectionInitStageCallback? onStageStatusChanged;
  final bool enableModelPrefetch;

  const DetectionInitOptions({
    this.powerSavingMode = false,
    this.onStageStatusChanged,
    this.enableModelPrefetch = true,
  });
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
  DetectionInitOptions? options,
}) async {
  try {
    LogMk.logDebug(
      '検出機能の初期化を開始',
      tag: 'initializeDetection',
    );
    
    final powerSavingMode = options?.powerSavingMode ?? false;
    void notifyStage(DetectionInitStage stage, DetectionInitStatus status) {
      options?.onStageStatusChanged?.call(stage, status);
    }

    // カメラマネージャーの初期化（プラットフォーム自動判定）
    final cameraManager = CameraManager.create();
    notifyStage(DetectionInitStage.camera, DetectionInitStatus.inProgress);

    // 検出サービスの初期化（キャッシュ活用）
    DetectionService service;
    final bool shouldCacheService = detectionService == null;

    if (detectionService != null) {
      service = detectionService;
    } else {
      service = _cachedDetectionService ?? createDetectionService(type: serviceType);
      if (_cachedDetectionService == null) {
        _cachedDetectionService = service;
        _cachedDetectionServiceInitialized = false;
      }
    }

    service.applyInitialPowerSavingMode(powerSavingMode);

    if (options?.enableModelPrefetch == true) {
      service.prefetchModel(powerSavingMode: powerSavingMode).catchError((error, stackTrace) {
        LogMk.logWarning(
          '検出サービスのプリフェッチに失敗しました: $error',
          tag: 'initializeDetection.prefetch',
        );
      });
    }

    final bool serviceInitNeeded = !shouldCacheService || !_cachedDetectionServiceInitialized;

    if (serviceInitNeeded) {
      notifyStage(DetectionInitStage.ai, DetectionInitStatus.inProgress);
      LogMk.logDebug(
        '検出サービスの初期化を開始: ${service.runtimeType} (powerSaving: $powerSavingMode)',
        tag: 'initializeDetection',
      );
    } else {
      notifyStage(DetectionInitStage.ai, DetectionInitStatus.success);
    }

    final cameraInitFuture = cameraManager.initialize().then((success) {
      notifyStage(
        DetectionInitStage.camera,
        success ? DetectionInitStatus.success : DetectionInitStatus.failure,
      );
      return success;
    });

    final detectionInitFuture = serviceInitNeeded
        ? service.initialize().then((success) {
            notifyStage(
              DetectionInitStage.ai,
              success ? DetectionInitStatus.success : DetectionInitStatus.failure,
            );
            return success;
          })
        : Future<bool>.value(true);

    final results = await Future.wait<bool>([
      cameraInitFuture,
      detectionInitFuture,
    ]);

    final cameraInitialized = results[0];
    final serviceInitialized = results[1];

    if (!cameraInitialized || !serviceInitialized) {
      LogMk.logError(
        'カメラ/検出サービスの初期化に失敗 (camera: $cameraInitialized, service: $serviceInitialized)',
        tag: 'initializeDetection',
      );
      await cameraManager.dispose();
      if (shouldCacheService) {
        await service.dispose();
        _cachedDetectionService = null;
        _cachedDetectionServiceInitialized = false;
      }
      return null;
    }

    if (shouldCacheService && !_cachedDetectionServiceInitialized) {
      _cachedDetectionServiceInitialized = true;
    }

    final bool controllerInitialModeSynced = (shouldCacheService && serviceInitNeeded)
        ? true
        : (service.currentPowerSavingMode == null ||
            service.currentPowerSavingMode == powerSavingMode);

    // 検出プロセッサーの作成
    final processor = DetectionProcessor(
      detectionService: service,
      cameraManager: cameraManager,
    );

    // 検出コントローラーの作成
    final controller = DetectionController(
      processor: processor,
      cameraManager: cameraManager,
      initialPowerSavingMode: powerSavingMode,
      initialModeSynced: controllerInitialModeSynced,
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

