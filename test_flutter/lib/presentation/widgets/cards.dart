import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

// ========================================
// 新しいデザインシステムに基づくカード
// ========================================

/// 標準カード（通常の情報表示）
class StandardCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const StandardCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// グラデーションカード（イベント画面用）
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  /// 青色グラデーション
  factory GradientCard.blue({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// 紫色グラデーション
  factory GradientCard.purple({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      gradientColors: const [Color(0xFF9E66D5), Color(0xFF7C3AED)],
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// ピンク色グラデーション
  factory GradientCard.pink({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      gradientColors: const [Color(0xFFEC4899), Color(0xFFC026D3)],
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// 黄色グラデーション
  factory GradientCard.yellow({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      gradientColors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// インタラクティブカード（タップ可能）
class InteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const InteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 統計表示カード（アイコン、数値、ラベル）
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double? width;
  final double? height;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// 既存のカード（互換性のために保持）
// ========================================

/// カード
class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const CustomCard({super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: AppColors.blackgray,
        margin: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

/// 時間入力カード（トラッキング用）
///
/// カテゴリごとに時間（分単位）を入力するカードです。
class TimeInputCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;

  const TimeInputCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor,
              radius: 24,
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  suffixText: '分',
                  suffixStyle: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
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

/// カテゴリ選択カード（アイコン、ラベル、選択状態を持つ）
class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: isSelected
              ? color
              : AppColors.gray.withValues(alpha: 0.35),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? color : AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      label,
                      style: AppTextStyles.body2.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// フォームセクション（タイトルと子ウィジェットを持つセクションコンテナ）
class FormSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? subtitle;
  final String? subtitleText;

  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.subtitle,
    this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.blackgray;
    final effectiveBorderColor =
        borderColor ?? AppColors.gray.withValues(alpha: 0.35);
    final effectiveBorderWidth = borderWidth ?? 1.5;

    return Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.sm),
            subtitle!,
          ] else if (subtitleText != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              subtitleText!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// 累計データ表示カード
///
/// 総作業時間を表示します。
class TotalStatsCard extends StatelessWidget {
  final String totalWorkTime;

  const TotalStatsCard({
    super.key,
    required this.totalWorkTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomCard(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: AppColors.green, size: 28),
              const SizedBox(height: 6),
              Text(
                totalWorkTime,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                '総作業時間',
                style: TextStyle(color: AppColors.gray, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
