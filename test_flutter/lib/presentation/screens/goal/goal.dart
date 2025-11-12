import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_data_manager.dart'
    as goal_model;
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/countdown/countdowndata.dart';

class Goal extends ConsumerStatefulWidget {
  const Goal({super.key});

  @override
  ConsumerState<Goal> createState() => _GoalState();
}

class _GoalState extends ConsumerState<Goal> {
  Timer? _timer;
  List<Countdown> _localCountdowns = [];
  List<goal_model.Goal> _localGoals = [];
  bool _isLoadingLocal = true;
  bool _showLocalData = false;

  @override
  void initState() {
    super.initState();
    // 毎秒更新のタイマーを開始
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    // ローカルデータを読み込み
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final countdownManager = CountdownDataManager();
    final goalManager = goal_model.GoalDataManager();

    final localCountdowns = await countdownManager.getLocalCountdowns();
    final localGoals = await goalManager.getLocalGoals();

    // ログに出力
    debugPrint('📱 ===== Countdown & Goal ローカルデータ確認 =====');
    debugPrint('✅ ローカルカウントダウン数: ${localCountdowns.length}件');
    for (var i = 0; i < localCountdowns.length; i++) {
      debugPrint(
        '  - ${i + 1}. ${localCountdowns[i].title}: ${localCountdowns[i].targetDate}',
      );
    }
    debugPrint('✅ ローカルゴール数: ${localGoals.length}件');
    for (var i = 0; i < localGoals.length; i++) {
      debugPrint(
        '  - ${i + 1}. ${localGoals[i].tag}: ${localGoals[i].targetTime}分',
      );
    }
    debugPrint('============================');

    if (mounted) {
      setState(() {
        _localCountdowns = localCountdowns;
        _localGoals = localGoals;
        _isLoadingLocal = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getDetectionItemText(goal_model.DetectionItem item) {
    switch (item) {
      case goal_model.DetectionItem.book:
        return '本';
      case goal_model.DetectionItem.smartphone:
        return 'スマホ';
      case goal_model.DetectionItem.pc:
        return 'パソコン';
    }
  }

  String _getComparisonTypeText(goal_model.ComparisonType type) {
    switch (type) {
      case goal_model.ComparisonType.above:
        return '以上';
      case goal_model.ComparisonType.below:
        return '以下';
    }
  }

  String _formatCountdown(Duration difference) {
    if (difference.isNegative) {
      return '期限切れ';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // 状況に応じた最適表示
    if (days > 0) {
      return '残り $days日 $hours時間 $minutes分 $seconds秒';
    } else if (hours > 0) {
      return '残り $hours時間 $minutes分 $seconds秒';
    } else if (minutes > 0) {
      return '残り $minutes分 $seconds秒';
    } else {
      return '残り $seconds秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsListProvider);
    final countdowns = ref.watch(countdownsListProvider);

    // 期限切れカウントダウンを削除（画面表示後に実行）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await deleteExpiredCountdownsHelper(ref);
    });

    debugPrint(
      '🎯 [Goal画面] Goals: ${goals.length}件, Countdowns: ${countdowns.length}件',
    );

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Goal'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カウントダウンセクション
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'カウントダウン',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomIconButton(
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.setgoal);
                        },
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (countdowns.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Text(
                          '新しいカウントダウンを追加して、大切なイベントまでの日数を確認しましょう！',
                          style: TextStyle(color: AppColors.gray, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...countdowns.map((countdown) {
                      final now = DateTime.now();
                      final difference = countdown.targetDate.difference(now);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  countdown.title,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCountdown(difference),
                                  style: const TextStyle(
                                    color: AppColors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  // ローカルデータ表示セクション
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ローカルデータ確認',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showLocalData = !_showLocalData;
                          });
                        },
                        icon: Icon(
                          _showLocalData
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.white,
                          size: 16,
                        ),
                        label: Text(
                          _showLocalData ? '非表示' : '表示',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_showLocalData)
                    CustomCard(
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
                                  color: AppColors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ローカルカウントダウンデータ',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isLoadingLocal)
                              const Center(child: CircularProgressIndicator())
                            else if (_localCountdowns.isEmpty)
                              const Text(
                                'ローカルカウントダウンデータなし',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 12,
                                ),
                              )
                            else ...[
                              Text(
                                '保存されているカウントダウン: ${_localCountdowns.length}件',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._localCountdowns.map((cd) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cd.title,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '目標日時: ${cd.targetDate.toString().split('.')[0]}',
                                          style: const TextStyle(
                                            color: AppColors.blue,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${cd.id}',
                                          style: const TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '削除済み: ${cd.isDeleted ? "はい" : "いいえ"}',
                                          style: TextStyle(
                                            color: cd.isDeleted
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              const Divider(color: AppColors.gray, height: 1),
                              const SizedBox(height: 8),
                              if (countdowns.length ==
                                  _localCountdowns
                                      .where((c) => !c.isDeleted)
                                      .length)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'Providerと一致',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Provider: ${countdowns.length}件、ローカル(アクティブ): ${_localCountdowns.where((c) => !c.isDeleted).length}件',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
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

                  if (_showLocalData) const SizedBox(height: 12),

                  // ローカルゴールデータカード
                  if (_showLocalData)
                    CustomCard(
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
                                  'ローカルゴールデータ',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isLoadingLocal)
                              const Center(child: CircularProgressIndicator())
                            else if (_localGoals.isEmpty)
                              const Text(
                                'ローカルゴールデータなし',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 12,
                                ),
                              )
                            else ...[
                              Text(
                                '保存されているゴール: ${_localGoals.length}件',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._localGoals.map((goal) {
                                final now = DateTime.now();
                                final endDate = goal.startDate.add(
                                  Duration(days: goal.durationDays),
                                );
                                final daysLeft = endDate.difference(now).inDays;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.tag,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_getDetectionItemText(goal.detectionItem)}: ${goal.targetTime}分${_getComparisonTypeText(goal.comparisonType)}',
                                          style: const TextStyle(
                                            color: AppColors.blue,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '期間: ${daysLeft >= 0 ? "残り$daysLeft日" : "期間終了"}',
                                          style: TextStyle(
                                            color: daysLeft >= 0
                                                ? AppColors.green
                                                : Colors.red,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '連続達成: ${goal.consecutiveAchievements}回',
                                          style: const TextStyle(
                                            color: AppColors.yellow,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${goal.id}',
                                          style: const TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '削除済み: ${goal.isDeleted ? "はい" : "いいえ"}',
                                          style: TextStyle(
                                            color: goal.isDeleted
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              const Divider(color: AppColors.gray, height: 1),
                              const SizedBox(height: 8),
                              if (goals.length ==
                                  _localGoals.where((g) => !g.isDeleted).length)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'Providerと一致',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Provider: ${goals.length}件、ローカル(アクティブ): ${_localGoals.where((g) => !g.isDeleted).length}件',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
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

                  const SizedBox(height: 32),

                  // 目標セクション
                  const Text(
                    '目標',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (goals.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          '目標がありません',
                          style: TextStyle(color: AppColors.gray, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...goals.map((goal) {
                      final now = DateTime.now();
                      final endDate = goal.startDate.add(
                        Duration(days: goal.durationDays),
                      );
                      final daysLeft = endDate.difference(now).inDays;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // タグ
                                if (goal.tag.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      goal.tag,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // タイトル
                                Text(
                                  goal.title,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // 目標情報
                                Text(
                                  '${_getDetectionItemText(goal.detectionItem)}: ${goal.targetTime}分${_getComparisonTypeText(goal.comparisonType)}',
                                  style: const TextStyle(
                                    color: AppColors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // 期間情報
                                Text(
                                  daysLeft >= 0 ? '残り $daysLeft日' : '期間終了',
                                  style: TextStyle(
                                    color: daysLeft >= 0
                                        ? AppColors.green
                                        : Colors.red,
                                    fontSize: 14,
                                  ),
                                ),

                                // 連続達成回数
                                if (goal.consecutiveAchievements > 0)
                                  Text(
                                    '連続達成: ${goal.consecutiveAchievements}回',
                                    style: const TextStyle(
                                      color: AppColors.yellow,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomPushButton(
            icon: Icons.add,
            routeName: AppRoutes.settinggoal,
            color: AppColors.blue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
