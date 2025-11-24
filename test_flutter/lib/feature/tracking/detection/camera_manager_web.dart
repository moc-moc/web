import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/feature/tracking/detection/camera_performance_config.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// Web版カメラ管理クラス
/// 
/// Web向けのカメラ実装（getUserMedia API使用）
class CameraManagerWeb implements CameraManager {
  html.MediaStream? _stream;
  html.VideoElement? _videoElement;
  bool _isInitialized = false;
  int _imageWidth = 640;
  int _imageHeight = 480;
  html.CanvasElement? _captureCanvas;
  html.CanvasRenderingContext2D? _captureContext;
  bool? _lastLowQualitySetting;

  @override
  bool get isInitialized => _isInitialized && _videoElement != null;

  @override
  Stream<CameraImageData>? get imageStream => null;

  /// VideoElementへのアクセス（Web版のプレビュー表示用）
  html.VideoElement? get videoElement => _videoElement;

  @override
  Future<bool> initialize() async {
    try {
      final desiredLowQuality = CameraPerformanceConfig.isLowQuality;
      if (_isInitialized &&
          _stream != null &&
          _videoElement != null &&
          _lastLowQualitySetting == desiredLowQuality) {
        LogMk.logDebug(
          '📷 [CameraManagerWeb] 既存ストリームを再利用します',
          tag: 'CameraManagerWeb.initialize',
        );
        await resume();
        return true;
      }

      LogMk.logDebug(
        '📷 [CameraManagerWeb] カメラ初期化開始',
        tag: 'CameraManagerWeb.initialize',
      );
      
      // ブラウザのgetUserMedia APIを使用してカメラにアクセス
      LogMk.logDebug(
        '📷 [CameraManagerWeb] mediaDevices確認中...',
        tag: 'CameraManagerWeb.initialize',
      );
      
      if (html.window.navigator.mediaDevices == null) {
        LogMk.logError(
          '❌ [CameraManagerWeb] このブラウザはカメラアクセスをサポートしていません',
          tag: 'CameraManagerWeb.initialize',
        );
        return false;
      }

      LogMk.logDebug(
        '📷 [CameraManagerWeb] getUserMedia呼び出し開始（権限要求）',
        tag: 'CameraManagerWeb.initialize',
      );
      
      // カメラ権限の要求（ブラウザが自動でダイアログを表示）
      final requestStartTime = DateTime.now();
      final constraints = CameraPerformanceConfig.webVideoConstraints();
      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia(constraints);
      final requestDuration = DateTime.now().difference(requestStartTime).inMilliseconds;
      
      LogMk.logDebug(
        '✅ [CameraManagerWeb] getUserMedia成功 (所要時間: ${requestDuration}ms)',
        tag: 'CameraManagerWeb.initialize',
      );
      
      if (_stream == null) {
        LogMk.logError(
          '❌ [CameraManagerWeb] ストリームがnullです',
          tag: 'CameraManagerWeb.initialize',
        );
        return false;
      }
      
      LogMk.logDebug(
        '📷 [CameraManagerWeb] VideoElement作成開始',
        tag: 'CameraManagerWeb.initialize',
      );

      // ビデオ要素を作成してストリームを設定
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..srcObject = _stream;

      LogMk.logDebug(
        '📷 [CameraManagerWeb] ビデオメタデータ読み込み待機中...',
        tag: 'CameraManagerWeb.initialize',
      );

      // ビデオのメタデータが読み込まれるまで待機
      await _videoElement!.onLoadedMetadata.first;

      // 画像サイズを取得
      _imageWidth = _videoElement!.videoWidth;
      _imageHeight = _videoElement!.videoHeight;
      
      LogMk.logDebug(
        '📷 [CameraManagerWeb] ビデオサイズ取得: ${_imageWidth}x$_imageHeight',
        tag: 'CameraManagerWeb.initialize',
      );
      
      // 明示的にビデオ再生を開始（autoplayが動作しない場合に備えて）
      LogMk.logDebug(
        '📷 [CameraManagerWeb] ビデオ再生開始...',
        tag: 'CameraManagerWeb.initialize',
      );
      
      try {
        await _videoElement!.play();
        LogMk.logDebug(
          '✅ [CameraManagerWeb] ビデオ再生開始成功',
          tag: 'CameraManagerWeb.initialize',
        );
      } catch (e) {
        LogMk.logWarning(
          '⚠️ [CameraManagerWeb] ビデオ再生開始エラー（autoplayで再生される可能性あり）: $e',
          tag: 'CameraManagerWeb.initialize',
        );
      }
      
      // ビデオが実際に再生開始されるまで待機
      LogMk.logDebug(
        '📷 [CameraManagerWeb] ビデオの再生開始イベント待機中...',
        tag: 'CameraManagerWeb.initialize',
      );
      
      // onPlayingイベントを待機（タイムアウト付き）
      final playingCompleter = Completer<void>();
      late StreamSubscription playingSub;
      
      playingSub = _videoElement!.onPlaying.listen((event) {
        if (!playingCompleter.isCompleted) {
          LogMk.logDebug(
            '✅ [CameraManagerWeb] ビデオ再生開始イベント受信',
            tag: 'CameraManagerWeb.initialize',
          );
          playingCompleter.complete();
          playingSub.cancel();
        }
      });
      
      // タイムアウト設定（3秒）
      Timer(const Duration(seconds: 3), () {
        if (!playingCompleter.isCompleted) {
          LogMk.logWarning(
            '⚠️ [CameraManagerWeb] ビデオ再生開始イベントのタイムアウト（3秒）- 続行します',
            tag: 'CameraManagerWeb.initialize',
          );
          playingCompleter.complete();
          playingSub.cancel();
        }
      });
      
      await playingCompleter.future;
      
      // ビデオの再生状態を確認
      if (_videoElement!.paused) {
        LogMk.logWarning(
          '⚠️ [CameraManagerWeb] ビデオがpaused状態です。再生を試みます...',
          tag: 'CameraManagerWeb.initialize',
        );
        try {
          await _videoElement!.play();
        } catch (e) {
          LogMk.logError(
            '❌ [CameraManagerWeb] ビデオ再生失敗: $e',
            tag: 'CameraManagerWeb.initialize',
          );
        }
      } else {
        LogMk.logDebug(
          '✅ [CameraManagerWeb] ビデオ再生中（paused: false）',
          tag: 'CameraManagerWeb.initialize',
        );
      }

      _isInitialized = true;
      _lastLowQualitySetting = desiredLowQuality;
      LogMk.logDebug(
        '✅ [CameraManagerWeb] カメラ初期化完了（Web版）',
        tag: 'CameraManagerWeb.initialize',
      );
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [CameraManagerWeb] カメラ初期化エラー: $e',
        tag: 'CameraManagerWeb.initialize',
        stackTrace: stackTrace,
      );
      await dispose();
      return false;
    }
  }

  @override
  Future<CameraImageData?> captureImage() async {
    if (!isInitialized || _videoElement == null) {
      LogMk.logError(
        '❌ [CameraManagerWeb] カメラが初期化されていません (isInitialized: $isInitialized, videoElement: ${_videoElement != null})',
        tag: 'CameraManagerWeb.captureImage',
      );
      return null;
    }

    try {
      if (_videoElement!.paused) {
        try {
          await _videoElement!.play();
        } catch (e) {
          LogMk.logWarning(
            '⚠️ [CameraManagerWeb] ビデオ再生開始に失敗しましたが、キャプチャを続行します: $e',
            tag: 'CameraManagerWeb.captureImage',
          );
        }
      }

      final bytes = await _captureFrameBytes();
      if (bytes == null) {
        LogMk.logError(
          '❌ [CameraManagerWeb] フレーム取得に失敗しました',
          tag: 'CameraManagerWeb.captureImage',
        );
        return null;
      }

      return CameraImageData.fromWeb(
        imageBytes: bytes,
        width: _imageWidth,
        height: _imageHeight,
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [CameraManagerWeb] 画像取得エラー: $e',
        tag: 'CameraManagerWeb.captureImage',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<Uint8List?> _captureFrameBytes() async {
    if (_videoElement == null) {
      return null;
    }

    final width = _imageWidth == 0 ? 640 : _imageWidth;
    final height = _imageHeight == 0 ? 480 : _imageHeight;

    if (_captureCanvas == null ||
        _captureCanvas!.width != width ||
        _captureCanvas!.height != height) {
      _captureCanvas = html.CanvasElement(width: width, height: height);
      final context = _captureCanvas!.getContext('2d');
      if (context is html.CanvasRenderingContext2D) {
        _captureContext = context;
      } else {
        LogMk.logError(
          '❌ [CameraManagerWeb] Canvasコンテキスト取得に失敗しました',
          tag: 'CameraManagerWeb._captureFrameBytes',
        );
        _captureContext = null;
        return null;
      }
    }

    final ctx = _captureContext;
    if (ctx == null) {
      return null;
    }

    ctx.drawImageScaled(
      _videoElement!,
      0,
      0,
      width,
      height,
    );

    final completer = Completer<Uint8List?>();
    _captureCanvas!.toBlob('image/png').then((blob) {
      final reader = html.FileReader();
      reader.onError.listen((event) {
        completer.complete(null);
      });
      reader.onLoad.listen((event) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(result);
        } else if (result is ByteBuffer) {
          completer.complete(result.asUint8List());
        } else if (result is List<int>) {
          completer.complete(Uint8List.fromList(result));
        } else {
          completer.complete(null);
        }
      });
      reader.readAsArrayBuffer(blob);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  @override
  Future<void> dispose() async {
    LogMk.logDebug(
      '📷 [CameraManagerWeb] dispose呼び出し',
      tag: 'CameraManagerWeb.dispose',
    );
    
    try {
      LogMk.logDebug(
        '📷 [CameraManagerWeb] キャプチャ用リソースを解放しています...',
        tag: 'CameraManagerWeb.dispose',
      );
      _captureCanvas = null;
      _captureContext = null;

      // ストリームの各トラックを停止
      if (_stream != null) {
        final tracks = _stream!.getTracks();
        LogMk.logDebug(
          '📷 [CameraManagerWeb] ストリームトラック停止中 (トラック数: ${tracks.length})',
          tag: 'CameraManagerWeb.dispose',
        );
        for (var track in tracks) {
          track.stop();
          LogMk.logDebug(
            '📷 [CameraManagerWeb] トラック停止: ${track.kind}',
            tag: 'CameraManagerWeb.dispose',
          );
        }
        _stream = null;
      }

      LogMk.logDebug(
        '📷 [CameraManagerWeb] VideoElement削除中...',
        tag: 'CameraManagerWeb.dispose',
      );
      _videoElement?.remove();
      _videoElement = null;

      _isInitialized = false;
      _lastLowQualitySetting = null;
      LogMk.logDebug(
        '✅ [CameraManagerWeb] カメラリソース解放完了（Web版）',
        tag: 'CameraManagerWeb.dispose',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [CameraManagerWeb] カメラリソース解放エラー: $e',
        tag: 'CameraManagerWeb.dispose',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> pause() async {
    if (_videoElement == null) {
      return;
    }
    try {
      _videoElement!.pause();
      LogMk.logDebug(
        '📷 [CameraManagerWeb] プレビューを一時停止しました',
        tag: 'CameraManagerWeb.pause',
      );
    } catch (e) {
      LogMk.logWarning(
        '⚠️ [CameraManagerWeb] プレビュー一時停止に失敗しました: $e',
        tag: 'CameraManagerWeb.pause',
      );
    }
  }

  @override
  Future<void> resume() async {
    if (_videoElement == null && _stream != null) {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..srcObject = _stream;
    }

    if (_videoElement == null) {
      await initialize();
      return;
    }

    if (_videoElement!.srcObject == null && _stream != null) {
      _videoElement!.srcObject = _stream;
    }

    try {
      await _videoElement!.play();
      LogMk.logDebug(
        '📷 [CameraManagerWeb] プレビューを再開しました',
        tag: 'CameraManagerWeb.resume',
      );
    } catch (e) {
      LogMk.logWarning(
        '⚠️ [CameraManagerWeb] プレビュー再開に失敗しました: $e',
        tag: 'CameraManagerWeb.resume',
      );
    }
  }
}

