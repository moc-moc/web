/// カウントダウンデータ
class DummyCountdown {
  final String id;
  final String eventName;
  final DateTime targetDate;
  final String? description;
  final String? emoji;

  const DummyCountdown({
    required this.id,
    required this.eventName,
    required this.targetDate,
    this.description,
    this.emoji,
  });

  Duration get remainingDuration => targetDate.difference(DateTime.now());

  int get remainingDays => remainingDuration.inDays;
  int get remainingHours => remainingDuration.inHours % 24;
  int get remainingMinutes => remainingDuration.inMinutes % 60;
  int get remainingSeconds => remainingDuration.inSeconds % 60;

  bool get isExpired => remainingDuration.isNegative;
}

/// アクティブなカウントダウン
final activeCountdown = DummyCountdown(
  id: 'countdown_1',
  eventName: 'Mid-term Exams',
  targetDate: DateTime.now().add(
    const Duration(days: 15, hours: 12, minutes: 30, seconds: 45),
  ),
  description: 'Important mid-term examination period',
  emoji: '📚',
);

/// 複数のカウントダウン例
final dummyCountdowns = [
  activeCountdown,
  DummyCountdown(
    id: 'countdown_2',
    eventName: 'Project Deadline',
    targetDate: DateTime.now().add(const Duration(days: 7)),
    description: 'Major project submission',
    emoji: '💼',
  ),
  DummyCountdown(
    id: 'countdown_3',
    eventName: 'Birthday',
    targetDate: DateTime.now().add(const Duration(days: 30)),
    description: 'My birthday celebration',
    emoji: '🎂',
  ),
  DummyCountdown(
    id: 'countdown_4',
    eventName: 'Vacation',
    targetDate: DateTime.now().add(const Duration(days: 60)),
    description: 'Summer vacation starts!',
    emoji: '🏖️',
  ),
];

/// 終了済みのカウントダウン（イベントプレビュー用）
final expiredCountdown = DummyCountdown(
  id: 'countdown_expired',
  eventName: 'Final Exams',
  targetDate: DateTime.now().subtract(const Duration(days: 1)),
  description: 'Final examination period',
  emoji: '🎓',
);
