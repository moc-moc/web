import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'display_settings_notifier.g.dart';

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
    return DisplaySettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(DisplaySettings settings) {
    state = settings;
  }
}

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
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await displaySettingsManager.sync(userId);
    
    // IDが 'display_settings' のものを探す
    DisplaySettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'display_settings');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = DisplaySettings.defaultSettings();
      await displaySettingsManager.saveWithRetry(userId, settings);
    }
    
    // Notifierを使用してProviderを更新
    ref.read(displaySettingsProvider.notifier).updateSettings(settings);
    
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
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await displaySettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(displaySettingsProvider.notifier).updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveDisplaySettingsHelper] エラー: $e');
    return false;
  }
}

