import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';

part 'tracking_settings_notifier.g.dart';

/// トラッキング設定を管理するNotifier
/// 
/// トラッキング設定（カメラのオン/オフ、省電力モード）を管理します。
/// 
/// **使用方法**:
/// ```dart
/// final settings = ref.watch(trackingSettingsProvider);
/// ref.read(trackingSettingsProvider.notifier).updateSettings(newSettings);
/// ```
@Riverpod(keepAlive: true)
class TrackingSettingsNotifier extends _$TrackingSettingsNotifier {
  @override
  TrackingSettings build() {
    return TrackingSettings.defaultSettings();
  }

  /// 設定を更新
  void updateSettings(TrackingSettings settings) {
    state = settings;
  }
}

/// トラッキング設定をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだトラッキング設定（ローカルまたはデフォルト値）
Future<TrackingSettings> loadTrackingSettingsWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー

  return await loadSingleDataWithBackgroundRefreshHelper<TrackingSettings>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final settingsList = await trackingSettingsManager.getAllWithAuth();
        try {
          return settingsList.firstWhere((s) => s.id == 'tracking_settings');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await trackingSettingsManager.getLocalById('tracking_settings');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => TrackingSettings.defaultSettings(),
    saveLocal: (settings) async {
      try {
        await trackingSettingsManager.addLocal(settings);
      } catch (e) {
        await trackingSettingsManager.updateLocal(settings);
      }
    },
    updateProvider: (settings) => ref.read(trackingSettingsProvider.notifier).updateSettings(settings),
    functionName: 'loadTrackingSettingsWithBackgroundRefreshHelper',
  );
}

/// トラッキング設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期されたトラッキング設定
Future<TrackingSettings> syncTrackingSettingsHelper(dynamic ref) async {
  try {
    final userId = AuthMk.getCurrentUserId();
    
    // データマネージャーで同期
    final settingsList = await trackingSettingsManager.sync(userId);
    
    // IDが 'tracking_settings' のものを探す
    TrackingSettings settings;
    try {
      settings = settingsList.firstWhere((s) => s.id == 'tracking_settings');
    } catch (e) {
      // データがない場合はデフォルト値を作成して保存
      settings = TrackingSettings.defaultSettings();
      await trackingSettingsManager.saveWithRetry(userId, settings);
    }
    
    // Notifierを使用してProviderを更新
    ref.read(trackingSettingsProvider.notifier).updateSettings(settings);
    
    return settings;
  } catch (e) {
    debugPrint('❌ [syncTrackingSettingsHelper] エラー: $e');
    
    // エラー時はデフォルト値を返す
    final defaultSettings = TrackingSettings.defaultSettings();
    ref.read(trackingSettingsProvider.notifier).updateSettings(defaultSettings);
    return defaultSettings;
  }
}

/// トラッキング設定を保存するヘルパー関数
/// 
/// トラッキング設定を保存し、Providerを更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// - `settings`: 保存するトラッキング設定
/// 
/// **戻り値**: 保存に成功した場合true
Future<bool> saveTrackingSettingsHelper(dynamic ref, TrackingSettings settings) async {
  try {
    final userId = AuthMk.getCurrentUserId();
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await trackingSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      ref.read(trackingSettingsProvider.notifier).updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveTrackingSettingsHelper] エラー: $e');
    return false;
  }
}

