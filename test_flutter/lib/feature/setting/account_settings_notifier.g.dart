// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アカウント設定を管理するNotifier
///
/// アカウント設定（名前、アバター色）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(accountSettingsProvider);
/// ref.read(accountSettingsProvider.notifier).updateSettings(newSettings);
/// ```

@ProviderFor(AccountSettingsNotifier)
const accountSettingsProvider = AccountSettingsNotifierProvider._();

/// アカウント設定を管理するNotifier
///
/// アカウント設定（名前、アバター色）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(accountSettingsProvider);
/// ref.read(accountSettingsProvider.notifier).updateSettings(newSettings);
/// ```
final class AccountSettingsNotifierProvider
    extends $NotifierProvider<AccountSettingsNotifier, AccountSettings> {
  /// アカウント設定を管理するNotifier
  ///
  /// アカウント設定（名前、アバター色）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final settings = ref.watch(accountSettingsProvider);
  /// ref.read(accountSettingsProvider.notifier).updateSettings(newSettings);
  /// ```
  const AccountSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSettingsNotifierHash();

  @$internal
  @override
  AccountSettingsNotifier create() => AccountSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountSettings>(value),
    );
  }
}

String _$accountSettingsNotifierHash() =>
    r'a07fc757aebd6001bc0224ebd3569c299f863fff';

/// アカウント設定を管理するNotifier
///
/// アカウント設定（名前、アバター色）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(accountSettingsProvider);
/// ref.read(accountSettingsProvider.notifier).updateSettings(newSettings);
/// ```

abstract class _$AccountSettingsNotifier extends $Notifier<AccountSettings> {
  AccountSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AccountSettings, AccountSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountSettings, AccountSettings>,
              AccountSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
