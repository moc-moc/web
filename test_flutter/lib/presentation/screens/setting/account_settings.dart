import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/feature/setting/account_settings_notifier.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/leveling/level_visuals.dart';
import 'package:test_flutter/presentation/widgets/level_badge.dart';

/// アカウント設定画面（新デザインシステム版）
class AccountSettingsScreenNew extends ConsumerStatefulWidget {
  const AccountSettingsScreenNew({super.key});

  @override
  ConsumerState<AccountSettingsScreenNew> createState() =>
      _AccountSettingsScreenNewState();
}

class _AccountSettingsScreenNewState
    extends ConsumerState<AccountSettingsScreenNew> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String _selectedColor = 'blue';
  bool _isLoading = true;
  bool _isAuthenticated = false;

  final List<Map<String, dynamic>> _avatarColors = [
    {'name': 'blue', 'color': AppColors.blue},
    {'name': 'purple', 'color': AppColors.purple},
    {'name': 'green', 'color': AppColors.success},
    {'name': 'yellow', 'color': AppColors.yellow},
    {'name': 'red', 'color': AppColors.red},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
      _loadSettings();
    });
  }

  Future<void> _checkAuthState() async {
    final isAuthenticated = AuthServiceUN.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuthenticated;
    });
  }

  Future<void> _loadSettings() async {
    try {
      await loadAccountSettingsWithBackgroundRefreshHelper(ref);
      final settings = ref.read(accountSettingsProvider);
      setState(() {
        _nameController.text = settings.accountName;
        _selectedColor = settings.avatarColor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getEmail() {
    final settings = ref.read(accountSettingsProvider);
    return settings.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final currentSettings = ref.read(accountSettingsProvider);
    final updatedSettings = currentSettings.copyWith(
      accountName: _nameController.text.isNotEmpty
          ? _nameController.text
          : 'ユーザー',
      avatarColor: _selectedColor,
      lastModified: DateTime.now(),
    );

    final success = await saveAccountSettingsHelper(ref, updatedSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Settings saved!' : 'Failed to save settings',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        appBar: AppBarWithBack(title: 'Account Settings'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Account Settings'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // アバタープレビュー
              _buildAvatarPreview(),
              _buildLevelOverview(),

              // アカウント名
              _buildTextFieldCard(
                child: AppTextField(
                  label: 'Username',
                  controller: _nameController,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // メールアドレス（読み取り専用）
              _buildEmailCard(),

              // 自己紹介
              _buildTextFieldCard(
                child: AppTextField(
                  label: 'Bio',
                  controller: _bioController,
                  maxLines: 3,
                  placeholder: 'Tell us about yourself...',
                  prefixIcon: const Icon(
                    Icons.edit,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // アバターカラー選択
              _buildColorPicker(),

              SizedBox(height: AppSpacing.md),

              // 保存ボタン
              PrimaryButton(
                text: 'Save Changes',
                size: ButtonSize.large,
                icon: Icons.check,
                onPressed: _handleSave,
              ),

              SizedBox(height: AppSpacing.lg),

              // 認証セクション
              _buildAuthSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Authentication',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (_isAuthenticated)
            // サインアウトボタン
            SecondaryButton(
              text: 'Sign Out',
              size: ButtonSize.large,
              icon: Icons.logout,
              onPressed: _handleSignOut,
            )
          else
            // サインインボタン
            PrimaryButton(
              text: 'Sign In',
              size: ButtonSize.large,
              icon: Icons.login,
              onPressed: _handleSignIn,
            ),
        ],
      ),
    );
  }

  Widget _buildLevelOverview() {
    final levelState = ref.watch(levelingStateProvider);
    final visuals = LevelRankVisuals.resolveForLevel(levelState.level);
    final hours = (levelState.personSeconds / 3600).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: visuals.badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          LevelBadge(
            tier: levelState.rank,
            level: levelState.level,
            showGlow: true,
            size: 72,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Rank',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${visuals.label} • Lv ${levelState.level}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$hours h human focus',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    await _showSignInDialog();
  }

  Future<void> _showSignInDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _SignInDialog(
        onGoogleSignIn: _handleGoogleSignIn,
        onAppleSignIn: _handleAppleSignIn,
        onEmailSignIn: _handleEmailSignIn,
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    Navigator.of(context).pop(); // ダイアログを閉じる

    try {
      final result = await AuthServiceUN.signInWithGoogle();

      if (result.success && mounted) {
        await _syncAccountSettingsAfterSocialLogin();

        setState(() {
          _isAuthenticated = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ログインに成功しました'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログイン中にエラーが発生しました'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    Navigator.of(context).pop(); // ダイアログを閉じる

    try {
      final result = await AuthServiceUN.signInWithApple();

      if (result.success && mounted) {
        await _syncAccountSettingsAfterSocialLogin();

        setState(() {
          _isAuthenticated = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appleでログインしました'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple認証中にエラーが発生しました'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    Navigator.of(context).pop(); // ダイアログを閉じる

    // UIのみ実装（今後実装予定）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('メールアドレス認証は今後実装予定です'),
        backgroundColor: AppColors.gray,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'サインアウト',
      message: '本当にサインアウトしますか？',
      confirmText: 'サインアウト',
      cancelText: 'キャンセル',
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      try {
        await AuthServiceUN.signOut();
        await ref.read(authControllerProvider.notifier).signOut();

        if (mounted) {
          // ログイン画面に遷移（全画面をクリア）
          await NavigationHelper.pushAndRemoveUntil(
            context,
            AppRoutes.signupLogin,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('サインアウト中にエラーが発生しました'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _syncAccountSettingsAfterSocialLogin() async {
    try {
      final container = AppInitUN.getGlobalContainer();
      if (container != null) {
        try {
          await syncAccountSettingsHelper(container).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⚠️ [AccountSettings] アカウント設定同期タイムアウト（10秒）');
              return AccountSettings.defaultSettings();
            },
          );
          debugPrint('✅ [AccountSettings] アカウント設定読み込み完了');
        } catch (e) {
          debugPrint('⚠️ [AccountSettings] アカウント設定同期エラー: $e');
        }
      } else {
        debugPrint('⚠️ [AccountSettings] ProviderContainerが設定されていません');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AccountSettings] アカウント設定読み込みエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
    }
  }

  Widget _buildTextFieldCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }

  Widget _buildAvatarPreview() {
    final selectedColor = _getColorFromName(_selectedColor);
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: selectedColor, width: 2.0),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0]
                      : '?',
                  style: TextStyle(
                    color: selectedColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text('Avatar Preview', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar Color',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: _avatarColors.map((colorData) {
              final isSelected = _selectedColor == colorData['name'];
              final color = colorData['color'] as Color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = colorData['name'];
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : color.withValues(alpha: 0.4),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(child: Icon(Icons.check, color: color, size: 28))
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colorData = _avatarColors.firstWhere(
      (c) => c['name'] == name,
      orElse: () => _avatarColors[0],
    );
    return colorData['color'];
  }

  Widget _buildEmailCard() {
    final email = _getEmail();
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.email, color: AppColors.textSecondary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  email ?? 'メールアドレスが設定されていません',
                  style: AppTextStyles.body1.copyWith(
                    color: email != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (email == null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'メールアドレスはFirebase認証から自動的に取得されます',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// サインインダイアログ
class _SignInDialog extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onEmailSignIn;

  const _SignInDialog({
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onEmailSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: 'サインイン',
      content: SpacedColumn(
        spacing: AppSpacing.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'サインイン方法を選択してください',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.lg),
          // Apple認証ボタン
          SocialLoginButton(
            text: 'Sign in with Apple',
            icon: Icons.apple,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            onTap: onAppleSignIn,
          ),
          // Google認証ボタン
          SocialLoginButton(
            text: 'Sign in with Google',
            icon: Icons.g_mobiledata,
            textColor: AppColors.textPrimary,
            backgroundColor: AppColors.backgroundCard,
            onTap: onGoogleSignIn,
          ),
          // メールアドレス認証ボタン
          SocialLoginButton(
            text: 'Sign in with Email',
            icon: Icons.email,
            textColor: AppColors.textPrimary,
            backgroundColor: AppColors.backgroundCard,
            onTap: onEmailSignIn,
          ),
        ],
      ),
      actions: [
        SecondaryButton(
          text: 'キャンセル',
          onPressed: () => Navigator.of(context).pop(),
          size: ButtonSize.small,
          borderRadius: 30,
        ),
      ],
    );
  }
}
