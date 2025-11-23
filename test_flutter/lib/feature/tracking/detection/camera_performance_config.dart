enum CameraPreviewQuality {
  low,
  standard,
}

/// カメラのプレビュー品質を制御する共有コンフィグ
class CameraPerformanceConfig {
  CameraPerformanceConfig._();

  static CameraPreviewQuality previewQuality = CameraPreviewQuality.low;

  static void configure({required bool lowResolutionPreview}) {
    previewQuality =
        lowResolutionPreview ? CameraPreviewQuality.low : CameraPreviewQuality.standard;
  }

  static bool get isLowQuality => previewQuality == CameraPreviewQuality.low;

  static Map<String, dynamic> webVideoConstraints() {
    if (isLowQuality) {
      return {
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640, 'max': 960},
          'height': {'ideal': 360, 'max': 540},
          'frameRate': {'ideal': 15, 'max': 20},
        },
      };
    }

    return {
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280, 'max': 1920},
        'height': {'ideal': 720, 'max': 1080},
        'frameRate': {'ideal': 24, 'max': 30},
      },
    };
  }
}

