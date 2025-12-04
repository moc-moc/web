import 'package:flutter/foundation.dart';

/// Google Mobile Ads の広告ユニットIDを一元管理するためのクラス。
/// 実際のIDを発行したら、下記のテストIDを差し替えてください。
class AdHelper {
  const AdHelper._();

  static bool get isMobileSupported => !kIsWeb;

  static String get friendFeedNativeId =>
      _friendFeedNative.resolveForCurrentPlatform();
  static String get trackingCameraOffNativeId =>
      _trackingCameraOffNative.resolveForCurrentPlatform();
  static String get trackingCameraOnBannerId =>
      _trackingCameraOnBanner.resolveForCurrentPlatform();

  static const _friendFeedNative = _AdUnitConfig(
    androidId: 'ca-app-pub-3940256099942544/2247696110',
    iosId: 'ca-app-pub-3940256099942544/3986624511',
  );

  static const _trackingCameraOffNative = _AdUnitConfig(
    androidId: 'ca-app-pub-3940256099942544/2247696110',
    iosId: 'ca-app-pub-3940256099942544/3986624511',
  );

  static const _trackingCameraOnBanner = _AdUnitConfig(
    androidId: 'ca-app-pub-3940256099942544/6300978111',
    iosId: 'ca-app-pub-3940256099942544/2934735716',
  );
}

class _AdUnitConfig {
  const _AdUnitConfig({
    required this.androidId,
    required this.iosId,
  });

  final String androidId;
  final String iosId;

  String resolveForCurrentPlatform() {
    if (kIsWeb) {
      throw UnsupportedError('Google Mobile AdsはFlutter Webでサポートされていません');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return iosId;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return androidId;
    }
  }
}

