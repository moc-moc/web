import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';

/// 認証フォーム処理の共通ヘルパー
class AuthFormHelper {
  /// メールアドレスのバリデーション
  /// 
  /// 戻り値: エラーメッセージ（nullの場合はバリデーション成功）
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return '有効なメールアドレスを入力してください';
    }
    
    return null;
  }

  /// パスワードのバリデーション
  /// 
  /// 戻り値: エラーメッセージ（nullの場合はバリデーション成功）
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'パスワードを入力してください';
    }
    
    if (password.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    
    return null;
  }

  /// パスワード一致確認
  /// 
  /// 戻り値: エラーメッセージ（nullの場合はバリデーション成功）
  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'パスワード確認を入力してください';
    }
    
    if (password != confirmPassword) {
      return 'パスワードが一致しません';
    }
    
    return null;
  }

  /// ユーザー名のバリデーション
  /// 
  /// 戻り値: エラーメッセージ（nullの場合はバリデーション成功）
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'ユーザー名を入力してください';
    }
    
    if (username.length < 3) {
      return 'ユーザー名は3文字以上で入力してください';
    }
    
    return null;
  }

  /// フォーム送信処理の共通ラッパー
  /// 
  /// エラーハンドリングを統一し、エラー発生時にSnackBarを表示
  static Future<T?> handleFormSubmit<T>({
    required BuildContext context,
    required Future<T?> Function() submitFunction,
    String? errorMessage,
  }) async {
    try {
      return await submitFunction();
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthFormHelper] フォーム送信エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(
          context,
          errorMessage ?? 'エラーが発生しました',
        );
      }
      
      return null;
    }
  }

  /// フォーム全体のバリデーション
  /// 
  /// 複数のフィールドを一度にバリデーションし、最初のエラーを返す
  static String? validateForm({
    String? email,
    String? password,
    String? confirmPassword,
    String? username,
    bool isSignUp = false,
  }) {
    if (email != null) {
      final emailError = validateEmail(email);
      if (emailError != null) return emailError;
    }
    
    if (password != null) {
      final passwordError = validatePassword(password);
      if (passwordError != null) return passwordError;
    }
    
    if (isSignUp) {
      if (username != null) {
        final usernameError = validateUsername(username);
        if (usernameError != null) return usernameError;
      }
      
      if (password != null && confirmPassword != null) {
        final matchError = validatePasswordMatch(password, confirmPassword);
        if (matchError != null) return matchError;
      }
    }
    
    return null;
  }
}

