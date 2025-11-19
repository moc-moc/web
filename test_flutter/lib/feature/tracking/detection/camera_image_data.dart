import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// カメラ画像データの抽象化
/// 
/// Web版とモバイル版で異なる画像形式を統一するためのラッパー
class CameraImageData {
  /// モバイル版のCameraImage（Web版ではnull）
  final CameraImage? mobileImage;
  
  /// Web版の画像データ（モバイル版ではnull）
  final Uint8List? webImageBytes;
  
  /// 画像の幅
  final int width;
  
  /// 画像の高さ
  final int height;

  CameraImageData._({
    required this.mobileImage,
    required this.webImageBytes,
    required this.width,
    required this.height,
  });

  /// モバイル版のCameraImageから作成
  factory CameraImageData.fromMobile(CameraImage image) {
    return CameraImageData._(
      mobileImage: image,
      webImageBytes: null,
      width: image.width,
      height: image.height,
    );
  }

  /// Web版の画像データから作成
  factory CameraImageData.fromWeb({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) {
    return CameraImageData._(
      mobileImage: null,
      webImageBytes: imageBytes,
      width: width,
      height: height,
    );
  }

  /// Uint8List形式で画像データを取得
  /// 
  /// Web版とモバイル版の両方で使用可能な形式に変換
  Future<Uint8List> toBytes() async {
    if (kIsWeb) {
      // Web版: そのまま返す
      return webImageBytes!;
    } else {
      // モバイル版: CameraImageから変換
      final image = mobileImage!;
      final bytes = <int>[];
      bytes.addAll(image.planes[0].bytes);
      bytes.addAll(image.planes[1].bytes);
      bytes.addAll(image.planes[2].bytes);
      return Uint8List.fromList(bytes);
    }
  }
}

