import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/services/log_service.dart';

// Web版用のインポート
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// カメラプレビューウィジェット
/// 
/// Web版とモバイル版の両方に対応
class CameraPreviewWidget extends StatefulWidget {
  final CameraManager cameraManager;
  final bool isVisible;

  const CameraPreviewWidget({
    super.key,
    required this.cameraManager,
    this.isVisible = true,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  String? _viewId;
  bool _isRegistered = false;
  int _registrationCounter = 0;
  Widget? _cachedHtmlElementView; // HtmlElementViewをキャッシュ

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.isVisible) {
      _registerWebView();
    }
  }

  @override
  void didUpdateWidget(CameraPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // カメラマネージャーが変わった場合は再登録が必要
    final cameraManagerChanged = oldWidget.cameraManager != widget.cameraManager;
    
    if (kIsWeb) {
      if (widget.isVisible && !oldWidget.isVisible) {
        // カメラがオンになったら再登録（新しいIDで）
        LogMk.logDebug(
          'カメラがオンになりました。再登録を開始します。',
          tag: 'CameraPreviewWidget.didUpdateWidget',
        );
        _isRegistered = false;
        _viewId = null;
        _registerWebView();
      } else if (!widget.isVisible && oldWidget.isVisible) {
        // カメラがオフになったら登録をクリア
        LogMk.logDebug(
          'カメラがオフになりました。登録をクリアします。',
          tag: 'CameraPreviewWidget.didUpdateWidget',
        );
        _viewId = null;
        _isRegistered = false;
        _cachedHtmlElementView = null; // キャッシュもクリア
      } else if (widget.isVisible && oldWidget.isVisible && cameraManagerChanged) {
        // カメラマネージャーが変わった場合は再登録
        LogMk.logDebug(
          'カメラマネージャーが変更されました。再登録を開始します。',
          tag: 'CameraPreviewWidget.didUpdateWidget',
        );
        _isRegistered = false;
        _viewId = null;
        _cachedHtmlElementView = null; // キャッシュもクリア
        _registerWebView();
      }
      // それ以外の場合は何もしない（同じ状態の場合は再登録不要）
    }
  }

  /// Web版のプラットフォームビューを登録
  void _registerWebView() {
    if (!kIsWeb || _isRegistered || !widget.isVisible) {
      return;
    }

    try {
      final webManager = widget.cameraManager as dynamic;
      final videoElement = webManager.videoElement as html.VideoElement?;

      if (videoElement == null) {
        // VideoElementがまだ準備できていない場合は、少し待ってから再試行
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.isVisible && !_isRegistered) {
            _registerWebView();
          }
        });
        return;
      }

      // 一意のIDを生成（カウンターを使用して確実に一意にする）
      _registrationCounter++;
      _viewId = 'camera-preview-${DateTime.now().millisecondsSinceEpoch}-$_registrationCounter';

      // VideoElementのスタイルを設定
      videoElement.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'cover'
        ..borderRadius = '0px'
        ..display = 'block';

      // プラットフォームビューとして登録
      // 注意: 同じIDで再登録しようとするとエラーになるため、必ず新しいIDを使用
      // 各プラットフォームビューで独立したVideoElementを作成して、同じストリームを参照する
      // これにより、古いプラットフォームビューが無効になっても新しいビューが正常に動作する
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId!,
        (int viewId) {
          // 新しいVideoElementを作成して、同じストリームを参照する
          final newVideoElement = html.VideoElement()
            ..autoplay = true
            ..muted = true
            ..setAttribute('playsinline', 'true')
            ..srcObject = videoElement.srcObject // 同じストリームを参照
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.borderRadius = '0px'
            ..style.display = 'block';
          return newVideoElement;
        },
      );

      // HtmlElementViewをキャッシュに保存
      _cachedHtmlElementView = ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: SizedBox(
          width: double.infinity,
          height: 280,
          child: HtmlElementView(
            key: ValueKey(_viewId!),
            viewType: _viewId!,
          ),
        ),
      );

      setState(() {
        _isRegistered = true;
      });
    } catch (e, stackTrace) {
      LogMk.logError(
        'Web版カメラビュー登録エラー: $e',
        tag: 'CameraPreviewWidget._registerWebView',
        stackTrace: stackTrace,
      );
      // エラーが発生した場合は、登録状態をリセットして再試行可能にする
      setState(() {
        _isRegistered = false;
        _viewId = null;
        _cachedHtmlElementView = null; // キャッシュもクリア
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return Container(
        color: AppColors.backgroundCard,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                size: 64,
                color: AppColors.textDisabled,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Camera Off',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb) {
      return _buildWebPreview();
    } else {
      return _buildMobilePreview();
    }
  }

  /// Web版のプレビュー
  Widget _buildWebPreview() {
    if (!_isRegistered || _viewId == null) {
      return Container(
        color: AppColors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text(
                'カメラを読み込み中...',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // キャッシュされたHtmlElementViewがあれば再利用
    if (_cachedHtmlElementView != null) {
      return _cachedHtmlElementView!;
    }
    
    // キャッシュがない場合は新規作成（通常は発生しない）
    final htmlElementView = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: SizedBox(
        width: double.infinity,
        height: 280,
        child: HtmlElementView(
          key: ValueKey(_viewId!),
          viewType: _viewId!,
        ),
      ),
    );
    
    // キャッシュに保存
    _cachedHtmlElementView = htmlElementView;
    
    return htmlElementView;
  }

  /// モバイル版のプレビュー
  Widget _buildMobilePreview() {
    final mobileManager = widget.cameraManager as dynamic;
    final controller = mobileManager.controller as CameraController?;

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: AppColors.backgroundCard,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text(
                'カメラを初期化中...',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
