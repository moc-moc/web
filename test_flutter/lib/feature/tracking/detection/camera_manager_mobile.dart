import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// モバイル版カメラ管理クラス
/// 
/// iOS/Android向けのカメラ実装
class CameraManagerMobile implements CameraManager {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  StreamController<CameraImageData>? _imageStreamController;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  Stream<CameraImageData>? get imageStream => _imageStreamController?.stream;

  @override
  Future<bool> initialize() async {
    try {
      // 権限確認
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        LogMk.logError(
          'カメラ権限が拒否されました',
          tag: 'CameraManagerMobile.initialize',
        );
        return false;
      }

      // カメラ一覧の取得
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        LogMk.logError(
          '利用可能なカメラが見つかりません',
          tag: 'CameraManagerMobile.initialize',
        );
        return false;
      }

      // フロントカメラを優先、なければバックカメラを使用
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      // カメラコントローラーの初期化
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      // 映像ストリームの設定
      _imageStreamController = StreamController<CameraImageData>.broadcast();
      _controller!.startImageStream((image) {
        if (!_imageStreamController!.isClosed) {
          _imageStreamController!.add(
            CameraImageData.fromMobile(image),
          );
        }
      });

      _isInitialized = true;
      LogMk.logDebug(
        'カメラ初期化完了（モバイル版）',
        tag: 'CameraManagerMobile.initialize',
      );
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'カメラ初期化エラー: $e',
        tag: 'CameraManagerMobile.initialize',
        stackTrace: stackTrace,
      );
      await dispose();
      return false;
    }
  }

  /// カメラ権限の確認・要求
  /// 
  /// **戻り値**: 権限が許可されている場合true
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }

      // 永続的に拒否されている場合
      if (status.isPermanentlyDenied) {
        LogMk.logError(
          'カメラ権限が永続的に拒否されています',
          tag: 'CameraManagerMobile._requestCameraPermission',
        );
        return false;
      }

      return false;
    } catch (e, stackTrace) {
      LogMk.logError(
        'カメラ権限確認エラー: $e',
        tag: 'CameraManagerMobile._requestCameraPermission',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<CameraImageData?> captureImage() async {
    if (!isInitialized || _controller == null) {
      LogMk.logError(
        'カメラが初期化されていません',
        tag: 'CameraManagerMobile.captureImage',
      );
      return null;
    }

    try {
      // ストリームから最新の画像を取得するため、1フレーム待機
      final completer = Completer<CameraImageData?>();
      late StreamSubscription subscription;

      subscription = imageStream!.listen((image) {
        if (!completer.isCompleted) {
          completer.complete(image);
          subscription.cancel();
        }
      });

      // タイムアウト設定（5秒）
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(null);
          subscription.cancel();
        }
      });

      return await completer.future;
    } catch (e, stackTrace) {
      LogMk.logError(
        '画像取得エラー: $e',
        tag: 'CameraManagerMobile.captureImage',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _imageStreamController?.close();
      _imageStreamController = null;

      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;

      _isInitialized = false;
      LogMk.logDebug(
        'カメラリソース解放完了（モバイル版）',
        tag: 'CameraManagerMobile.dispose',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        'カメラリソース解放エラー: $e',
        tag: 'CameraManagerMobile.dispose',
        stackTrace: stackTrace,
      );
    }
  }
}

