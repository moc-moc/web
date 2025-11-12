import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/total/total_data_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TotalData? _localTotalData;
  bool _isLoadingLocal = true;
  bool _showLocalData = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final manager = TotalDataManager();
    final localData = await manager.getLocalTotalData();
    
    // ログに出力
    debugPrint('📱 ===== Total ローカルデータ確認 =====');
    if (localData == null) {
      debugPrint('❌ ローカルデータなし');
    } else {
      debugPrint('✅ ローカルデータあり:');
      debugPrint('  - ID: ${localData.id}');
      debugPrint('  - 総ログイン日数: ${localData.totalLoginDays}日');
      debugPrint('  - 総作業時間: ${localData.totalWorkTimeMinutes}分');
      debugPrint('  - 最終トラッキング日: ${localData.lastTrackedDate}');
      debugPrint('  - 最終更新日時: ${localData.lastModified}');
    }
    debugPrint('============================');
    
    if (mounted) {
      setState(() {
        _localTotalData = localData;
        _isLoadingLocal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalData = ref.watch(totalDataProvider);
    final manager = TotalDataManager();
    final formattedWorkTime = manager.formatWorkTime(totalData.totalWorkTimeMinutes);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TotalStatsCard(
              totalLoginDays: totalData.totalLoginDays,
              totalWorkTime: formattedWorkTime,
            ),
            // ローカルデータ表示トグルボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showLocalData = !_showLocalData;
                      });
                    },
                    icon: Icon(
                      _showLocalData ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.blackgray,
                      size: 16,
                    ),
                    label: Text(
                      _showLocalData ? 'ローカルデータを非表示' : 'ローカルデータを表示',
                      style: const TextStyle(
                        color: AppColors.blackgray,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ローカルデータカード
            if (_showLocalData)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomCard(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.smartphone,
                              color: AppColors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ローカルデータ（SharedPreferences）',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingLocal)
                          const Center(child: CircularProgressIndicator())
                        else if (_localTotalData == null)
                          const Text(
                            'ローカルデータなし',
                            style: TextStyle(color: AppColors.gray, fontSize: 12),
                          )
                        else ...[
                          _buildLocalStatRow('総ログイン日数', '${_localTotalData!.totalLoginDays}日'),
                          const SizedBox(height: 8),
                          _buildLocalStatRow('総作業時間', manager.formatWorkTime(_localTotalData!.totalWorkTimeMinutes)),
                          const SizedBox(height: 8),
                          const Divider(color: AppColors.gray, height: 1),
                          const SizedBox(height: 8),
                          if (totalData.totalLoginDays == _localTotalData!.totalLoginDays &&
                              totalData.totalWorkTimeMinutes == _localTotalData!.totalWorkTimeMinutes)
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Providerと一致',
                                    style: TextStyle(color: Colors.green, fontSize: 11),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange, size: 16),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Providerと不一致',
                                    style: TextStyle(color: Colors.orange, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSnsButton(
                    text: 'Setting',
                    color: AppColors.gray,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.trackingsetting);
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomReplacementButton(
                    text: 'Start Tracking',
                    routeName: AppRoutes.tracking,
                  ),
                  const SizedBox(height: 20),
                  CustomSnsButton(
                    text: 'Googleでログイン',
                    color: AppColors.blue,
                    onPressed: () async {
                      final result = await AuthServiceUN.signInWithGoogle();
                      if (result.success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                        debugPrint('✅ ${result.userInfo}');
                        
                        // ログイン成功後、全データを同期
                        debugPrint('🔄 ログイン後のデータ同期を開始...');
                        await syncCountdownsHelper(ref);
                        await syncStreakDataHelper(ref);
                        await syncGoalsHelper(ref);
                        await syncTotalDataHelper(ref);
                        await syncAccountSettingsHelper(ref);
                        await syncNotificationSettingsHelper(ref);
                        await syncDisplaySettingsHelper(ref);
                        await syncTimeSettingsHelper(ref);
                        debugPrint('✅ ログイン後のデータ同期完了');
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomSnsButton(
                    text: 'サインアウト',
                    color: AppColors.gray,
                    onPressed: () async {
                      await AuthServiceUN.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('サインアウトしました')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ローカルデータの統計情報行を作成
  Widget _buildLocalStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

