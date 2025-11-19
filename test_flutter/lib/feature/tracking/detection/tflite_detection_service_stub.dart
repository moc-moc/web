import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';

/// TensorFlow Lite検出サービス（スタブ版）
/// 
/// Web版ではTensorFlow Liteは使用できません
class TFLiteDetectionService implements DetectionService {
  @override
  Future<bool> initialize() async {
    throw UnsupportedError('TensorFlow LiteはWeb版では使用できません。ONNX RuntimeまたはTensorFlow.jsを使用してください。');
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    throw UnsupportedError('TensorFlow LiteはWeb版では使用できません。ONNX RuntimeまたはTensorFlow.jsを使用してください。');
  }
  
  @override
  Future<bool> switchModel({required bool powerSavingMode}) async {
    throw UnsupportedError('TensorFlow LiteはWeb版では使用できません。ONNX RuntimeまたはTensorFlow.jsを使用してください。');
  }
  
  @override
  Future<void> dispose() async {
    // スタブ実装
  }
}

