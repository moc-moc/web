/// レポート用のデータポイント
class DataPoint {
  final String label;
  final double value;

  const DataPoint({required this.label, required this.value});
}

/// カテゴリー別のデータポイント
class CategoryDataPoint {
  final String label;
  final Map<String, double> values; // カテゴリー別の値

  const CategoryDataPoint({required this.label, required this.values});
}

/// 日次レポートデータ（24時間）
final dailyReportData = List.generate(24, (index) {
  // 0-24時のデータ
  final hour = index;
  double studyHours = 0.0;
  double pcHours = 0.0;
  double smartphoneHours = 0.0;

  // 勤務時間帯に集中
  if (hour >= 9 && hour <= 18) {
    studyHours = (0.3 + (index % 3) * 0.2);
    pcHours = (0.2 + (index % 2) * 0.15);
    smartphoneHours = 0.05;
  } else if (hour >= 19 && hour <= 22) {
    studyHours = 0.4;
    pcHours = 0.3;
    smartphoneHours = 0.1;
  }

  return CategoryDataPoint(
    label: '$hour:00',
    values: {
      'study': studyHours,
      'pc': pcHours,
      'smartphone': smartphoneHours,
      'personOnly': 0.05,
      'nothingDetected': 0.0,
    },
  );
});

/// 週次レポートデータ（7日分）
final weeklyReportData = [
  const CategoryDataPoint(
    label: 'Mon',
    values: {
      'study': 3.5,
      'pc': 2.8,
      'smartphone': 0.8,
      'personOnly': 0.5,
      'nothingDetected': 0.4,
    },
  ),
  const CategoryDataPoint(
    label: 'Tue',
    values: {
      'study': 4.2,
      'pc': 3.1,
      'smartphone': 0.6,
      'personOnly': 0.7,
      'nothingDetected': 0.4,
    },
  ),
  const CategoryDataPoint(
    label: 'Wed',
    values: {
      'study': 3.8,
      'pc': 2.5,
      'smartphone': 1.0,
      'personOnly': 0.4,
      'nothingDetected': 0.3,
    },
  ),
  const CategoryDataPoint(
    label: 'Thu',
    values: {
      'study': 4.5,
      'pc': 3.5,
      'smartphone': 0.5,
      'personOnly': 0.8,
      'nothingDetected': 0.2,
    },
  ),
  const CategoryDataPoint(
    label: 'Fri',
    values: {
      'study': 3.2,
      'pc': 2.9,
      'smartphone': 0.9,
      'personOnly': 0.6,
      'nothingDetected': 0.4,
    },
  ),
  const CategoryDataPoint(
    label: 'Sat',
    values: {
      'study': 5.0,
      'pc': 2.0,
      'smartphone': 1.2,
      'personOnly': 0.3,
      'nothingDetected': 0.5,
    },
  ),
  const CategoryDataPoint(
    label: 'Sun',
    values: {
      'study': 4.8,
      'pc': 1.5,
      'smartphone': 1.5,
      'personOnly': 0.2,
      'nothingDetected': 0.5,
    },
  ),
];

/// 月次レポートデータ（30日分）
final monthlyReportData = List.generate(30, (index) {
  final day = index + 1;
  final baseStudy = 3.0 + (index % 5) * 0.5;
  final basePc = 2.0 + (index % 4) * 0.4;
  final baseSmartphone = 0.5 + (index % 3) * 0.3;

  return CategoryDataPoint(
    label: '$day',
    values: {
      'study': baseStudy,
      'pc': basePc,
      'smartphone': baseSmartphone,
      'personOnly': 0.4,
      'nothingDetected': 0.3,
    },
  );
});

/// 年次レポートデータ（12ヶ月分）
final yearlyReportData = [
  const CategoryDataPoint(
    label: 'Jan',
    values: {
      'study': 85.0,
      'pc': 60.0,
      'smartphone': 18.0,
      'personOnly': 12.0,
      'nothingDetected': 10.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Feb',
    values: {
      'study': 90.0,
      'pc': 65.0,
      'smartphone': 15.0,
      'personOnly': 10.0,
      'nothingDetected': 8.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Mar',
    values: {
      'study': 95.0,
      'pc': 70.0,
      'smartphone': 20.0,
      'personOnly': 15.0,
      'nothingDetected': 12.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Apr',
    values: {
      'study': 88.0,
      'pc': 68.0,
      'smartphone': 17.0,
      'personOnly': 11.0,
      'nothingDetected': 9.0,
    },
  ),
  const CategoryDataPoint(
    label: 'May',
    values: {
      'study': 92.0,
      'pc': 72.0,
      'smartphone': 19.0,
      'personOnly': 13.0,
      'nothingDetected': 11.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Jun',
    values: {
      'study': 87.0,
      'pc': 66.0,
      'smartphone': 21.0,
      'personOnly': 14.0,
      'nothingDetected': 10.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Jul',
    values: {
      'study': 93.0,
      'pc': 75.0,
      'smartphone': 16.0,
      'personOnly': 12.0,
      'nothingDetected': 8.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Aug',
    values: {
      'study': 89.0,
      'pc': 69.0,
      'smartphone': 18.0,
      'personOnly': 11.0,
      'nothingDetected': 9.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Sep',
    values: {
      'study': 94.0,
      'pc': 73.0,
      'smartphone': 17.0,
      'personOnly': 13.0,
      'nothingDetected': 10.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Oct',
    values: {
      'study': 91.0,
      'pc': 71.0,
      'smartphone': 19.0,
      'personOnly': 12.0,
      'nothingDetected': 11.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Nov',
    values: {
      'study': 96.0,
      'pc': 74.0,
      'smartphone': 15.0,
      'personOnly': 14.0,
      'nothingDetected': 8.0,
    },
  ),
  const CategoryDataPoint(
    label: 'Dec',
    values: {
      'study': 90.0,
      'pc': 70.0,
      'smartphone': 20.0,
      'personOnly': 13.0,
      'nothingDetected': 10.0,
    },
  ),
];

/// カテゴリー別の総計（円グラフ用）
const categorySummary = {
  'study': 70.0,
  'pc': 60.0,
  'smartphone': 22.0,
  'personOnly': 18.0,
  'nothingDetected': 10.0,
};

/// カテゴリー別の詳細（Focused/Unfocused）
const categoryDetails = {
  'studyFocused': 55.0,
  'studyUnfocused': 15.0,
  'pcFocused': 45.0,
  'pcUnfocused': 15.0,
  'smartphone': 22.0,
  'personOnly': 18.0,
};

/// レポート統計サマリー
const reportStats = {
  'totalFocusedWork': 180.0, // 時間
  'consecutiveDays': 65,
  'totalFocusedWorkChange': 12.0, // %
  'consecutiveDaysChange': 1,
};
