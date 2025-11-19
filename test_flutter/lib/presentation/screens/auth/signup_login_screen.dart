import 'package:flutter/material.dart';
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

/// サインアップ/ログイン画面
class SignupLoginScreen extends StatefulWidget {
  const SignupLoginScreen({super.key});

  @override
  State<SignupLoginScreen> createState() => _SignupLoginScreenState();
}

class _SignupLoginScreenState extends State<SignupLoginScreen> {
  bool _isSignUp = true;
  bool _isLoading = false;
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

  void _handleSubmit() {
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

    // ダミー認証: 次の画面へ遷移
    NavigationHelper.push(context, AppRoutes.initialSetup);
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await AuthFormHelper.handleFormSubmit(
      context: context,
      submitFunction: () async {
        final result = await AuthServiceUN.signInWithGoogle();

        if (result.success && mounted) {
          // 認証成功後にデータ読み込みを実行
          try {
            debugPrint('🔄 [認証成功] Firestoreからデータを読み込み開始');
            await AppInitUN.loadAllData();
            debugPrint('✅ [認証成功] データ読み込み完了');
          } catch (e) {
            debugPrint('⚠️ [認証成功] データ読み込みエラー: $e');
            // エラーが発生してもホーム画面に遷移
          }

          NavigationHelper.pushReplacement(context, AppRoutes.home);
        } else if (mounted) {
          showErrorSnackBar(context, result.message);
        }
        return result.success;
      },
      errorMessage: '認証エラーが発生しました',
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildInputFields(),
                SizedBox(height: AppSpacing.xl),
                // Submit Button
                _buildSubmitButton(),
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
          text: 'Sign in with Apple',
          icon: Icons.apple,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          onTap: _handleSubmit,
        ),
        SocialLoginButton(
          text: 'Sign in with Google',
          icon: Icons.g_mobiledata,
          textColor: AppColors.textPrimary,
          backgroundColor: AppColors.backgroundCard,
          onTap: _handleGoogleSignIn,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildInputFields() {
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
        ),
        if (_isSignUp)
          ColoredTextField(
            label: 'Username',
            placeholder: 'your_username',
            controller: _usernameController,
            icon: Icons.person,
            focusColor: AppColors.green,
          ),
        ColoredTextField(
          label: 'Password',
          placeholder: '••••••••',
          controller: _passwordController,
          obscureText: true,
          icon: Icons.lock,
          focusColor: AppColors.orange,
        ),
        if (_isSignUp)
          ColoredTextField(
            label: 'Confirm Password',
            placeholder: '••••••••',
            controller: _passwordConfirmController,
            obscureText: true,
            icon: Icons.lock,
            focusColor: AppColors.orange,
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
            onTap: _handleSubmit,
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Center(
                child: Text(
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
        onPressed: _handleSubmit,
        size: ButtonSize.large,
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
}
