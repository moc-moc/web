import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 統計アイテム（アイコン、数値、ラベル）
class StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double? iconSize;

  const StatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: iconSize ?? 32),
        SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTextStyles.h3, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

/// 統計アイテムの横並び表示
class StatRow extends StatelessWidget {
  final List<StatItem> stats;
  final MainAxisAlignment mainAxisAlignment;

  const StatRow({
    super.key,
    required this.stats,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: mainAxisAlignment, children: stats);
  }
}

/// カウントダウン表示
class CountdownDisplay extends StatelessWidget {
  final String eventName;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final Color? accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const CountdownDisplay({
    super.key,
    required this.eventName,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.accentColor,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppColors.blue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountdownUnit(
                  value: days,
                  label: 'Days',
                  accentColor: effectiveAccentColor,
                ),
                _CountdownUnit(
                  value: hours,
                  label: 'Hours',
                  accentColor: effectiveAccentColor,
                ),
                _CountdownUnit(
                  value: minutes,
                  label: 'Minutes',
                  accentColor: effectiveAccentColor,
                ),
                _CountdownUnit(
                  value: seconds,
                  label: 'Seconds',
                  accentColor: effectiveAccentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;
  final Color accentColor;

  const _CountdownUnit({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: AppTextStyles.h2.copyWith(color: accentColor),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

/// アバターウィジェット（プロフィールアイコン）
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.blue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          shape: BoxShape.circle,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Center(
                child: Text(
                  initials ?? '?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
