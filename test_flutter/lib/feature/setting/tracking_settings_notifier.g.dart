// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// トラッキング設定を管理するNotifier
///
/// トラッキング設定（カメラのオン/オフ、省電力モード）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(trackingSettingsProvider);
/// ref.read(trackingSettingsProvider.notifier).updateSettings(newSettings);
/// ```

@ProviderFor(TrackingSettingsNotifier)
const trackingSettingsProvider = TrackingSettingsNotifierProvider._();

/// トラッキング設定を管理するNotifier
///
/// トラッキング設定（カメラのオン/オフ、省電力モード）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(trackingSettingsProvider);
/// ref.read(trackingSettingsProvider.notifier).updateSettings(newSettings);
/// ```
final class TrackingSettingsNotifierProvider
    extends $NotifierProvider<TrackingSettingsNotifier, TrackingSettings> {
  /// トラッキング設定を管理するNotifier
  ///
  /// トラッキング設定（カメラのオン/オフ、省電力モード）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final settings = ref.watch(trackingSettingsProvider);
  /// ref.read(trackingSettingsProvider.notifier).updateSettings(newSettings);
  /// ```
  const TrackingSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingSettingsNotifierHash();

  @$internal
  @override
  TrackingSettingsNotifier create() => TrackingSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingSettings>(value),
    );
  }
}

String _$trackingSettingsNotifierHash() =>
    r'bc21912bd6bef2fd6a3f8527a5bc6a969101da39';

/// トラッキング設定を管理するNotifier
///
/// トラッキング設定（カメラのオン/オフ、省電力モード）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(trackingSettingsProvider);
/// ref.read(trackingSettingsProvider.notifier).updateSettings(newSettings);
/// ```

abstract class _$TrackingSettingsNotifier extends $Notifier<TrackingSettings> {
  TrackingSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TrackingSettings, TrackingSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackingSettings, TrackingSettings>,
              TrackingSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
