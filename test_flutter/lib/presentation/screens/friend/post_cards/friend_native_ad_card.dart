import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:test_flutter/core/ads/ad_helper.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/web_native_ad.dart';

class FriendNativeAdCard extends StatefulWidget {
  const FriendNativeAdCard({super.key});

  @override
  State<FriendNativeAdCard> createState() => _FriendNativeAdCardState();
}

class _FriendNativeAdCardState extends State<FriendNativeAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasTriedLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AdHelper.isMobileSupported || _hasTriedLoading) return;

    _hasTriedLoading = true;

    final nativeAd = NativeAd(
      adUnitId: AdHelper.friendFeedNativeId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _nativeAd = ad as NativeAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );

    nativeAd.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: AppColors.gray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Web版の場合はWeb広告Widgetを表示
    if (kIsWeb) {
      return const WebNativeAd(
        // TODO: 実際のAdSenseのクライアントIDとスロットIDを設定してください
        // adClientId: 'ca-pub-xxxxxxxx',
        // adSlotId: 'yyyyyyyy',
      );
    }

    // モバイル版の場合はGoogle Mobile Adsを表示
    if (_isAdLoaded && _nativeAd != null) {
      return AdWidget(ad: _nativeAd!);
    }

    return _buildPlaceholder('広告を読み込み中...');
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      color: AppColors.blackgray,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ad_units,
              color: AppColors.gray,
              size: 32,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

