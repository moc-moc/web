// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 表示設定を管理するNotifier
///
/// 表示設定（カテゴリ名）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(displaySettingsProvider);
/// ref.read(displaySettingsProvider.notifier).updateSettings(newSettings);
/// ```

@ProviderFor(DisplaySettingsNotifier)
const displaySettingsProvider = DisplaySettingsNotifierProvider._();

/// 表示設定を管理するNotifier
///
/// 表示設定（カテゴリ名）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(displaySettingsProvider);
/// ref.read(displaySettingsProvider.notifier).updateSettings(newSettings);
/// ```
final class DisplaySettingsNotifierProvider
    extends $NotifierProvider<DisplaySettingsNotifier, DisplaySettings> {
  /// 表示設定を管理するNotifier
  ///
  /// 表示設定（カテゴリ名）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final settings = ref.watch(displaySettingsProvider);
  /// ref.read(displaySettingsProvider.notifier).updateSettings(newSettings);
  /// ```
  const DisplaySettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displaySettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displaySettingsNotifierHash();

  @$internal
  @override
  DisplaySettingsNotifier create() => DisplaySettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisplaySettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisplaySettings>(value),
    );
  }
}

String _$displaySettingsNotifierHash() =>
    r'cd5462eedf2abc2833856af58271de02233db057';

/// 表示設定を管理するNotifier
///
/// 表示設定（カテゴリ名）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(displaySettingsProvider);
/// ref.read(displaySettingsProvider.notifier).updateSettings(newSettings);
/// ```

abstract class _$DisplaySettingsNotifier extends $Notifier<DisplaySettings> {
  DisplaySettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DisplaySettings, DisplaySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DisplaySettings, DisplaySettings>,
              DisplaySettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
