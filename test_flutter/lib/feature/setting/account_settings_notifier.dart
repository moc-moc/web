import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'account_settings_notifier.g.dart';

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
    return AccountSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(AccountSettings settings) {
    state = settings;
  }
}

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
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await accountSettingsManager.sync(userId);
    
    // IDが 'account_settings' のものを探す
    AccountSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'account_settings');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = AccountSettings.defaultSettings();
      await accountSettingsManager.saveWithRetry(userId, settings);
    }
    
    // Notifierを使用してProviderを更新
    ref.read(accountSettingsProvider.notifier).updateSettings(settings);
    
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
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await accountSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(accountSettingsProvider.notifier).updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveAccountSettingsHelper] エラー: $e');
    return false;
  }
}

