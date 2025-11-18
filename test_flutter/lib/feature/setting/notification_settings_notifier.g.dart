// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
    r'7c2daeb24cd5d12e9de30de03af560c073bb0e57';

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
