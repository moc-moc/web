import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/tab_bars.dart';
import 'package:test_flutter/presentation/widgets/charts.dart';
import 'package:test_flutter/dummy_data/report_data.dart';

/// レポート画面（新デザインシステム版）
class ReportScreenNew extends StatefulWidget {
  const ReportScreenNew({super.key});

  @override
  State<ReportScreenNew> createState() => _ReportScreenNewState();
}

class _ReportScreenNewState extends State<ReportScreenNew> {
  int _selectedPeriodIndex = 1; // 0: Day, 1: Week, 2: Month, 3: Year
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // タイトル
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Report', style: AppTextStyles.h1),
              ),

              // 期間切り替えタブ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: PeriodTabBar(
                  selectedIndex: _selectedPeriodIndex,
                  onPeriodSelected: (index) {
                    setState(() {
                      _selectedPeriodIndex = index;
                    });
                  },
                ),
              ),

              // 日付選択
              _buildDateSelector(),

              // 統計サマリー
              _buildStatsSummary(),

              // 棒グラフ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildBarChart(),
              ),

              // 円グラフ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildPieChart(),
              ),

              // カテゴリー内訳
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildCategoryBreakdown(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    String dateText = '';
    switch (_selectedPeriodIndex) {
      case 0: // Daily
        dateText =
            '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}';
        break;
      case 1: // Weekly
        dateText = 'Week of ${_selectedDate.month}/${_selectedDate.day}';
        break;
      case 2: // Monthly
        final months = [
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
        dateText = '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
        break;
      case 3: // Yearly
        dateText = '${_selectedDate.year}';
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _selectedDate = _getPreviousDate();
              });
            },
          ),
          Text(dateText, style: AppTextStyles.h3),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _selectedDate = _getNextDate();
              });
            },
          ),
        ],
      ),
    );
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

  Widget _buildStatsSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.timer,
                  iconColor: AppColors.blue,
                  value: '${reportStats['totalFocusedWork']}h',
                  label: 'Total Focused',
                  height: 120,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.success,
                  value: '${reportStats['consecutiveDays']}',
                  label: 'Streak Days',
                  height: 120,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarChart() {
    final data = _getChartData();
    final maxY = _getMaxY();

    return StandardCard(
      child: AppBarChart(
        title: 'Activity Overview',
        barGroups: data,
        maxY: maxY,
        getBottomTitles: (value, meta) {
          return Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _getBottomLabel(value.toInt()),
              style: AppTextStyles.caption,
            ),
          );
        },
        getLeftTitles: (value, meta) {
          if (value == 0 || value == maxY) {
            return Text('${value.toInt()}h', style: AppTextStyles.caption);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = _getPieChartSections();
    final total = categorySummary.values.reduce((a, b) => a + b);

    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Distribution', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.lg),
          AppPieChart(
            sections: sections,
            centerText: '${total.toInt()}h\nTotal',
            radius: 70,
          ),
          SizedBox(height: AppSpacing.lg),
          ChartLegend(
            items: [
              LegendItem(
                label: 'Study',
                color: AppChartColors.study,
                value: '${categorySummary['study']!.toInt()}h',
              ),
              LegendItem(
                label: 'Computer',
                color: AppChartColors.pc,
                value: '${categorySummary['pc']!.toInt()}h',
              ),
              LegendItem(
                label: 'Smartphone',
                color: AppChartColors.smartphone,
                value: '${categorySummary['smartphone']!.toInt()}h',
              ),
              LegendItem(
                label: 'Person Only',
                color: AppChartColors.personOnly,
                value: '${categorySummary['personOnly']!.toInt()}h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detailed Breakdown', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Study (Focused)',
            AppChartColors.studyFocused,
            categoryDetails['studyFocused']!,
          ),
          _buildDetailRow(
            'Study (Unfocused)',
            AppChartColors.study,
            categoryDetails['studyUnfocused']!,
          ),
          _buildDetailRow(
            'PC (Focused)',
            AppChartColors.pcFocused,
            categoryDetails['pcFocused']!,
          ),
          _buildDetailRow(
            'PC (Unfocused)',
            AppChartColors.pc,
            categoryDetails['pcUnfocused']!,
          ),
          _buildDetailRow(
            'Smartphone',
            AppChartColors.smartphone,
            categoryDetails['smartphone']!,
          ),
          _buildDetailRow(
            'Person Only',
            AppChartColors.personOnly,
            categoryDetails['personOnly']!,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Color color, double hours) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.small / 2),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${hours.toInt()}h',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getChartData() {
    List<CategoryDataPoint> data;
    switch (_selectedPeriodIndex) {
      case 0:
        data = dailyReportData;
        break;
      case 1:
        data = weeklyReportData;
        break;
      case 2:
        data = monthlyReportData.take(7).toList(); // 簡略化のため7日分のみ
        break;
      case 3:
        data = yearlyReportData;
        break;
      default:
        data = weeklyReportData;
    }

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY:
                (point.values['study'] ?? 0) +
                (point.values['pc'] ?? 0) +
                (point.values['smartphone'] ?? 0),
            width: 16,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                point.values['study'] ?? 0,
                AppChartColors.study,
              ),
              BarChartRodStackItem(
                point.values['study'] ?? 0,
                (point.values['study'] ?? 0) + (point.values['pc'] ?? 0),
                AppChartColors.pc,
              ),
            ],
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
        return 10.0;
      case 3:
        return 250.0;
      default:
        return 10.0;
    }
  }

  String _getBottomLabel(int index) {
    List<CategoryDataPoint> data;
    switch (_selectedPeriodIndex) {
      case 0:
        data = dailyReportData;
        break;
      case 1:
        data = weeklyReportData;
        break;
      case 2:
        data = monthlyReportData.take(7).toList();
        break;
      case 3:
        data = yearlyReportData;
        break;
      default:
        data = weeklyReportData;
    }

    if (index >= 0 && index < data.length) {
      return data[index].label;
    }
    return '';
  }

  List<PieChartSectionData> _getPieChartSections() {
    return [
      PieChartSectionData(
        value: categorySummary['study'],
        color: AppChartColors.study,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['pc'],
        color: AppChartColors.pc,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['smartphone'],
        color: AppChartColors.smartphone,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: categorySummary['personOnly'],
        color: AppChartColors.personOnly,
        radius: 50,
        showTitle: false,
      ),
    ];
  }
}
