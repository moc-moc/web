// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 時間設定を管理するNotifier
///
/// 時間設定（一日の区切り時刻）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(timeSettingsProvider);
/// ref.read(timeSettingsProvider.notifier).updateSettings(newSettings);
/// ```

@ProviderFor(TimeSettingsNotifier)
const timeSettingsProvider = TimeSettingsNotifierProvider._();

/// 時間設定を管理するNotifier
///
/// 時間設定（一日の区切り時刻）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(timeSettingsProvider);
/// ref.read(timeSettingsProvider.notifier).updateSettings(newSettings);
/// ```
final class TimeSettingsNotifierProvider
    extends $NotifierProvider<TimeSettingsNotifier, TimeSettings> {
  /// 時間設定を管理するNotifier
  ///
  /// 時間設定（一日の区切り時刻）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final settings = ref.watch(timeSettingsProvider);
  /// ref.read(timeSettingsProvider.notifier).updateSettings(newSettings);
  /// ```
  const TimeSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeSettingsNotifierHash();

  @$internal
  @override
  TimeSettingsNotifier create() => TimeSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeSettings>(value),
    );
  }
}

String _$timeSettingsNotifierHash() =>
    r'9407c6659e62b59efa1ae824a6f47b75c6b8debb';

/// 時間設定を管理するNotifier
///
/// 時間設定（一日の区切り時刻）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(timeSettingsProvider);
/// ref.read(timeSettingsProvider.notifier).updateSettings(newSettings);
/// ```

abstract class _$TimeSettingsNotifier extends $Notifier<TimeSettings> {
  TimeSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimeSettings, TimeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimeSettings, TimeSettings>,
              TimeSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
