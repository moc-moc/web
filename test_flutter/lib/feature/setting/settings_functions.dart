import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'settings_functions.g.dart';

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
@Riverpod(keepAlive: true)
class AccountSettingsNotifier extends _$AccountSettingsNotifier {
  @override
  AccountSettings build() {
    debugPrint('🔍 [AccountSettingsNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    return AccountSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(AccountSettings settings) {
    debugPrint('🔍 [AccountSettingsNotifier.updateSettings] 設定を更新');
    state = settings;
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
@Riverpod(keepAlive: true)
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  NotificationSettings build() {
    debugPrint('🔍 [NotificationSettingsNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    return NotificationSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(NotificationSettings settings) {
    debugPrint('🔍 [NotificationSettingsNotifier.updateSettings] 設定を更新');
    state = settings;
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
@Riverpod(keepAlive: true)
class DisplaySettingsNotifier extends _$DisplaySettingsNotifier {
  @override
  DisplaySettings build() {
    debugPrint('🔍 [DisplaySettingsNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    return DisplaySettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(DisplaySettings settings) {
    debugPrint('🔍 [DisplaySettingsNotifier.updateSettings] 設定を更新');
    state = settings;
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
@Riverpod(keepAlive: true)
class TimeSettingsNotifier extends _$TimeSettingsNotifier {
  @override
  TimeSettings build() {
    debugPrint('🔍 [TimeSettingsNotifier.build] ★★★ Provider初期化実行（keepAlive: true）★★★');
    return TimeSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(TimeSettings settings) {
    debugPrint('🔍 [TimeSettingsNotifier.updateSettings] 設定を更新');
    state = settings;
  }
}

// ===== ヘルパー関数 =====

/// アカウント設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期されたアカウント設定
Future<AccountSettings> syncAccountSettingsHelper(dynamic ref) async {
  try {
    debugPrint('🔍 [syncAccountSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    debugPrint('🔍 [syncAccountSettingsHelper] userId: $userId');
    
    // データマネージャーで同期
    final settingsList = await accountSettingsManager.sync(userId);
    debugPrint('🔍 [syncAccountSettingsHelper] 同期完了: ${settingsList.length}件');
    
    // IDが 'account_settings' のものを探す
    AccountSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'account_settings');
      debugPrint('🔍 [syncAccountSettingsHelper] アカウント設定を取得');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = AccountSettings.defaultSettings();
      await accountSettingsManager.saveWithRetry(userId, settings);
      debugPrint('🔍 [syncAccountSettingsHelper] デフォルト設定を作成');
    }
    
    // Notifierを使用してProviderを更新
    ref.read(accountSettingsProvider.notifier).updateSettings(settings);
    debugPrint('✅ [syncAccountSettingsHelper] Provider更新完了');
    
    return settings;
  } catch (e) {
    debugPrint('❌ [syncAccountSettingsHelper] エラー: $e');
    
    // エラー時はデフォルト値を返す
    final defaultSettings = AccountSettings.defaultSettings();
    ref.read(accountSettingsProvider.notifier).updateSettings(defaultSettings);
    return defaultSettings;
  }
}

/// アカウント設定を保存するヘルパー関数
/// 
/// アカウント設定を保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `settings`: 保存するアカウント設定
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveAccountSettingsHelper(dynamic ref, AccountSettings settings) async {
  try {
    debugPrint('🔍 [saveAccountSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await accountSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(accountSettingsProvider.notifier).updateSettings(updatedSettings);
      debugPrint('✅ [saveAccountSettingsHelper] 保存成功');
    } else {
      debugPrint('❌ [saveAccountSettingsHelper] 保存失敗');
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveAccountSettingsHelper] エラー: $e');
    return false;
  }
}

// ===== 通知設定 =====

/// 通知設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期された通知設定
Future<NotificationSettings> syncNotificationSettingsHelper(dynamic ref) async {
  try {
    debugPrint('🔍 [syncNotificationSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await notificationSettingsManager.sync(userId);
    debugPrint('🔍 [syncNotificationSettingsHelper] 同期完了: ${settingsList.length}件');
    
    // IDが 'notification_settings' のものを探す
    NotificationSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'notification_settings');
      debugPrint('🔍 [syncNotificationSettingsHelper] 通知設定を取得');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = NotificationSettings.defaultSettings();
      await notificationSettingsManager.saveWithRetry(userId, settings);
      debugPrint('🔍 [syncNotificationSettingsHelper] デフォルト設定を作成');
    }
    
    // Notifierを使用してProviderを更新
    ref.read(notificationSettingsProvider.notifier).updateSettings(settings);
    debugPrint('✅ [syncNotificationSettingsHelper] Provider更新完了');
    
    return settings;
  } catch (e) {
    debugPrint('❌ [syncNotificationSettingsHelper] エラー: $e');
    
    // エラー時はデフォルト値を返す
    final defaultSettings = NotificationSettings.defaultSettings();
    ref.read(notificationSettingsProvider.notifier).updateSettings(defaultSettings);
    return defaultSettings;
  }
}

/// 通知設定を保存するヘルパー関数
/// 
/// 通知設定を保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `settings`: 保存する通知設定
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveNotificationSettingsHelper(dynamic ref, NotificationSettings settings) async {
  try {
    debugPrint('🔍 [saveNotificationSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await notificationSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(notificationSettingsProvider.notifier).updateSettings(updatedSettings);
      debugPrint('✅ [saveNotificationSettingsHelper] 保存成功');
    } else {
      debugPrint('❌ [saveNotificationSettingsHelper] 保存失敗');
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveNotificationSettingsHelper] エラー: $e');
    return false;
  }
}

// ===== 表示設定 =====

/// 表示設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期された表示設定
Future<DisplaySettings> syncDisplaySettingsHelper(dynamic ref) async {
  try {
    debugPrint('🔍 [syncDisplaySettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await displaySettingsManager.sync(userId);
    debugPrint('🔍 [syncDisplaySettingsHelper] 同期完了: ${settingsList.length}件');
    
    // IDが 'display_settings' のものを探す
    DisplaySettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'display_settings');
      debugPrint('🔍 [syncDisplaySettingsHelper] 表示設定を取得');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = DisplaySettings.defaultSettings();
      await displaySettingsManager.saveWithRetry(userId, settings);
      debugPrint('🔍 [syncDisplaySettingsHelper] デフォルト設定を作成');
    }
    
    // Notifierを使用してProviderを更新
    ref.read(displaySettingsProvider.notifier).updateSettings(settings);
    debugPrint('✅ [syncDisplaySettingsHelper] Provider更新完了');
    
    return settings;
  } catch (e) {
    debugPrint('❌ [syncDisplaySettingsHelper] エラー: $e');
    
    // エラー時はデフォルト値を返す
    final defaultSettings = DisplaySettings.defaultSettings();
    ref.read(displaySettingsProvider.notifier).updateSettings(defaultSettings);
    return defaultSettings;
  }
}

/// 表示設定を保存するヘルパー関数
/// 
/// 表示設定を保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `settings`: 保存する表示設定
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveDisplaySettingsHelper(dynamic ref, DisplaySettings settings) async {
  try {
    debugPrint('🔍 [saveDisplaySettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await displaySettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(displaySettingsProvider.notifier).updateSettings(updatedSettings);
      debugPrint('✅ [saveDisplaySettingsHelper] 保存成功');
    } else {
      debugPrint('❌ [saveDisplaySettingsHelper] 保存失敗');
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveDisplaySettingsHelper] エラー: $e');
    return false;
  }
}

// ===== 時間設定 =====

/// 時間設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期された時間設定
Future<TimeSettings> syncTimeSettingsHelper(dynamic ref) async {
  try {
    debugPrint('🔍 [syncTimeSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await timeSettingsManager.sync(userId);
    debugPrint('🔍 [syncTimeSettingsHelper] 同期完了: ${settingsList.length}件');
    
    // IDが 'time_settings' のものを探す
    TimeSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'time_settings');
      debugPrint('🔍 [syncTimeSettingsHelper] 時間設定を取得');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = TimeSettings.defaultSettings();
      await timeSettingsManager.saveWithRetry(userId, settings);
      debugPrint('🔍 [syncTimeSettingsHelper] デフォルト設定を作成');
    }
    
    // Notifierを使用してProviderを更新
    ref.read(timeSettingsProvider.notifier).updateSettings(settings);
    debugPrint('✅ [syncTimeSettingsHelper] Provider更新完了');
    
    return settings;
  } catch (e) {
    debugPrint('❌ [syncTimeSettingsHelper] エラー: $e');
    
    // エラー時はデフォルト値を返す
    final defaultSettings = TimeSettings.defaultSettings();
    ref.read(timeSettingsProvider.notifier).updateSettings(defaultSettings);
    return defaultSettings;
  }
}

/// 時間設定を保存するヘルパー関数
/// 
/// 時間設定を保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `settings`: 保存する時間設定
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveTimeSettingsHelper(dynamic ref, TimeSettings settings) async {
  try {
    debugPrint('🔍 [saveTimeSettingsHelper] 開始');
    
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await timeSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(timeSettingsProvider.notifier).updateSettings(updatedSettings);
      debugPrint('✅ [saveTimeSettingsHelper] 保存成功');
    } else {
      debugPrint('❌ [saveTimeSettingsHelper] 保存失敗');
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveTimeSettingsHelper] エラー: $e');
    return false;
  }
}
