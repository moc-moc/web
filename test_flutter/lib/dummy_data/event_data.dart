/// イベントタイプ
enum EventType {
  goalAchieved, // 目標達成
  goalSet, // 目標設定完了
  goalPeriodEnded, // 目標期間終了
  streakMilestone, // 連続日数大台
  totalHoursMilestone, // 総時間大台
  countdownEnded, // カウントダウン終了
  countdownSet, // カウントダウン設定完了
}

/// イベントデータ
class DummyEvent {
  final String id;
  final EventType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const DummyEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });
}

/// 目標達成イベント
final goalAchievedEvent = DummyEvent(
  id: 'event_goal_achieved',
  type: EventType.goalAchieved,
  title: 'Congratulations!',
  message: 'You have achieved your Studying goal!',
  timestamp: DateTime.now(),
  data: {
    'goalName': 'Studying',
    'targetHours': 2.0,
    'achievedHours': 2.5,
    'period': 'Daily',
    'isFocusedOnly': true,
  },
);

/// 目標設定完了イベント
final goalSetEvent = DummyEvent(
  id: 'event_goal_set',
  type: EventType.goalSet,
  title: 'This goal has been set!',
  message: 'Today is Day 0. Keep up the good work!',
  timestamp: DateTime.now(),
  data: {'goalName': 'Study Time', 'targetHours': 3.0, 'period': 'Weekly'},
);

/// 目標期間終了イベント
final goalPeriodEndedEvent = DummyEvent(
  id: 'event_goal_period_ended',
  type: EventType.goalPeriodEnded,
  title: 'You Can Do It!',
  message: 'Your weekly goal period has ended. Keep pushing forward!',
  timestamp: DateTime.now(),
  data: {
    'goalName': 'Study Time',
    'targetHours': 10.0,
    'achievedHours': 8.5,
    'progress': 0.85,
    'consecutiveDays': 12,
    'period': 'Weekly',
  },
);

/// 連続日数7日達成イベント
final streak7DaysEvent = DummyEvent(
  id: 'event_streak_7',
  type: EventType.streakMilestone,
  title: 'Congratulations!',
  message: 'You have reached 7 consecutive days!',
  timestamp: DateTime.now(),
  data: {'days': 7, 'nextMilestone': 10},
);

/// 連続日数10日達成イベント
final streak10DaysEvent = DummyEvent(
  id: 'event_streak_10',
  type: EventType.streakMilestone,
  title: 'Congratulations!',
  message: 'You have reached 10 consecutive days!',
  timestamp: DateTime.now(),
  data: {'days': 10, 'nextMilestone': 30},
);

/// 連続日数100日達成イベント
final streak100DaysEvent = DummyEvent(
  id: 'event_streak_100',
  type: EventType.streakMilestone,
  title: 'Amazing Achievement!',
  message: 'You have reached 100 consecutive days!',
  timestamp: DateTime.now(),
  data: {'days': 100, 'nextMilestone': 200},
);

/// 総時間1000時間達成イベント
final totalHours1000Event = DummyEvent(
  id: 'event_total_1000',
  type: EventType.totalHoursMilestone,
  title: 'Congratulations!',
  message: 'You have reached 1000 hours of focused work!',
  timestamp: DateTime.now(),
  data: {'hours': 1000, 'nextMilestone': 2000},
);

/// カウントダウン終了イベント
final countdownEndedEvent = DummyEvent(
  id: 'event_countdown_ended',
  type: EventType.countdownEnded,
  title: 'Time\'s Up!',
  message: 'Mid-term Exams have arrived. Good luck!',
  timestamp: DateTime.now(),
  data: {'eventName': 'Mid-term Exams'},
);

/// カウントダウン設定完了イベント
final countdownSetEvent = DummyEvent(
  id: 'event_countdown_set',
  type: EventType.countdownSet,
  title: 'Countdown Set!',
  message: 'Your countdown for Mid-term Exams has been created.',
  timestamp: DateTime.now(),
  data: {'eventName': 'Mid-term Exams', 'remainingDays': 15},
);

/// 全イベント一覧（イベントプレビュー用）
final allEvents = [
  goalAchievedEvent,
  goalSetEvent,
  goalPeriodEndedEvent,
  streak7DaysEvent,
  streak10DaysEvent,
  streak100DaysEvent,
  totalHours1000Event,
  countdownEndedEvent,
  countdownSetEvent,
];
