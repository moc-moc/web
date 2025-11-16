import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/dummy_data/tracking_data.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';

/// トラッキング終了画面（新デザインシステム版）
class TrackingFinishedScreenNew extends StatelessWidget {
  const TrackingFinishedScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    final session = completedTrackingSession;
    final workHours = (session.studyHours + session.pcHours).clamp(0.0, double.infinity);

    return AppScaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCongratulations(),
              _buildTimeRange(session),
              _buildSummaryCards(session, workHours),
              _buildBreakdownCard(session),
              _buildGoalUpdates(session),
              SizedBox(height: AppSpacing.md),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratulations() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withValues(alpha: 0.3),
            AppColors.purple.withValues(alpha: 0.3),
            AppColors.green.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Great Work!',
        style: AppTextStyles.h1.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRange(DummyTrackingSession session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.gray,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            _formatTimeRange(session),
            style: AppTextStyles.body1.copyWith(
              color: AppColors.gray,
              fontFeatures: [const FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DummyTrackingSession session, double workHours) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.blue,
                icon: Icons.timer_rounded,
                title: 'Session Total',
                value: '${session.totalHours.toStringAsFixed(1)}h',
                subtitle: '',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.orange,
                icon: Icons.work_history_rounded,
                title: 'Work Total',
                value: '${workHours.toStringAsFixed(1)}h',
                subtitle: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required Color accentColor,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 30),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: accentColor,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(DummyTrackingSession session) {
    final categories = [
      _CategoryStat(
        label: 'Study',
        icon: Icons.menu_book,
        color: AppColors.green,
        hours: session.studyHours,
      ),
      _CategoryStat(
        label: 'Computer',
        icon: Icons.computer,
        color: AppColors.blue,
        hours: session.pcHours,
      ),
      _CategoryStat(
        label: 'Smartphone',
        icon: Icons.smartphone,
        color: AppColors.orange,
        hours: session.smartphoneHours,
      ),
      _CategoryStat(
        label: 'People',
        icon: Icons.person,
        color: AppColors.gray,
        hours: session.personOnlyHours,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[0]),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildCategoryCard(categories[1]),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[2]),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildCategoryCard(categories[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryStat data) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: data.color.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 24,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            data.label,
            style: AppTextStyles.body2.copyWith(
              color: data.color.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${data.hours.toStringAsFixed(1)}h',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: data.color,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalUpdates(DummyTrackingSession session) {
    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    final plusHoursByCategory = <String, double>{
      'study': session.studyHours,
      'pc': session.pcHours,
      'smartphone': session.smartphoneHours,
      'person': session.personOnlyHours,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Goal Progress',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          ...todaysGoals.asMap().entries.map((entry) {
            final goal = entry.value;
            final plusHours = plusHoursByCategory[goal.category] ?? 0.0;
            final previousHours = goal.currentHours;
            final previousPercent = _calculatePercent(previousHours, goal.targetHours);
            final plusPercent = _calculatePercent(plusHours, goal.targetHours);

            final isLast = entry.key == todaysGoals.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: _buildGoalUpdateRow(
                goal: goal,
                previousHours: previousHours,
                previousPercent: previousPercent,
                plusHours: plusHours,
                plusPercent: plusPercent,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalUpdateRow({
    required DummyGoal goal,
    required double previousHours,
    required double previousPercent,
    required double plusHours,
    required double plusPercent,
  }) {
    final color = _getGoalColor(goal.category);
    final afterHours = previousHours + plusHours;
    final afterPercent = (afterHours / goal.targetHours * 100).clamp(0.0, 999.0);
    final progress = (afterHours / goal.targetHours).clamp(0.0, 1.0);
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 1.0),
                ),
              ),
              Text(
                '目標: ${goal.targetHours.toStringAsFixed(1)}h',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          LinearProgressBar(
            percentage: progress,
            height: 12,
            progressColor: color,
            backgroundColor: AppColors.blackgray,
            barBackgroundColor: AppColors.gray.withValues(alpha: 0.4),
            showFlowAnimation: false,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${previousHours.toStringAsFixed(1)}h → ${afterHours.toStringAsFixed(1)}h',
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+${plusHours.toStringAsFixed(1)}h',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${previousPercent.toStringAsFixed(0)}% → ${afterPercent.toStringAsFixed(0)}%',
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+${plusPercent.toStringAsFixed(0)}%',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context) {
    final borderRadiusValue = BorderRadius.circular(30.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.gray.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Material(
              color: AppColors.blackgray,
              borderRadius: borderRadiusValue,
              elevation: 2,
              shadowColor: AppColors.black.withValues(alpha: 0.2),
              child: InkWell(
                onTap: () {
                  // 将来実装
                },
                borderRadius: borderRadiusValue,
                child: Container(
                  height: 56.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: AppColors.gray,
                          size: 18.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Share on Social Media',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: AppColors.blue.withValues(alpha: 0.5),
              borderRadius: borderRadiusValue,
              elevation: 4,
              shadowColor: AppColors.blue.withValues(alpha: 0.3),
              child: InkWell(
                onTap: () {
                  NavigationHelper.pushAndRemoveUntil(
                    context,
                    AppRoutes.home,
                  );
                },
                borderRadius: borderRadiusValue,
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 20.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'OK',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      default:
        return AppColors.blue;
    }
  }

  String _formatTimeRange(DummyTrackingSession session) {
    final start = _formatTime(session.startTime);
    final end = _formatTime(session.endTime);
    return '$start - $end';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _CategoryStat {
  const _CategoryStat({
    required this.label,
    required this.icon,
    required this.color,
    required this.hours,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double hours;
}


double _calculatePercent(double hours, double target) {
  if (target == 0) return 0;
  return (hours / target * 100).clamp(0.0, 999.0);
}
