import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';

/// ダイアログベース
class AppDialogBase extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final double? height;

  const AppDialogBase({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.85,
        height: height,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(title, style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.md),
            // Content
            Flexible(child: SingleChildScrollView(child: content)),
            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.lg),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
            ],
          ],
        ),
      ),
    );
  }

  /// ダイアログを表示する
  static Future<T?> show<T>(BuildContext context, Widget dialog) {
    return showDialog<T>(context: context, builder: (context) => dialog);
  }
}

/// 確認ダイアログ
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: title,
      content: Text(message, style: AppTextStyles.body1),
      actions: [
        AppTextButton(
          text: cancelText,
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          size: ButtonSize.small,
        ),
        SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          text: confirmText,
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          size: ButtonSize.small,
        ),
      ],
    );
  }

  /// 確認ダイアログを表示する
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
  }) {
    return AppDialogBase.show<bool>(
      context,
      ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
      ),
    );
  }
}

/// 目標設定ダイアログ
class GoalSettingDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialCategory;
  final String? initialPeriod;
  final double? initialTargetHours;
  final bool? initialIsFocusedOnly;
  final bool isEdit;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const GoalSettingDialog({
    super.key,
    this.initialTitle,
    this.initialCategory,
    this.initialPeriod,
    this.initialTargetHours,
    this.initialIsFocusedOnly,
    this.isEdit = false,
    this.onSave,
    this.onDelete,
  });

  @override
  State<GoalSettingDialog> createState() => _GoalSettingDialogState();
}

class _GoalSettingDialogState extends State<GoalSettingDialog> {
  late TextEditingController _titleController;
  late TextEditingController _targetHoursController;
  late String _selectedCategory;
  late String _selectedPeriod;
  late bool _isFocusedOnly;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'study', 'label': 'Study', 'icon': Icons.menu_book},
    {'id': 'pc', 'label': 'Computer', 'icon': Icons.computer},
    {'id': 'smartphone', 'label': 'Smartphone', 'icon': Icons.smartphone},
    {'id': 'work', 'label': 'Work', 'icon': Icons.work},
  ];

  final List<Map<String, String>> _periods = [
    {'id': 'daily', 'label': 'Daily'},
    {'id': 'weekly', 'label': 'Weekly'},
    {'id': 'monthly', 'label': 'Monthly'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _targetHoursController = TextEditingController(
      text: widget.initialTargetHours?.toStringAsFixed(1) ?? '2.0',
    );
    _selectedCategory = widget.initialCategory ?? 'study';
    _selectedPeriod = widget.initialPeriod ?? 'daily';
    _isFocusedOnly = widget.initialIsFocusedOnly ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: widget.isEdit ? 'Edit Goal' : 'Set New Goal',
      height: MediaQuery.of(context).size.height * 0.8,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル入力
          AppTextField(
            label: 'Goal Title',
            controller: _titleController,
            placeholder: 'e.g., Study Time',
          ),
          SizedBox(height: AppSpacing.lg),

          // カテゴリー選択
          Text(
            'Category',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'] as String;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blue.withValues(alpha: 0.2)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: isSelected ? AppColors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? AppColors.blue
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        category['label'] as String,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? AppColors.blue
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.lg),

          // 期間選択
          Text(
            'Period',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period['id'];
              return AppFilterChip(
                label: period['label']!,
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPeriod = period['id']!;
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.lg),

          // 目標時間入力
          AppTextField(
            label: 'Target Hours',
            controller: _targetHoursController,
            placeholder: '2.0',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: AppSpacing.lg),

          // 集中時間のみ
          Row(
            children: [
              AppToggleSwitch(
                value: _isFocusedOnly,
                onChanged: (value) {
                  setState(() {
                    _isFocusedOnly = value;
                  });
                },
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Focused time only', style: AppTextStyles.body2),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.isEdit && widget.onDelete != null)
          AppTextButton(
            text: 'Delete',
            textColor: AppColors.error,
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            size: ButtonSize.small,
          ),
        Spacer(),
        AppTextButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          size: ButtonSize.small,
        ),
        SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          text: 'Save',
          onPressed: () {
            // ダミー保存処理
            Navigator.of(context).pop();
            widget.onSave?.call();

            // スナックバーで保存成功を表示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.isEdit
                      ? 'Goal updated successfully!'
                      : 'Goal created successfully!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          },
          size: ButtonSize.small,
        ),
      ],
    );
  }
}

/// カウントダウン設定ダイアログ
class CountdownSettingDialog extends StatefulWidget {
  final String? initialEventName;
  final DateTime? initialDate;
  final bool isEdit;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const CountdownSettingDialog({
    super.key,
    this.initialEventName,
    this.initialDate,
    this.isEdit = false,
    this.onSave,
    this.onDelete,
  });

  @override
  State<CountdownSettingDialog> createState() => _CountdownSettingDialogState();
}

class _CountdownSettingDialogState extends State<CountdownSettingDialog> {
  late TextEditingController _eventNameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(
      text: widget.initialEventName ?? '',
    );
    _selectedDate =
        widget.initialDate ?? DateTime.now().add(Duration(days: 30));
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _selectedDate.difference(DateTime.now()).inDays;

    return AppDialogBase(
      title: widget.isEdit ? 'Edit Countdown' : 'Set Countdown',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // イベント名入力
          AppTextField(
            label: 'Event Name',
            controller: _eventNameController,
            placeholder: 'e.g., Mid-term Exams',
          ),
          SizedBox(height: AppSpacing.lg),

          // 日付選択
          Text(
            'Target Date',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          AppDatePicker(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          SizedBox(height: AppSpacing.md),

          // 残り日数表示
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.blue, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '$daysRemaining days remaining',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.isEdit && widget.onDelete != null)
          AppTextButton(
            text: 'Delete',
            textColor: AppColors.error,
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            size: ButtonSize.small,
          ),
        Spacer(),
        AppTextButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          size: ButtonSize.small,
        ),
        SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          text: 'Save',
          onPressed: () {
            // ダミー保存処理
            Navigator.of(context).pop();
            widget.onSave?.call();

            // スナックバーで保存成功を表示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.isEdit
                      ? 'Countdown updated successfully!'
                      : 'Countdown created successfully!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          },
          size: ButtonSize.small,
        ),
      ],
    );
  }
}
