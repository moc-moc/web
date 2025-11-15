import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/dummy_data/event_data.dart';

/// イベントプレビュー画面（新デザインシステム版）
class EventPreviewScreenNew extends StatelessWidget {
  const EventPreviewScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: 'Event Preview'),
      body: ScrollableContent(
        child: SpacedColumn(
          spacing: AppSpacing.md,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Preview All Events', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Tap any event to see how it looks',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: AppSpacing.md),

            // イベント一覧
            ...allEvents.map((event) => _buildEventItem(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, DummyEvent event) {
    return InteractiveCard(
      onTap: () {
        String routeName;
        switch (event.type) {
          case EventType.goalAchieved:
            routeName = AppRoutes.goalAchievedEvent;
            break;
          case EventType.goalSet:
            routeName = AppRoutes.goalSetEvent;
            break;
          case EventType.goalPeriodEnded:
            routeName = AppRoutes.goalPeriodEndedEvent;
            break;
          case EventType.streakMilestone:
            routeName = AppRoutes.streakMilestoneEvent;
            break;
          case EventType.totalHoursMilestone:
            routeName = AppRoutes.totalHoursMilestoneEvent;
            break;
          case EventType.countdownEnded:
            routeName = AppRoutes.countdownEndedEvent;
            break;
          case EventType.countdownSet:
            routeName = AppRoutes.countdownSetEvent;
            break;
        }
        Navigator.pushNamed(context, routeName);
      },
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: _getEventColor(event.type),
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  _getEventDescription(event.type),
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.goalAchieved:
        return AppColors.purple;
      case EventType.goalSet:
        return AppColors.blue;
      case EventType.goalPeriodEnded:
        return Color(0xFFEC4899); // Pink
      case EventType.streakMilestone:
        return AppColors.success;
      case EventType.totalHoursMilestone:
        return AppColors.yellow;
      case EventType.countdownEnded:
        return AppColors.red;
      case EventType.countdownSet:
        return AppColors.info;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.goalAchieved:
        return Icons.emoji_events;
      case EventType.goalSet:
        return Icons.flag;
      case EventType.goalPeriodEnded:
        return Icons.trending_up;
      case EventType.streakMilestone:
        return Icons.local_fire_department;
      case EventType.totalHoursMilestone:
        return Icons.timer;
      case EventType.countdownEnded:
        return Icons.alarm;
      case EventType.countdownSet:
        return Icons.alarm_add;
    }
  }

  String _getEventDescription(EventType type) {
    switch (type) {
      case EventType.goalAchieved:
        return 'When you achieve a goal';
      case EventType.goalSet:
        return 'When you set a new goal';
      case EventType.goalPeriodEnded:
        return 'When goal period ends';
      case EventType.streakMilestone:
        return 'Consecutive days milestone';
      case EventType.totalHoursMilestone:
        return 'Total hours milestone';
      case EventType.countdownEnded:
        return 'When countdown reaches zero';
      case EventType.countdownSet:
        return 'When countdown is created';
    }
  }
}
