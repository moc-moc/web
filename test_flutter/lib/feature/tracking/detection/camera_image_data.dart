import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;

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
  /// モバイル版では、カメラ画像をPNG形式にエンコードして返す
  Future<Uint8List> toBytes() async {
    if (kIsWeb) {
      // Web版: そのまま返す
      return webImageBytes!;
    } else {
      // モバイル版: CameraImageをPNGにエンコード
      final cameraImage = mobileImage!;
      
      // CameraImageからimg.Imageを作成
      img.Image? image;
      
      if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        // BGRA8888フォーマット（iOS）
        image = img.Image.fromBytes(
          width: cameraImage.width,
          height: cameraImage.height,
          bytes: cameraImage.planes[0].bytes.buffer,
          order: img.ChannelOrder.bgra,
        );
      } else if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        // YUV420フォーマット（Android）
        // YUV420からRGBへの変換
        image = _convertYUV420ToImage(cameraImage);
      } else {
        // その他のフォーマット
        throw UnsupportedError('Unsupported image format: ${cameraImage.format.group}');
      }
      
      // PNGにエンコード
      return Uint8List.fromList(img.encodePng(image));
    }
  }
  
  /// YUV420画像をimg.Imageに変換
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;
    
    final image = img.Image(width: width, height: height);
    
    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        final int uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;
        
        final yp = cameraImage.planes[0].bytes[index];
        final up = cameraImage.planes[1].bytes[uvIndex];
        final vp = cameraImage.planes[2].bytes[uvIndex];
        
        // YUV to RGB conversion
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        
        image.setPixelRgb(w, h, r, g, b);
      }
    }
    
    return image;
  }
}

