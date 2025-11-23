import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';
import 'package:test_flutter/feature/base/data_helper_functions.dart';
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

/// アカウント設定をバックグラウンド更新で読み込むヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 読み込んだアカウント設定（ローカルまたはデフォルト値）
Future<AccountSettings> loadAccountSettingsWithBackgroundRefreshHelper(dynamic ref) async {
  final dummyManager = Object(); // マネージャーは使用しないためダミー
  final accountNotifier = ref.read(accountSettingsProvider.notifier);

  return await loadSingleDataWithBackgroundRefreshHelper<AccountSettings>(
    ref: ref,
    manager: dummyManager,
    getWithAuth: () async {
      try {
        final settingsList = await accountSettingsManager.getAllWithAuth();
        try {
          return settingsList.firstWhere((s) => s.id == 'account_settings');
        } catch (e) {
          return null;
        }
      } catch (e) {
        return null;
      }
    },
    getLocal: () async {
      try {
        return await accountSettingsManager.getLocalById('account_settings');
      } catch (e) {
        return null;
      }
    },
    getDefault: () async => AccountSettings.defaultSettings(),
    saveLocal: (settings) async {
      try {
        await accountSettingsManager.addLocal(settings);
      } catch (e) {
        // 既に存在する場合は更新
        await accountSettingsManager.updateLocal(settings);
      }
    },
    updateProvider: accountNotifier.updateSettings,
    functionName: 'loadAccountSettingsWithBackgroundRefreshHelper',
  );
}

/// アカウント設定を同期するヘルパー関数
/// 
/// FirestoreとSharedPreferencesを同期し、Providerを更新します。
/// 共通ヘルパー関数を使用してタイムアウト処理とエラーハンドリングを統一します。
/// メールアドレスがFirestoreにない場合は、Firebase AuthまたはSecureStorageから取得して補完します。
/// 
/// **パラメータ**:
/// - `ref`: dynamic（Provider操作用）
/// 
/// **戻り値**: 同期されたアカウント設定
Future<AccountSettings> syncAccountSettingsHelper(dynamic ref) async {
  final manager = accountSettingsManager;
  final accountNotifier = ref.read(accountSettingsProvider.notifier);

  final syncedSettings = await syncSingleDataHelper<AccountSettings>(
    ref: ref,
    manager: manager,
    syncWithAuth: () async {
      final userId = AuthMk.getCurrentUserId();
      final settingsList = await manager.sync(userId);
      return settingsList;
    },
    getDefault: () async => AccountSettings.defaultSettings(),
    updateProvider: accountNotifier.updateSettings,
    functionName: 'syncAccountSettingsHelper',
  );

  // メールアドレスがnullの場合は補完
  if (syncedSettings.email == null || syncedSettings.email!.isEmpty) {
    final email = await _getEmailFromAuthOrStorage();
    if (email != null && email.isNotEmpty) {
      final updatedSettings = syncedSettings.copyWith(
        email: email,
        lastModified: DateTime.now(),
      );
      // Providerを更新
      accountNotifier.updateSettings(updatedSettings);
      
      // Firestoreにも保存（バックグラウンドで実行、エラーは無視）
      final userId = AuthMk.getCurrentUserId();
      manager.saveWithRetry(userId, updatedSettings).then((success) {
        if (success) {
          debugPrint('✅ [syncAccountSettingsHelper] メールアドレスをFirestoreに保存しました');
        } else {
          debugPrint('⚠️ [syncAccountSettingsHelper] メールアドレスのFirestore保存に失敗しました');
        }
      }).catchError((e) {
        debugPrint('⚠️ [syncAccountSettingsHelper] メールアドレスのFirestore保存エラー: $e');
      });
      
      return updatedSettings;
    }
  }

  return syncedSettings;
}

/// Firebase AuthまたはSecureStorageからメールアドレスを取得するヘルパー関数
/// 
/// 優先順位: Firebase Auth > SecureStorage
Future<String?> _getEmailFromAuthOrStorage() async {
  try {
    // 1. Firebase Authから取得を試みる
    final user = AuthMk.getCurrentUser();
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email;
    }

    // 2. SecureStorageから取得を試みる
    final storedInfo = await SecureStorageMk.getUserInfoFromStorage();
    final email = storedInfo['email'];
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return null;
  } catch (e) {
    debugPrint('❌ [_getEmailFromAuthOrStorage] エラー: $e');
    return null;
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
    final accountNotifier = ref.read(accountSettingsProvider.notifier);
    
    // 最終更新日時を更新
    final updatedSettings = settings.copyWith(lastModified: DateTime.now());
    
    // データマネージャーで保存
    final success = await accountSettingsManager.saveWithRetry(userId, updatedSettings);
    
    if (success) {
      // Notifierを使用してProviderを更新
      accountNotifier.updateSettings(updatedSettings);
    }
    
    return success;
  } catch (e) {
    debugPrint('❌ [saveAccountSettingsHelper] エラー: $e');
    return false;
  }
}

