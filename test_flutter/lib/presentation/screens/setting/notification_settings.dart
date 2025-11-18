import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/toggles_chips.dart';
import 'package:test_flutter/presentation/widgets/input_fields.dart';
import 'package:test_flutter/feature/setting/notification_settings_notifier.dart';

/// 通知設定画面（新デザインシステム版）
class NotificationSettingsScreenNew extends ConsumerStatefulWidget {
  const NotificationSettingsScreenNew({super.key});

  @override
  ConsumerState<NotificationSettingsScreenNew> createState() =>
      _NotificationSettingsScreenNewState();
}

class _NotificationSettingsScreenNewState
    extends ConsumerState<NotificationSettingsScreenNew> {
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      await syncNotificationSettingsHelper(ref);
      final settings = ref.read(notificationSettingsProvider);
      
      setState(() {
        _countdownNotif = settings.countdownNotification;
        _goalAchievement = settings.goalDeadlineNotification;
        _goalReset = settings.goalDeadlineNotification; // 同じフィールドを使用
        _dailySummary = settings.dailyReportNotification;
        _streakBroken = settings.streakBreakNotification;
        
        // 通知時間を読み込み
        final morningParts = settings.morningTime.split(':');
        if (morningParts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.tryParse(morningParts[0]) ?? 8,
            minute: int.tryParse(morningParts[1]) ?? 30,
          );
        }
        
        final eveningParts = settings.eveningTime.split(':');
        if (eveningParts.length == 2) {
          _endTime = TimeOfDay(
            hour: int.tryParse(eveningParts[0]) ?? 22,
            minute: int.tryParse(eveningParts[1]) ?? 0,
          );
        }
        
        // 通知頻度に基づいて通知全体のON/OFFを設定
        _notificationsEnabled = settings.notificationFrequency != 'none';
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    final currentSettings = ref.read(notificationSettingsProvider);
    
    // 通知頻度を決定（通知が有効な場合は'both'、無効な場合は'none'）
    final notificationFrequency = _notificationsEnabled ? 'both' : 'none';
    
    final morningTimeString = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final eveningTimeString = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
    
    final updatedSettings = currentSettings.copyWith(
      countdownNotification: _countdownNotif,
      goalDeadlineNotification: _goalAchievement || _goalReset, // どちらかがONならtrue
      streakBreakNotification: _streakBroken,
      dailyReportNotification: _dailySummary,
      notificationFrequency: notificationFrequency,
      morningTime: morningTimeString,
      eveningTime: eveningTimeString,
      lastModified: DateTime.now(),
    );
    
    final success = await saveNotificationSettingsHelper(ref, updatedSettings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Notification settings saved!' : 'Failed to save settings'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        appBar: AppBarWithBack(title: 'Notifications'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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

              SizedBox(height: AppSpacing.md),

              // 保存ボタン
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: AppColors.blackgray,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: InkWell(
                    onTap: _handleSave,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    child: Container(
                      height: 56.0,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                color: AppColors.success,
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
