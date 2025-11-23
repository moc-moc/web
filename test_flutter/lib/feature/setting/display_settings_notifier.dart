import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
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

/// 表示設定をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだ表示設定（ローカルまたはデフォルト値）
Future<DisplaySettings> loadDisplaySettingsWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー
  final displayNotifier = ref.read(displaySettingsProvider.notifier);

  return await loadSingleDataWithBackgroundRefreshHelper<DisplaySettings>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final settingsList = await displaySettingsManager.getAllWithAuth();
        try {
          return settingsList.firstWhere((s) => s.id == 'display_settings');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await displaySettingsManager.getLocalById('display_settings');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => DisplaySettings.defaultSettings(),
    saveLocal: (settings) async {
      try {
        await displaySettingsManager.addLocal(settings);
      } catch (e) {
        await displaySettingsManager.updateLocal(settings);
      }
    },
    updateProvider: displayNotifier.updateSettings,
    functionName: 'loadDisplaySettingsWithBackgroundRefreshHelper',
  );
}

/// 表示設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期された表示設定
Future<DisplaySettings> syncDisplaySettingsHelper(dynamic ref) async {
  final manager = displaySettingsManager;
  final displayNotifier = ref.read(displaySettingsProvider.notifier);

  return await syncSingleDataHelper<DisplaySettings>(
    ref: ref,
    manager: manager,
    syncWithAuth: () async {
      final userId = AuthMk.getCurrentUserId();
      final settingsList = await manager.sync(userId);
      return settingsList;
    },
    getDefault: () async => DisplaySettings.defaultSettings(),
    updateProvider: displayNotifier.updateSettings,
    functionName: 'syncDisplaySettingsHelper',
  );
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
    final displayNotifier = ref.read(displaySettingsProvider.notifier);
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await displaySettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      displayNotifier.updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveDisplaySettingsHelper] エラー: $e');
    return false;
  }
}

