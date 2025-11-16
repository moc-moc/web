/// トラッキング機能用のヘルパー関数
library;

import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';
import 'package:test_flutter/feature/tracking/detection/detection_processor.dart';
import 'package:test_flutter/feature/tracking/detection/detection_controller.dart';
import 'package:test_flutter/feature/tracking/detection/dummy_detection_service.dart';

/// 検出機能の初期化
/// 
/// カメラと検出サービスを初期化します
/// Web版とモバイル版の両方に対応
/// 
/// **パラメータ**:
/// - `detectionService`: 検出サービス（nullの場合はダミーサービスを使用）
/// 
/// **戻り値**: 初期化されたDetectionController（失敗時はnull）
Future<DetectionController?> initializeDetection({
  DetectionService? detectionService,
}) async {
  try {
    // カメラマネージャーの初期化（プラットフォーム自動判定）
    final cameraManager = CameraManager.create();
    final cameraInitialized = await cameraManager.initialize();
    
    if (!cameraInitialized) {
      return null;
    }

    // 検出サービスの初期化（未指定の場合はダミーサービスを使用）
    final service = detectionService ?? DummyDetectionService();
    final serviceInitialized = await service.initialize();
    
    if (!serviceInitialized) {
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

    return controller;
  } catch (e) {
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

