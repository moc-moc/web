import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';

/// 表示名・リセット時間設定画面（新デザインシステム版）
class DisplaySettingsScreenNew extends StatefulWidget {
  const DisplaySettingsScreenNew({super.key});

  @override
  State<DisplaySettingsScreenNew> createState() =>
      _DisplaySettingsScreenNewState();
}

class _DisplaySettingsScreenNewState extends State<DisplaySettingsScreenNew> {
  late TextEditingController _studyNameController;
  late TextEditingController _pcNameController;
  late TextEditingController _smartphoneNameController;
  TimeOfDay _resetTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _studyNameController = TextEditingController(text: 'Study');
    _pcNameController = TextEditingController(text: 'Computer');
    _smartphoneNameController = TextEditingController(text: 'Smartphone');
  }

  @override
  void dispose() {
    _studyNameController.dispose();
    _pcNameController.dispose();
    _smartphoneNameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // ダミー: 保存処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Display settings saved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: 'Display Settings'),
      body: ScrollableContent(
        child: SpacedColumn(
          spacing: AppSpacing.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // カテゴリー表示名設定
            StandardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Display Names',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Customize how categories are displayed',
                    style: AppTextStyles.caption,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Study',
                    controller: _studyNameController,
                    prefixIcon: Icon(
                      Icons.menu_book,
                      color: AppChartColors.study,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Computer',
                    controller: _pcNameController,
                    prefixIcon: Icon(Icons.computer, color: AppChartColors.pc),
                  ),
                  SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Smartphone',
                    controller: _smartphoneNameController,
                    prefixIcon: Icon(
                      Icons.smartphone,
                      color: AppChartColors.smartphone,
                    ),
                  ),
                ],
              ),
            ),

            // リセット時間設定
            StandardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reset Time',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Time when daily statistics reset',
                    style: AppTextStyles.caption,
                  ),
                  SizedBox(height: AppSpacing.md),

                  AppTimePicker(
                    selectedTime: _resetTime,
                    onTimeSelected: (time) {
                      setState(() => _resetTime = time);
                    },
                  ),
                ],
              ),
            ),

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
    );
  }
}
