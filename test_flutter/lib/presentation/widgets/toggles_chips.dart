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
    final effectiveActiveColor = activeColor ?? AppColors.blue;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          color: value
              ? effectiveActiveColor.withValues(alpha: 0.2)
              : AppColors.blackgray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value
                ? effectiveActiveColor
                : AppColors.gray.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: value ? effectiveActiveColor : AppColors.gray,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value ? effectiveActiveColor : AppColors.gray,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
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
  final Color? backgroundColor;
  final Color? textColor;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.selectedColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.blue;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.backgroundCard;
    final effectiveTextColor = textColor ?? AppColors.textPrimary;

    return Material(
      color: selected ? effectiveSelectedColor : effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BorderRadius.circular(AppRadius.large),
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
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (selected) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(Icons.check, size: 16, color: effectiveTextColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 選択可能なボタン（トグル機能付き）
class SelectableButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final EdgeInsetsGeometry? padding;
  final bool showCheckmark;

  const SelectableButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.padding,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.purple;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveSelectedColor.withValues(alpha: 0.15)
                : AppColors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? effectiveSelectedColor
                  : AppColors.gray.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(
                  color: isSelected
                      ? effectiveSelectedColor
                      : AppColors.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (showCheckmark && isSelected) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.check,
                  size: 16,
                  color: effectiveSelectedColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
