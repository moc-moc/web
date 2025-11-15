import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 棒グラフ
class AppBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final String? title;
  final double maxY;
  final Widget Function(double, TitleMeta)? getBottomTitles;
  final Widget Function(double, TitleMeta)? getLeftTitles;
  final double height;

  // 統一されたアニメーション設定
  static const Duration _animationDuration = Duration(milliseconds: 1000);
  static const Curve _animationCurve = Curves.easeOutCubic;

  const AppBarChart({
    super.key,
    required this.barGroups,
    this.title,
    required this.maxY,
    this.getBottomTitles,
    this.getLeftTitles,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.md),
        ],
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: SizedBox(
            height: height,
            child: ClipRect(
              child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.backgroundSecondary,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          getBottomTitles ??
                          (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.caption,
                            );
                          },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget:
                          getLeftTitles ??
                          (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.caption,
                            );
                          },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.blackgray,
                    tooltipRoundedRadius: AppRadius.medium,
                    tooltipPadding: EdgeInsets.all(AppSpacing.sm),
                  ),
                ),
              ),
              duration: _animationDuration,
              curve: _animationCurve,
            ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 円グラフ
class AppPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final String? centerText;
  final double? radius;
  final double strokeWidth;
  final Color backgroundColor;

  const AppPieChart({
    super.key,
    required this.sections,
    this.centerText,
    this.radius,
    this.strokeWidth = 20,
    this.backgroundColor = AppColors.disabledGray,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? 100;
    final size = effectiveRadius * 2;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPiePainter(
              sections: sections,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
            ),
          ),
          if (centerText != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerText!.split('\n').first,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (centerText!.contains('\n')) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      centerText!.split('\n').skip(1).join('\n'),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPiePainter extends CustomPainter {
  final List<PieChartSectionData> sections;
  final double strokeWidth;
  final Color backgroundColor;

  _RingPiePainter({
    required this.sections,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    final total = sections.fold<double>(
      0,
      (sum, section) => sum + section.value,
    );
    if (total == 0) {
      return;
    }

    double startAngle = -math.pi / 2;
    for (final section in sections) {
      if (section.value <= 0) continue;

      final sweepAngle = (section.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = section.color;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPiePainter oldDelegate) {
    return oldDelegate.sections != sections ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// グラフの凡例
class ChartLegend extends StatelessWidget {
  final List<LegendItem> items;
  final Axis direction;
  final WrapAlignment alignment;

  const ChartLegend({
    super.key,
    required this.items,
    this.direction = Axis.vertical,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: alignment == WrapAlignment.start
            ? CrossAxisAlignment.start
            : alignment == WrapAlignment.end
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: items.map((item) => _LegendItemWidget(item: item)).toList(),
      );
    } else {
      return Wrap(
        alignment: alignment,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: items.map((item) => _LegendItemWidget(item: item)).toList(),
      );
    }
  }
}

class _LegendItemWidget extends StatelessWidget {
  final LegendItem item;

  const _LegendItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(AppRadius.small / 2),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              item.label,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.value != null) ...[
            SizedBox(width: AppSpacing.xs),
            Text(
              item.value!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 凡例アイテム
class LegendItem {
  final String label;
  final Color color;
  final String? value;

  const LegendItem({required this.label, required this.color, this.value});
}
