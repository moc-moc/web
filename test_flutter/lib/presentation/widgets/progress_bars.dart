import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'dart:math' as math;

/// 円形プログレスバー（パーセンテージ表示）
class CircularProgressBar extends StatelessWidget {
  final double percentage; // 0.0 ~ 1.0
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final bool showPercentage;

  const CircularProgressBar({
    super.key,
    required this.percentage,
    this.progressColor,
    this.backgroundColor,
    this.size = 120,
    this.strokeWidth = 12,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? AppColors.blue;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.backgroundSecondary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              percentage: 1.0,
              color: effectiveBackgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              percentage: clampedPercentage,
              color: effectiveProgressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Percentage text
          if (showPercentage)
            Text(
              '${(clampedPercentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 線形プログレスバー
class LinearProgressBar extends StatelessWidget {
  final double percentage; // 0.0 ~ 1.0
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const LinearProgressBar({
    super.key,
    required this.percentage,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? AppColors.blue;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.backgroundSecondary;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedPercentage,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveProgressColor,
            borderRadius: effectiveBorderRadius,
          ),
        ),
      ),
    );
  }
}

/// 目標達成率表示用の円形プログレスバー付きカード
class GoalProgressCard extends StatelessWidget {
  final String goalName;
  final double percentage; // 0.0 ~ 1.0
  final String currentValue;
  final String targetValue;
  final Color? progressColor;

  const GoalProgressCard({
    super.key,
    required this.goalName,
    required this.percentage,
    required this.currentValue,
    required this.targetValue,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
      child: Row(
        children: [
          CircularProgressBar(
            percentage: percentage,
            progressColor: progressColor,
            size: 80,
            strokeWidth: 8,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalName,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '$currentValue / $targetValue',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
