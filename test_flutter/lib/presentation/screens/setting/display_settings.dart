import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/feature/setting/time_settings_notifier.dart';

/// リセット時間設定画面（新デザインシステム版）
class DisplaySettingsScreenNew extends ConsumerStatefulWidget {
  const DisplaySettingsScreenNew({super.key});

  @override
  ConsumerState<DisplaySettingsScreenNew> createState() =>
      _DisplaySettingsScreenNewState();
}

class _DisplaySettingsScreenNewState
    extends ConsumerState<DisplaySettingsScreenNew> {
  TimeOfDay _resetTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      await loadTimeSettingsWithBackgroundRefreshHelper(ref);

      final timeSettings = ref.read(timeSettingsProvider);

      setState(() {
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

  Future<void> _handleSave() async {
    final timeSettings = ref.read(timeSettingsProvider);

    final resetTimeString =
        '${_resetTime.hour.toString().padLeft(2, '0')}:${_resetTime.minute.toString().padLeft(2, '0')}';
    final updatedTimeSettings = timeSettings.copyWith(
      dayBoundaryTime: resetTimeString,
      lastModified: DateTime.now(),
    );

    final timeSuccess = await saveTimeSettingsHelper(ref, updatedTimeSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            timeSuccess ? 'Reset time saved!' : 'Failed to save settings',
          ),
          backgroundColor: timeSuccess ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        appBar: AppBarWithBack(title: 'Reset Time Setting'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Reset Time Setting'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
