import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';

// ========================================
// 新しいデザインシステムに基づくボタン
// ========================================

/// ボタンのサイズ
enum ButtonSize { small, medium, large }

/// プライマリボタン（青背景、白文字）
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final double fontSize = _getFontSize();
    final double horizontalPadding = _getHorizontalPadding();
    final double effectiveRadius = borderRadius ?? AppRadius.large;
    final borderRadiusValue = BorderRadius.circular(effectiveRadius);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: borderRadiusValue,
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadiusValue,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: fontSize,
                      height: fontSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.blue,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: AppColors.blue,
                            size: fontSize,
                          ),
                          SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.md;
      case ButtonSize.medium:
        return AppSpacing.lg;
      case ButtonSize.large:
        return AppSpacing.xl;
    }
  }
}

/// セカンダリボタン（グレー背景、白文字）
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final double? borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final double fontSize = _getFontSize();
    final double horizontalPadding = _getHorizontalPadding();
    final double effectiveRadius = borderRadius ?? AppRadius.medium;
    final borderRadiusValue = BorderRadius.circular(effectiveRadius);

    return Material(
      color: AppColors.blackgray,
      borderRadius: borderRadiusValue,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: borderRadiusValue,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: fontSize,
                    height: fontSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: AppColors.textPrimary,
                          size: fontSize,
                        ),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.md;
      case ButtonSize.medium:
        return AppSpacing.lg;
      case ButtonSize.large:
        return AppSpacing.xl;
    }
  }
}

/// アウトラインボタン（枠線のみ、透明背景）
class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Color? borderColor;

  const OutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final double fontSize = _getFontSize();
    final double horizontalPadding = _getHorizontalPadding();
    final Color effectiveBorderColor = borderColor ?? AppColors.blue;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: effectiveBorderColor, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: fontSize,
                      height: fontSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveBorderColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: effectiveBorderColor,
                            size: fontSize,
                          ),
                          SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: effectiveBorderColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.md;
      case ButtonSize.medium:
        return AppSpacing.lg;
      case ButtonSize.large:
        return AppSpacing.xl;
    }
  }
}

/// テキストボタン（枠線なし、テキストのみ）
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Color? textColor;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final double fontSize = _getFontSize();
    final double horizontalPadding = _getHorizontalPadding();
    final Color effectiveTextColor = textColor ?? AppColors.blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: fontSize,
                    height: fontSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveTextColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: effectiveTextColor, size: fontSize),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.sm;
      case ButtonSize.medium:
        return AppSpacing.md;
      case ButtonSize.large:
        return AppSpacing.lg;
    }
  }
}

// ========================================
// 既存のボタン（互換性のために保持）
// ========================================

/// 小さいアイコンボタン（ヘッダー用）
///
/// セクションのヘッダーなどに配置する小さめのアイコンボタンです。
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
      ),
    );
  }
}

/// 細長ボタン
class CustomSnsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CustomSnsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 円形ボタン
class CustomPushButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final String routeName;
  final Color? color;

  const CustomPushButton({
    super.key,
    this.text,
    this.icon,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.green,
      shape: const CircleBorder(),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          NavigationHelper.push(context, routeName);
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.white, size: 32)
                : Text(
                    text ?? '',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}

/// pushReplacementNamedを使用して画面遷移する細長ボタン
/// 現在の画面を新しい画面で置き換える（戻れない）
class CustomReplacementButton extends StatelessWidget {
  final String text;
  final String routeName;
  final Color? color;

  const CustomReplacementButton({
    super.key,
    required this.text,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          NavigationHelper.pushReplacement(context, routeName);
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// popAndPushNamedを使用して画面遷移する細長ボタン
/// 現在の画面をpopしてから新しい画面をpush（スムーズなアニメーション）
class CustomPopAndPushButton extends StatelessWidget {
  final String text;
  final String routeName;
  final Color? color;

  const CustomPopAndPushButton({
    super.key,
    required this.text,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          NavigationHelper.popAndPush(context, routeName);
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// pushNamedAndRemoveUntilを使用してホーム画面に戻る細長ボタン
/// 全ての履歴を削除してホーム画面に戻る
class CustomBackToHomeButton extends StatelessWidget {
  final String text;
  final Color? color;

  const CustomBackToHomeButton({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          NavigationHelper.pushAndRemoveUntil(context, '/');
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// ソーシャルログインボタン（Apple、Googleなど）
class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: backgroundColor == AppColors.black
            ? Border.all(color: AppColors.gray.withValues(alpha: 0.35))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              else
                Icon(icon, color: textColor, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: AppTextStyles.body1.copyWith(
                  color: isLoading
                      ? textColor.withValues(alpha: 0.6)
                      : textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
