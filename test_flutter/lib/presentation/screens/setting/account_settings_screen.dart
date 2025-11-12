import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/data/models/settings_models.dart';

/// アカウント設定画面
/// ユーザーのアカウント情報を管理する画面
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  String _accountName = '';
  String _avatarColor = 'blue';

  @override
  Widget build(BuildContext context) {
    // Providerを監視（自動更新）
    final accountSettings = ref.watch(accountSettingsProvider);

    // Providerの値で初期化（初回のみ）
    if (_accountName.isEmpty) {
      _accountName = accountSettings.accountName;
      _avatarColor = accountSettings.avatarColor;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('アカウント設定'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // アバタープレビュー
            CustomAvatarDisplay(
              name: _accountName,
              colorName: _avatarColor,
              size: 120,
            ),
            const SizedBox(height: 30),

            // アカウント名入力
            CustomTextField(
              label: 'アカウント名',
              initialValue: _accountName,
              onChanged: (value) {
                setState(() {
                  _accountName = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 色選択
            CustomColorPicker(
              selectedColor: _avatarColor,
              onColorSelected: (color) {
                setState(() {
                  _avatarColor = color;
                });
              },
            ),
            const SizedBox(height: 30),

            // 保存ボタン
            CustomSnsButton(
              text: '保存',
              color: AppColors.blue,
              onPressed: () async {
                // 設定を保存
                final settings = AccountSettings(
                  id: 'account_settings',
                  accountName: _accountName,
                  avatarColor: _avatarColor,
                  lastModified: DateTime.now(),
                );

                final success = await saveAccountSettingsHelper(ref, settings);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '保存しました' : '保存に失敗しました'),
                      backgroundColor: success
                          ? AppColors.green
                          : AppColors.red,
                    ),
                  );

                  if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
