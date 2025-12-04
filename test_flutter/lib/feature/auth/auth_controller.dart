import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/models/app_user.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/data/repositories/user_repository.dart';
import 'package:test_flutter/data/services/auth_service.dart';

enum AuthStatus {
  unknown,
  loading,
  authenticated,
  requiresEmailVerification,
  signedOut,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.firebaseUser,
    this.profile,
    this.errorMessage,
    this.verificationEmailSent = false,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);

  final AuthStatus status;
  final User? firebaseUser;
  final AppUser? profile;
  final String? errorMessage;
  final bool verificationEmailSent;

  bool get isLoading => status == AuthStatus.loading;

  bool get isVerified => firebaseUser?.emailVerified == true;

  static const _profileSentinel = Object();
  static const _errorSentinel = Object();

  AuthState copyWith({
    AuthStatus? status,
    User? firebaseUser,
    Object? profile = _profileSentinel,
    Object? errorMessage = _errorSentinel,
    bool? verificationEmailSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      profile: profile == _profileSentinel ? this.profile : profile as AppUser?,
      errorMessage: errorMessage == _errorSentinel
          ? this.errorMessage
          : errorMessage as String?,
      verificationEmailSent: verificationEmailSent ?? this.verificationEmailSent,
    );
  }
}

final emailAuthServiceProvider = Provider<EmailAuthService>((ref) {
  return EmailAuthService();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final StreamSubscription<User?> _authStateSubscription;

  EmailAuthService get authService => ref.read(emailAuthServiceProvider);
  UserRepository get userRepository => ref.read(userRepositoryProvider);

  @override
  AuthState build() {
    _authStateSubscription =
        authService.authStateChanges().listen(_handleAuthStream);
    ref.onDispose(() => _authStateSubscription.cancel());
    unawaited(restoreSession());
    return AuthState.initial();
  }

  Future<void> restoreSession() async {
    final user = authService.currentUser;
    if (user == null) {
      state = const AuthState(status: AuthStatus.signedOut);
      return;
    }

    final profile = await userRepository.fetchUser(user.uid);
    state = state.copyWith(
      status: user.emailVerified
          ? AuthStatus.authenticated
          : AuthStatus.requiresEmailVerification,
      firebaseUser: user,
      profile: profile,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    int? goalMinutes,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );
    try {
      final previousUserId = FirebaseAuth.instance.currentUser?.uid;
      final credential = await authService.signUp(
        email: email,
        password: password,
        displayName: nickname,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'ユーザー作成に失敗しました',
        );
      }

      if (previousUserId != null && previousUserId != user.uid) {
        await AuthServiceUN.clearLocalDataForUser(previousUserId);
      }
      // Firestoreにユーザードキュメントを作成（メール認証前でも作成可能に変更）
      await AuthServiceUN.persistSessionForUser(
        user,
        providerId: 'password',
        persistRemoteData: true,
      );

      await authService.sendVerificationEmail();
      state = state.copyWith(
        status: AuthStatus.requiresEmailVerification,
        firebaseUser: user,
        verificationEmailSent: true,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapAuthError(e),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthController] signUpエラー: $e');
      debugPrint('   - $stackTrace');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'サインアップ中にエラーが発生しました: $e',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );
    try {
      final previousUserId = FirebaseAuth.instance.currentUser?.uid;
      final credential = await authService.signIn(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'ログインに失敗しました',
        );
      }

      if (previousUserId != null && previousUserId != user.uid) {
        await AuthServiceUN.clearLocalDataForUser(previousUserId);
      }
      await AuthServiceUN.persistSessionForUser(
        user,
        providerId: 'password',
      );

      final profile = await userRepository.fetchUser(user.uid);
      state = state.copyWith(
        status: user.emailVerified
            ? AuthStatus.authenticated
            : AuthStatus.requiresEmailVerification,
        firebaseUser: user,
        profile: profile,
        verificationEmailSent: false,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapAuthError(e),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    await authService.sendVerificationEmail();
    state = state.copyWith(verificationEmailSent: true);
  }

  Future<void> refreshEmailVerification() async {
    final user = await authService.reloadCurrentUser();
    if (user == null) return;

    if (user.emailVerified) {
      await user.getIdToken(true);
      await _ensureUserProfile(
        user,
        nickname: state.profile?.nickname ?? user.displayName,
        goalMinutes: state.profile?.goalMinutes,
      );
      await AuthServiceUN.persistSessionForUser(
        user,
        providerId: 'password',
      );
      final profile = await userRepository.fetchUser(user.uid);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        firebaseUser: user,
        profile: profile,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.requiresEmailVerification,
        firebaseUser: user,
      );
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    state = const AuthState(status: AuthStatus.signedOut);
  }

  Future<void> _ensureUserProfile(
    User user, {
    String? nickname,
    int? goalMinutes,
  }) async {
    try {
      await userRepository.updateProfileFields(
        user.uid,
        nickname: nickname ?? user.displayName,
        goalMinutes: goalMinutes,
        emailVerified: user.emailVerified,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          '⚠️ [AuthController] Firestore書き込みが許可されませんでした: ${e.message}',
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> _handleAuthStream(User? user) async {
    if (user == null) {
      state = const AuthState(status: AuthStatus.signedOut);
      return;
    }

    final profile = await userRepository.fetchUser(user.uid);
    state = state.copyWith(
      status: user.emailVerified
          ? AuthStatus.authenticated
          : AuthStatus.requiresEmailVerification,
      firebaseUser: user,
      profile: profile,
    );
  }

  String _mapAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'このメールアドレスは既に登録されています';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'weak-password':
        return 'パスワードは6文字以上で入力してください';
      case 'user-not-found':
      case 'wrong-password':
        return 'メールアドレスまたはパスワードが間違っています';
      case 'too-many-requests':
        return 'リクエストが多すぎます。しばらく待ってから再試行してください';
      default:
        return exception.message ?? '認証に失敗しました (${exception.code})';
    }
  }
}

