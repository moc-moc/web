import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// テキスト入力フィールド
class AppTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final Color? labelColor;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.fillColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.body2.copyWith(
              color: labelColor ?? AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textDisabled,
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.body2.copyWith(color: AppColors.error),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// カスタマイズ可能なフォーカスカラーのテキストフィールド
class ColoredTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData icon;
  final Color focusColor;
  final TextInputType keyboardType;
  final bool obscureText;

  const ColoredTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.icon,
    required this.focusColor,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.body1.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(icon, color: AppColors.gray),
            filled: true,
            fillColor: AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(color: focusColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

