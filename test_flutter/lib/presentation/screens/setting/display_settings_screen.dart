import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/settings_widgets.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/data/models/settings_models.dart';

/// 表示設定画面
/// アプリの表示に関する設定を管理する画面
class DisplaySettingsScreen extends ConsumerStatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  ConsumerState<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends ConsumerState<DisplaySettingsScreen> {
  String _category1Name = 'カテゴリ1';
  String _category2Name = 'カテゴリ2';
  String _category3Name = 'カテゴリ3';
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Providerを監視（自動更新）
    final displaySettings = ref.watch(displaySettingsProvider);
    
    // Providerの値で初期化（初回のみ）
    if (!_isInitialized) {
      _isInitialized = true;
      _category1Name = displaySettings.category1Name;
      _category2Name = displaySettings.category2Name;
      _category3Name = displaySettings.category3Name;
    }
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('表示設定'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'カテゴリ名の設定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackgray,
              ),
            ),
            const SizedBox(height: 20),
            
            // カテゴリ1の名前
            CustomTextField(
              label: 'カテゴリ1',
              initialValue: _category1Name,
              onChanged: (value) {
                setState(() {
                  _category1Name = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // カテゴリ2の名前
            CustomTextField(
              label: 'カテゴリ2',
              initialValue: _category2Name,
              onChanged: (value) {
                setState(() {
                  _category2Name = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // カテゴリ3の名前
            CustomTextField(
              label: 'カテゴリ3',
              initialValue: _category3Name,
              onChanged: (value) {
                setState(() {
                  _category3Name = value;
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
                final settings = DisplaySettings(
                  id: 'display_settings',
                  category1Name: _category1Name,
                  category2Name: _category2Name,
                  category3Name: _category3Name,
                  lastModified: DateTime.now(),
                );
                
                final success = await saveDisplaySettingsHelper(ref, settings);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '保存しました' : '保存に失敗しました'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
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
