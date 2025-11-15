import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';

/// 通知設定画面（新デザインシステム版）
class NotificationSettingsScreenNew extends StatefulWidget {
  const NotificationSettingsScreenNew({super.key});

  @override
  State<NotificationSettingsScreenNew> createState() =>
      _NotificationSettingsScreenNewState();
}

class _NotificationSettingsScreenNewState
    extends State<NotificationSettingsScreenNew> {
  bool _notificationsEnabled = true;
  bool _showContent = true;
  bool _countdownNotif = true;
  bool _goalAchievement = true;
  bool _goalReset = true;
  bool _dailySummary = true;
  bool _weeklySummary = true;
  bool _monthlySummary = false;
  bool _streakBroken = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Notifications'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 通知全体のオン/オフ
              _buildMainToggle(),

              // 通知コンテンツ表示
              _buildToggleItemCard(
                'Show Notification Content',
                'Display details in notifications',
                _showContent,
                (value) => setState(() => _showContent = value),
              ),

              // 目標関連通知
              _buildSection('Goal Notifications', [
                _buildToggleItem(
                  'Countdown',
                  'Countdown event notifications',
                  _countdownNotif,
                  (value) => setState(() => _countdownNotif = value),
                ),
                _buildToggleItem(
                  'Goal Achievement',
                  'When you achieve a goal',
                  _goalAchievement,
                  (value) => setState(() => _goalAchievement = value),
                ),
                _buildToggleItem(
                  'Goal Reset',
                  'When goal period resets',
                  _goalReset,
                  (value) => setState(() => _goalReset = value),
                ),
              ]),

              // トラッキング関連通知
              _buildSection('Tracking Notifications', [
                _buildToggleItem(
                  'Daily Summary',
                  'Daily focus time summary',
                  _dailySummary,
                  (value) => setState(() => _dailySummary = value),
                ),
                _buildToggleItem(
                  'Weekly Summary',
                  'Weekly progress summary',
                  _weeklySummary,
                  (value) => setState(() => _weeklySummary = value),
                ),
                _buildToggleItem(
                  'Monthly Summary',
                  'Monthly report summary',
                  _monthlySummary,
                  (value) => setState(() => _monthlySummary = value),
                ),
                _buildToggleItem(
                  'Streak Broken',
                  'When your streak is broken',
                  _streakBroken,
                  (value) => setState(() => _streakBroken = value),
                ),
              ]),

              // 通知時間設定
              _buildTimeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _notificationsEnabled ? 'Enabled' : 'Disabled',
                  style: AppTextStyles.caption.copyWith(
                    color: _notificationsEnabled
                        ? AppColors.success
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          AppToggleSwitch(
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItemCard(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Time',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Only receive notifications during this time',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTimePicker(
                  label: 'Start Time',
                  selectedTime: _startTime,
                  onTimeSelected: (time) {
                    setState(() => _startTime = time);
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTimePicker(
                  label: 'End Time',
                  selectedTime: _endTime,
                  onTimeSelected: (time) {
                    setState(() => _endTime = time);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
