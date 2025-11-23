import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/screens/event/ui_event_type.dart';
import 'package:test_flutter/presentation/widgets/event_content_builder.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/data/services/streak_milestone_service.dart';

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

            // イベント一覧（実際のUIを表示）
            ...UIEventInfoList.allEvents.map((event) => _buildEventPreview(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreview(BuildContext context, UIEventInfo event) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getEventGradientColors(event.type),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // イベントタイトル
                Text(
                  event.title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                // 実際のイベントコンテンツ
                _buildEventContent(context, event.type),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context, UIEventType type) {
    switch (type) {
      case UIEventType.countdownSet:
        return _buildCountdownSetContent();
      case UIEventType.countdownEnded:
        return _buildCountdownEndedContent();
      case UIEventType.goalSet:
        return _buildGoalSetContent();
      case UIEventType.goalAchieved:
        return _buildGoalAchievedContent();
      case UIEventType.goalPeriodEnded:
        return _buildGoalPeriodEndedContent();
      case UIEventType.streakMilestone:
        return _buildStreakMilestoneContent();
      case UIEventType.totalHoursMilestone:
        return _buildTotalHoursMilestoneContent();
    }
  }

  List<Color> _getEventGradientColors(UIEventType type) {
    switch (type) {
      case UIEventType.goalAchieved:
        return const [Color(0xFF9E66D5), Color(0xFF7C3AED)]; // Purple
      case UIEventType.goalSet:
        return const [Color(0xFF3B82F6), Color(0xFF1E40AF)]; // Blue
      case UIEventType.goalPeriodEnded:
        return const [Color(0xFFEC4899), Color(0xFFC026D3)]; // Pink
      case UIEventType.streakMilestone:
        return const [Color(0xFF3B82F6), Color(0xFF1E3A8A)]; // Blue
      case UIEventType.totalHoursMilestone:
        return const [Color(0xFFD97706), Color(0xFFB45309)]; // Yellow
      case UIEventType.countdownEnded:
        return const [Color(0xFFEF4444), Color(0xFFDC2626)]; // Red
      case UIEventType.countdownSet:
        return const [Color(0xFF06B6D4), Color(0xFF0891B2)]; // Cyan
    }
  }

  Widget _buildCountdownSetContent() {
    const eventName = 'Sample Event';
    const remainingDays = 30;
    final estimatedEndDate = DateTime.now().add(Duration(days: remainingDays));
    final formattedEndDate = DateFormat('yyyy/MM/dd').format(estimatedEndDate);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        EventContentBuilder.buildIconContent(
          icon: Icons.alarm_add,
          title: 'Countdown Set!',
          message: 'Keep it up!',
          iconSize: 80,
          titleFontSize: 36,
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildEventNameCard(
          eventName: eventName,
          fontSize: 24,
          additionalContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSpacing.md),
              EventContentBuilder.buildDetailRow(
                'Remaining Days',
                '$remainingDays days',
              ),
              EventContentBuilder.buildDetailRow(
                'Finish Date',
                formattedEndDate,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Next Step: Set your goals and start tracking!',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownEndedContent() {
    const eventName = 'Sample Event';
    final completionDate = DateFormat('yyyy/MM/dd').format(DateTime.now());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        EventContentBuilder.buildIconContent(
          icon: Icons.alarm,
          title: 'Countdown Ended!',
          message: 'The countdown has reached zero.',
          iconSize: 100,
          titleFontSize: 40,
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildEventNameCard(
          eventName: eventName,
          fontSize: 28,
          additionalContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSpacing.md),
              EventContentBuilder.buildDetailRow(
                'Completed on',
                completionDate,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.textPrimary, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Suggested Actions',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '• Review your progress\n• Set new goals\n• Celebrate your achievement!',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSetContent() {
    const goalTitle = 'Sample Goal';
    const targetTime = 7200; // 2 hours in seconds
    const consecutiveDays = 5;
    const durationDays = 7;
    const consecutivePeriodAchievements = 3;
    final targetHours = targetTime / 3600.0;
    final dailyTargetHours = durationDays > 0 ? targetHours / durationDays : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag,
              size: 60,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Goal Set!',
              style: AppTextStyles.h2.copyWith(fontSize: 40),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Your new goal has been set successfully',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildEventNameCard(
          eventName: goalTitle,
          fontSize: 24,
          additionalContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSpacing.md),
              EventContentBuilder.buildDetailRow(
                'Target Time',
                '${targetHours.toStringAsFixed(1)}h',
              ),
              EventContentBuilder.buildDetailRow(
                'Daily Target',
                '${dailyTargetHours.toStringAsFixed(1)}h / day',
              ),
              EventContentBuilder.buildDetailRow(
                'Current Streak',
                '$consecutiveDays days',
              ),
              EventContentBuilder.buildDetailRow(
                'Duration',
                '$durationDays days',
              ),
              EventContentBuilder.buildDetailRow(
                'Consecutive Achievements',
                '$consecutivePeriodAchievements times',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalAchievedContent() {
    const goalName = 'Sample Goal';
    const period = 'Weekly';
    const targetHours = 10.0;
    const achievedHours = 12.5;
    const progressPercent = 125.0;
    const consecutiveDays = 7;
    final difference = achievedHours - targetHours;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        EventContentBuilder.buildIconContent(
          icon: Icons.emoji_events,
          title: 'Goal Achieved!',
          message: 'Congratulations! You have achieved your goal.',
          iconSize: 100,
          titleFontSize: 40,
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildEventNameCard(
          eventName: goalName,
          fontSize: 28,
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            EventContentBuilder.buildChip(label: period),
            EventContentBuilder.buildChip(
              label: '${progressPercent.toStringAsFixed(0)}%',
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildAchievementCard(
          goalName: goalName,
          achievedHours: achievedHours,
          targetHours: targetHours,
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Progress: ${progressPercent.toStringAsFixed(1)}%',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        if (difference > 0) ...[
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: AppColors.textPrimary, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Exceeded by ${difference.toStringAsFixed(1)}h',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (consecutiveDays > 0) ...[
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: AppColors.textPrimary, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Consecutive Days: $consecutiveDays',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Keep Growing! Set your next challenge.',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalPeriodEndedContent() {
    const goalName = 'Sample Goal';
    const targetHours = 10.0;
    const achievedHours = 8.5;
    const progress = 0.85;
    const consecutiveDays = 5;
    const period = 'Weekly';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Goal Period Ended',
          style: AppTextStyles.h1.copyWith(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'The goal period has ended. Check your progress below.',
          style: AppTextStyles.body1,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xl),
        CircularProgressBar(
          percentage: progress,
          size: 160,
          strokeWidth: 16,
          progressColor: AppColors.textPrimary,
          backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
        ),
        SizedBox(height: AppSpacing.xl),
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: [
              EventContentBuilder.buildDetailRow('Goal', goalName),
              EventContentBuilder.buildDetailRow(
                'Hours',
                '${achievedHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(1)}h',
              ),
              EventContentBuilder.buildDetailRow(
                'Achievement',
                '${(progress * 100).toInt()}%',
              ),
              EventContentBuilder.buildDetailRow(
                'Consecutive Days',
                '$consecutiveDays days',
              ),
              EventContentBuilder.buildDetailRow('Goal Period', period),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakMilestoneContent() {
    const days = 30;

    return FutureBuilder<int?>(
      future: StreakMilestoneService.getNextMilestoneAfter(days),
      builder: (context, snapshot) {
        final effectiveNextMilestone = snapshot.data;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 60,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '$days',
              style: TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Days Streak',
              style: AppTextStyles.h2.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Streak Milestone!',
              style: AppTextStyles.h1.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Amazing! You have reached a new milestone.',
              style: AppTextStyles.body1.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            EventContentBuilder.buildMilestoneCard(
              nextMilestoneText: effectiveNextMilestone != null && effectiveNextMilestone > 0
                  ? 'Next Milestone: $effectiveNextMilestone Days'
                  : 'All Milestones Achieved!',
              icon: Icons.arrow_forward,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalHoursMilestoneContent() {
    const hours = 1000;
    const nextMilestone = 2000;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: 60, color: AppColors.textPrimary),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildNumberContent(
          number: '$hours',
          label: 'Hours',
          title: 'Total Hours Milestone!',
          message: 'Congratulations! You have reached a new milestone.',
          numberFontSize: 70,
          titleFontSize: 28,
        ),
        SizedBox(height: AppSpacing.md),
        EventContentBuilder.buildMilestoneCard(
          nextMilestoneText: 'Next target time is $nextMilestone hours',
          icon: Icons.arrow_forward,
        ),
      ],
    );
  }
}
