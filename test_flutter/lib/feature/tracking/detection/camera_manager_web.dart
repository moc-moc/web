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
  
  /// ストリーム閉鎖警告のカウント（最初の3回のみ警告）
  static int _closedWarningCount = 0;

  @override
  bool get isInitialized => _isInitialized && _videoElement != null;

  @override
  Stream<CameraImageData>? get imageStream => _imageStreamController?.stream;

  /// VideoElementへのアクセス（Web版のプレビュー表示用）
  html.VideoElement? get videoElement => _videoElement;

  @override
  Future<bool> initialize() async {
    try {
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
      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': true});
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

      // 画像ストリームの設定
      LogMk.logDebug(
        '📷 [CameraManagerWeb] 画像ストリーム設定開始',
        tag: 'CameraManagerWeb.initialize',
      );
      
      _imageStreamController = StreamController<CameraImageData>.broadcast();
      _startImageCapture();

      _isInitialized = true;
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

  /// 画像キャプチャを開始
  /// 
  /// Canvasを使ってビデオから画像を定期的に取得
  void _startImageCapture() {
    html.CanvasElement? canvas;
    html.CanvasRenderingContext2D? ctx;

    LogMk.logDebug(
      '📷 [CameraManagerWeb] 画像キャプチャ開始 (10FPS, 100ms間隔)',
      tag: 'CameraManagerWeb._startImageCapture',
    );

    _imageCaptureTimer = Timer.periodic(
      const Duration(milliseconds: 100), // 10FPS
      (timer) {
        if (!_isInitialized ||
            _videoElement == null ||
            _imageStreamController == null ||
            _imageStreamController!.isClosed) {
          LogMk.logDebug(
            '📷 [CameraManagerWeb] 画像キャプチャ停止 (初期化状態: $_isInitialized, videoElement: ${_videoElement != null}, streamController: ${_imageStreamController != null && !_imageStreamController!.isClosed})',
            tag: 'CameraManagerWeb._startImageCapture',
          );
          timer.cancel();
          return;
        }

        try {
          
          // Canvasが未作成の場合は作成
          if (canvas == null) {
            LogMk.logDebug(
              '📷 [CameraManagerWeb] Canvas作成: ${_imageWidth}x$_imageHeight',
              tag: 'CameraManagerWeb._startImageCapture',
            );
            canvas = html.CanvasElement(
              width: _imageWidth,
              height: _imageHeight,
            );
            final context = canvas?.getContext('2d');
            if (context != null && context is html.CanvasRenderingContext2D) {
              ctx = context;
              LogMk.logDebug(
                '✅ [CameraManagerWeb] Canvasコンテキスト取得成功',
                tag: 'CameraManagerWeb._startImageCapture',
              );
            } else {
              LogMk.logError(
                '❌ [CameraManagerWeb] Canvasコンテキスト取得失敗',
                tag: 'CameraManagerWeb._startImageCapture',
              );
              timer.cancel();
              return;
            }
            
            // 最初のキャプチャ時にビデオの再生状態を確認
            if (_videoElement!.paused) {
              LogMk.logWarning(
                '⚠️ [CameraManagerWeb] ビデオがpaused状態です。再生を試みます...',
                tag: 'CameraManagerWeb._startImageCapture',
              );
              try {
                _videoElement!.play();
              } catch (e) {
                LogMk.logError(
                  '❌ [CameraManagerWeb] ビデオ再生失敗: $e',
                  tag: 'CameraManagerWeb._startImageCapture',
                );
              }
            } else {
              LogMk.logDebug(
                '✅ [CameraManagerWeb] ビデオ再生中（readyState: ${_videoElement!.readyState}, paused: ${_videoElement!.paused}, currentTime: ${_videoElement!.currentTime}）',
                tag: 'CameraManagerWeb._startImageCapture',
              );
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
                  // FileReader.readAsArrayBuffer()の結果はUint8ListまたはNativeUint8Listとして返される
                  // Web版では、readAsArrayBuffer()の結果は既にUint8Listとして扱える
                  Uint8List bytes;
                  if (result is Uint8List) {
                    // 既にUint8Listの場合はそのまま使用
                    bytes = result;
                  } else {
                    // その他の型の場合は、バイト配列として扱う
                    // ignore: avoid_web_libraries_in_flutter
                    try {
                      // dynamic型からUint8Listに変換を試みる
                      final dynamicResult = result as dynamic;
                      // NativeUint8ListやArrayBufferの場合の処理
                      if (dynamicResult is List<int>) {
                        bytes = Uint8List.fromList(dynamicResult);
                      } else {
                        // 予期しない型の場合はスキップ
                        LogMk.logError(
                          '❌ [CameraManagerWeb] 予期しない型: ${result.runtimeType}',
                          tag: 'CameraManagerWeb._startImageCapture',
                        );
                        return;
                      }
                    } catch (e) {
                      LogMk.logError(
                        '❌ [CameraManagerWeb] 型変換エラー: $e',
                        tag: 'CameraManagerWeb._startImageCapture',
                      );
                      return;
                    }
                  }
                  
                  if (_imageStreamController != null && !_imageStreamController!.isClosed) {
                    _imageStreamController!.add(
                      CameraImageData.fromWeb(
                        imageBytes: bytes,
                        width: _imageWidth,
                        height: _imageHeight,
                      ),
                    );
                  } else {
                    // ストリームが閉じられている場合は警告のみ（最初の数回のみ）
                    if (_closedWarningCount < 3) {
                      LogMk.logWarning(
                        '⚠️ [CameraManagerWeb] ストリームが閉じられています',
                        tag: 'CameraManagerWeb._startImageCapture',
                      );
                      _closedWarningCount++;
                    }
                  }
                } else {
                  LogMk.logError(
                    '❌ [CameraManagerWeb] FileReaderの結果がnullです',
                    tag: 'CameraManagerWeb._startImageCapture',
                  );
                }
              });
              
              reader.readAsArrayBuffer(blob);
            }).catchError((error) {
              LogMk.logError(
                '❌ [CameraManagerWeb] toBlobエラー: $error',
                tag: 'CameraManagerWeb._startImageCapture',
              );
            });
          }
          
          // パフォーマンス警告は削除（ログが多すぎるため）
        } catch (e, stackTrace) {
          LogMk.logError(
            '❌ [CameraManagerWeb] 画像キャプチャエラー: $e',
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
        '❌ [CameraManagerWeb] カメラが初期化されていません (isInitialized: $isInitialized, videoElement: ${_videoElement != null})',
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
          LogMk.logWarning(
            '⚠️ [CameraManagerWeb] 画像取得タイムアウト (5秒)',
            tag: 'CameraManagerWeb.captureImage',
          );
          completer.complete(null);
          subscription.cancel();
        }
      });

      return await completer.future;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [CameraManagerWeb] 画像取得エラー: $e',
        tag: 'CameraManagerWeb.captureImage',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    LogMk.logDebug(
      '📷 [CameraManagerWeb] dispose呼び出し',
      tag: 'CameraManagerWeb.dispose',
    );
    
    try {
      LogMk.logDebug(
        '📷 [CameraManagerWeb] タイマー停止中...',
        tag: 'CameraManagerWeb.dispose',
      );
      _imageCaptureTimer?.cancel();
      _imageCaptureTimer = null;

      LogMk.logDebug(
        '📷 [CameraManagerWeb] ストリームコントローラー閉鎖中...',
        tag: 'CameraManagerWeb.dispose',
      );
      await _imageStreamController?.close();
      _imageStreamController = null;

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
}

