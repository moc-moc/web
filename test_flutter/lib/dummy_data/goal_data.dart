/// 目標データ
class DummyGoal {
  final String id;
  final String title;
  final String category; // 'study', 'pc', 'smartphone', 'work'
  final double targetHours;
  final double currentHours;
  final String period; // 'daily', 'weekly', 'monthly'
  final int remainingDays;
  final int consecutiveAchievements;
  final bool isFocusedOnly;
  final String comparisonType; // 'above' or 'below'

  const DummyGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetHours,
    required this.currentHours,
    required this.period,
    required this.remainingDays,
    required this.consecutiveAchievements,
    required this.isFocusedOnly,
    required this.comparisonType,
  });

  double get progress => currentHours / targetHours;
  double get progressPercentage => (progress * 100).clamp(0.0, 100.0);
  bool get isAchieved => comparisonType == 'above'
      ? currentHours >= targetHours
      : currentHours <= targetHours;
}

/// ダミー目標データ
final dummyGoals = [
  const DummyGoal(
    id: 'goal_1',
    title: 'Study',
    category: 'study',
    targetHours: 2.0,
    currentHours: 1.5,
    period: 'weekly',
    remainingDays: 2,
    consecutiveAchievements: 4,
    isFocusedOnly: true,
    comparisonType: 'above',
  ),
  const DummyGoal(
    id: 'goal_2',
    title: 'Computer Work',
    category: 'pc',
    targetHours: 5.0,
    currentHours: 2.0,
    period: 'monthly',
    remainingDays: 14,
    consecutiveAchievements: 2,
    isFocusedOnly: true,
    comparisonType: 'above',
  ),
  const DummyGoal(
    id: 'goal_3',
    title: 'Smartphone Limit',
    category: 'smartphone',
    targetHours: 1.0,
    currentHours: 0.6,
    period: 'weekly',
    remainingDays: 6,
    consecutiveAchievements: 8,
    isFocusedOnly: false,
    comparisonType: 'below',
  ),
  const DummyGoal(
    id: 'goal_4',
    title: 'Work Hours',
    category: 'work',
    targetHours: 40.0,
    currentHours: 20.0,
    period: 'monthly',
    remainingDays: 15,
    consecutiveAchievements: 3,
    isFocusedOnly: false,
    comparisonType: 'above',
  ),
  const DummyGoal(
    id: 'goal_5',
    title: 'Daily Reading',
    category: 'study',
    targetHours: 0.5,
    currentHours: 0.3,
    period: 'daily',
    remainingDays: 0,
    consecutiveAchievements: 12,
    isFocusedOnly: true,
    comparisonType: 'above',
  ),
];

/// 今日の目標（Home画面用）
final todaysGoals = [
  dummyGoals[0], // Study - weekly
  dummyGoals[4], // Daily Reading
];
