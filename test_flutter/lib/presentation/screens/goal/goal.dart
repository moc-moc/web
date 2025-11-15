import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/goal_progress_card.dart';
import 'package:test_flutter/dummy_data/goal_data.dart';
import 'package:test_flutter/dummy_data/countdown_data.dart';

/// 目標画面（新デザインシステム版）
class GoalScreenNew extends StatelessWidget {
  const GoalScreenNew({super.key});

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
                  _buildCountdownSection(context),

                  SizedBox(height: AppSpacing.md),

                  // 目標一覧
                  _buildGoalsList(context),

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
                    _showAddEditDialog(context);
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
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildCountdownSection(BuildContext context) {
    final countdown = activeCountdown;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CountdownDisplay(
        eventName: countdown.eventName,
        days: _nonNegative(countdown.remainingDays),
        hours: _nonNegative(countdown.remainingHours),
        minutes: _nonNegative(countdown.remainingMinutes),
        seconds: _nonNegative(countdown.remainingSeconds),
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

  int _nonNegative(int value) => value < 0 ? 0 : value;

  Widget _buildGoalsList(BuildContext context) {
    // 写真のデザインに合わせて、最初の4つの目標を表示
    final displayGoals = dummyGoals.take(4).toList();

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

  Widget _buildGoalCard(BuildContext context, DummyGoal goal) {
    final color = _getGoalColor(goal.category);
    final icon = _getGoalIcon(goal.category);
    
    // ラベルの決定（表示しない）
    List<String> labels = [];

    // Goalテキストの生成（Goal:を削除）
    String goalText;
    if (goal.comparisonType == 'below') {
      goalText = '< ${goal.targetHours.toStringAsFixed(0)} hour${goal.targetHours == 1 ? '' : 's'}';
    } else {
      goalText = '${goal.targetHours.toStringAsFixed(0)} hour${goal.targetHours == 1 ? '' : 's'}';
    }

    // 時間数値を「2h/5h」形式で生成
    String progressText;
    final currentHours = goal.currentHours.toInt();
    final targetHours = goal.targetHours.toInt();
    progressText = '${currentHours}h/${targetHours}h';

    // 期間ラベル
    String periodLabel = _getPeriodLabel(goal.period);

    // 日数テキスト
    String daysText;
    if (goal.remainingDays >= 30) {
      final months = (goal.remainingDays / 30).floor();
      daysText = months == 1 ? '1 month' : '$months months';
    } else if (goal.remainingDays >= 7) {
      final weeks = (goal.remainingDays / 7).floor();
      daysText = weeks == 1 ? '1 week' : '$weeks weeks';
    } else {
      daysText = goal.remainingDays == 1 ? '1 day' : '${goal.remainingDays} days';
    }

    // ストリーク番号（写真のデザインに合わせて設定）
    int streakNumber;
    switch (goal.category) {
      case 'study':
        streakNumber = 3;
        break;
      case 'pc':
        streakNumber = 5;
        break;
      case 'smartphone':
        streakNumber = 1;
        break;
      case 'work':
        streakNumber = 2;
        break;
      default:
        streakNumber = goal.consecutiveAchievements;
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => GoalSettingDialog(
            isEdit: true,
            initialTitle: goal.title,
            initialCategory: goal.category,
            initialPeriod: goal.period,
            initialTargetHours: goal.targetHours,
            initialIsFocusedOnly: goal.isFocusedOnly,
            onDelete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal deleted successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
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
        percentage: goal.progress.clamp(0.0, 1.0),
        progressColor: color,
        daysText: daysText,
      ),
    );
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

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return period;
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
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.report);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  void _showAddEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddEditSelectionDialog(
        onCountdownAdd: () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => const CountdownSettingDialog(),
          );
        },
        onCountdownEdit: () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => CountdownSettingDialog(
              isEdit: true,
              initialEventName: activeCountdown.eventName,
              onDelete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Countdown deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          );
        },
        onGoalAdd: () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => const GoalSettingDialog(),
          );
        },
        onGoalEdit: () {
          Navigator.of(context).pop();
          // 最初のゴールを編集する（実際の実装では選択ダイアログを表示する）
          if (dummyGoals.isNotEmpty) {
            final goal = dummyGoals.first;
            showDialog(
              context: context,
              builder: (context) => GoalSettingDialog(
                isEdit: true,
                initialTitle: goal.title,
                initialCategory: goal.category,
                initialPeriod: goal.period,
                initialTargetHours: goal.targetHours,
                initialIsFocusedOnly: goal.isFocusedOnly,
                onDelete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Goal deleted successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
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
                  onTap: () => Navigator.of(context).pop(),
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
