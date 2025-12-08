import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';
import 'dart:js' as js if (dart.library.js) 'dart:js';

/// Web版用のバナー広告Widget
/// 
/// Google AdSense/Ad Managerの広告を表示します。
/// 実際の広告ユニットIDは `web/index.html` にスクリプトを追加し、
/// このWidgetの `data-ad-client` と `data-ad-slot` を設定してください。
class WebBannerAd extends StatefulWidget {
  /// 広告の高さ（デフォルト: 100px）
  final double height;
  
  /// 広告の幅（デフォルト: 320px）
  final double width;
  
  /// AdSenseのクライアントID（例: ca-pub-xxxxxxxx）
  /// 未設定の場合はプレースホルダーを表示
  final String? adClientId;
  
  /// 広告スロットID（例: yyyyyyyy）
  /// 未設定の場合はプレースホルダーを表示
  final String? adSlotId;

  const WebBannerAd({
    super.key,
    this.height = 100,
    this.width = 320,
    this.adClientId,
    this.adSlotId,
  });

  @override
  State<WebBannerAd> createState() => _WebBannerAdState();
}

class _WebBannerAdState extends State<WebBannerAd> {
  late final String _viewType;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'web-banner-ad-${DateTime.now().millisecondsSinceEpoch}';
    
    if (kIsWeb && widget.adClientId != null && widget.adSlotId != null) {
      _registerViewFactory();
    }
  }

  void _registerViewFactory() {
    if (_isRegistered) return;
    
    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final html.Element element = html.Element.html('''
          <ins class="adsbygoogle"
               style="display:block; width:${widget.width}px; height:${widget.height}px;"
               data-ad-client="${widget.adClientId}"
               data-ad-slot="${widget.adSlotId}"
               data-ad-format="auto"
               data-full-width-responsive="true"></ins>
        ''');
        
        // adsbygoogle.push()を実行
        html.window.console.log('adsbygoogle push for $_viewType');
        try {
          final adsbygoogle = js.context['adsbygoogle'];
          if (adsbygoogle != null) {
            (adsbygoogle as js.JsArray).callMethod('push', [js.JsObject.jsify({})]);
          }
        } catch (e) {
          html.window.console.warn('adsbygoogle.push() failed: $e');
        }
        
        return element;
      });
      _isRegistered = true;
    } catch (e) {
      debugPrint('❌ Web広告の登録エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    if (widget.adClientId == null || widget.adSlotId == null) {
      return _buildPlaceholder();
    }

    if (!_isRegistered) {
      return _buildPlaceholder();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ad_units,
              color: Color(0xFF666666),
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              '広告を読み込み中...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

