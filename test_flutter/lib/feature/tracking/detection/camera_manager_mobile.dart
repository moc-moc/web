import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/feature/tracking/detection/camera_performance_config.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// モバイル版カメラ管理クラス
/// 
/// iOS/Android向けのカメラ実装
class CameraManagerMobile implements CameraManager {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  StreamController<CameraImageData>? _imageStreamController;
  CameraImage? _latestCameraImage;
  final List<Completer<CameraImageData?>> _pendingCaptureRequests = [];

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
      final resolutionPreset = CameraPerformanceConfig.isLowQuality
          ? ResolutionPreset.low
          : ResolutionPreset.medium;

      _controller = CameraController(
        camera,
        resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      // 映像ストリームの設定
      _imageStreamController = StreamController<CameraImageData>.broadcast();
      _controller!.startImageStream((image) {
        if (_imageStreamController != null && !_imageStreamController!.isClosed) {
          final data = CameraImageData.fromMobile(image);
          _imageStreamController!.add(data);
          _latestCameraImage = image;
          _completePendingCaptures(data);
        } else {
          _latestCameraImage = image;
          _completePendingCaptures(CameraImageData.fromMobile(image));
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
      final latest = _latestCameraImage;
      if (latest != null) {
        return CameraImageData.fromMobile(latest);
      }

      final completer = Completer<CameraImageData?>();
      _pendingCaptureRequests.add(completer);

      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(null);
          _pendingCaptureRequests.remove(completer);
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
      _latestCameraImage = null;
      for (final completer in _pendingCaptureRequests) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
      _pendingCaptureRequests.clear();
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

  void _completePendingCaptures(CameraImageData data) {
    if (_pendingCaptureRequests.isEmpty) {
      return;
    }
    final pending = List<Completer<CameraImageData?>>.from(_pendingCaptureRequests);
    _pendingCaptureRequests.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.complete(data);
      }
    }
  }
}

