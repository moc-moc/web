import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/dummy_data/user_data.dart';

/// アカウント設定画面（新デザインシステム版）
class AccountSettingsScreenNew extends StatefulWidget {
  const AccountSettingsScreenNew({super.key});

  @override
  State<AccountSettingsScreenNew> createState() =>
      _AccountSettingsScreenNewState();
}

class _AccountSettingsScreenNewState extends State<AccountSettingsScreenNew> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String _selectedColor = 'blue';

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
    _nameController = TextEditingController(text: dummyUser.name);
    _bioController = TextEditingController(text: dummyUser.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // ダミー: 保存処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ),
      ),
    );
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
                border: Border.all(
                  color: selectedColor,
                  width: 2.0,
                ),
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
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: color,
                            size: 28,
                          ),
                        )
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
}
