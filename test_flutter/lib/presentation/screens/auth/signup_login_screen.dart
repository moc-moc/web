import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/tab_bars.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/presentation/widgets/auth/auth_form_helper.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';

/// サインアップ/ログイン画面
class SignupLoginScreen extends ConsumerStatefulWidget {
  const SignupLoginScreen({super.key});

  @override
  ConsumerState<SignupLoginScreen> createState() => _SignupLoginScreenState();
}

class _SignupLoginScreenState extends ConsumerState<SignupLoginScreen> {
  bool _isSignUp = true;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isVerificationScreenOpen = false;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (!mounted) return;

    if (next.status == AuthStatus.error && next.errorMessage != null) {
      showErrorSnackBar(context, next.errorMessage!);
    }

    final movedToVerification =
        next.status == AuthStatus.requiresEmailVerification &&
        previous?.status != AuthStatus.requiresEmailVerification;

    if (movedToVerification && !_isVerificationScreenOpen) {
      _isVerificationScreenOpen = true;
      NavigationHelper.push(context, AppRoutes.emailVerification).whenComplete(
        () {
          _isVerificationScreenOpen = false;
        },
      );
    }

    if (next.status == AuthStatus.authenticated &&
        previous?.status != AuthStatus.authenticated) {
      _isVerificationScreenOpen = false;
      _runPostAuthInitialization();
    }

    if (next.status == AuthStatus.signedOut) {
      _isVerificationScreenOpen = false;
    }
  }

  Future<void> _handleSubmit() async {
    // バリデーション
    final validationError = AuthFormHelper.validateForm(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _isSignUp ? _passwordConfirmController.text : null,
      username: _isSignUp ? _usernameController.text : null,
      isSignUp: _isSignUp,
    );

    if (validationError != null) {
      showErrorSnackBar(context, validationError);
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);

    if (_isSignUp) {
      await authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _usernameController.text.trim(),
      );
    } else {
      await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    await AuthFormHelper.handleFormSubmit(
      context: context,
      submitFunction: () async {
        final result = await AuthServiceUN.signInWithGoogle();

        if (result.success && mounted) {
          await _runPostAuthInitialization();
        } else if (mounted) {
          showErrorSnackBar(context, result.message);
        }
        return result.success;
      },
      errorMessage: '認証エラーが発生しました',
    );

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isAppleLoading) return;

    setState(() {
      _isAppleLoading = true;
    });

    await AuthFormHelper.handleFormSubmit(
      context: context,
      submitFunction: () async {
        final result = await AuthServiceUN.signInWithApple();

        if (result.success && mounted) {
          await _runPostAuthInitialization();
        } else if (mounted) {
          showErrorSnackBar(context, result.message);
        }
        return result.success;
      },
      errorMessage: 'Apple認証中にエラーが発生しました',
    );

    if (mounted) {
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  Future<void> _runPostAuthInitialization() async {
    try {
      debugPrint('🔄 [認証成功] アプリ初期化開始');
      await AppInitUN.initialize();
      debugPrint('✅ [認証成功] AppContext初期化完了');

      debugPrint('🔄 [認証成功] loadCriticalData開始');
      try {
        await AppInitUN.loadCriticalData().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('⚠️ [認証成功] loadCriticalData全体タイムアウト（30秒）');
            throw TimeoutException(
              'loadCriticalDataがタイムアウトしました',
              const Duration(seconds: 30),
            );
          },
        );
        debugPrint('✅ [認証成功] データ読み込み完了');
      } on TimeoutException catch (e) {
        debugPrint('⚠️ [認証成功] loadCriticalDataタイムアウト: $e');
        debugPrint('   一部のデータ読み込みが完了していない可能性がありますが、続行します');
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ [認証成功] データ読み込みエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
    }

    if (!mounted) return;

    await NavigationHelper.pushAndRemoveUntil(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen は build メソッド内で呼び出す必要がある
    ref.listen<AuthState>(authControllerProvider, _handleAuthStateChange);

    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;

    return AppScaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ConstrainedContent(
            maxWidth: 400,
            child: SpacedColumn(
              spacing: AppSpacing.xl,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xxl),
                // Logo & Title
                _buildHeader(),
                SizedBox(height: AppSpacing.lg),
                // Tab Switcher
                TabSwitcher(
                  firstTab: 'Sign Up',
                  secondTab: 'Log In',
                  isFirstSelected: _isSignUp,
                  onTabChanged: (isFirst) {
                    setState(() {
                      _isSignUp = isFirst;
                    });
                  },
                ),
                SizedBox(height: AppSpacing.xl),
                // Social Login Buttons
                _buildSocialLogins(),
                SizedBox(height: AppSpacing.lg),
                // Divider
                const OrDivider(),
                SizedBox(height: AppSpacing.lg),
                // Input Fields
                _buildInputFields(isSubmitting),
                SizedBox(height: AppSpacing.xl),
                // Submit Button
                _buildSubmitButton(isSubmitting),
                SizedBox(height: AppSpacing.md),
                // Toggle Text
                _buildToggleText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.timer, size: 80, color: AppColors.blue),
        SizedBox(height: AppSpacing.md),
        Text('Focus Tracker', style: AppTextStyles.h1),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Track your focus, achieve your goals',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialLogins() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialLoginButton(
          text: _buildSocialButtonLabel('Apple'),
          icon: Icons.apple,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          onTap: _handleAppleSignIn,
          isLoading: _isAppleLoading,
        ),
        SocialLoginButton(
          text: _buildSocialButtonLabel('Google'),
          icon: Icons.g_mobiledata,
          textColor: AppColors.textPrimary,
          backgroundColor: AppColors.backgroundCard,
          onTap: _handleGoogleSignIn,
          isLoading: _isGoogleLoading,
        ),
      ],
    );
  }

  Widget _buildInputFields(bool isSubmitting) {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredTextField(
          label: 'Email',
          placeholder: 'your.email@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email,
          focusColor: AppColors.blue,
          enabled: !isSubmitting,
        ),
        if (_isSignUp)
          ColoredTextField(
            label: 'Username',
            placeholder: 'your_username',
            controller: _usernameController,
            icon: Icons.person,
            focusColor: AppColors.green,
            enabled: !isSubmitting,
          ),
        ColoredTextField(
          label: 'Password',
          placeholder: '••••••••',
          controller: _passwordController,
          obscureText: true,
          icon: Icons.lock,
          focusColor: AppColors.orange,
          enabled: !isSubmitting,
        ),
        if (_isSignUp)
          ColoredTextField(
            label: 'Confirm Password',
            placeholder: '••••••••',
            controller: _passwordConfirmController,
            obscureText: true,
            icon: Icons.lock,
            focusColor: AppColors.orange,
            enabled: !isSubmitting,
          ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    if (_isSignUp) {
      // Create Accountボタン: blue背景と枠、白テキスト
      return Container(
        height: 56.0,
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.blue, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSubmitting
                ? null
                : () {
                    _handleSubmit();
                  },
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Center(
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    } else {
      return PrimaryButton(
        text: 'Log In',
        onPressed: () {
          if (isSubmitting) return;
          _handleSubmit();
        },
        size: ButtonSize.large,
        isLoading: isSubmitting,
      );
    }
  }

  Widget _buildToggleText() {
    return Center(
      child: TextButton(
        onPressed: _toggleMode,
        child: Text(
          _isSignUp
              ? 'Already have an account? Log In'
              : 'Don\'t have an account? Sign Up',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray),
        ),
      ),
    );
  }

  String _buildSocialButtonLabel(String provider) {
    return _isSignUp ? 'Sign up with $provider' : 'Sign in with $provider';
  }
}
