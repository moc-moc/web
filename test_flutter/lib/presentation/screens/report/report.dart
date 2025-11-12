import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:intl/intl.dart';

class Report extends ConsumerStatefulWidget {
  const Report({super.key});

  @override
  ConsumerState<Report> createState() => _ReportState();
}

class _ReportState extends ConsumerState<Report> {
  StreakData? _localStreakData;
  bool _isLoadingLocal = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final manager = StreakDataManager();
    final localData = await manager.getLocalStreakData();
    
    // ログに出力
    debugPrint('📱 ===== ローカルデータ確認 =====');
    if (localData == null) {
      debugPrint('❌ ローカルデータなし');
    } else {
      debugPrint('✅ ローカルデータあり:');
      debugPrint('  - ID: ${localData.id}');
      debugPrint('  - 現在の連続日数: ${localData.currentStreak}日');
      debugPrint('  - 最長記録: ${localData.longestStreak}日');
      debugPrint('  - 最終トラッキング日: ${localData.lastTrackedDate}');
      debugPrint('  - 最終更新日時: ${localData.lastModified}');
    }
    debugPrint('============================');
    
    if (mounted) {
      setState(() {
        _localStreakData = localData;
        _isLoadingLocal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Providerから連続継続日数データを監視
    final streakData = ref.watch(streakDataProvider);
    
    // Providerのデータもログに出力（ローカルデータと比較用）
    if (!_isLoadingLocal && _localStreakData != null) {
      debugPrint('☁️  ===== Providerデータ（Firestore同期済み） =====');
      debugPrint('  - ID: ${streakData.id}');
      debugPrint('  - 現在の連続日数: ${streakData.currentStreak}日');
      debugPrint('  - 最長記録: ${streakData.longestStreak}日');
      debugPrint('  - 最終トラッキング日: ${streakData.lastTrackedDate}');
      debugPrint('  - 最終更新日時: ${streakData.lastModified}');
      debugPrint('============================');
      
      // 比較
      if (streakData.currentStreak == _localStreakData!.currentStreak &&
          streakData.longestStreak == _localStreakData!.longestStreak) {
        debugPrint('✅ ProviderとローカルのデータはcurrentStreakとlongestStreakが一致');
      } else {
        debugPrint('⚠️  Providerとローカルのデータが異なります:');
        if (streakData.currentStreak != _localStreakData!.currentStreak) {
          debugPrint('  - currentStreak: Provider=${streakData.currentStreak}, Local=${_localStreakData!.currentStreak}');
        }
        if (streakData.longestStreak != _localStreakData!.longestStreak) {
          debugPrint('  - longestStreak: Provider=${streakData.longestStreak}, Local=${_localStreakData!.longestStreak}');
        }
      }
    }
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 連続継続日数カード（Provider/Firestore同期済み）
              CustomCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル行
                      Row(
                        children: [
                          Icon(
                            Icons.cloud,
                            color: AppColors.blue,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '連続継続日数（Provider）',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // 現在の連続日数（大きく表示）
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${streakData.currentStreak}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '日',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.gray),
                      const SizedBox(height: 16),
                      // 統計情報
                      _buildStatRow(
                        '最長記録',
                        '${streakData.longestStreak}日',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        '最終トラッキング日',
                        DateFormat('yyyy/MM/dd').format(streakData.lastTrackedDate),
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        '最終更新日時',
                        DateFormat('yyyy/MM/dd HH:mm').format(streakData.lastModified),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ローカルデータカード
              CustomCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル行
                      Row(
                        children: [
                          Icon(
                            Icons.smartphone,
                            color: AppColors.green,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ローカルデータ（SharedPreferences）',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingLocal)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (_localStreakData == null)
                        const Center(
                          child: Text(
                            'ローカルデータなし',
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else ...[
                        _buildStatRow(
                          '現在の連続日数',
                          '${_localStreakData!.currentStreak}日',
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          '最長記録',
                          '${_localStreakData!.longestStreak}日',
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          '最終トラッキング日',
                          DateFormat('yyyy/MM/dd').format(_localStreakData!.lastTrackedDate),
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          '最終更新日時',
                          DateFormat('yyyy/MM/dd HH:mm').format(_localStreakData!.lastModified),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.gray),
                        const SizedBox(height: 12),
                        // 比較結果
                        if (streakData.currentStreak == _localStreakData!.currentStreak &&
                            streakData.longestStreak == _localStreakData!.longestStreak)
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Providerとローカルのデータは一致しています',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Providerとローカルのデータが異なります',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 統計情報の行を作成
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}