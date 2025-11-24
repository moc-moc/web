import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple認証のプラットフォーム別フローをまとめたサービス
class AppleAuthService {
  AppleAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Appleでサインインし、FirebaseのUserCredentialを返す
  static Future<UserCredential> signIn() async {
    if (kIsWeb) {
      return _signInWithWeb();
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _signInWithAppleDevices();
      case TargetPlatform.android:
        return _signInWithOAuthProvider();
      default:
        throw UnsupportedError('このプラットフォームではAppleサインインをサポートしていません');
    }
  }

  /// iOS/macOSネイティブのSign in with Appleフロー
  static Future<UserCredential> _signInWithAppleDevices() async {
    final isAvailable = await SignInWithApple.isAvailable();
    if (!isAvailable) {
      throw UnsupportedError('このデバイスではAppleサインインを利用できません');
    }

    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw StateError('Apple IDトークンを取得できませんでした');
    }

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      rawNonce: rawNonce,
      accessToken: credential.authorizationCode,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  /// Android向け：OAuthProvider経由でブラウザ（Chrome Custom Tab）を起動
  static Future<UserCredential> _signInWithOAuthProvider() {
    final provider = OAuthProvider('apple.com');
    provider.addScope('email');
    provider.addScope('name');
    provider.setCustomParameters({'locale': 'ja_JP'});
    return _auth.signInWithProvider(provider);
  }

  /// Web向け：ポップアップでAppleログイン
  static Future<UserCredential> _signInWithWeb() {
    final provider = OAuthProvider('apple.com');
    provider.addScope('email');
    provider.addScope('name');
    provider.setCustomParameters({'locale': 'ja_JP'});
    return FirebaseAuth.instance.signInWithPopup(provider);
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
