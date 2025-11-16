// このファイルはモバイル版でのみ使用されます
// Web版ではcamera_manager_web.dartが使用されます

import 'camera_manager.dart';
import 'camera_image_data.dart';

/// Web版のスタブ実装（モバイル版用）
/// 
/// 実際の実装はcamera_manager_web.dartで定義される
class CameraManagerWebStub implements CameraManager {
  @override
  bool get isInitialized => throw UnimplementedError('Web版の実装が必要です');

  @override
  Stream<CameraImageData>? get imageStream => throw UnimplementedError('Web版の実装が必要です');

  @override
  Future<bool> initialize() => throw UnimplementedError('Web版の実装が必要です');

  @override
  Future<CameraImageData?> captureImage() => throw UnimplementedError('Web版の実装が必要です');

  @override
  Future<void> dispose() => throw UnimplementedError('Web版の実装が必要です');
}

// Web版のエイリアス（モバイル版では使用されない）
typedef CameraManagerWeb = CameraManagerWebStub;

