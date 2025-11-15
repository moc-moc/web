import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';

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
      backgroundColor: AppColors.blackgray,
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
        SecondaryButton(
          text: cancelText,
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          size: ButtonSize.small,
          borderRadius: 30,
        ),
        SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          text: confirmText,
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          size: ButtonSize.small,
          borderRadius: 30,
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
  late String _comparisonType;

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
    _comparisonType = widget.initialIsFocusedOnly == false ? 'below' : 'above';
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
            fillColor: AppColors.lightblackgray,
          ),
          SizedBox(height: AppSpacing.lg),

          // カテゴリー選択
          Text(
            'Category',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['id'];
              final Color backgroundColor =
                  isSelected ? AppColors.blue : AppColors.lightblackgray;
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
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blue.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        category['label'] as String,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
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
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period['id']!;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blue
                        : AppColors.lightblackgray,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blue.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    period['label']!,
                    style: AppTextStyles.body2.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.lg),

          // 目標時間入力
          AppTextField(
            label: 'Target Hours',
            controller: _targetHoursController,
            placeholder: 'e.g., 12',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            fillColor: AppColors.lightblackgray,
            suffixIcon: Padding(
              padding: EdgeInsets.only(
                right: AppSpacing.md,
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                'hrs',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Set the total hours for the selected period.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // 比較タイプ選択
          Text(
            'Comparison Type',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _comparisonType = 'above';
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _comparisonType == 'above'
                        ? AppColors.blue
                        : AppColors.lightblackgray,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _comparisonType == 'above'
                          ? AppColors.blue.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Above',
                    style: AppTextStyles.body2.copyWith(
                      color: _comparisonType == 'above'
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: _comparisonType == 'above'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _comparisonType = 'below';
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _comparisonType == 'below'
                        ? AppColors.blue
                        : AppColors.lightblackgray,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _comparisonType == 'below'
                          ? AppColors.blue.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Below',
                    style: AppTextStyles.body2.copyWith(
                      color: _comparisonType == 'below'
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: _comparisonType == 'below'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.isEdit && widget.onDelete != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Material(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete?.call();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: Text(
                      'Delete',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.gray.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Material(
            color: AppColors.gray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Material(
            color: AppColors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
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
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'Save',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
            fillColor: AppColors.lightblackgray,
          ),
          SizedBox(height: AppSpacing.lg),

          // 日付選択
          AppDatePicker(
            label: 'Target Date',
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            backgroundColor: AppColors.lightblackgray,
            labelColor: AppColors.gray,
          ),
        ],
      ),
      actions: [
        if (widget.isEdit && widget.onDelete != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Material(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete?.call();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: Text(
                      'Delete',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.gray.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Material(
            color: AppColors.gray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Material(
            color: AppColors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
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
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'Save',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
