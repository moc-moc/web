// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_functions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 設定機能用の関数群
///
/// **提供機能**:
/// - アカウント設定管理Provider（Notifier）
/// - 通知設定管理Provider（Notifier）
/// - 表示設定管理Provider（Notifier）
/// - 時間設定管理Provider（Notifier）
/// - 同期・保存ヘルパー関数
// ===== Providers (Riverpod Generator) =====
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

/// 設定機能用の関数群
///
/// **提供機能**:
/// - アカウント設定管理Provider（Notifier）
/// - 通知設定管理Provider（Notifier）
/// - 表示設定管理Provider（Notifier）
/// - 時間設定管理Provider（Notifier）
/// - 同期・保存ヘルパー関数
// ===== Providers (Riverpod Generator) =====
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
  /// 設定機能用の関数群
  ///
  /// **提供機能**:
  /// - アカウント設定管理Provider（Notifier）
  /// - 通知設定管理Provider（Notifier）
  /// - 表示設定管理Provider（Notifier）
  /// - 時間設定管理Provider（Notifier）
  /// - 同期・保存ヘルパー関数
  // ===== Providers (Riverpod Generator) =====
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

/// 設定機能用の関数群
///
/// **提供機能**:
/// - アカウント設定管理Provider（Notifier）
/// - 通知設定管理Provider（Notifier）
/// - 表示設定管理Provider（Notifier）
/// - 時間設定管理Provider（Notifier）
/// - 同期・保存ヘルパー関数
// ===== Providers (Riverpod Generator) =====
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

/// 通知設定を管理するNotifier
///
/// 通知設定（各種通知のON/OFF、通知時間）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(notificationSettingsProvider);
/// ref.read(notificationSettingsProvider.notifier).updateSettings(newSettings);
/// ```

@ProviderFor(NotificationSettingsNotifier)
const notificationSettingsProvider = NotificationSettingsNotifierProvider._();

/// 通知設定を管理するNotifier
///
/// 通知設定（各種通知のON/OFF、通知時間）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(notificationSettingsProvider);
/// ref.read(notificationSettingsProvider.notifier).updateSettings(newSettings);
/// ```
final class NotificationSettingsNotifierProvider
    extends
        $NotifierProvider<NotificationSettingsNotifier, NotificationSettings> {
  /// 通知設定を管理するNotifier
  ///
  /// 通知設定（各種通知のON/OFF、通知時間）を管理します。
  ///
  /// **使用方法**:
  /// ```dart
  /// final settings = ref.watch(notificationSettingsProvider);
  /// ref.read(notificationSettingsProvider.notifier).updateSettings(newSettings);
  /// ```
  const NotificationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsNotifierHash();

  @$internal
  @override
  NotificationSettingsNotifier create() => NotificationSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettings>(value),
    );
  }
}

String _$notificationSettingsNotifierHash() =>
    r'3fb5871deca67f7ca8d6f3307a6374ed16c1e3ef';

/// 通知設定を管理するNotifier
///
/// 通知設定（各種通知のON/OFF、通知時間）を管理します。
///
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(notificationSettingsProvider);
/// ref.read(notificationSettingsProvider.notifier).updateSettings(newSettings);
/// ```

abstract class _$NotificationSettingsNotifier
    extends $Notifier<NotificationSettings> {
  NotificationSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NotificationSettings, NotificationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationSettings, NotificationSettings>,
              NotificationSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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
    r'a86b1ac5974eb6717f70eb83d923f5f0342b14e3';

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
    r'1e4ac94a0bba194d86249fbe99de3cbcebd97f7d';

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
