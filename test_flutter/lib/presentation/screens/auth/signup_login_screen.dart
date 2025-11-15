import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
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
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _toggleMode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
              color: isSelected
                  ? AppColors.blue
                  : AppColors.textSecondary,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
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
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: backgroundColor == AppColors.black
            ? Border.all(color: AppColors.gray.withValues(alpha: 0.35))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSubmit,
          borderRadius: BorderRadius.circular(AppRadius.large),
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
        Expanded(
          child: Divider(
            color: AppColors.gray.withValues(alpha: 0.35),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.gray.withValues(alpha: 0.35),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return SpacedColumn(
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildColoredTextField(
          label: 'Email',
          placeholder: 'your.email@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email,
          focusColor: AppColors.blue,
        ),
        if (_isSignUp)
          _buildColoredTextField(
            label: 'Username',
            placeholder: 'your_username',
            controller: _usernameController,
            icon: Icons.person,
            focusColor: AppColors.green,
          ),
        _buildColoredTextField(
          label: 'Password',
          placeholder: '••••••••',
          controller: _passwordController,
          obscureText: true,
          icon: Icons.lock,
          focusColor: AppColors.orange,
        ),
        if (_isSignUp)
          _buildColoredTextField(
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

  Widget _buildColoredTextField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required IconData icon,
    required Color focusColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.body1.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(icon, color: AppColors.gray),
            filled: true,
            fillColor: AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(color: focusColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
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
          border: Border.all(
            color: AppColors.blue,
            width: 1.5,
          ),
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
          style: AppTextStyles.body2.copyWith(
            color: AppColors.gray,
          ),
        ),
      ),
    );
  }
}

