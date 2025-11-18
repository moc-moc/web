import 'dart:async';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_processor.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 検出コントローラー
/// 
/// 検出タイミングの制御を担当
/// - 省電力モード: 10秒間隔での検出（yolo11l、閾値0.6）
/// - 通常モード: 3秒間隔での検出（yolo11m、閾値0.6）
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

    final rawStream = _cameraManager.imageStream;
    if (rawStream == null) {
      LogMk.logError(
        'カメラストリームが利用できません',
        tag: 'DetectionController.start',
      );
      _isRunning = false;
      return;
    }
    final imageStream = rawStream;


    try {
      final switched = await _processor.detectionService.switchModel(
        powerSavingMode: _isPowerSavingMode,
      );
      if (!switched) {
        LogMk.logWarning(
          '⚠️ 要求したモードへのモデル切り替えに失敗しました（省電力モード: $_isPowerSavingMode）',
          tag: 'DetectionController.start',
        );
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ モデル切り替え中にエラーが発生しましたが、処理を続行します: $e',
        tag: 'DetectionController.start',
        stackTrace: stackTrace,
      );
    }

    if (_isPowerSavingMode) {
      // 省電力モード: 10秒間隔で検出
      _startPeriodicDetection(imageStream, const Duration(seconds: 10));
    } else {
      // 通常モード: 3秒間隔で検出
      _startPeriodicDetection(imageStream, const Duration(seconds: 3));
    }

  }

  /// 定期検出を開始（通常モード・省電力モード共通）
  /// 
  /// カメラストリームから指定間隔ごとに1フレームだけ取得して検出処理を実行
  /// 
  /// **パラメータ**:
  /// - `imageStream`: カメラ画像ストリーム
  /// - `interval`: 検出間隔（通常モード: 3秒、省電力モード: 10秒）
  void _startPeriodicDetection(Stream<CameraImageData> imageStream, Duration interval) {
    bool _isProcessingDetection = false; // 検出処理中フラグ

    // ストリームを購読するが、指定間隔ごとに1フレームだけ処理
    // それ以外のフレームは破棄（省電力のため）
    _imageSubscription = imageStream.listen(
      (image) {
        // ストリームは動作させる必要があるが、フレームは破棄
        // タイマーで処理するため、ここでは何もしない
      },
      onError: (error, stackTrace) {
        LogMk.logError(
          '画像ストリームエラー: $error',
          tag: 'DetectionController._startPeriodicDetection',
          stackTrace: stackTrace,
        );
      },
    );

    // 指定間隔で検出
    _detectionTimer = Timer.periodic(
      interval,
      (timer) async {
        if (!_isRunning) {
          timer.cancel();
          return;
        }

        if (_isProcessingDetection) {
          return;
        }

        _isProcessingDetection = true;

        try {
          // カメラから1フレームだけ取得
          final image = await _cameraManager.captureImage();

          if (image != null) {
            final result = await _processor.processImage(image);
            
            if (result != null && !_resultController.isClosed) {
              _resultController.add(result);
            }
          }
        } finally {
          _isProcessingDetection = false;
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

    // モデルを切り替え
    // 省電力ON（10秒間隔）→ yolo11l（高精度、時間的余裕あり）
    // 省電力OFF（3秒間隔）→ yolo11m（バランス、閾値0.6で高精度化）
    try {
      final success = await _processor.detectionService.switchModel(
        powerSavingMode: enabled,
      );
      
      if (!success) {
        LogMk.logWarning(
          '⚠️ モデル切り替えに失敗しましたが、処理を続行します',
          tag: 'DetectionController.setPowerSavingMode',
        );
      }
    } catch (e) {
      LogMk.logError(
        '❌ モデル切り替え中にエラーが発生しましたが、処理を続行します: $e',
        tag: 'DetectionController.setPowerSavingMode',
      );
    }

    if (wasRunning) {
      await start(powerSavingMode: enabled);
    }

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

  }

  /// リソースを解放
  Future<void> dispose() async {
    await stop();
    await _resultController.close();
  }
}

