import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/screens/event/ui_event_type.dart';

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
            ...UIEventInfoList.allEvents.map((event) => _buildEventItem(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, UIEventInfo event) {
    return InteractiveCard(
      onTap: () {
        NavigationHelper.push(context, event.routeName);
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
                  event.description,
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

  Color _getEventColor(UIEventType type) {
    switch (type) {
      case UIEventType.goalAchieved:
        return AppColors.purple;
      case UIEventType.goalSet:
        return AppColors.blue;
      case UIEventType.goalPeriodEnded:
        return Color(0xFFEC4899); // Pink
      case UIEventType.streakMilestone:
        return AppColors.success;
      case UIEventType.totalHoursMilestone:
        return AppColors.yellow;
      case UIEventType.countdownEnded:
        return AppColors.red;
      case UIEventType.countdownSet:
        return AppColors.info;
    }
  }

  IconData _getEventIcon(UIEventType type) {
    switch (type) {
      case UIEventType.goalAchieved:
        return Icons.emoji_events;
      case UIEventType.goalSet:
        return Icons.flag;
      case UIEventType.goalPeriodEnded:
        return Icons.trending_up;
      case UIEventType.streakMilestone:
        return Icons.local_fire_department;
      case UIEventType.totalHoursMilestone:
        return Icons.timer;
      case UIEventType.countdownEnded:
        return Icons.alarm;
      case UIEventType.countdownSet:
        return Icons.alarm_add;
    }
  }
}
