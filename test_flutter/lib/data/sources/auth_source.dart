import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/services/error_handler.dart';

/// Firebase Auth関連の汎用的な基本関数
/// 
/// 認証に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class AuthMk {
  /// Googleでサインイン
  /// 
  /// プラットフォームに応じた認証方式を自動選択：
  /// - Web: Redirect方式（Popupより安定）
  /// - モバイル: google_sign_inパッケージ使用（未実装）
  /// 
  /// 成功時はFirebase Userを返す
  static Future<User?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        return await _signInWithGoogleWeb(provider);
      } else {
        debugPrint('❌ [AuthMk] モバイル版のGoogle認証は未実装です');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthMk] signInWithGoogle()で予期しないエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return null;
    }
  }

  /// Web版のGoogle認証（Popup方式）
  /// 
  /// Popup方式でGoogle認証を実行
  /// Web環境の型エラーを回避するため、広範な例外キャッチを使用
  static Future<User?> _signInWithGoogleWeb(GoogleAuthProvider provider) async {
    try {
      final UserCredential result = await FirebaseAuth.instance.signInWithPopup(provider);
      
      if (result.user != null) {
        debugPrint('✅ [AuthMk] Google認証成功: ${result.user!.email}');
        return result.user;
      }
      
      debugPrint('⚠️ [AuthMk] 認証がキャンセルされました');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthMk] _signInWithGoogleWeb()でエラーが発生しました');
      debugPrint('   - エラータイプ: ${e.runtimeType}');
      debugPrint('   - エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      
      // Web環境ではFirebaseAuthExceptionを直接キャッチすると型エラーが発生するため、
      // すべての例外をObjectとしてキャッチし、エラーメッセージから情報を抽出
      final errorMessage = e.toString();
      debugPrint('   - エラーメッセージ（文字列）: $errorMessage');
      
      // FirebaseAuthExceptionの特徴的な文字列をチェック
      if (errorMessage.contains('FirebaseAuthException') || 
          errorMessage.contains('auth/')) {
        debugPrint('   - FirebaseAuthExceptionと判定されました');
        
        // エラーコードを抽出（例: auth/popup-closed-by-user）
        final codeMatch = RegExp(r'auth/([a-z-]+)').firstMatch(errorMessage);
        final code = codeMatch?.group(1) ?? 'unknown';
        debugPrint('   - 抽出されたエラーコード: $code');
        
        // ユーザーに分かりやすいメッセージに変換
        String userMessage;
        switch (code) {
          case 'popup-closed-by-user':
            userMessage = '認証がキャンセルされました';
            break;
          case 'popup-blocked':
            userMessage = 'ポップアップがブロックされました。ブラウザの設定を確認してください';
            break;
          case 'network-request-failed':
            userMessage = 'ネットワークエラーが発生しました';
            break;
          default:
            userMessage = '認証エラーが発生しました: $code';
        }
        
        debugPrint('❌ [AuthMk] Firebase認証エラー: $code - $userMessage');
        debugPrint('   - 詳細: $errorMessage');
        return null;
      }
      
      // その他のエラー
      debugPrint('❌ [AuthMk] Web認証エラー（FirebaseAuthException以外）');
      debugPrint('   - エラーメッセージ: $errorMessage');
      return null;
    }
  }

  /// Redirect認証の結果を取得
  /// 
  /// Popup方式に変更したため、この関数は互換性のために残していますが、
  /// 常にnullを返します。
  /// 
  /// **戻り値**: 常にnull（Popup方式では不要）
  @Deprecated('Popup方式に変更したため、この関数は不要です')
  static Future<User?> getRedirectResult() async {
    try {
      if (!kIsWeb) {
        // Web以外では不要
        return null;
      }
      
      final result = await FirebaseAuth.instance.getRedirectResult();
      
      if (result.user != null) {
        debugPrint('✅ Redirect認証成功: ${result.user!.email}');
        return result.user;
      }
      
      return null;
    } catch (e) {
      // Web環境ではFirebaseAuthExceptionを直接キャッチすると型エラーが発生するため、
      // すべての例外をObjectとしてキャッチ
      final errorMessage = e.toString();
      debugPrint('❌ Redirect結果取得エラー: $errorMessage');
      return null;
    }
  }

  /// Firebase サインアウト
  /// 
  /// 現在のFirebase認証セッションを終了する
  static Future<void> signOutFromFirebase() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('🚪 サインアウト(Web) 完了');
    } catch (e) {
      debugPrint('❌ サインアウトエラー(Web): $e');
    }
  }

  /// 現在のFirebaseユーザーを取得
  /// 
  /// 現在ログインしているユーザー情報を取得する
  /// ログインしていない場合はnullを返す
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// ユーザーのIDトークンを取得
  /// 
  /// 現在のユーザーのIDトークンを取得する
  /// ユーザーがログインしていない場合はnullを返す
  static Future<String?> getUserIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthMk] IDトークン取得エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return null;
    }
  }

  /// トークンを強制更新
  /// 
  /// 現在のユーザーのIDトークンを強制的に更新する
  /// 成功時は新しいトークンを返す
  static Future<String?> refreshUserToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newToken = await user.getIdToken(true); // 強制更新
        debugPrint('✅ トークンを更新しました');
        return newToken;
      }
      return null;
    } catch (e) {
      debugPrint('❌ トークン更新エラー: $e');
      return null;
    }
  }

  /// 現在の認証状態を確認
  /// 
  /// 現在Firebaseにログインしているかどうかを確認する
  /// ログインしている場合はtrue、していない場合はfalseを返す
  static bool checkFirebaseAuthState() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  /// 認証状態の変更を監視
  /// 
  /// Firebase認証状態の変更を監視するStreamを返す
  /// ログイン/ログアウトの検知に使用する
  static Stream<User?> watchAuthStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  /// ユーザー情報を取得
  /// 
  /// 現在のユーザーの基本情報をMap形式で取得する
  /// ログインしていない場合は空のMapを返す
  static Map<String, String?> getCurrentUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
    }
    return {};
  }

  // ===== Phase 2: 認証統合機能 =====

  /// 現在のユーザーIDを取得
  /// 
  /// **処理フロー**:
  /// 1. currentUserを取得
  /// 2. ログインしていない場合は例外をスロー
  /// 3. user.uidを返す
  /// 
  /// **戻り値**: ユーザーID
  /// 
  /// **例外**: ログインしていない場合は例外をスロー
  static String getCurrentUserId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final error = DataManagerError.authenticationError(
          'ユーザーがログインしていません。',
        );
        LogMk.logError(
          'ユーザーID取得エラー: ログインしていません',
          tag: 'AuthMk.getCurrentUserId',
          error: error,
        );
        throw error;
      }
      
      LogMk.logDebug('ユーザーID取得: ${user.uid}', tag: 'AuthMk.getCurrentUserId');
      return user.uid;
    } catch (e) {
      if (e is DataManagerError) {
        rethrow;
      }
      
      final error = DataManagerError.authenticationError(
        'ユーザーID取得エラー',
        originalError: e,
      );
      LogMk.logError(
        'ユーザーID取得エラー',
        tag: 'AuthMk.getCurrentUserId',
        error: error,
      );
      throw error;
    }
  }

  /// ユーザーIDの変更を監視
  /// 
  /// **処理フロー**:
  /// 1. authStateChanges()でStream作成
  /// 2. ユーザーがログインしている場合はuser.uidを流す
  /// 3. ログアウト時はnullを流す
  /// 
  /// **戻り値**: ユーザーIDのStream（ログアウト時はnull）
  static Stream<String?> watchUserId() {
    try {
      return FirebaseAuth.instance
          .authStateChanges()
          .map((user) {
            if (user != null) {
              LogMk.logDebug('ユーザーID変更検知: ${user.uid}', tag: 'AuthMk.watchUserId');
              return user.uid;
            } else {
              LogMk.logDebug('ユーザーログアウト検知', tag: 'AuthMk.watchUserId');
              return null;
            }
          })
          .handleError((error) {
            LogMk.logError(
              'ユーザーID監視エラー',
              tag: 'AuthMk.watchUserId',
              error: error,
            );
            return null;
          });
    } catch (e) {
      LogMk.logError(
        'ユーザーID監視開始エラー',
        tag: 'AuthMk.watchUserId',
        error: e,
      );
      return Stream.value(null);
    }
  }

  /// userIdが必須な処理用のヘルパー
  /// 
  /// **処理フロー**:
  /// 1. getCurrentUserId()を呼び出し
  /// 2. ログインしていない場合は例外をスロー
  /// 
  /// **戻り値**: ユーザーID
  /// 
  /// **例外**: ログインしていない場合は例外をスロー
  static String requireUserId() {
    return getCurrentUserId();
  }
}
