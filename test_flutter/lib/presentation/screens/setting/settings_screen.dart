import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';

/// 設定画面のメイン画面
/// ユーザー情報と4つの設定項目へのリンクを表示
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ユーザー情報セクション
            _buildUserInfoSection(ref),
            const SizedBox(height: 30),

            // 設定項目リスト
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  /// ユーザー情報セクションを構築
  Widget _buildUserInfoSection(WidgetRef ref) {
    // アカウント設定を取得
    final accountSettings = ref.watch(accountSettingsProvider);

    // 値を取得
    final userName = accountSettings.accountName;
    final avatarColor = accountSettings.avatarColor;

    return Column(
      children: [
        // ユーザーアイコン（色+頭文字）
        CustomAvatarDisplay(name: userName, colorName: avatarColor, size: 100),
        const SizedBox(height: 15),

        // ユーザー名
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.blackgray,
          ),
        ),
      ],
    );
  }

  /// 設定項目リストを構築
  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        // アカウント設定
        SettingsTile(
          icon: Icons.person,
          iconBackgroundColor: AppColors.blue,
          title: 'アカウント設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.accountSettings);
          },
        ),
        const SizedBox(height: 12),

        // 通知設定（iOS/Androidのみ表示）
        if (!kIsWeb) ...[
          SettingsTile(
            icon: Icons.notifications,
            iconBackgroundColor: AppColors.green,
            title: '通知設定',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notificationSettings);
            },
          ),
          const SizedBox(height: 12),
        ],

        // 表示設定
        SettingsTile(
          icon: Icons.display_settings,
          iconBackgroundColor: AppColors.red,
          title: '表示設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.displaySettings);
          },
        ),
        const SizedBox(height: 12),

        // 時間設定
        SettingsTile(
          icon: Icons.access_time,
          iconBackgroundColor: AppColors.gray,
          title: '時間設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.timeSettings);
          },
        ),

        // ========== テスト用セクション ==========
        const SizedBox(height: 30),
        const Divider(color: AppColors.gray),
        const SizedBox(height: 12),
        Text(
          '🧪 新デザインシステム版画面（テスト用）',
          style: TextStyle(
            color: AppColors.gray,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // テスト用: 認証フロー
        SettingsTile(
          icon: Icons.login,
          iconBackgroundColor: AppColors.purple,
          title: '認証フロー',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.signupLogin);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: 新ホーム画面
        SettingsTile(
          icon: Icons.home,
          iconBackgroundColor: AppColors.blue,
          title: 'ホーム画面',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.homeNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: トラッキング設定
        SettingsTile(
          icon: Icons.settings,
          iconBackgroundColor: AppColors.green,
          title: 'トラッキング設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.trackingSettingNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: トラッキング中
        SettingsTile(
          icon: Icons.play_circle,
          iconBackgroundColor: AppColors.success,
          title: 'トラッキング中',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.trackingNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: トラッキング終了
        SettingsTile(
          icon: Icons.check_circle,
          iconBackgroundColor: AppColors.purple,
          title: 'トラッキング終了',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.trackingFinishedNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: 目標画面
        SettingsTile(
          icon: Icons.flag,
          iconBackgroundColor: AppColors.yellow,
          title: '目標画面',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.goalNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: レポート画面
        SettingsTile(
          icon: Icons.assessment,
          iconBackgroundColor: AppColors.red,
          title: 'レポート画面',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.reportNew);
          },
        ),
        const SizedBox(height: 12),

        const Divider(color: AppColors.gray),
        const SizedBox(height: 12),
        Text(
          '🧪 設定画面（テスト用）',
          style: TextStyle(
            color: AppColors.gray,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // テスト用: メイン設定画面
        SettingsTile(
          icon: Icons.settings,
          iconBackgroundColor: AppColors.blue,
          title: 'メイン設定画面',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.settingsNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: アカウント設定
        SettingsTile(
          icon: Icons.person,
          iconBackgroundColor: AppColors.purple,
          title: 'アカウント設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.accountSettingsNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: 通知設定
        SettingsTile(
          icon: Icons.notifications,
          iconBackgroundColor: AppColors.green,
          title: '通知設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.notificationSettingsNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: 表示設定
        SettingsTile(
          icon: Icons.display_settings,
          iconBackgroundColor: AppColors.yellow,
          title: '表示設定',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.displaySettingsNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: サブスクリプション
        SettingsTile(
          icon: Icons.star,
          iconBackgroundColor: AppColors.yellow,
          title: 'サブスクリプション',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.subscriptionNew);
          },
        ),
        const SizedBox(height: 12),

        // テスト用: イベントプレビュー
        SettingsTile(
          icon: Icons.celebration,
          iconBackgroundColor: AppColors.red,
          title: 'イベントプレビュー',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.eventPreviewNew);
          },
        ),
      ],
    );
  }
}
