// Web専用のヘルパー関数
// このファイルはWebでのみ使用される

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Web版のプラットフォームビューを登録するヘルパー関数
void registerWebCameraView({
  required String viewId,
  required dynamic videoElement,
  required Function(String, dynamic) onRegistered,
}) {
  // VideoElementのスタイルを設定
  final videoElementStyle = videoElement.style as html.CssStyleDeclaration;
  videoElementStyle.width = '100%';
  videoElementStyle.height = '100%';
  videoElementStyle.objectFit = 'cover';
  videoElementStyle.borderRadius = '0px';
  videoElementStyle.display = 'block';

  // プラットフォームビューとして登録
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
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

  onRegistered(viewId, videoElement);
}

