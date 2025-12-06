import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/setting/account_settings_notifier.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';
import 'package:test_flutter/data/models/subscription_status.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// メイン設定画面（新デザインシステム版）
class SettingsScreenNew extends ConsumerStatefulWidget {
  const SettingsScreenNew({super.key});

  @override
  ConsumerState<SettingsScreenNew> createState() => _SettingsScreenNewState();
}

class _SettingsScreenNewState extends ConsumerState<SettingsScreenNew> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.profile?.isAdmin ?? false;
    return ScrollableContent(
      child: SpacedColumn(
        spacing: AppSpacing.lg,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileSection(context, ref),
          _buildSettingsSection(context, isAdmin: isAdmin),
          _buildPreviewSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref) {
    final accountSettings = ref.watch(accountSettingsProvider);
    final displayName = accountSettings.accountName.isNotEmpty 
        ? accountSettings.accountName 
        : 'ユーザー';
    final userId = '@${accountSettings.id}';
    final avatarColorName = accountSettings.avatarColor;
    final avatarColor = CustomColorPicker.colors[avatarColorName] ?? AppColors.blue;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.blackgray,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // アバター（左上）- 背景は透明度付きの設定色
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: avatarColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // ユーザー名（右側）
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: AppTextStyles.h2),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      userId,
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required bool isAdmin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.md),

        _buildSettingItem(
          context,
          icon: Icons.person,
          iconColor: AppColors.blue,
          title: 'Account Settings',
          subtitle: 'Profile, bio, and more',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.accountSettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.notifications,
          iconColor: AppColors.success,
          title: 'Notification Settings',
          subtitle: 'Manage your notifications',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.notificationSettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.schedule,
          iconColor: AppColors.purple,
          title: 'Reset Time Setting',
          subtitle: 'Choose when your day resets',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.displaySettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.star,
          iconColor: AppColors.yellow,
          title: 'Subscribe',
          subtitle: 'Unlock premium features',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.subscriptionNew);
          },
        ),

        if (isAdmin)
          _buildSettingItem(
            context,
            icon: Icons.lock_open,
            iconColor: AppColors.green,
            title: 'Subscription Admin',
            subtitle: 'プラン・トライアルを手動で管理',
            onTap: () {
              NavigationHelper.push(context, AppRoutes.subscriptionAdmin);
            },
          ),

        _buildSettingItem(
          context,
          icon: Icons.help_outline,
          iconColor: AppColors.textSecondary,
          title: 'Contact Us',
          subtitle: 'Get help and support',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.contactUsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.celebration,
          iconColor: AppColors.red,
          title: 'Event Preview',
          subtitle: 'View all event screens',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.eventPreviewNew);
          },
        ),

        SizedBox(height: AppSpacing.lg),

        // デバッグセクション
        Text('Debug', style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.md),
        _buildDebugSubscriptionToggle(context),

        SizedBox(height: AppSpacing.lg),
        _buildSignOutItem(context),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackgray,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // 丸いアイコン
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: iconColor.withValues(alpha: 0.2),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugSubscriptionToggle(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final isPremium = subscriptionStatus.hasPremiumAccess;
    final currentPlan = subscriptionStatus.planType.name;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.orange.withValues(alpha: 0.2),
                child: Icon(Icons.bug_report, color: AppColors.orange, size: 24),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Debug',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      'Current: $currentPlan (${isPremium ? "Premium" : "Free"})',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _switchToFree(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.2),
                    foregroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      side: BorderSide(color: AppColors.error, width: 1),
                    ),
                  ),
                  child: Text('Free', style: AppTextStyles.body2),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _switchToPremium(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success.withValues(alpha: 0.2),
                    foregroundColor: AppColors.success,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      side: BorderSide(color: AppColors.success, width: 1),
                    ),
                  ),
                  child: Text('Premium', style: AppTextStyles.body2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _switchToFree(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '無料版に切り替え',
      message: 'サブスクリプションを無料版に切り替えますか？',
      confirmText: '切り替え',
      cancelText: 'キャンセル',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final repository = ref.read(userRepositoryProvider);
      final freeStatus = const SubscriptionStatus.free();
      
      await repository.updateSubscriptionStatus(user.uid, freeStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('無料版に切り替えました'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切り替え中にエラーが発生しました: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _switchToPremium(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '有料版に切り替え',
      message: 'サブスクリプションを有料版（月額プラン）に切り替えますか？',
      confirmText: '切り替え',
      cancelText: 'キャンセル',
      confirmColor: AppColors.success,
    );

    if (confirmed != true) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final repository = ref.read(userRepositoryProvider);
      final premiumStatus = SubscriptionStatus(
        planType: SubscriptionPlanType.monthly,
        nextBillingAt: DateTime.now().add(const Duration(days: 30)),
      );
      
      await repository.updateSubscriptionStatus(user.uid, premiumStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('有料版に切り替えました'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切り替え中にエラーが発生しました: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildSignOutItem(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.logout,
      iconColor: AppColors.error,
      title: 'Sign Out',
      subtitle: 'Log out from this device',
      onTap: () => _handleSignOut(context),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'サインアウト',
      message: '本当にサインアウトしますか？',
      confirmText: 'サインアウト',
      cancelText: 'キャンセル',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) {
      return;
    }

    try {
      await AuthServiceUN.signOut();
      await ref.read(authControllerProvider.notifier).signOut();

      if (!mounted) return;
      await NavigationHelper.pushAndRemoveUntil(
        context,
        AppRoutes.signupLogin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('サインアウト中にエラーが発生しました ($e)'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPreviewSection(BuildContext context) {
    final captionStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview & Test Screens', style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.md),

        // Auth screens
        Text('Auth', style: captionStyle),
        SizedBox(height: AppSpacing.sm),
        _buildSettingItem(
          context,
          icon: Icons.login,
          iconColor: AppColors.blue,
          title: 'Sign Up & Login',
          subtitle: 'Preview authentication entry screen',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.signupLogin);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.tune,
          iconColor: AppColors.purple,
          title: 'Initial Setup',
          subtitle: 'Initial preferences flow',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.initialSetup);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.flag,
          iconColor: AppColors.orange,
          title: 'Initial Goal Setup',
          subtitle: 'Set the first goal during onboarding',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.initialGoal);
          },
        ),

        SizedBox(height: AppSpacing.lg),

        // Components
        Text('Components', style: captionStyle),
        SizedBox(height: AppSpacing.sm),
        _buildSettingItem(
          context,
          icon: Icons.widgets,
          iconColor: AppColors.blue,
          title: 'Widget Catalog',
          subtitle: 'Component showcase for the new design system',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.widgetCatalog);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.palette,
          iconColor: AppColors.purple,
          title: 'Color Palette',
          subtitle: 'Preview application color variations',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.colorPreview);
          },
        ),

        SizedBox(height: AppSpacing.lg),

        // Event screens
        Text('Event Screens', style: captionStyle),
        SizedBox(height: AppSpacing.sm),
        _buildSettingItem(
          context,
          icon: Icons.celebration,
          iconColor: AppColors.success,
          title: 'Goal Set',
          subtitle: 'Event screen when a new goal is created',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.goalSetEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.emoji_events,
          iconColor: AppColors.yellow,
          title: 'Goal Achieved',
          subtitle: 'Celebrate reaching a goal',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.goalAchievedEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.hourglass_bottom,
          iconColor: AppColors.orange,
          title: 'Goal Period Ended',
          subtitle: 'Display when a goal period is complete',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.goalPeriodEndedEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.local_fire_department,
          iconColor: AppColors.red,
          title: 'Streak Milestone',
          subtitle: 'Milestone event for streak achievements',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.streakMilestoneEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.timer,
          iconColor: AppColors.blue,
          title: 'Total Hours Milestone',
          subtitle: 'Celebrate total focused hours milestones',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.totalHoursMilestoneEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.schedule,
          iconColor: AppColors.green,
          title: 'Countdown Set',
          subtitle: 'Event when a countdown timer is created',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.countdownSetEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.alarm_on,
          iconColor: AppColors.purple,
          title: 'Countdown Ended',
          subtitle: 'Event when a countdown reaches zero',
          onTap: () {
            NavigationHelper.push(context, AppRoutes.countdownEndedEvent);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 4,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 4) return;
    switch (index) {
      case 0:
        NavigationHelper.pushReplacement(context, AppRoutes.home);
        break;
      case 1:
        NavigationHelper.pushReplacement(context, AppRoutes.goal);
        break;
      case 2:
        NavigationHelper.pushReplacement(context, AppRoutes.report);
        break;
      case 3:
        NavigationHelper.pushReplacement(context, AppRoutes.friend);
        break;
    }
  }
}
