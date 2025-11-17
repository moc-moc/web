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
  /// 
  /// カメラストリームから5秒ごとに1フレームだけ取得して検出処理を実行
  void _startPeriodicDetection(Stream<CameraImageData> imageStream) {
    int _detectionExecuteCount = 0; // 検出実行カウント
    DateTime? _lastDetectionTime; // 最後の検出実行時刻
    bool _isProcessingDetection = false; // 検出処理中フラグ

    LogMk.logDebug(
      '省電力モード開始: 5秒間隔でカメラ画像を取得して検出を実行します',
      tag: 'DetectionController._startPeriodicDetection',
    );

    // ストリームを購読するが、5秒ごとに1フレームだけ処理
    // それ以外のフレームは破棄（省電力のため）
    _imageSubscription = imageStream.listen(
      (image) {
        // 検出処理中でない場合のみ画像を保持
        // ただし、5秒間隔のタイマーで処理するため、ここでは何もしない
        // ストリームは動作させる必要があるが、フレームは破棄
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

        if (_isProcessingDetection) {
          LogMk.logDebug(
            '⏭️ 前回の検出処理がまだ実行中のためスキップ',
            tag: 'DetectionController._startPeriodicDetection',
          );
          return;
        }

        _isProcessingDetection = true;
        _detectionExecuteCount++;
        final now = DateTime.now();
        final timeSinceLastDetection = _lastDetectionTime != null
            ? now.difference(_lastDetectionTime!).inSeconds
            : 0;
        _lastDetectionTime = now;

        LogMk.logDebug(
          '⏰ 5秒間隔タイマー実行 #$_detectionExecuteCount '
          '(${timeSinceLastDetection > 0 ? "${timeSinceLastDetection}秒前から" : "初回"})',
          tag: 'DetectionController._startPeriodicDetection',
        );

        try {
          // カメラから1フレームだけ取得
          LogMk.logDebug(
            '📷 カメラ画像取得開始',
            tag: 'DetectionController._startPeriodicDetection',
          );
          
          final captureStartTime = DateTime.now();
          final image = await _cameraManager.captureImage();
          final captureDuration = DateTime.now().difference(captureStartTime).inMilliseconds;

          if (image != null) {
            LogMk.logDebug(
              '📷 カメラ画像取得完了 (取得時間: ${captureDuration}ms)',
              tag: 'DetectionController._startPeriodicDetection',
            );
            
            LogMk.logDebug(
              '🔍 検出処理開始（画像あり）',
              tag: 'DetectionController._startPeriodicDetection',
            );
            
            final detectionStartTime = DateTime.now();
            final result = await _processor.processImage(image);
            final detectionDuration = DateTime.now().difference(detectionStartTime).inMilliseconds;
            
            if (result != null && !_resultController.isClosed) {
              LogMk.logDebug(
                '✅ 検出完了: ${result.categoryString} '
                '(信頼度: ${result.confidence.toStringAsFixed(2)}, '
                '検出処理時間: ${detectionDuration}ms, '
                '合計時間: ${captureDuration + detectionDuration}ms)',
                tag: 'DetectionController._startPeriodicDetection',
              );
              _resultController.add(result);
            } else {
              LogMk.logDebug(
                '⚠️ 検出結果なしまたはストリーム閉鎖 '
                '(検出処理時間: ${detectionDuration}ms)',
                tag: 'DetectionController._startPeriodicDetection',
              );
            }
          } else {
            LogMk.logDebug(
              '❌ カメラ画像取得失敗 (取得時間: ${captureDuration}ms)',
              tag: 'DetectionController._startPeriodicDetection',
            );
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

