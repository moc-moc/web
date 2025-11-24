import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/data/services/apple_auth_service.dart';
import 'package:test_flutter/data/services/user_profile_service.dart';
import 'package:test_flutter/data/services/user_session_service.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/hive_source.dart';
import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/setting/account_settings_notifier.dart';
import 'package:test_flutter/feature/setting/goal_memo_notifier.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/total/total_functions.dart';

/// 認証サービス統合クラス
class AuthServiceUN {
  /// Googleでサインイン
  static Future<AuthResult> signInWithGoogle() async {
    try {
      // 現在のユーザーIDを取得（ユーザー切り替え検知のため）
      final currentUser = AuthMk.getCurrentUser();
      final currentUserId = currentUser?.uid;

      final user = await AuthMk.signInWithGoogle();

      if (user == null) {
        return AuthResult(success: false, message: '認証がキャンセルされました');
      }

      // ユーザー切り替えを検知
      if (currentUserId != null && currentUserId != user.uid) {
        debugPrint(
          '🔄 [AuthServiceUN] ユーザー切り替えを検知: $currentUserId -> ${user.uid}',
        );
        // 前のユーザーのローカルデータをクリア
        await _clearPreviousUserData(previousUserId: currentUserId);
      }

      final result = await _handlePostSignIn(
        user: user,
        providerId: 'google.com',
        successMessage: 'ログインに成功しました',
      );
      debugPrint('✅ [AuthServiceUN] Google認証成功: ${user.email}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthServiceUN] ログイン処理エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return AuthResult(success: false, message: 'ログイン処理中にエラーが発生しました: $e');
    }
  }

  /// Appleでサインイン
  static Future<AuthResult> signInWithApple() async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      final currentUserId = currentUser?.uid;

      final credential = await AppleAuthService.signIn();
      final user = credential.user;

      if (user == null) {
        return AuthResult(success: false, message: 'Apple認証がキャンセルされました');
      }

      if (currentUserId != null && currentUserId != user.uid) {
        debugPrint(
          '🔄 [AuthServiceUN] Apple認証: ユーザー切り替えを検知: $currentUserId -> ${user.uid}',
        );
        await _clearPreviousUserData(previousUserId: currentUserId);
      }

      final result = await _handlePostSignIn(
        user: user,
        providerId: 'apple.com',
        successMessage: 'Appleでログインしました',
      );
      debugPrint('✅ [AuthServiceUN] Apple認証成功: ${user.email}');
      return result;
    } on UnsupportedError catch (e, stackTrace) {
      debugPrint('⚠️ [AuthServiceUN] Apple認証非対応: ${e.message}');
      debugPrint('   - スタックトレース: $stackTrace');
      return AuthResult(
        success: false,
        message: e.message ?? 'このプラットフォームではApple認証を利用できません',
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthServiceUN] Apple認証エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return AuthResult(success: false, message: 'Apple認証中にエラーが発生しました: $e');
    }
  }

  @Deprecated('Popup方式に変更したため、この関数は不要です。signInWithGoogle()を使用してください。')
  static Future<AuthResult> handleRedirectResult() async {
    try {
      // 現在のユーザーIDを取得（ユーザー切り替え検知のため）
      final currentUser = AuthMk.getCurrentUser();
      final currentUserId = currentUser?.uid;

      final user = await AuthMk.getRedirectResult();

      if (user == null) {
        return AuthResult(success: false, message: 'リダイレクト認証なし');
      }

      // ユーザー切り替えを検知
      if (currentUserId != null && currentUserId != user.uid) {
        debugPrint(
          '🔄 [AuthServiceUN] Redirect認証: ユーザー切り替えを検知: $currentUserId -> ${user.uid}',
        );
        // 前のユーザーのローカルデータをクリア
        await _clearPreviousUserData(previousUserId: currentUserId);
      }

      final token = await AuthMk.getUserIdToken();

      await SecureStorageMk.saveUserInfoToStorage(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        token: token,
        photoUrl: user.photoURL,
      );

      // メールアドレスをFirestoreのAccountSettingsに保存
      await _saveEmailToAccountSettings(user.uid, user.email);

      debugPrint('✅ Redirect認証成功 & データ保存完了: ${user.email}');

      return AuthResult(
        success: true,
        message: 'ログインに成功しました',
        user: user,
        userInfo: UserInfo(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          token: token,
        ),
      );
    } catch (e) {
      debugPrint('❌ Redirect結果処理エラー: $e');
      return AuthResult(
        success: false,
        message: 'Redirect認証処理中にエラーが発生しました: $e',
      );
    }
  }

  /// 全ローカルデータを削除
  ///
  /// SecureStorage、Hive、SharedPreferencesの全データを削除する
  static Future<void> clearAllLocalData() async {
    try {
      // 1. SecureStorageを削除
      await SecureStorageMk.deleteAllSecureStorage();
      debugPrint('✅ SecureStorage削除完了');

      // 2. Hiveの全ボックスを削除
      try {
        final boxNames = await HiveMk.getAllBoxNames();
        for (final boxName in boxNames) {
          await HiveMk.removeFromHive(boxName);
        }
        debugPrint('✅ Hive全ボックス削除完了: ${boxNames.length}件');
      } catch (e) {
        debugPrint('⚠️ Hive削除エラー: $e');
      }

      // 3. SharedPreferencesの全キーを削除
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        debugPrint('✅ SharedPreferences削除完了');
      } catch (e) {
        debugPrint('⚠️ SharedPreferences削除エラー: $e');
      }

      debugPrint('✅ 全ローカルデータ削除完了');
    } catch (e) {
      debugPrint('❌ 全ローカルデータ削除エラー: $e');
      rethrow;
    }
  }

  /// サインアウト
  ///
  /// Firebaseからサインアウトし、Providerの状態をクリアします。
  /// ローカルデータ（SecureStorage、Hive、SharedPreferences）は保持されます。
  /// これにより、次回サインイン時にデータを復元できます。
  static Future<void> signOut() async {
    try {
      // 初期化フラグをリセット
      AppInitUN.resetInitializationFlags();

      // Providerの状態をクリア
      await _clearProviderStates();

      // Firebaseからサインアウト（ローカルデータは保持）
      await AuthMk.signOutFromFirebase();
      await UserSessionService.clearActiveUser();

      debugPrint('✅ サインアウト完了（ローカルデータは保持、Provider状態はクリア）');
    } catch (e) {
      debugPrint('❌ サインアウトエラー: $e');
      rethrow;
    }
  }

  /// Providerの状態をクリアするヘルパーメソッド
  ///
  /// サインアウト時に、各Providerの状態をデフォルト値にリセットします。
  static Future<void> _clearProviderStates() async {
    try {
      final container = AppInitUN.getGlobalContainer();
      if (container == null) {
        debugPrint(
          '⚠️ [AuthServiceUN] ProviderContainerが設定されていないため、Provider状態のクリアをスキップ',
        );
        return;
      }

      debugPrint('🔄 [AuthServiceUN] Provider状態のクリア開始');

      // 各ProviderのNotifierをリセット
      try {
        // TotalDataProvider
        container.read(totalDataProvider.notifier).reset();
        debugPrint('✅ [AuthServiceUN] TotalDataProviderをリセット');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] TotalDataProviderリセットエラー: $e');
      }

      try {
        // StreakDataProvider
        container.read(streakDataProvider.notifier).reset();
        debugPrint('✅ [AuthServiceUN] StreakDataProviderをリセット');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] StreakDataProviderリセットエラー: $e');
      }

      try {
        // CountdownsListProvider
        container.read(countdownsListProvider.notifier).clear();
        debugPrint('✅ [AuthServiceUN] CountdownsListProviderをクリア');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] CountdownsListProviderクリアエラー: $e');
      }

      try {
        // GoalsListProvider
        container.read(goalsListProvider.notifier).clear();
        debugPrint('✅ [AuthServiceUN] GoalsListProviderをクリア');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] GoalsListProviderクリアエラー: $e');
      }

      try {
        // AccountSettingsProvider
        container
            .read(accountSettingsProvider.notifier)
            .updateSettings(AccountSettings.defaultSettings());
        debugPrint('✅ [AuthServiceUN] AccountSettingsProviderをリセット');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] AccountSettingsProviderリセットエラー: $e');
      }

      try {
        // GoalMemoProvider
        container
            .read(goalMemoProvider.notifier)
            .updateMemo(GoalMemo.defaultMemo());
        debugPrint('✅ [AuthServiceUN] GoalMemoProviderをリセット');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] GoalMemoProviderリセットエラー: $e');
      }

      debugPrint('✅ [AuthServiceUN] Provider状態のクリア完了');
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthServiceUN] Provider状態のクリアエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      // エラーが発生してもサインアウト処理は続行する
    }
  }

  /// 認証状態を復元
  static Future<bool> restoreAuthState() async {
    try {
      final hasStoredAuth = await SecureStorageMk.hasValidStoredAuth();
      final isFirebaseAuthenticated = AuthMk.checkFirebaseAuthState();

      if (hasStoredAuth && isFirebaseAuthenticated) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// アプリ起動時の認証初期化
  static Future<UserInfo?> initializeAuth() async {
    try {
      final isAuthenticated = await restoreAuthState();

      if (!isAuthenticated) {
        return null;
      }

      final userInfo = await getCurrentUserInfo();
      return userInfo;
    } catch (e) {
      return null;
    }
  }

  /// 現在のユーザー情報を取得
  static Future<UserInfo?> getCurrentUserInfo() async {
    try {
      final user = AuthMk.getCurrentUser();

      if (user == null) {
        debugPrint('ℹ️ ログインしていません');
        return null;
      }

      final storedInfo = await SecureStorageMk.getUserInfoFromStorage();
      final token = await AuthMk.getUserIdToken();

      return UserInfo(
        userId: user.uid,
        email: user.email ?? storedInfo['email'],
        displayName: user.displayName ?? storedInfo['displayName'],
        photoURL: user.photoURL ?? storedInfo['photoUrl'],
        token: token ?? storedInfo['token'],
      );
    } catch (e) {
      debugPrint('❌ ユーザー情報取得エラー: $e');
      return null;
    }
  }

  static User? getCurrentUser() {
    return AuthMk.getCurrentUser();
  }

  static bool isAuthenticated() {
    return AuthMk.checkFirebaseAuthState();
  }

  /// トークンを更新
  static Future<String?> refreshToken() async {
    try {
      final newToken = await AuthMk.refreshUserToken();

      if (newToken != null) {
        await SecureStorageMk.updateToken(newToken);
        debugPrint('✅ トークン更新 & 保存完了');
      }

      return newToken;
    } catch (e) {
      debugPrint('❌ トークン更新エラー: $e');
      return null;
    }
  }

  /// 認証状態の変更を監視
  static Stream<User?> watchAuthStateChanges() {
    return AuthMk.watchAuthStateChanges();
  }

  /// 前のユーザーのローカルデータをクリアするヘルパーメソッド
  ///
  /// ユーザー切り替え時に、前のユーザーのProvider状態、SharedPreferences、Hiveデータをクリアします。
  static Future<void> _clearPreviousUserData({String? previousUserId}) async {
    try {
      debugPrint(
        '🔄 [AuthServiceUN] 前のユーザーのローカルデータをクリア開始'
        '${previousUserId != null ? ' (uid: $previousUserId)' : ''}',
      );

      // まずProviderの状態をクリア
      await _clearProviderStates();

      final scopedPrefix = (previousUserId != null && previousUserId.isNotEmpty)
          ? 'user_${previousUserId}__'
          : null;

      if (scopedPrefix != null) {
        try {
          await SharedMk.removeKeysWithPrefix(scopedPrefix);
          debugPrint(
            '✅ [AuthServiceUN] SharedPreferencesプレフィックス削除: $scopedPrefix',
          );
        } catch (e) {
          debugPrint('⚠️ [AuthServiceUN] SharedPreferencesプレフィックス削除エラー: $e');
        }
      } else {
        // 既存データとの互換性のため、従来のキーも削除
        final storageKeys = [
          'account_settings',
          'notification_settings',
          'display_settings',
          'time_settings',
          'tracking_settings',
          'goal_memo',
          'goals',
          'streak_data',
          'total_data',
          'countdowns',
          'tracking_sessions',
          'daily_statistics',
          'weekly_statistics',
          'monthly_statistics',
          'yearly_statistics',
        ];
        for (final key in storageKeys) {
          try {
            await SharedMk.removeFromSharedPrefs(key);
            await SharedMk.removeFromSharedPrefs('${key}_last_sync');
            debugPrint('✅ [AuthServiceUN] SharedPreferencesクリア完了: $key');
          } catch (e) {
            debugPrint('⚠️ [AuthServiceUN] SharedPreferencesクリアエラー ($key): $e');
          }
        }
      }

      if (scopedPrefix != null) {
        try {
          await HiveMk.removeBoxesWithPrefix(scopedPrefix);
          debugPrint('✅ [AuthServiceUN] Hiveプレフィックス削除: $scopedPrefix');
        } catch (e) {
          debugPrint('⚠️ [AuthServiceUN] Hiveプレフィックス削除エラー: $e');
        }
      } else {
        try {
          final boxNames = await HiveMk.getAllBoxNames();
          for (final boxName in boxNames) {
            try {
              await HiveMk.removeFromHive(boxName);
              debugPrint('✅ [AuthServiceUN] Hiveクリア完了: $boxName');
            } catch (e) {
              debugPrint('⚠️ [AuthServiceUN] Hiveクリアエラー ($boxName): $e');
            }
          }
        } catch (e) {
          debugPrint('⚠️ [AuthServiceUN] Hive全ボックスクリアエラー: $e');
        }
      }

      // SecureStorageも明示的にクリア（新しいユーザーの情報で即座に上書きされるが、整合性のため）
      try {
        await SecureStorageMk.deleteAllSecureStorage();
        debugPrint('✅ [AuthServiceUN] SecureStorageクリア完了');
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] SecureStorageクリアエラー: $e');
      }

      debugPrint('✅ [AuthServiceUN] 前のユーザーのローカルデータクリア完了');
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthServiceUN] 前のユーザーのローカルデータクリアエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      // エラーが発生しても認証処理は続行する
    }
  }

  /// メールアドレスをAccountSettingsに保存するヘルパーメソッド
  ///
  /// 既存のAccountSettingsがある場合はemailのみ更新し、
  /// ない場合は新規作成します。
  /// 保存後、Providerも更新して、`syncAccountSettingsHelper()`での補完処理を避けます。
  static Future<void> _saveEmailToAccountSettings(
    String userId,
    String? email,
  ) async {
    if (email == null || email.isEmpty) {
      debugPrint('⚠️ [AuthServiceUN] メールアドレスが空のため、AccountSettingsに保存しません');
      return;
    }

    try {
      // 既存のAccountSettingsを取得（Firestore優先、なければローカル）
      AccountSettings? existingSettings;
      try {
        existingSettings = await accountSettingsManager.getById(
          userId,
          'account_settings',
        );
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] FirestoreからAccountSettings取得エラー: $e');
      }

      // Firestoreにない場合はローカルデータを取得
      if (existingSettings == null) {
        try {
          existingSettings = await accountSettingsManager.getLocalById(
            'account_settings',
          );
          debugPrint('✅ [AuthServiceUN] ローカルからAccountSettingsを取得しました');
        } catch (e) {
          debugPrint('⚠️ [AuthServiceUN] ローカルからAccountSettings取得エラー: $e');
        }
      }

      // 既存の設定がある場合はemailのみ更新、ない場合は既存のローカルデータまたはデフォルト値を使用
      final updatedSettings = existingSettings != null
          ? existingSettings.copyWith(
              email: email,
              lastModified: DateTime.now(),
            )
          : AccountSettings(
              id: 'account_settings',
              accountName: 'ユーザー',
              avatarColor: 'blue',
              email: email,
              lastModified: DateTime.now(),
            );

      final success = await accountSettingsManager.saveWithRetry(
        userId,
        updatedSettings,
      );
      if (success) {
        if (existingSettings != null) {
          debugPrint('✅ [AuthServiceUN] AccountSettingsのメールアドレスを更新しました');
        } else {
          debugPrint('✅ [AuthServiceUN] AccountSettingsを新規作成しました（メールアドレス含む）');
        }
      } else {
        if (existingSettings != null) {
          debugPrint('⚠️ [AuthServiceUN] AccountSettingsのメールアドレス更新に失敗しました');
        } else {
          debugPrint('⚠️ [AuthServiceUN] AccountSettingsの新規作成に失敗しました');
        }
      }

      // Providerも更新して、`syncAccountSettingsHelper()`での補完処理を避ける
      try {
        final container = AppInitUN.getGlobalContainer();
        if (container != null) {
          container
              .read(accountSettingsProvider.notifier)
              .updateSettings(updatedSettings);
          debugPrint('✅ [AuthServiceUN] AccountSettingsProviderを更新しました');
        }
      } catch (e) {
        debugPrint('⚠️ [AuthServiceUN] AccountSettingsProvider更新エラー: $e');
        // Provider更新が失敗しても続行
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthServiceUN] AccountSettingsへのメールアドレス保存エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      // エラーが発生しても認証処理は続行する（Firestoreへの保存は失敗してもSecureStorageには保存済み）
    }
  }

  static Future<String?> _persistSession({
    required User user,
    required String providerId,
    bool persistRemoteData = true,
  }) async {
    final token = await AuthMk.getUserIdToken();

    await SecureStorageMk.saveUserInfoToStorage(
      userId: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.email ?? ''),
      token: token,
      photoUrl: user.photoURL,
    );

    if (persistRemoteData) {
      await _saveEmailToAccountSettings(user.uid, user.email);
      await _ensureUserDocument(user, providerId: providerId);
    }
    await UserSessionService.setActiveUser(user.uid);
    return token;
  }

  static Future<void> persistSessionForUser(
    User user, {
    String providerId = 'password',
    bool persistRemoteData = true,
  }) async {
    await _persistSession(
      user: user,
      providerId: providerId,
      persistRemoteData: persistRemoteData,
    );
  }

  static Future<void> ensureActiveUserConsistency() async {
    final currentUid = AuthMk.getCurrentUser()?.uid;
    final storedUid = await UserSessionService.getActiveUser();

    if (currentUid == null) {
      if (storedUid != null) {
        await UserSessionService.clearActiveUser();
      }
      return;
    }

    if (storedUid != currentUid) {
      await UserSessionService.setActiveUser(currentUid);
    }
  }

  static Future<void> clearLocalDataForUser(String? userId) async {
    await _clearPreviousUserData(previousUserId: userId);
  }

  static Future<AuthResult> _handlePostSignIn({
    required User user,
    required String providerId,
    required String successMessage,
  }) async {
    final token = await _persistSession(
      user: user,
      providerId: providerId,
    );

    return AuthResult(
      success: true,
      message: successMessage,
      user: user,
      userInfo: UserInfo(
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        token: token,
      ),
    );
  }

  static Future<void> _ensureUserDocument(
    User user, {
    required String providerId,
  }) async {
    try {
      await UserProfileService.upsertUserDocument(user, providerId: providerId);
    } catch (e, stackTrace) {
      debugPrint('⚠️ [AuthServiceUN] ユーザードキュメント作成に失敗: $e');
      debugPrint('   - スタックトレース: $stackTrace');
    }
  }
}

/// 認証結果を表すクラス
class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final UserInfo? userInfo;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.userInfo,
  });
}

/// ユーザー情報を表すクラス
class UserInfo {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? token;

  UserInfo({
    required this.userId,
    this.email,
    this.displayName,
    this.photoURL,
    this.token,
  });

  @override
  String toString() {
    return 'UserInfo('
        'userId: $userId, '
        'email: $email, '
        'displayName: $displayName, '
        'photoURL: $photoURL, '
        'hasToken: ${token != null}'
        ')';
  }
}
