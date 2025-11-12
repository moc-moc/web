import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';

/// サインアップ/ログイン画面
class SignupLoginScreen extends StatefulWidget {
  const SignupLoginScreen({super.key});

  @override
  State<SignupLoginScreen> createState() => _SignupLoginScreenState();
}

class _SignupLoginScreenState extends State<SignupLoginScreen> {
  bool _isSignUp = true;
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
    // ダミー認証: 次の画面へ遷移
    Navigator.pushNamed(context, AppRoutes.initialSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: ScrollableContent(
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
                _buildTabSwitcher(),
                SizedBox(height: AppSpacing.xl),
                // Social Login Buttons
                _buildSocialLogins(),
                SizedBox(height: AppSpacing.lg),
                // Divider
                _buildDivider(),
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

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('Sign Up', _isSignUp)),
          Expanded(child: _buildTab('Log In', !_isSignUp)),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Material(
      color: isSelected ? AppColors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: _toggleMode,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            text,
            style: AppTextStyles.body1.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogins() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSocialButton(
          'Sign in with Apple',
          Icons.apple,
          Colors.white,
          Colors.black,
        ),
        _buildSocialButton(
          'Sign in with Google',
          Icons.g_mobiledata,
          AppColors.textPrimary,
          AppColors.backgroundCard,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color textColor,
    Color backgroundColor,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: backgroundColor == AppColors.backgroundCard
            ? Border.all(color: AppColors.textSecondary, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSubmit,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: AppTextStyles.body1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textDisabled, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textDisabled, thickness: 1)),
      ],
    );
  }

  Widget _buildInputFields() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Email',
          placeholder: 'your.email@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
        ),
        if (_isSignUp)
          AppTextField(
            label: 'Username',
            placeholder: 'your_username',
            controller: _usernameController,
            prefixIcon: const Icon(
              Icons.person,
              color: AppColors.textSecondary,
            ),
          ),
        AppTextField(
          label: 'Password',
          placeholder: '••••••••',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondary),
        ),
        if (_isSignUp)
          AppTextField(
            label: 'Confirm Password',
            placeholder: '••••••••',
            controller: _passwordConfirmController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: _isSignUp ? 'Create Account' : 'Log In',
      onPressed: _handleSubmit,
      size: ButtonSize.large,
    );
  }

  Widget _buildToggleText() {
    return Center(
      child: AppTextButton(
        text: _isSignUp
            ? 'Already have an account? Log In'
            : 'Don\'t have an account? Sign Up',
        onPressed: _toggleMode,
        size: ButtonSize.small,
      ),
    );
  }
}
