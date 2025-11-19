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
        backgroundColor ?? AppColors.disabledGray;

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
              '${(clampedPercentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: size * 0.18,
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
class LinearProgressBar extends StatefulWidget {
  final double percentage; // 0.0 ~ 1.0
  final Color? progressColor;
  final Color? backgroundColor; // 外側の背景色（blackgray）
  final Color? barBackgroundColor; // バー全体の背景色（gray）
  final double height;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool animate;
  final bool showFlowAnimation;
  final Duration flowAnimationDuration;
  final double flowHighlightWidthFactor;

  const LinearProgressBar({
    super.key,
    required this.percentage,
    this.progressColor,
    this.backgroundColor,
    this.barBackgroundColor,
    this.height = 8,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeOutCubic,
    this.animate = true,
    this.showFlowAnimation = false,
    this.flowAnimationDuration = const Duration(milliseconds: 2800),
    this.flowHighlightWidthFactor = 0.5,
  });

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: widget.flowAnimationDuration,
    );

    if (widget.showFlowAnimation) {
      _flowController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.flowAnimationDuration != widget.flowAnimationDuration) {
      _flowController.duration = widget.flowAnimationDuration;
      if (_flowController.isAnimating) {
        _flowController
          ..reset()
          ..repeat();
      }
    }

    if (widget.showFlowAnimation && !_flowController.isAnimating) {
      _flowController.repeat();
    } else if (!widget.showFlowAnimation && _flowController.isAnimating) {
      _flowController.stop();
    }
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = widget.percentage.clamp(0.0, 1.0);
    final effectiveProgressColor = widget.progressColor ?? AppColors.blue;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? AppColors.blackgray;
    final effectiveBarBackgroundColor =
        widget.barBackgroundColor ?? AppColors.gray;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    final hasBorder = widget.borderColor != null && widget.borderWidth != null;

    return Container(
      height: widget.height,
      padding: hasBorder ? EdgeInsets.all(widget.borderWidth!) : null,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: hasBorder
            ? Border.all(
                color: widget.borderColor!,
                width: widget.borderWidth!,
              )
            : null,
      ),
      child: Stack(
        children: [
          // バー全体の背景と進捗部分（ClipRRectでクリップ）
          ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: Stack(
              children: [
                // バー全体の背景（gray）
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: effectiveBarBackgroundColor,
                    borderRadius: effectiveBorderRadius,
                  ),
                ),
                // 進捗部分（各色）
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: clampedPercentage,
                  ),
                  duration:
                      widget.animate ? widget.animationDuration : Duration.zero,
                  curve: widget.animationCurve,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.animate ? value : clampedPercentage,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: effectiveProgressColor,
                      borderRadius: effectiveBorderRadius,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ハイライトアニメーション（バー全体の上に重ねる、ClipRRectでクリップ）
          if (widget.showFlowAnimation)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: effectiveBorderRadius,
                child: _FlowHighlight(
                  controller: _flowController,
                  color: effectiveProgressColor,
                  highlightWidthFactor: widget.flowHighlightWidthFactor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowHighlight extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double highlightWidthFactor;

  const _FlowHighlight({
    required this.controller,
    required this.color,
    required this.highlightWidthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedWidthFactor = highlightWidthFactor.clamp(0.15, 0.6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        if (barWidth == double.infinity || barWidth == 0) {
          return const SizedBox.shrink();
        }

        final highlightWidth = barWidth * clampedWidthFactor;
        // ハイライトが左端から右端まで移動する距離
        final travelDistance = barWidth + highlightWidth;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(barWidth, constraints.maxHeight),
              painter: _FlowHighlightPainter(
                controllerValue: controller.value,
                highlightWidth: highlightWidth,
                travelDistance: travelDistance,
                barWidth: barWidth,
                color: color,
              ),
            );
          },
        );
      },
    );
  }
}

class _FlowHighlightPainter extends CustomPainter {
  final double controllerValue;
  final double highlightWidth;
  final double travelDistance;
  final double barWidth;
  final Color color;

  _FlowHighlightPainter({
    required this.controllerValue,
    required this.highlightWidth,
    required this.travelDistance,
    required this.barWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ハイライトの位置を計算（左端から右端まで移動）
    final offset = (controllerValue * travelDistance) - highlightWidth;
    
    // ハイライトの矩形を計算（進捗バーの範囲内に制限）
    final highlightLeft = offset.clamp(0.0, barWidth);
    final highlightRight = (offset + highlightWidth).clamp(0.0, barWidth);
    final highlightRect = Rect.fromLTRB(
      highlightLeft,
      0,
      highlightRight,
      size.height,
    );

    // ハイライトが表示範囲内にある場合のみ描画
    if (highlightRect.width > 0) {
      final gradient = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.85),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(highlightRect);

      canvas.drawRect(highlightRect, paint);
    }
  }

  @override
  bool shouldRepaint(_FlowHighlightPainter oldDelegate) {
    return oldDelegate.controllerValue != controllerValue ||
        oldDelegate.highlightWidth != highlightWidth ||
        oldDelegate.travelDistance != travelDistance ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.color != color;
  }
}

/// 目標達成率表示用の棒グラフスタイルカード
class GoalProgressCard extends StatelessWidget {
  final String goalName;
  final double percentage; // 0.0 ~ 1.0
  final String currentValue;
  final String targetValue;
  final Color? progressColor;
  final Color? labelColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? barBackgroundColor; // 追加

  const GoalProgressCard({
    super.key,
    required this.goalName,
    required this.percentage,
    required this.currentValue,
    required this.targetValue,
    this.progressColor,
    this.labelColor,
    this.borderColor,
    this.backgroundColor,
    this.barBackgroundColor, // 追加
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? AppColors.blue;
    final effectiveLabelColor = labelColor ?? effectiveProgressColor;
    final effectiveBorderColor =
        borderColor ?? effectiveProgressColor.withValues(alpha: 0.4);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: effectiveBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: LinearProgressBar(
              percentage: clampedPercentage,
              progressColor: effectiveProgressColor,
              backgroundColor: AppColors.disabledGray,
              barBackgroundColor: barBackgroundColor ?? AppColors.disabledGray, // 変更
              height: 12,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${(clampedPercentage * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goalName,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectiveLabelColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '$currentValue / $targetValue',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
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
