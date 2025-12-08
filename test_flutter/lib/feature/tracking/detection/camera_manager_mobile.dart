import 'dart:async';
import 'package:camera/camera.dart';
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
  bool _isStreaming = false;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  Stream<CameraImageData>? get imageStream => _imageStreamController?.stream;

  @override
  double? get aspectRatio {
    if (!isInitialized || _controller == null) {
      return null;
    }
    return _controller!.value.aspectRatio;
  }

  /// カメラコントローラーを取得（プレビュー表示用）
  CameraController? get controller => _controller;

  @override
  Future<bool> initialize() async {
    try {
      // カメラ一覧の取得
      // availableCameras()は内部でカメラ権限をチェックし、
      // 未許可の場合はiOSが自動的にダイアログを表示する
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        LogMk.logError(
          '利用可能なカメラが見つかりません。カメラへのアクセスが許可されているか確認してください。',
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

      // CameraControllerの初期化
      // ここでもカメラ権限がチェックされ、未許可の場合はiOSがダイアログを表示する
      try {
        await _controller!.initialize();
      } on CameraException catch (e) {
        LogMk.logError(
          'カメラ初期化エラー: ${e.code} - ${e.description}',
          tag: 'CameraManagerMobile.initialize',
        );
        
        // カメラ権限が拒否されている場合の詳細なメッセージ
        if (e.code == 'CameraAccessDenied' || 
            e.description?.toLowerCase().contains('permission') == true) {
          LogMk.logError(
            'カメラへのアクセスが拒否されました。\n'
            'iPhoneの設定 > Test Flutter > カメラ でアクセスを許可してください。',
            tag: 'CameraManagerMobile.initialize',
          );
        }
        
        await dispose();
        return false;
      }

      // 映像ストリームの設定
      _imageStreamController = StreamController<CameraImageData>.broadcast();
      await _startImageStream();

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

      await _stopImageStream();
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

  Future<void> _startImageStream() async {
    if (_controller == null) {
      return;
    }
    if (_controller!.value.isStreamingImages || _isStreaming) {
      return;
    }
    await _controller!.startImageStream(_handleCameraImage);
    _isStreaming = true;
  }

  Future<void> _stopImageStream() async {
    if (!(_controller?.value.isStreamingImages ?? false)) {
      _isStreaming = false;
      return;
    }
    await _controller!.stopImageStream();
    _isStreaming = false;
  }

  void _handleCameraImage(CameraImage image) {
    if (_imageStreamController != null && !_imageStreamController!.isClosed) {
      final data = CameraImageData.fromMobile(image);
      _imageStreamController!.add(data);
      _latestCameraImage = image;
      _completePendingCaptures(data);
    } else {
      _latestCameraImage = image;
      _completePendingCaptures(CameraImageData.fromMobile(image));
    }
  }

  @override
  Future<void> pause() async {
    await _stopImageStream();
  }

  @override
  Future<void> resume() async {
    if (_controller == null) {
      return;
    }
    await _startImageStream();
  }
}

