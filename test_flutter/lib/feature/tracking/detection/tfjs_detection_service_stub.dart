import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';

/// TensorFlow.jsを使った物体検出サービス（スタブ版）
/// 
/// モバイル版ビルド時に使用されるスタブ実装
class TFJSDetectionService implements DetectionService {
  @override
  Future<bool> initialize() async {
    throw UnsupportedError('TensorFlow.jsはWeb版でのみサポートされています');
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    throw UnsupportedError('TensorFlow.jsはWeb版でのみサポートされています');
  }
  
  @override
  Future<bool> switchModel({required bool powerSavingMode}) async {
    throw UnsupportedError('TensorFlow.jsはWeb版でのみサポートされています');
  }
  
  @override
  Future<void> dispose() async {
    // スタブ実装
  }
}

