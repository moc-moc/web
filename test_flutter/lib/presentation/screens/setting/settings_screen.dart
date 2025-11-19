import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/dummy_data/user_data.dart';

/// メイン設定画面（新デザインシステム版）
class SettingsScreenNew extends StatelessWidget {
  const SettingsScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // プロフィールセクション
              _buildProfileSection(context),

              // 設定項目リスト
              _buildSettingsSection(context),

              // プレビュー / テスト用リンク
              _buildPreviewSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
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
              color: AppColors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blue,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                dummyUser.name[0],
                style: TextStyle(
                  color: AppColors.blue,
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
                Text(dummyUser.name, style: AppTextStyles.h2),
                SizedBox(height: AppSpacing.xs),
                Text(
                  dummyUser.userId,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
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
            Navigator.pushNamed(context, AppRoutes.accountSettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.notifications,
          iconColor: AppColors.success,
          title: 'Notification Settings',
          subtitle: 'Manage your notifications',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.notificationSettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.display_settings,
          iconColor: AppColors.purple,
          title: 'Display Settings',
          subtitle: 'Category names and reset time',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.displaySettingsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.star,
          iconColor: AppColors.yellow,
          title: 'Subscribe',
          subtitle: 'Unlock premium features',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.subscriptionNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.help_outline,
          iconColor: AppColors.textSecondary,
          title: 'Contact Us',
          subtitle: 'Get help and support',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.contactUsNew);
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.celebration,
          iconColor: AppColors.red,
          title: 'Event Preview',
          subtitle: 'View all event screens',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.eventPreviewNew);
          },
        ),
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
            Navigator.pushNamed(context, AppRoutes.signupLogin);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.tune,
          iconColor: AppColors.purple,
          title: 'Initial Setup',
          subtitle: 'Initial preferences flow',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.initialSetup);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.flag,
          iconColor: AppColors.orange,
          title: 'Initial Goal Setup',
          subtitle: 'Set the first goal during onboarding',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.initialGoal);
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
            Navigator.pushNamed(context, AppRoutes.widgetCatalog);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.palette,
          iconColor: AppColors.purple,
          title: 'Color Palette',
          subtitle: 'Preview application color variations',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.colorPreview);
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
            Navigator.pushNamed(context, AppRoutes.goalSetEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.emoji_events,
          iconColor: AppColors.yellow,
          title: 'Goal Achieved',
          subtitle: 'Celebrate reaching a goal',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.goalAchievedEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.hourglass_bottom,
          iconColor: AppColors.orange,
          title: 'Goal Period Ended',
          subtitle: 'Display when a goal period is complete',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.goalPeriodEndedEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.local_fire_department,
          iconColor: AppColors.red,
          title: 'Streak Milestone',
          subtitle: 'Milestone event for streak achievements',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.streakMilestoneEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.timer,
          iconColor: AppColors.blue,
          title: 'Total Hours Milestone',
          subtitle: 'Celebrate total focused hours milestones',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.totalHoursMilestoneEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.schedule,
          iconColor: AppColors.green,
          title: 'Countdown Set',
          subtitle: 'Event when a countdown timer is created',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.countdownSetEvent);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.alarm_on,
          iconColor: AppColors.purple,
          title: 'Countdown Ended',
          subtitle: 'Event when a countdown reaches zero',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.countdownEndedEvent);
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
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.goal);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.report);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.friend);
        break;
    }
  }
}
