import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'time_settings_notifier.g.dart';

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
    return TimeSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(TimeSettings settings) {
    state = settings;
  }
}

/// 時間設定をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだ時間設定（ローカルまたはデフォルト値）
Future<TimeSettings> loadTimeSettingsWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー

  return await loadSingleDataWithBackgroundRefreshHelper<TimeSettings>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final settingsList = await timeSettingsManager.getAllWithAuth();
        try {
          return settingsList.firstWhere((s) => s.id == 'time_settings');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await timeSettingsManager.getLocalById('time_settings');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => TimeSettings.defaultSettings(),
    saveLocal: (settings) async {
      try {
        await timeSettingsManager.addLocal(settings);
      } catch (e) {
        await timeSettingsManager.updateLocal(settings);
      }
    },
    updateProvider: (settings) => ref.read(timeSettingsProvider.notifier).updateSettings(settings),
    functionName: 'loadTimeSettingsWithBackgroundRefreshHelper',
  );
}

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
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await timeSettingsManager.sync(userId);
    
    // IDが 'time_settings' のものを探す
    TimeSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'time_settings');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = TimeSettings.defaultSettings();
      await timeSettingsManager.saveWithRetry(userId, settings);
    }
    
    // Notifierを使用してProviderを更新
    ref.read(timeSettingsProvider.notifier).updateSettings(settings);
    
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
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await timeSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(timeSettingsProvider.notifier).updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveTimeSettingsHelper] エラー: $e');
    return false;
  }
}

