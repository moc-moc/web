import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';

/// 認証サービス統合クラス
class AuthServiceUN {
  /// Googleでサインイン
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final user = await AuthMk.signInWithGoogle();
      
      if (user == null) {
        return AuthResult(
          success: false,
          message: '認証がキャンセルされました',
        );
      }

      final token = await AuthMk.getUserIdToken();
      
      await SecureStorageMk.saveUserInfoToStorage(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        token: token,
        photoUrl: user.photoURL,
      );
      
      debugPrint('✅ [AuthServiceUN] Google認証成功: ${user.email}');
      
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
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthServiceUN] ログイン処理エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return AuthResult(
        success: false,
        message: 'ログイン処理中にエラーが発生しました: $e',
      );
    }
  }

  @Deprecated('Popup方式に変更したため、この関数は不要です。signInWithGoogle()を使用してください。')
  static Future<AuthResult> handleRedirectResult() async {
    try {
      final user = await AuthMk.getRedirectResult();
      
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'リダイレクト認証なし',
        );
      }

      final token = await AuthMk.getUserIdToken();
      
      await SecureStorageMk.saveUserInfoToStorage(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        token: token,
        photoUrl: user.photoURL,
      );
      
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

  /// サインアウト
  static Future<void> signOut() async {
    try {
      await AuthMk.signOutFromFirebase();
      await SecureStorageMk.deleteAllSecureStorage();
      
      debugPrint('✅ サインアウト & データ削除完了');
    } catch (e) {
      debugPrint('❌ サインアウトエラー: $e');
      rethrow;
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
