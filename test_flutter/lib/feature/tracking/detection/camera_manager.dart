import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';

// モバイル版のインポート
import 'camera_manager_mobile.dart' show CameraManagerMobile;

// Web版のインポート（条件付き）
import 'camera_manager_web_stub.dart' if (dart.library.html) 'camera_manager_web.dart'
    show CameraManagerWeb;

/// カメラ管理クラス
/// 
/// カメラの初期化、権限管理、映像ストリームの取得を担当
/// Web版とモバイル版の両方に対応
abstract class CameraManager {
  /// カメラが初期化されているかどうか
  bool get isInitialized;

  /// カメラ映像のストリーム
  Stream<CameraImageData>? get imageStream;

  /// カメラの初期化
  /// 
  /// **戻り値**: 初期化成功時true、失敗時false
  Future<bool> initialize();

  /// カメラ映像の取得（単一フレーム）
  /// 
  /// **戻り値**: カメラ画像（初期化されていない場合はnull）
  Future<CameraImageData?> captureImage();

  /// カメラのリソースを解放
  /// 
  /// 使用後は必ず呼び出す
  Future<void> dispose();

  /// ファクトリコンストラクタ
  /// 
  /// プラットフォームに応じて適切な実装を返す
  factory CameraManager.create() {
    if (kIsWeb) {
      // Web版の実装（条件付きインポート）
      return CameraManagerWeb();
    } else {
      // モバイル版の実装
      return CameraManagerMobile();
    }
  }
}
