import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/feature/tracking/detection/camera_image_data.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// Web版カメラ管理クラス
/// 
/// Web向けのカメラ実装（getUserMedia API使用）
class CameraManagerWeb implements CameraManager {
  html.MediaStream? _stream;
  html.VideoElement? _videoElement;
  bool _isInitialized = false;
  StreamController<CameraImageData>? _imageStreamController;
  Timer? _imageCaptureTimer;
  int _imageWidth = 640;
  int _imageHeight = 480;

  @override
  bool get isInitialized => _isInitialized && _videoElement != null;

  @override
  Stream<CameraImageData>? get imageStream => _imageStreamController?.stream;

  /// VideoElementへのアクセス（Web版のプレビュー表示用）
  html.VideoElement? get videoElement => _videoElement;

  @override
  Future<bool> initialize() async {
    try {
      // ブラウザのgetUserMedia APIを使用してカメラにアクセス
      if (html.window.navigator.mediaDevices == null) {
        LogMk.logError(
          'このブラウザはカメラアクセスをサポートしていません',
          tag: 'CameraManagerWeb.initialize',
        );
        return false;
      }

      // カメラ権限の要求（ブラウザが自動でダイアログを表示）
      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': true});

      // ビデオ要素を作成してストリームを設定
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..srcObject = _stream;

      // ビデオが読み込まれるまで待機
      await _videoElement!.onLoadedMetadata.first;

      // 画像サイズを取得
      _imageWidth = _videoElement!.videoWidth;
      _imageHeight = _videoElement!.videoHeight;

      // 画像ストリームの設定
      _imageStreamController = StreamController<CameraImageData>.broadcast();
      _startImageCapture();

      _isInitialized = true;
      LogMk.logDebug(
        'カメラ初期化完了（Web版）',
        tag: 'CameraManagerWeb.initialize',
      );
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        'カメラ初期化エラー: $e',
        tag: 'CameraManagerWeb.initialize',
        stackTrace: stackTrace,
      );
      await dispose();
      return false;
    }
  }

  /// 画像キャプチャを開始
  /// 
  /// Canvasを使ってビデオから画像を定期的に取得
  void _startImageCapture() {
    html.CanvasElement? canvas;
    html.CanvasRenderingContext2D? ctx;

    _imageCaptureTimer = Timer.periodic(
      const Duration(milliseconds: 100), // 10FPS
      (timer) {
        if (!_isInitialized ||
            _videoElement == null ||
            _imageStreamController == null ||
            _imageStreamController!.isClosed) {
          timer.cancel();
          return;
        }

        try {
          // Canvasが未作成の場合は作成
          if (canvas == null) {
            canvas = html.CanvasElement(
              width: _imageWidth,
              height: _imageHeight,
            );
            final context = canvas?.getContext('2d');
            if (context != null && context is html.CanvasRenderingContext2D) {
              ctx = context;
            } else {
              timer.cancel();
              return;
            }
          }

          // ビデオから画像を描画
          if (ctx != null) {
            ctx!.drawImageScaled(
              _videoElement!,
              0,
              0,
              _imageWidth,
              _imageHeight,
            );
          }

          // Canvasから画像データを取得（JPEG形式）
          final currentCanvas = canvas;
          if (currentCanvas != null) {
            currentCanvas.toBlob('image/jpeg', 0.8).then((blob) {
              // BlobをUint8Listに変換
              final reader = html.FileReader();
              reader.onLoad.listen((event) {
                final result = reader.result;
                if (result != null) {
                  // ArrayBufferをUint8Listに変換
                  // ignore: avoid_web_libraries_in_flutter
                  final bytes = Uint8List.view(result as dynamic);
                  
                  if (!_imageStreamController!.isClosed) {
                    _imageStreamController!.add(
                      CameraImageData.fromWeb(
                        imageBytes: bytes,
                        width: _imageWidth,
                        height: _imageHeight,
                      ),
                    );
                  }
                }
              });
              
              reader.readAsArrayBuffer(blob);
            });
          }
        } catch (e, stackTrace) {
          LogMk.logError(
            '画像キャプチャエラー: $e',
            tag: 'CameraManagerWeb._startImageCapture',
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  @override
  Future<CameraImageData?> captureImage() async {
    if (!isInitialized || _videoElement == null) {
      LogMk.logError(
        'カメラが初期化されていません',
        tag: 'CameraManagerWeb.captureImage',
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
        tag: 'CameraManagerWeb.captureImage',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      _imageCaptureTimer?.cancel();
      _imageCaptureTimer = null;

      await _imageStreamController?.close();
      _imageStreamController = null;

      // ストリームの各トラックを停止
      _stream?.getTracks().forEach((track) {
        track.stop();
      });
      _stream = null;

      _videoElement?.remove();
      _videoElement = null;

      _isInitialized = false;
      LogMk.logDebug(
        'カメラリソース解放完了（Web版）',
        tag: 'CameraManagerWeb.dispose',
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        'カメラリソース解放エラー: $e',
        tag: 'CameraManagerWeb.dispose',
        stackTrace: stackTrace,
      );
    }
  }
}

