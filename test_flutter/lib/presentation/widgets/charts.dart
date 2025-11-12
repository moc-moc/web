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

  const AppBarChart({
    super.key,
    required this.barGroups,
    this.title,
    required this.maxY,
    this.getBottomTitles,
    this.getLeftTitles,
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
        SizedBox(
          height: 250,
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
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
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

  const AppPieChart({
    super.key,
    required this.sections,
    this.centerText,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: radius ?? 60,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          ),
          if (centerText != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerText!,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
