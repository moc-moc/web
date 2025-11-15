import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
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
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Display Settings'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // カテゴリー表示名設定
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
                ),
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
                      labelColor: AppColors.green,
                      prefixIcon: Icon(
                        Icons.menu_book,
                        color: AppColors.green,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Computer',
                      controller: _pcNameController,
                      labelColor: AppColors.blue,
                      prefixIcon: Icon(Icons.computer, color: AppColors.blue),
                    ),
                    SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Smartphone',
                      controller: _smartphoneNameController,
                      labelColor: AppColors.orange,
                      prefixIcon: Icon(
                        Icons.smartphone,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // リセット時間設定
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
                ),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: AppColors.blackgray,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: InkWell(
                    onTap: _handleSave,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    child: Container(
                      height: 56.0,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: AppColors.blue,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                color: AppColors.blue,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
