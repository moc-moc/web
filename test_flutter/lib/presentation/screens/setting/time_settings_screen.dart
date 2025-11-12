import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/data/models/settings_models.dart';

/// 時間設定画面
/// アプリの時間に関する設定を管理する画面
class TimeSettingsScreen extends ConsumerStatefulWidget {
  const TimeSettingsScreen({super.key});

  @override
  ConsumerState<TimeSettingsScreen> createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends ConsumerState<TimeSettingsScreen> {
  String _dayBoundaryTime = '04:00';
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Providerを監視（自動更新）
    final timeSettings = ref.watch(timeSettingsProvider);

    // Providerの値で初期化（初回のみ）
    if (!_isInitialized) {
      _isInitialized = true;
      _dayBoundaryTime = timeSettings.dayBoundaryTime;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('時間設定'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '一日の区切り時刻',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackgray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'この時刻を過ぎると翌日としてカウントされます',
              style: TextStyle(fontSize: 14, color: AppColors.gray),
            ),
            const SizedBox(height: 20),

            // 一日の区切り時刻
            CustomTimePicker(
              label: '区切り時刻',
              currentTime: _dayBoundaryTime,
              onTimeSelected: (time) {
                setState(() {
                  _dayBoundaryTime = time;
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
                final settings = TimeSettings(
                  id: 'time_settings',
                  dayBoundaryTime: _dayBoundaryTime,
                  lastModified: DateTime.now(),
                );

                final success = await saveTimeSettingsHelper(ref, settings);

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
}
