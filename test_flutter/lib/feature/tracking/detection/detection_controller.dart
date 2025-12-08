import 'dart:async';
import 'package:test_flutter/feature/tracking/detection/detection_result.dart';
import 'package:test_flutter/feature/tracking/detection/detection_processor.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 検出コントローラー
/// 
/// 検出タイミングの制御を担当
/// - 省電力モード: 10秒間隔での検出（yolo11l、閾値0.6）
/// - 通常モード: 3秒間隔での検出（yolo11m、閾値0.6）
class DetectionController {
  final DetectionProcessor _processor;
  final CameraManager _cameraManager;
  bool _initialModeSynced;
  bool _lastAppliedMode;

  Timer? _detectionTimer;
  bool _isPowerSavingMode = false;
  bool _isRunning = false;
  
  // 実行中の検出処理を追跡
  final Set<Future<void>> _activeDetections = {};
  
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
    bool initialModeSynced = false,
    bool initialPowerSavingMode = false,
  })  : _processor = processor,
        _cameraManager = cameraManager,
        _initialModeSynced = initialModeSynced,
        _lastAppliedMode = initialPowerSavingMode,
        _isPowerSavingMode = initialPowerSavingMode;

  /// 検出を開始
  /// 
  /// **パラメータ**:
  /// - `powerSavingMode`: 省電力モードの有効/無効
  Future<void> start({bool powerSavingMode = false}) async {
    LogMk.logDebug(
      '🎬 検出開始を試みます（省電力モード: $powerSavingMode）',
      tag: 'DetectionController.start',
    );

    if (_isRunning) {
      LogMk.logDebug(
        '⚠️ 検出は既に実行中です',
        tag: 'DetectionController.start',
      );
      return;
    }

    _isPowerSavingMode = powerSavingMode;
    _isRunning = true;

    LogMk.logDebug(
      '✅ 検出状態を実行中に設定しました（_isRunning: $_isRunning）',
      tag: 'DetectionController.start',
    );

    if (!_initialModeSynced || _lastAppliedMode != _isPowerSavingMode) {
      LogMk.logDebug(
        '🔄 モデル切り替えが必要です（initialModeSynced: $_initialModeSynced, lastAppliedMode: $_lastAppliedMode, currentMode: $_isPowerSavingMode）',
        tag: 'DetectionController.start',
      );
      try {
        final switched = await _processor.detectionService.switchModel(
          powerSavingMode: _isPowerSavingMode,
        );
        if (!switched) {
          LogMk.logWarning(
            '⚠️ 要求したモードへのモデル切り替えに失敗しました（省電力モード: $_isPowerSavingMode）',
            tag: 'DetectionController.start',
          );
        } else {
          LogMk.logDebug(
            '✅ モデル切り替え成功',
            tag: 'DetectionController.start',
          );
          _lastAppliedMode = _isPowerSavingMode;
          _initialModeSynced = true;
        }
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ モデル切り替え中にエラーが発生しましたが、処理を続行します: $e',
          tag: 'DetectionController.start',
          stackTrace: stackTrace,
        );
      }
    } else {
      LogMk.logDebug(
        '✅ モデル切り替えは不要です（既に正しいモードです）',
        tag: 'DetectionController.start',
      );
    }

    final interval =
        _isPowerSavingMode ? const Duration(seconds: 10) : const Duration(seconds: 3);
    
    LogMk.logDebug(
      '⏱️ 定期検出を開始します（間隔: ${interval.inSeconds}秒）',
      tag: 'DetectionController.start',
    );
    _startPeriodicDetection(interval);
    
    LogMk.logDebug(
      '🎉 検出開始完了',
      tag: 'DetectionController.start',
    );
  }

  /// 定期検出を開始（通常モード・省電力モード共通）
  /// 
  /// カメラストリームから指定間隔ごとに1フレームだけ取得して検出処理を実行
  /// 
  /// **パラメータ**:
  /// - `interval`: 検出間隔（通常モード: 3秒、省電力モード: 10秒）
  void _startPeriodicDetection(Duration interval) {
    bool isProcessingDetection = false; // 検出処理中フラグ

    LogMk.logDebug(
      '🔄 定期検出を開始します（間隔: ${interval.inSeconds}秒）',
      tag: 'DetectionController._startPeriodicDetection',
    );

    Future<void> runDetection() async {
      if (!_isRunning || isProcessingDetection) {
        LogMk.logDebug(
          '⏭️ 検出をスキップ（実行中: $_isRunning, 処理中: $isProcessingDetection）',
          tag: 'DetectionController.runDetection',
        );
        return;
      }

      isProcessingDetection = true;
      
      // 実行中の検出処理として追跡を開始
      final detectionFuture = _executeDetection();
      _activeDetections.add(detectionFuture);
      
      try {
        await detectionFuture;
      } finally {
        _activeDetections.remove(detectionFuture);
        isProcessingDetection = false;
      }
    }

    // 初回検出を即実行
    LogMk.logDebug(
      '🚀 初回検出を実行します',
      tag: 'DetectionController._startPeriodicDetection',
    );
    unawaited(runDetection());

    // 指定間隔で検出
    _detectionTimer = Timer.periodic(
      interval,
      (timer) {
        if (!_isRunning) {
          LogMk.logDebug(
            '⏹️ 検出が停止されているため、タイマーをキャンセルします',
            tag: 'DetectionController._startPeriodicDetection',
          );
          timer.cancel();
          return;
        }

        LogMk.logDebug(
          '⏰ タイマー発火、検出を実行します',
          tag: 'DetectionController._startPeriodicDetection',
        );
        unawaited(runDetection());
      },
    );
  }

  /// 実際の検出処理を実行
  Future<void> _executeDetection() async {
    LogMk.logDebug(
      '🔍 検出処理を開始します',
      tag: 'DetectionController.runDetection',
    );

    try {
      // カメラから1フレームだけ取得
      final image = await _cameraManager.captureImage();

      if (image == null) {
        LogMk.logWarning(
          '⚠️ カメラから画像を取得できませんでした',
          tag: 'DetectionController.runDetection',
        );
      } else {
        LogMk.logDebug(
          '📷 画像取得成功、検出処理を実行します',
          tag: 'DetectionController.runDetection',
        );
        final result = await _processor.processImage(image);
        
        if (result != null && !_resultController.isClosed) {
          LogMk.logDebug(
            '✅ 検出結果を配信: ${result.categoryString}',
            tag: 'DetectionController.runDetection',
          );
          _resultController.add(result);
        } else {
          LogMk.logWarning(
            '⚠️ 検出結果がnullまたはストリームがクローズされています',
            tag: 'DetectionController.runDetection',
          );
        }
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 検出処理エラー: $e',
        tag: 'DetectionController.runDetection',
        stackTrace: stackTrace,
      );
    } finally {
      LogMk.logDebug(
        '🏁 検出処理完了',
        tag: 'DetectionController.runDetection',
      );
    }
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
      } else {
        _lastAppliedMode = enabled;
        _initialModeSynced = true;
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

    LogMk.logDebug(
      '⏸️ 検出停止を開始します（実行中の検出数: ${_activeDetections.length}）',
      tag: 'DetectionController.stop',
    );

    _isRunning = false;
    _detectionTimer?.cancel();
    _detectionTimer = null;
    
    // 実行中の検出処理が完了するまで待機
    if (_activeDetections.isNotEmpty) {
      LogMk.logDebug(
        '⏳ 実行中の検出処理の完了を待機します（${_activeDetections.length}件）',
        tag: 'DetectionController.stop',
      );
      
      try {
        await Future.wait(
          List.from(_activeDetections),
          eagerError: false,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            LogMk.logWarning(
              '⚠️ 検出処理の完了待機がタイムアウトしました',
              tag: 'DetectionController.stop',
            );
            return [];
          },
        );
        
        LogMk.logDebug(
          '✅ すべての検出処理が完了しました',
          tag: 'DetectionController.stop',
        );
      } catch (e) {
        LogMk.logWarning(
          '⚠️ 検出処理の完了待機中にエラーが発生しました: $e',
          tag: 'DetectionController.stop',
        );
      }
    }
    
    LogMk.logDebug(
      '✅ 検出停止完了',
      tag: 'DetectionController.stop',
    );
  }

  /// リソースを解放
  Future<void> dispose() async {
    LogMk.logDebug(
      '🗑️ DetectionControllerのdisposeを開始します',
      tag: 'DetectionController.dispose',
    );
    
    // 検出を停止（実行中の処理の完了を待機）
    await stop();
    
    // 念のため、まだ実行中の処理があれば再度待機
    if (_activeDetections.isNotEmpty) {
      LogMk.logWarning(
        '⚠️ stop()後もまだ実行中の検出処理があります（${_activeDetections.length}件）',
        tag: 'DetectionController.dispose',
      );
      try {
        await Future.wait(
          List.from(_activeDetections),
          eagerError: false,
        ).timeout(const Duration(seconds: 3));
      } catch (e) {
        LogMk.logWarning(
          '⚠️ 残存する検出処理の待機中にエラー: $e',
          tag: 'DetectionController.dispose',
        );
      }
    }
    
    // すべての処理が完了したことを確認してからストリームをクローズ
    await _resultController.close();
    LogMk.logDebug(
      '✅ 結果ストリームをクローズしました',
      tag: 'DetectionController.dispose',
    );
    
    // モデルリソースの明示的な解放
    try {
      await _processor.detectionService.dispose();
      LogMk.logDebug(
        '✅ 検出モデルリソースを解放しました',
        tag: 'DetectionController.dispose',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ 検出モデルリソース解放エラー: $e',
        tag: 'DetectionController.dispose',
        stackTrace: stackTrace,
      );
    }
    
    LogMk.logDebug(
      '✅ DetectionControllerのdispose完了',
      tag: 'DetectionController.dispose',
    );
  }
}

