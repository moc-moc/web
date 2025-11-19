import 'dart:async';
import 'dart:math' as math;

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

/// カウントダウン表示（リアルタイム更新版）
class RealtimeCountdownDisplay extends StatefulWidget {
  final String eventName;
  final DateTime targetDate;
  final Color? accentColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? labelColor;
  final Color? valueTextColor;
  final Color? valueBackgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const RealtimeCountdownDisplay({
    super.key,
    required this.eventName,
    required this.targetDate,
    this.accentColor,
    this.borderColor,
    this.backgroundColor,
    this.titleColor,
    this.labelColor,
    this.valueTextColor,
    this.valueBackgroundColor,
    this.onTap,
    this.onEdit,
  });

  @override
  State<RealtimeCountdownDisplay> createState() => _RealtimeCountdownDisplayState();
}

class _RealtimeCountdownDisplayState extends State<RealtimeCountdownDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1秒ごとに更新
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _nonNegative(int value) => value < 0 ? 0 : value;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final duration = widget.targetDate.difference(now);
    
    final days = _nonNegative(duration.inDays);
    final hours = _nonNegative(duration.inHours % 24);
    final minutes = _nonNegative(duration.inMinutes % 60);
    final seconds = _nonNegative(duration.inSeconds % 60);

    return CountdownDisplay(
      eventName: widget.eventName,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      accentColor: widget.accentColor,
      borderColor: widget.borderColor,
      backgroundColor: widget.backgroundColor,
      titleColor: widget.titleColor,
      labelColor: widget.labelColor,
      valueTextColor: widget.valueTextColor,
      valueBackgroundColor: widget.valueBackgroundColor,
      onTap: widget.onTap,
      onEdit: widget.onEdit,
    );
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
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? labelColor;
  final Color? valueTextColor;
  final Color? valueBackgroundColor;
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
    this.borderColor,
    this.backgroundColor,
    this.titleColor,
    this.labelColor,
    this.valueTextColor,
    this.valueBackgroundColor,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppColors.blue;
    final effectiveBorderColor = borderColor;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.blackgray;
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary;
    final effectiveLabelColor =
        labelColor ?? effectiveAccentColor.withValues(alpha: 0.8);
    final effectiveValueTextColor = valueTextColor ?? AppColors.white;
    final effectiveValueBackgroundColor =
        valueBackgroundColor ?? AppColors.lightblackgray;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: effectiveBorderColor != null
              ? Border.all(color: effectiveBorderColor, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (eventName.isNotEmpty) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    eventName,
                    style: AppTextStyles.body1.copyWith(
                      color: effectiveTitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (onEdit != null)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ],
            Builder(builder: (context) {
              final units = [
                {'value': days, 'label': 'Days'},
                {'value': hours, 'label': 'Hours'},
                {'value': minutes, 'label': 'Minutes'},
                {'value': seconds, 'label': 'Seconds'},
              ];
              return Row(
                children: [
                  for (var i = 0; i < units.length; i++) ...[
                    Expanded(
                      child: _CountdownUnit(
                        value: units[i]['value'] as int,
                        label: units[i]['label'] as String,
                        labelColor: effectiveLabelColor,
                        valueTextColor: effectiveValueTextColor,
                        valueBackgroundColor: effectiveValueBackgroundColor,
                      ),
                    ),
                    if (i < units.length - 1)
                      SizedBox(width: AppSpacing.sm),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;
  final Color labelColor;
  final Color valueTextColor;
  final Color valueBackgroundColor;

  const _CountdownUnit({
    required this.value,
    required this.label,
    required this.labelColor,
    required this.valueTextColor,
    required this.valueBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          child: _FlipCard(
            value: value,
            backgroundColor: valueBackgroundColor,
            textColor: valueTextColor,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  final int value;
  final Color backgroundColor;
  final Color textColor;

  const _FlipCard({
    required this.value,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> {
  late int _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _displayValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _displayValue.toString().padLeft(2, '0');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        final rotateAnimation =
            Tween<double>(begin: math.pi / 2, end: 0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        return AnimatedBuilder(
          animation: rotateAnimation,
          child: child,
          builder: (context, child) {
            final tilt = (animation.value - 0.5).abs() - 0.5;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(rotateAnimation.value)
              ..translate(0.0, tilt * 10);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: Container(
        key: ValueKey(formatted),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.large * 2),
        ),
        alignment: Alignment.center,
        child: Text(
          formatted,
          style: AppTextStyles.h2.copyWith(color: widget.textColor),
        ),
      ),
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
