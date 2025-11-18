import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/widgets/goal_progress_card.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';

/// 目標画面（新デザインシステム版）
class GoalScreenNew extends ConsumerStatefulWidget {
  const GoalScreenNew({super.key});

  @override
  ConsumerState<GoalScreenNew> createState() => _GoalScreenNewState();
}

class _GoalScreenNewState extends ConsumerState<GoalScreenNew> {
  @override
  void initState() {
    super.initState();
    // 画面が開かれた時にデータをバックグラウンド更新で読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      // カウントダウンとゴールのデータをバックグラウンド更新で読み込む
      await Future.wait([
        loadCountdownsWithBackgroundRefreshHelper(ref),
        loadGoalsWithBackgroundRefreshHelper(ref),
      ]);
      
      // 期限切れカウントダウンを削除
      await deleteExpiredCountdownsHelper(ref);
    } catch (e) {
      debugPrint('❌ [GoalScreenNew] データ初期化エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Stack(
          children: [
            ScrollableContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // やる気の出る名言バナー
                  _buildQuoteSection(),

                  SizedBox(height: AppSpacing.md),

                  // カウントダウン表示
                  _buildCountdownSection(context, ref),

                  SizedBox(height: AppSpacing.md),

                  // 目標一覧
                  _buildGoalsList(context, ref),

                  SizedBox(height: AppSpacing.xxl * 2), // FABのスペース確保
                ],
              ),
            ),

