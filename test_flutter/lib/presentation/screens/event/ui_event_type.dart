/// UIイベントタイプ
/// 
/// アプリ内で表示されるイベント（目標達成、連続日数など）のタイプを定義
enum UIEventType {
  goalAchieved,
  goalSet,
  goalPeriodEnded,
  streakMilestone,
  totalHoursMilestone,
  countdownEnded,
  countdownSet,
}

/// UIイベント情報
class UIEventInfo {
  final UIEventType type;
  final String title;
  final String description;
  final String routeName;

  const UIEventInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.routeName,
  });
}

/// UIイベント情報のリスト
class UIEventInfoList {
  static const List<UIEventInfo> allEvents = [
    UIEventInfo(
      type: UIEventType.goalAchieved,
      title: 'Goal Achieved!',
      description: 'When you achieve a goal',
      routeName: '/goal-achieved-event',
    ),
    UIEventInfo(
      type: UIEventType.goalSet,
      title: 'Goal Set',
      description: 'When you set a new goal',
      routeName: '/goal-set-event',
    ),
    UIEventInfo(
      type: UIEventType.goalPeriodEnded,
      title: 'Goal Period Ended',
      description: 'When goal period ends',
      routeName: '/goal-period-ended-event',
    ),
    UIEventInfo(
      type: UIEventType.streakMilestone,
      title: 'Streak Milestone',
      description: 'Consecutive days milestone',
      routeName: '/streak-milestone-event',
    ),
    UIEventInfo(
      type: UIEventType.totalHoursMilestone,
      title: 'Total Hours Milestone',
      description: 'Total hours milestone',
      routeName: '/total-hours-milestone-event',
    ),
    UIEventInfo(
      type: UIEventType.countdownEnded,
      title: 'Countdown Ended',
      description: 'When countdown reaches zero',
      routeName: '/countdown-ended-event',
    ),
    UIEventInfo(
      type: UIEventType.countdownSet,
      title: 'Countdown Set',
      description: 'When countdown is created',
      routeName: '/countdown-set-event',
    ),
  ];
}

