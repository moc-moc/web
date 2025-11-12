/// トラッキングセッションデータ
class DummyTrackingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, double> categoryHours; // カテゴリー別の時間（時間単位）
  final bool isCompleted;

  const DummyTrackingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.categoryHours,
    required this.isCompleted,
  });

  Duration get duration => endTime.difference(startTime);
  double get totalHours => duration.inMinutes / 60.0;

  double get studyHours => categoryHours['study'] ?? 0.0;
  double get pcHours => categoryHours['pc'] ?? 0.0;
  double get smartphoneHours => categoryHours['smartphone'] ?? 0.0;
  double get personOnlyHours => categoryHours['personOnly'] ?? 0.0;
  double get nothingDetectedHours => categoryHours['nothingDetected'] ?? 0.0;
}

/// 現在のトラッキングセッション（トラッキング中画面用）
final currentTrackingSession = DummyTrackingSession(
  id: 'session_current',
  startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  endTime: DateTime.now(),
  categoryHours: {
    'study': 1.0,
    'pc': 0.3,
    'smartphone': 0.1,
    'personOnly': 0.05,
    'nothingDetected': 0.05,
  },
  isCompleted: false,
);

/// 完了済みのトラッキングセッション（例）
final completedTrackingSession = DummyTrackingSession(
  id: 'session_1',
  startTime: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
  endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  categoryHours: {
    'study': 1.5,
    'pc': 0.5,
    'smartphone': 0.167,
    'personOnly': 0.083,
    'nothingDetected': 0.0,
  },
  isCompleted: true,
);

/// 今日のトラッキングセッション一覧
final todaysSessions = [
  DummyTrackingSession(
    id: 'session_today_1',
    startTime: DateTime.now().subtract(const Duration(hours: 8)),
    endTime: DateTime.now().subtract(const Duration(hours: 6)),
    categoryHours: {
      'study': 1.2,
      'pc': 0.5,
      'smartphone': 0.2,
      'personOnly': 0.1,
      'nothingDetected': 0.0,
    },
    isCompleted: true,
  ),
  DummyTrackingSession(
    id: 'session_today_2',
    startTime: DateTime.now().subtract(const Duration(hours: 4)),
    endTime: DateTime.now().subtract(const Duration(hours: 2)),
    categoryHours: {
      'study': 1.0,
      'pc': 0.7,
      'smartphone': 0.15,
      'personOnly': 0.05,
      'nothingDetected': 0.1,
    },
    isCompleted: true,
  ),
];

/// 週間トラッキングデータサマリー
final weeklyTrackingSummary = {
  'totalHours': 45.5,
  'studyHours': 18.0,
  'pcHours': 15.0,
  'smartphoneHours': 5.5,
  'personOnlyHours': 4.0,
  'nothingDetectedHours': 3.0,
};

/// 月間トラッキングデータサマリー
final monthlyTrackingSummary = {
  'totalHours': 180.0,
  'studyHours': 70.0,
  'pcHours': 60.0,
  'smartphoneHours': 22.0,
  'personOnlyHours': 18.0,
  'nothingDetectedHours': 10.0,
};
