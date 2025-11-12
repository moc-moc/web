import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// トグルスイッチ
class AppToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const AppToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: (activeColor ?? AppColors.blue).withValues(alpha: 0.5),
      inactiveThumbColor: AppColors.textDisabled,
      inactiveTrackColor: AppColors.backgroundSecondary,
    );
  }
}

/// チップ（タグ表示用）
class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  /// 青色チップ
  factory AppChip.blue({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return AppChip(
      label: label,
      backgroundColor: AppColors.blue,
      textColor: AppColors.textPrimary,
      icon: icon,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  /// 緑色チップ
  factory AppChip.green({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return AppChip(
      label: label,
      backgroundColor: AppColors.green,
      textColor: AppColors.textPrimary,
      icon: icon,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  /// 紫色チップ
  factory AppChip.purple({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return AppChip(
      label: label,
      backgroundColor: AppColors.purple,
      textColor: AppColors.textPrimary,
      icon: icon,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  /// グレーチップ
  factory AppChip.gray({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return AppChip(
      label: label,
      backgroundColor: AppColors.backgroundCard,
      textColor: AppColors.textPrimary,
      icon: icon,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.backgroundCard;
    final effectiveTextColor = textColor ?? AppColors.textPrimary;

    return Material(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: effectiveTextColor),
                SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onDelete != null) ...[
                SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: 16, color: effectiveTextColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// フィルターチップ（選択可能）
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final Color? selectedColor;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.blue;

    return Material(
      color: selected ? effectiveSelectedColor : AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textPrimary),
                SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (selected) ...[
                SizedBox(width: AppSpacing.xs),
                const Icon(Icons.check, size: 16, color: AppColors.textPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
