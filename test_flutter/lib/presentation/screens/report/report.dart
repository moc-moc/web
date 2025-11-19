import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/charts.dart';
import 'package:test_flutter/dummy_data/report_data.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';

/// レポート画面（新デザインシステム版）
class ReportScreenNew extends StatefulWidget {
  const ReportScreenNew({super.key});

  @override
  State<ReportScreenNew> createState() => _ReportScreenNewState();
}

class _ReportScreenNewState extends State<ReportScreenNew> {
  int _selectedPeriodIndex = 3; // 0: Day, 1: Week, 2: Month, 3: Year
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.only(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodTabs(),
              SizedBox(height: AppSpacing.md),
              _buildDateSelector(),
              SizedBox(height: AppSpacing.md),
              _buildStatHighlights(),
              SizedBox(height: AppSpacing.lg),
              _buildActivityChartCard(),
              SizedBox(height: AppSpacing.lg),
              _buildDistributionCard(),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodTitle() {
    switch (_selectedPeriodIndex) {
      case 0:
        return '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}';
      case 1:
        final weekStart = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}';
      case 2:
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 3:
        return 'Year ${_selectedDate.year}';
      default:
        return '--';
    }
  }

  Widget _buildPeriodTabs() {
    const periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = index == _selectedPeriodIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _selectedPeriodIndex = index;
                      _selectedDate = DateTime.now();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppColors.blue : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      periods[index],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body2.copyWith(
                        color: isSelected
                            ? AppColors.blue
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateSelector() {
    final label = _getPeriodTitle();
    final baseFontSize = AppTextStyles.body2.fontSize ?? 14.0;
    final labelStyle = AppTextStyles.body2.copyWith(
      fontSize: baseFontSize * 1.3,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        _buildDateArrow(
          icon: Icons.chevron_left,
          onTap: () {
            setState(() {
              _selectedDate = _getPreviousDate();
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _buildDateArrow(
          icon: Icons.chevron_right,
          onTap: () {
            setState(() {
              _selectedDate = _getNextDate();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
            color: AppColors.black,
          ),
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildStatHighlights() {
    final totalFocused = _getSelectedTotalHours();
    final totalChange = reportStats['totalFocusedWorkChange'] as double;
    final periodDescriptor = _getPeriodDescriptor();

    return _buildHeroStatCard(
      icon: Icons.schedule,
      title: 'Total Time ($periodDescriptor)',
      value: _formatHoursWhole(totalFocused),
      subtitle: 'Tracked focus time',
      changeLabel: _formatChange(totalChange, isPercentage: true),
      accentColor: AppColors.blue,
      isPositive: totalChange >= 0,
    );
  }

  Widget _buildHeroStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required String changeLabel,
    required Color accentColor,
    required bool isPositive,
  }) {
    final badgeColor = isPositive ? AppColors.green : AppColors.red;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: accentColor, size: 30),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 42,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildTrendBadge(changeLabel, badgeColor, isPositive),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(String text, Color color, bool isPositive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 14,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHoursWhole(double hours) {
    return '${hours.round()}h';
  }

  String _formatChange(
    double value, {
    bool isPercentage = true,
    String unit = '',
  }) {
    final prefix = value > 0 ? '+' : '';
    final formatted = isPercentage
        ? '${value.toStringAsFixed(0)}%'
        : value.toStringAsFixed(0);
    return '$prefix$formatted$unit';
  }

  double _getSelectedTotalHours() {
    final data = _getDataPointsForCurrentPeriod();
    double total = 0;
    for (final point in data) {
      total += _sumAllCategories(point);
    }
    return total;
  }

  List<CategoryDataPoint> _getDataPointsForCurrentPeriod({
    bool forChart = false,
  }) {
    switch (_selectedPeriodIndex) {
      case 0:
        return dailyReportData;
      case 1:
        return weeklyReportData;
      case 2:
        return monthlyReportData;
      case 3:
        return yearlyReportData;
      default:
        return weeklyReportData;
    }
  }

  double _sumAllCategories(CategoryDataPoint point) {
    return (point.values['study'] ?? 0) +
        (point.values['pc'] ?? 0) +
        (point.values['smartphone'] ?? 0) +
        (point.values['personOnly'] ?? 0) +
        (point.values['nothingDetected'] ?? 0);
  }

  String _getPeriodDescriptor() {
    switch (_selectedPeriodIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'This Week';
      case 2:
        return 'This Month';
      case 3:
        return 'This Year';
      default:
        return 'This Period';
    }
  }

  /// 前の日付を取得（期間タイプに応じて）
  DateTime _getPreviousDate() {
    switch (_selectedPeriodIndex) {
      case 0: // Daily: 1日前
        return _selectedDate.subtract(const Duration(days: 1));
      case 1: // Weekly: 1週間前
        return _selectedDate.subtract(const Duration(days: 7));
      case 2: // Monthly: 1ヶ月前
        return DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
      case 3: // Yearly: 1年前
        return DateTime(
          _selectedDate.year - 1,
          _selectedDate.month,
          _selectedDate.day,
        );
      default:
        return _selectedDate.subtract(const Duration(days: 7));
    }
  }

  /// 次の日付を取得（期間タイプに応じて）
  DateTime _getNextDate() {
    switch (_selectedPeriodIndex) {
      case 0: // Daily: 1日後
        return _selectedDate.add(const Duration(days: 1));
      case 1: // Weekly: 1週間後
        return _selectedDate.add(const Duration(days: 7));
      case 2: // Monthly: 1ヶ月後
        return DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
      case 3: // Yearly: 1年後
        return DateTime(
          _selectedDate.year + 1,
          _selectedDate.month,
          _selectedDate.day,
        );
      default:
        return _selectedDate.add(const Duration(days: 7));
    }
  }

  Widget _buildActivityChartCard() {
    final data = _getChartData();
    final maxY = _getMaxY();
    final titleStyle = AppTextStyles.body1.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Timeline', style: titleStyle)],
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _buildLegendPill('Study', AppColors.green),
                  _buildLegendPill('PC', AppColors.blue),
                  _buildLegendPill('Phone', AppColors.orange),
                  if (_selectedPeriodIndex <= 1)
                    _buildLegendPill('People', AppColors.gray),
                  if (_selectedPeriodIndex <= 1)
                    _buildLegendPill('No Detection', AppColors.disabledGray),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppBarChart(
            height: 220,
            barGroups: data,
            maxY: maxY,
            getBottomTitles: (value, meta) {
              final index = value.toInt();
              if (_selectedPeriodIndex == 0 && index % 3 != 0) {
                return const SizedBox.shrink();
              }
              final label = _getBottomLabel(index);
              if (label.isEmpty) return const SizedBox.shrink();
              final isDense =
                  _selectedPeriodIndex == 0 || _selectedPeriodIndex == 2;
              final style = isDense
                  ? AppTextStyles.caption.copyWith(fontSize: 10)
                  : AppTextStyles.caption;
              return Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text(label, style: style),
              );
            },
            getLeftTitles: (value, meta) {
              if (value == 0 || value == maxY) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: value == 0 ? AppSpacing.xs : 0,
                    top: value == maxY ? AppSpacing.sm : 0,
                  ),
                  child: Text(
                    '${value.toInt()}h',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDistributionCard() {
    final sections = _getPieChartSections();
    final total = categorySummary.values.reduce((a, b) => a + b);
    final titleStyle = AppTextStyles.body1.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Distribution', style: titleStyle),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPieChart(
                sections: sections,
                centerText: '${total.toInt()}h',
                radius: 80,
                strokeWidth: 22,
                backgroundColor: AppColors.blackgray,
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow(
                      'Study',
                      categorySummary['study'] ?? 0,
                      AppColors.green,
                    ),
                    _buildLegendRow(
                      'PC',
                      categorySummary['pc'] ?? 0,
                      AppColors.blue,
                    ),
                    _buildLegendRow(
                      'Smartphone',
                      categorySummary['smartphone'] ?? 0,
                      AppColors.orange,
                    ),
                    _buildLegendRow(
                      'People',
                      categorySummary['personOnly'] ?? 0,
                      AppColors.gray,
                      dimWhenZero: true,
                    ),
                    _buildLegendRow(
                      'No Detection',
                      categorySummary['nothingDetected'] ?? 0,
                      AppColors.disabledGray,
                      dimWhenZero: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(
    String label,
    double hours,
    Color color, {
    bool dimWhenZero = false,
  }) {
    final effectiveColor = dimWhenZero && hours == 0
        ? AppColors.disabledGray
        : color;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatHoursShort(hours),
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatHoursShort(double hours) {
    final h = hours.floor();
    final minutes = ((hours - h) * 60).round();
    if (minutes == 0) {
      return '${h}h';
    }
    return '${h}h ${minutes.toString().padLeft(2, '0')}m';
  }

  List<BarChartGroupData> _getChartData() {
    final data = _getDataPointsForCurrentPeriod(forChart: true);
    final isDay = _selectedPeriodIndex == 0;
    final isWeek = _selectedPeriodIndex == 1;
    final isMonth = _selectedPeriodIndex == 2;
    final denseBarWidth = 10.0;
    final normalBarWidth = 16.0;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      double cursor = 0;
      final stackItems = <BarChartRodStackItem>[];

      void addSegment(double? value, Color color) {
        if (value == null || value == 0) return;
        stackItems.add(BarChartRodStackItem(cursor, cursor + value, color));
        cursor += value;
      }

      addSegment(point.values['study'], AppColors.green);
      addSegment(point.values['pc'], AppColors.blue);
      addSegment(point.values['smartphone'], AppColors.orange);

      if (isDay || isWeek) {
        addSegment(point.values['personOnly'], AppColors.gray);
        addSegment(point.values['nothingDetected'], AppColors.disabledGray);
      }

      final barWidth = (isDay || isMonth || data.length > 20)
          ? denseBarWidth
          : normalBarWidth;

      if (isDay && cursor == 0) {
        return BarChartGroupData(x: index, barRods: const []);
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: cursor,
            width: barWidth,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: List.from(stackItems),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    switch (_selectedPeriodIndex) {
      case 0:
        return 2.0;
      case 1:
        return 10.0;
      case 2:
        return 15.0;
      case 3:
        return 250.0;
      default:
        return 10.0;
    }
  }

  String _getBottomLabel(int index) {
    final data = _getDataPointsForCurrentPeriod(forChart: true);

    if (index >= 0 && index < data.length) {
      return data[index].label;
    }
    return '';
  }

  List<PieChartSectionData> _getPieChartSections() {
    final peopleValue = categorySummary['personOnly'] ?? 0;
    final peopleColor = peopleValue == 0
        ? AppColors.disabledGray
        : AppColors.gray;
    final nothingValue = categorySummary['nothingDetected'] ?? 0;
    return [
      PieChartSectionData(
        value: categorySummary['study'],
        color: AppColors.green,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['pc'],
        color: AppColors.blue,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['smartphone'],
        color: AppColors.orange,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['personOnly'],
        color: peopleColor,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: nothingValue,
        color: AppColors.disabledGray,
        radius: 50,
        showTitle: false,
      ),
    ];
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.goal);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.friend);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }
}
