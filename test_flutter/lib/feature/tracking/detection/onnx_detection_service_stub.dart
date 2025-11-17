import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_service.dart';

/// ONNX Runtimeを使った物体検出サービス（スタブ版）
/// 
/// このファイルは使用されません（条件付きエクスポートで適切な実装が選択されます）
class ONNXDetectionService implements DetectionService {
  @override
  Future<bool> initialize() async {
    throw UnsupportedError('このスタブは使用されるべきではありません');
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    throw UnsupportedError('このスタブは使用されるべきではありません');
  }
  
  @override
  Future<void> dispose() async {
    // スタブ実装
  }
}

