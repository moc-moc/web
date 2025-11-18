import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/feature/setting/display_settings_notifier.dart';
import 'package:test_flutter/feature/setting/time_settings_notifier.dart';

/// 表示名・リセット時間設定画面（新デザインシステム版）
class DisplaySettingsScreenNew extends ConsumerStatefulWidget {
  const DisplaySettingsScreenNew({super.key});

  @override
  ConsumerState<DisplaySettingsScreenNew> createState() =>
      _DisplaySettingsScreenNewState();
}

class _DisplaySettingsScreenNewState extends ConsumerState<DisplaySettingsScreenNew> {
  late TextEditingController _studyNameController;
  late TextEditingController _pcNameController;
  late TextEditingController _smartphoneNameController;
  TimeOfDay _resetTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _studyNameController = TextEditingController();
    _pcNameController = TextEditingController();
    _smartphoneNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      await loadDisplaySettingsWithBackgroundRefreshHelper(ref);
      await loadTimeSettingsWithBackgroundRefreshHelper(ref);
      
      final displaySettings = ref.read(displaySettingsProvider);
      final timeSettings = ref.read(timeSettingsProvider);
      
      setState(() {
        // DisplaySettings: category1Name=study, category2Name=pc, category3Name=smartphone
        _studyNameController.text = displaySettings.category1Name;
        _pcNameController.text = displaySettings.category2Name;
        _smartphoneNameController.text = displaySettings.category3Name;
        
        // TimeSettings: dayBoundaryTimeをTimeOfDayに変換
        final timeParts = timeSettings.dayBoundaryTime.split(':');
        if (timeParts.length == 2) {
          _resetTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 0,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _studyNameController.dispose();
    _pcNameController.dispose();
    _smartphoneNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final displaySettings = ref.read(displaySettingsProvider);
    final timeSettings = ref.read(timeSettingsProvider);
    
    // DisplaySettingsを更新
    final updatedDisplaySettings = displaySettings.copyWith(
      category1Name: _studyNameController.text.isNotEmpty 
          ? _studyNameController.text 
          : 'Study',
      category2Name: _pcNameController.text.isNotEmpty 
          ? _pcNameController.text 
          : 'Computer',
      category3Name: _smartphoneNameController.text.isNotEmpty 
          ? _smartphoneNameController.text 
          : 'Smartphone',
      lastModified: DateTime.now(),
    );
    
    // TimeSettingsを更新（リセット時間）
    final resetTimeString = '${_resetTime.hour.toString().padLeft(2, '0')}:${_resetTime.minute.toString().padLeft(2, '0')}';
    final updatedTimeSettings = timeSettings.copyWith(
      dayBoundaryTime: resetTimeString,
      lastModified: DateTime.now(),
    );
    
    final displaySuccess = await saveDisplaySettingsHelper(ref, updatedDisplaySettings);
    final timeSuccess = await saveTimeSettingsHelper(ref, updatedTimeSettings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (displaySuccess && timeSuccess) 
                ? 'Display settings saved!' 
                : 'Failed to save settings'
          ),
          backgroundColor: (displaySuccess && timeSuccess) 
              ? AppColors.success 
              : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        appBar: AppBarWithBack(title: 'Display Settings'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    color: AppColors.purple.withValues(alpha: 0.4),
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
                              color: AppColors.purple,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                color: AppColors.purple,
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
