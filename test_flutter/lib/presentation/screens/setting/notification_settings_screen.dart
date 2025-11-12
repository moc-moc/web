import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/data/models/settings_models.dart';

/// 通知設定画面
/// アプリの通知に関する設定を管理する画面
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _countdownNotification = true;
  bool _goalDeadlineNotification = true;
  bool _streakBreakNotification = true;
  bool _dailyReportNotification = true;
  String _notificationFrequency = '毎日';
  String _morningTime = '08:00';
  String _eveningTime = '20:00';
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Providerを監視（自動更新）
    final notificationSettings = ref.watch(notificationSettingsProvider);

    // Providerの値で初期化（初回のみ）
    if (!_isInitialized) {
      _isInitialized = true;
      _countdownNotification = notificationSettings.countdownNotification;
      _goalDeadlineNotification = notificationSettings.goalDeadlineNotification;
      _streakBreakNotification = notificationSettings.streakBreakNotification;
      _dailyReportNotification = notificationSettings.dailyReportNotification;
      _notificationFrequency = notificationSettings.notificationFrequency;
      _morningTime = notificationSettings.morningTime;
      _eveningTime = notificationSettings.eveningTime;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 各通知項目のスイッチ
            CustomSwitchTile(
              title: 'カウントダウン通知',
              value: _countdownNotification,
              onChanged: (value) {
                setState(() {
                  _countdownNotification = value;
                });
              },
            ),
            const SizedBox(height: 12),

            CustomSwitchTile(
              title: '目標期限通知',
              value: _goalDeadlineNotification,
              onChanged: (value) {
                setState(() {
                  _goalDeadlineNotification = value;
                });
              },
            ),
            const SizedBox(height: 12),

            CustomSwitchTile(
              title: '継続日数途切れ通知',
              value: _streakBreakNotification,
              onChanged: (value) {
                setState(() {
                  _streakBreakNotification = value;
                });
              },
            ),
            const SizedBox(height: 12),

            CustomSwitchTile(
              title: '昨日の報告通知',
              value: _dailyReportNotification,
              onChanged: (value) {
                setState(() {
                  _dailyReportNotification = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // 通知回数の選択
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  '通知回数',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackgray,
                  ),
                ),
              ),
            ),
            CustomSegmentedControl(
              options: const ['朝のみ', '夜のみ', '両方'],
              selectedValue: _getFrequencyLabel(_notificationFrequency),
              onChanged: (value) {
                setState(() {
                  _notificationFrequency = _getFrequencyValue(value);
                });
              },
            ),
            const SizedBox(height: 30),

            // 朝の通知時間
            CustomTimePicker(
              label: '朝の通知時間',
              currentTime: _morningTime,
              onTimeSelected: (time) {
                setState(() {
                  _morningTime = time;
                });
              },
            ),
            const SizedBox(height: 12),

            // 夜の通知時間
            CustomTimePicker(
              label: '夜の通知時間',
              currentTime: _eveningTime,
              onTimeSelected: (time) {
                setState(() {
                  _eveningTime = time;
                });
              },
            ),
            const SizedBox(height: 30),

            // 保存ボタン
            CustomSnsButton(
              text: '保存',
              color: AppColors.blue,
              onPressed: () async {
                // 設定を保存
                final settings = NotificationSettings(
                  id: 'notification_settings',
                  countdownNotification: _countdownNotification,
                  goalDeadlineNotification: _goalDeadlineNotification,
                  streakBreakNotification: _streakBreakNotification,
                  dailyReportNotification: _dailyReportNotification,
                  notificationFrequency: _notificationFrequency,
                  morningTime: _morningTime,
                  eveningTime: _eveningTime,
                  lastModified: DateTime.now(),
                );

                final success = await saveNotificationSettingsHelper(
                  ref,
                  settings,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '保存しました' : '保存に失敗しました'),
                      backgroundColor: success
                          ? AppColors.green
                          : AppColors.red,
                    ),
                  );

                  if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 通知回数の値からラベルを取得
  String _getFrequencyLabel(String value) {
    switch (value) {
      case 'morning':
        return '朝のみ';
      case 'evening':
        return '夜のみ';
      case 'both':
      default:
        return '両方';
    }
  }

  /// 通知回数のラベルから値を取得
  String _getFrequencyValue(String label) {
    switch (label) {
      case '朝のみ':
        return 'morning';
      case '夜のみ':
        return 'evening';
      case '両方':
      default:
        return 'both';
    }
  }
}