            // 右下の＋ボタン
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: FloatingActionButton(
                  backgroundColor: AppColors.blue.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  elevation: 8,
                  onPressed: () {
                    _showAddEditDialog(context, ref);
                  },
                  child: const Icon(Icons.add, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuoteSection() {
    const quotes = [
      {
        'quote': 'Build momentum. Design tomorrow.',
        'author': 'Studio Nova',
      },
      {
        'quote': 'Make bold moves. Iterate relentlessly.',
        'author': 'Future Lab',
      },
      {
        'quote': 'Slow is smooth. Smooth becomes fast.',
        'author': 'Modern Craft',
      },
    ];
    final quoteData = quotes[DateTime.now().day % quotes.length];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4A5568), // グレー
              Color(0xFF2D3748), // ダークグレー
              Color(0xFFF97316), // オレンジ
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Motivational Quote',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFB8C1EC),
                      Color(0xFFFDE68A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    quoteData['quote'] as String,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 28.8, // 24.0 * 1.2
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              quoteData['author'] as String,
              style: AppTextStyles.body2.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSection(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownsListProvider);
    if (countdowns.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 最初のカウントダウンを使用（または最も近い未来のカウントダウン）
    final now = DateTime.now();
    final activeCountdowns = countdowns.where((c) => c.targetDate.isAfter(now)).toList();
    if (activeCountdowns.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 最も近い未来のカウントダウンを選択
    activeCountdowns.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    final countdown = activeCountdowns.first;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: RealtimeCountdownDisplay(
        eventName: countdown.title,
        targetDate: countdown.targetDate,
        accentColor: AppColors.blue,
        borderColor: AppColors.blue.withValues(alpha: 0.45),
        backgroundColor: AppColors.black,
        titleColor: AppColors.white,
        labelColor: AppColors.gray,
        valueTextColor: AppColors.white,
        valueBackgroundColor: AppColors.middleblackgray,
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsListProvider);
    // 写真のデザインに合わせて、最初の4つの目標を表示
    final displayGoals = goals.take(4).toList();

    if (displayGoals.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.blackgray,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '目標がありません',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...displayGoals.map(
            (goal) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildGoalCard(context, goal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    final category = _getCategoryFromDetectionItem(goal.detectionItem);
    final color = _getGoalColor(category);
    final icon = _getGoalIcon(category);
    
    // ラベルの決定（表示しない）
    List<String> labels = [];

    // Goalテキストの生成（Goal:を削除）
    // 秒単位で計算し、表示時に変換
    final targetSeconds = goal.targetTime;
    String goalText = _formatSecondsToDisplay(targetSeconds);
    if (goal.comparisonType == ComparisonType.below) {
      goalText = '< $goalText';
    }

    // 時間数値を「120m/300m」または「2h/5h」形式で生成
    // 秒単位で計算し、表示時に変換
    final currentSeconds = goal.achievedTime ?? 0;
    final currentDisplay = _formatSecondsToDisplay(currentSeconds);
    final targetDisplay = _formatSecondsToDisplay(targetSeconds);
    final progressText = '$currentDisplay/$targetDisplay';

    // 期間ラベル
    String periodLabel = _getPeriodLabelFromDurationDays(goal.durationDays);

    // 日数テキスト
    final endDate = goal.startDate.add(Duration(days: goal.durationDays));
    final remainingDuration = endDate.difference(DateTime.now());
    final remainingDays = remainingDuration.inDays;
    final remainingHours = remainingDuration.inHours % 24;
    String daysText;
    if (remainingDays >= 30) {
      final months = (remainingDays / 30).floor();
      daysText = months == 1 ? '1 month' : '$months months';
    } else if (remainingDays >= 7) {
      final weeks = (remainingDays / 7).floor();
      daysText = weeks == 1 ? '1 week' : '$weeks weeks';
    } else {
      // 日数表示の場合、時間も追加
      if (remainingDays == 1) {
        daysText = remainingHours > 0 ? '1day${remainingHours}h' : '1 day';
      } else if (remainingDays > 0) {
        daysText = remainingHours > 0 ? '${remainingDays}days${remainingHours}h' : '$remainingDays days';
      } else {
        // 日数が0の場合、時間のみ表示
        daysText = remainingHours > 0 ? '${remainingHours}h' : '0 days';
      }
    }

    // ストリーク番号
    final streakNumber = goal.consecutiveAchievements;

    // 進捗率の計算（秒単位で計算）
    final currentSecondsForCalc = goal.achievedTime ?? 0;
    final targetSecondsForCalc = goal.targetTime;
    double percentage;
    if (goal.comparisonType == ComparisonType.below) {
      // 以下タイプの場合、目標時間を超えないようにする
      percentage = targetSecondsForCalc > 0
          ? (currentSecondsForCalc / targetSecondsForCalc).clamp(0.0, 1.0)
          : 0.0;
    } else {
      // 以上タイプの場合、目標時間に対する達成率
      percentage = targetSecondsForCalc > 0
          ? (currentSecondsForCalc / targetSecondsForCalc).clamp(0.0, 1.0)
          : 0.0;
    }

    return GestureDetector(
      onTap: () {
        // GoalSettingDialogには時間単位で渡す必要がある
        final targetHours = goal.targetTime / 3600.0;
        showDialog(
          context: context,
          builder: (context) => GoalSettingDialog(
            isEdit: true,
            goalId: goal.id,
            initialTitle: goal.title,
            initialCategory: category,
            initialPeriod: periodLabel.toLowerCase(),
            initialTargetHours: targetHours,
            initialIsFocusedOnly: true, // GoalモデルにはisFocusedOnlyがないため、デフォルト値を使用
            onDelete: () {
              // 削除処理はGoalSettingDialog内で実行される
            },
          ),
        );
      },
      child: GoalProgressCardNew(
        title: goal.title,
        icon: icon,
        iconColor: color,
        streakNumber: streakNumber,
        labels: labels,
        goalText: goalText,
        progressText: progressText,
        periodLabel: periodLabel,
        percentage: percentage,
        progressColor: color,
        daysText: daysText,
        comparisonType: goal.comparisonType,
      ),
    );
  }

  String _getCategoryFromDetectionItem(DetectionItem item) {
    switch (item) {
      case DetectionItem.book:
        return 'study';
      case DetectionItem.pc:
        return 'pc';
      case DetectionItem.smartphone:
        return 'smartphone';
    }
  }

  String _getPeriodLabelFromDurationDays(int durationDays) {
    if (durationDays == 1) {
      return 'Daily';
    } else if (durationDays == 7) {
      return 'Weekly';
    } else if (durationDays == 30) {
      return 'Monthly';
    } else {
      return '$durationDays days';
    }
  }

  IconData _getGoalIcon(String category) {
    switch (category) {
      case 'study':
        return Icons.school;
      case 'pc':
        return Icons.computer;
      case 'smartphone':
        return Icons.smartphone;
      case 'work':
        return Icons.work;
      default:
        return Icons.flag;
    }
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      case 'work':
        return AppColors.purple;
      default:
        return AppColors.blue;
    }
  }

  /// 秒単位の値を表示用の文字列に変換（分/時間単位）
  String _formatSecondsToDisplay(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (m == 0) {
        return '${h}h';
      } else {
        return '${h}h ${m}m';
      }
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 1,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        NavigationHelper.pushReplacement(context, AppRoutes.home);
        break;
      case 2:
        NavigationHelper.pushReplacement(context, AppRoutes.report);
        break;
      case 3:
        NavigationHelper.pushReplacement(context, AppRoutes.settings);
        break;
    }
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => _AddEditSelectionDialog(
        onCountdownAdd: () {
          NavigationHelper.pop(context);
          showDialog(
            context: context,
            builder: (context) => const CountdownSettingDialog(),
          );
        },
        onCountdownEdit: () {
          NavigationHelper.pop(context);
          showDialog(
            context: context,
              builder: (context) {
                final countdowns = ref.read(countdownsListProvider);
                if (countdowns.isEmpty) {
                  return const SizedBox.shrink();
                }
                final now = DateTime.now();
                final activeCountdowns = countdowns.where((c) => c.targetDate.isAfter(now)).toList();
                if (activeCountdowns.isEmpty) {
                  return const SizedBox.shrink();
                }
                activeCountdowns.sort((a, b) => a.targetDate.compareTo(b.targetDate));
                final countdown = activeCountdowns.first;
                return CountdownSettingDialog(
                  isEdit: true,
                  countdownId: countdown.id,
                  initialEventName: countdown.title,
                  initialDate: countdown.targetDate,
                  onDelete: () {
                    // 削除処理はCountdownSettingDialog内で実行される
                  },
                );
              },
          );
        },
        onGoalAdd: () {
          NavigationHelper.pop(context);
          showDialog(
            context: context,
            builder: (context) => const GoalSettingDialog(),
          );
        },
        onGoalEdit: () {
          NavigationHelper.pop(context);
          // 最初のゴールを編集する（実際の実装では選択ダイアログを表示する）
          final goals = ref.read(goalsListProvider);
          if (goals.isNotEmpty) {
            final goal = goals.first;
            final category = _getCategoryFromDetectionItem(goal.detectionItem);
            final targetHours = goal.targetTime / 3600.0;
            final periodLabel = _getPeriodLabelFromDurationDays(goal.durationDays);
            showDialog(
              context: context,
              builder: (context) => GoalSettingDialog(
                isEdit: true,
                goalId: goal.id,
                initialTitle: goal.title,
                initialCategory: category,
                initialPeriod: periodLabel.toLowerCase(),
                initialTargetHours: targetHours,
                initialIsFocusedOnly: true,
                onDelete: () {
                  // 削除処理はGoalSettingDialog内で実行される
                },
              ),
            );
          }
        },
      ),
    );
  }
}

/// 追加/編集選択ダイアログ
class _AddEditSelectionDialog extends StatelessWidget {
  final VoidCallback onCountdownAdd;
  final VoidCallback onCountdownEdit;
  final VoidCallback onGoalAdd;
  final VoidCallback onGoalEdit;

  const _AddEditSelectionDialog({
    required this.onCountdownAdd,
    required this.onCountdownEdit,
    required this.onGoalAdd,
    required this.onGoalEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.blackgray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add or Edit',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildOptionButton(
              context: context,
              icon: Icons.timer,
              label: 'Add Countdown',
              iconColor: AppColors.blue,
              onTap: onCountdownAdd,
            ),
            SizedBox(height: AppSpacing.md),
            _buildOptionButton(
              context: context,
              icon: Icons.edit,
              label: 'Edit Countdown',
              iconColor: AppColors.purple,
              onTap: onCountdownEdit,
            ),
            SizedBox(height: AppSpacing.md),
            _buildOptionButton(
              context: context,
              icon: Icons.flag,
              label: 'Add Goal',
              iconColor: AppColors.green,
              onTap: onGoalAdd,
            ),
            SizedBox(height: AppSpacing.md),
            _buildOptionButton(
              context: context,
              icon: Icons.edit_outlined,
              label: 'Edit Goal',
              iconColor: AppColors.orange,
              onTap: onGoalEdit,
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Material(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () => NavigationHelper.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightblackgray,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.gray.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
