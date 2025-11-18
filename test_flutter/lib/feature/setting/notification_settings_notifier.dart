import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'notification_settings_notifier.g.dart';

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
    return NotificationSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(NotificationSettings settings) {
    state = settings;
  }
}

/// 通知設定をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだ通知設定（ローカルまたはデフォルト値）
Future<NotificationSettings> loadNotificationSettingsWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー

  return await loadSingleDataWithBackgroundRefreshHelper<NotificationSettings>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final settingsList = await notificationSettingsManager.getAllWithAuth();
        try {
          return settingsList.firstWhere((s) => s.id == 'notification_settings');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await notificationSettingsManager.getLocalById('notification_settings');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => NotificationSettings.defaultSettings(),
    saveLocal: (settings) async {
      try {
        await notificationSettingsManager.addLocal(settings);
      } catch (e) {
        await notificationSettingsManager.updateLocal(settings);
      }
    },
    updateProvider: (settings) => ref.read(notificationSettingsProvider.notifier).updateSettings(settings),
    functionName: 'loadNotificationSettingsWithBackgroundRefreshHelper',
  );
}

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
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await notificationSettingsManager.sync(userId);
    
    // IDが 'notification_settings' のものを探す
    NotificationSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'notification_settings');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = NotificationSettings.defaultSettings();
      await notificationSettingsManager.saveWithRetry(userId, settings);
    }
    
    // Notifierを使用してProviderを更新
    ref.read(notificationSettingsProvider.notifier).updateSettings(settings);
    
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
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await notificationSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(notificationSettingsProvider.notifier).updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveNotificationSettingsHelper] エラー: $e');
    return false;
  }
}

