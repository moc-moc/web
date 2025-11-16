import 'dart:async';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_processor.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 検出コントローラー
/// 
/// 検出タイミングの制御を担当
/// - 省電力モード: 5秒間隔での検出
/// - 通常モード: リアルタイム検出
class DetectionController {
  final DetectionProcessor _processor;
  final CameraManager _cameraManager;
  
  StreamSubscription<CameraImageData>? _imageSubscription;
  Timer? _detectionTimer;
  bool _isPowerSavingMode = false;
  bool _isRunning = false;
  
  final StreamController<DetectionResult> _resultController =
      StreamController<DetectionResult>.broadcast();

  /// 検出結果のストリーム
  Stream<DetectionResult> get resultStream => _resultController.stream;

  /// 省電力モードかどうか
  bool get isPowerSavingMode => _isPowerSavingMode;

  /// 検出が実行中かどうか
  bool get isRunning => _isRunning;

  /// カメラマネージャーを取得
  CameraManager get cameraManager => _cameraManager;

  DetectionController({
    required DetectionProcessor processor,
    required CameraManager cameraManager,
  })  : _processor = processor,
        _cameraManager = cameraManager;

  /// 検出を開始
  /// 
  /// **パラメータ**:
  /// - `powerSavingMode`: 省電力モードの有効/無効
  Future<void> start({bool powerSavingMode = false}) async {
    if (_isRunning) {
      LogMk.logDebug(
        '検出は既に実行中です',
        tag: 'DetectionController.start',
      );
      return;
    }

    _isPowerSavingMode = powerSavingMode;
    _isRunning = true;

    final imageStream = _cameraManager.imageStream;
    if (imageStream == null) {
      LogMk.logError(
        'カメラストリームが利用できません',
        tag: 'DetectionController.start',
      );
      _isRunning = false;
      return;
    }

    if (_isPowerSavingMode) {
      // 省電力モード: 5秒間隔で検出
      _startPeriodicDetection(imageStream);
    } else {
      // 通常モード: リアルタイム検出
      _startRealtimeDetection(imageStream);
    }

    LogMk.logDebug(
      '検出開始（省電力モード: $_isPowerSavingMode）',
      tag: 'DetectionController.start',
    );
  }

  /// リアルタイム検出を開始
  void _startRealtimeDetection(Stream<CameraImageData> imageStream) {
    _imageSubscription = imageStream.listen(
      (image) async {
        if (!_isRunning) return;

        final result = await _processor.processImage(image);
        if (result != null && !_resultController.isClosed) {
          _resultController.add(result);
        }
      },
      onError: (error, stackTrace) {
        LogMk.logError(
          '画像ストリームエラー: $error',
          tag: 'DetectionController._startRealtimeDetection',
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// 定期検出を開始（省電力モード）
  void _startPeriodicDetection(Stream<CameraImageData> imageStream) {
    CameraImageData? latestImage;

    // 最新の画像を保持
    _imageSubscription = imageStream.listen(
      (image) {
        latestImage = image;
      },
      onError: (error, stackTrace) {
        LogMk.logError(
          '画像ストリームエラー: $error',
          tag: 'DetectionController._startPeriodicDetection',
          stackTrace: stackTrace,
        );
      },
    );

    // 5秒間隔で検出
    _detectionTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (!_isRunning) {
          timer.cancel();
          return;
        }

        if (latestImage != null) {
          final result = await _processor.processImage(latestImage!);
          if (result != null && !_resultController.isClosed) {
            _resultController.add(result);
          }
        }
      },
    );
  }

  /// 省電力モードの切り替え
  /// 
  /// **パラメータ**:
  /// - `enabled`: 省電力モードの有効/無効
  Future<void> setPowerSavingMode(bool enabled) async {
    if (_isPowerSavingMode == enabled) {
      return;
    }

    final wasRunning = _isRunning;
    if (wasRunning) {
      await stop();
    }

    _isPowerSavingMode = enabled;

    if (wasRunning) {
      await start(powerSavingMode: enabled);
    }

    LogMk.logDebug(
      '省電力モード切り替え: $enabled',
      tag: 'DetectionController.setPowerSavingMode',
    );
  }

  /// 検出を停止
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    await _imageSubscription?.cancel();
    _imageSubscription = null;
    _detectionTimer?.cancel();
    _detectionTimer = null;

    LogMk.logDebug('検出停止', tag: 'DetectionController.stop');
  }

  /// リソースを解放
  Future<void> dispose() async {
    await stop();
    await _resultController.close();
  }
}

