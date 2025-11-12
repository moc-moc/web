import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/dummy_data/user_data.dart';

/// メイン設定画面（新デザインシステム版）
class SettingsScreenNew extends StatelessWidget {
  const SettingsScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: 'Settings'),
      body: ScrollableContent(
        child: SpacedColumn(
          spacing: AppSpacing.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // プロフィールセクション
            _buildProfileSection(context),

            SizedBox(height: AppSpacing.md),

            // 設定項目リスト
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return StandardCard(
      child: Column(
        children: [
          // アバター
          AvatarWidget(
            initials: dummyUser.name[0],
            size: 80,
            backgroundColor: AppColors.blue,
          ),
          SizedBox(height: AppSpacing.md),

          // ユーザー名
          Text(dummyUser.name, style: AppTextStyles.h2),
          SizedBox(height: AppSpacing.xs),
          Text(
            dummyUser.userId,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),

          // 統計情報（将来実装: フォロー・フォロワー数）
          // SizedBox(height: AppSpacing.md),
          // Row(...)
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
            // 将来実装
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
      child: InteractiveCard(
        onTap: onTap,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
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
    );
  }
}
