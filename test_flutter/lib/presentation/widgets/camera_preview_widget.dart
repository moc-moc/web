import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:test_flutter/feature/tracking/detection/camera_manager.dart';
import 'package:test_flutter/core/theme.dart';

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
    if (kIsWeb) {
      if (widget.isVisible && !oldWidget.isVisible) {
        // カメラがオンになったら再登録
        _registerWebView();
      } else if (!widget.isVisible && oldWidget.isVisible) {
        // カメラがオフになったら登録をクリア
        _viewId = null;
        _isRegistered = false;
      }
    }
  }

  /// Web版のプラットフォームビューを登録
  void _registerWebView() {
    if (!kIsWeb || _isRegistered || !widget.isVisible) return;

    try {
      final webManager = widget.cameraManager as dynamic;
      final videoElement = webManager.videoElement as html.VideoElement?;

      if (videoElement == null) {
        // VideoElementがまだ準備できていない場合は、少し待ってから再試行
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.isVisible) {
            _registerWebView();
          }
        });
        return;
      }

      // 一意のIDを生成
      _viewId = 'camera-preview-${DateTime.now().millisecondsSinceEpoch}';

      // VideoElementのスタイルを設定
      videoElement.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'cover'
        ..borderRadius = '0px'
        ..display = 'block';

      // プラットフォームビューとして登録
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId!,
        (int viewId) => videoElement,
      );

      setState(() {
        _isRegistered = true;
      });
    } catch (e) {
      debugPrint('Web版カメラビュー登録エラー: $e');
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: SizedBox(
        width: double.infinity,
        height: 280,
        child: HtmlElementView(
          viewType: _viewId!,
        ),
      ),
    );
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
