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
import 'package:test_flutter/feature/countdown/countdown_model.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/presentation/widgets/entitlement_gate.dart';
import 'package:test_flutter/feature/setting/goal_memo_notifier.dart';

/// 目標画面（新デザインシステム版）
class GoalScreenNew extends ConsumerStatefulWidget {
  const GoalScreenNew({super.key});

  @override
  ConsumerState<GoalScreenNew> createState() => _GoalScreenNewState();
}

class _GoalScreenNewState extends ConsumerState<GoalScreenNew> {
  bool _isLoading = false; // 初期値はfalse（データ更新が必要な場合のみtrueになる）
  bool _hasError = false;
  String? _errorMessage;
  int? _pendingGoalToken;
  bool _hasInitialized = false; // 初期化済みフラグ

  @override
  void initState() {
    super.initState();
    // 初期状態をチェック（最初のフレーム後）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _hasInitialized = true;
        _handleGoalRefreshTrigger(ref.read(dataRefreshProvider));
      }
    });
  }

  Future<void> _loadGoalData() async {
    if (!mounted) return;
    await deleteExpiredCountdownsHelper(
      ref,
      context: context,
      mounted: mounted,
    );
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        loadGoalsWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [GoalScreen] Goals取得エラー: $e');
          return loadGoalsHelper(ref);
        }),
        loadCountdownsWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [GoalScreen] Countdown取得エラー: $e');
          return loadCountdownsHelper(ref);
        }),
      ]);
    } catch (e, stackTrace) {
      debugPrint('❌ [GoalScreen] データ取得エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'データの取得に失敗しました。';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleGoalRefreshTrigger(DataRefreshState state) {
    final token = state.goalToken;
    final ack = state.goalAckToken;
    
    // tokenが0または既に処理済みの場合は何もしない
    if (token == 0 || token == ack) {
      return;
    }
    
    // 既に同じtokenを処理中または処理済みの場合は何もしない
    if (_pendingGoalToken == token) {
      return;
    }
    
    // 他のtokenを処理中の場合は待つ
    if (_pendingGoalToken != null) {
      return;
    }
    
    // データ読み込みを開始
    _pendingGoalToken = token;
    _loadGoalData().whenComplete(() {
      if (!mounted) return;
      markGoalHandled(ref, token);
      _pendingGoalToken = null;
      
      // 処理完了後、新しい更新がないか確認（再帰呼び出しを削除）
      // 新しい更新はref.listenで検知されるため、再帰呼び出しは不要
    });
  }

  @override
  Widget build(BuildContext context) {
    // データ更新のリスナーを設定（build内でのみ使用可能）
    ref.listen<DataRefreshState>(
      dataRefreshProvider,
      (previous, next) {
        // 初回呼び出し（previous == null）はinitStateで処理済みなのでスキップ
        if (previous == null) {
          return;
        }

        // goalTokenに変化がなければ何もしない
        if (previous.goalToken == next.goalToken) {
          return;
        }

        _handleGoalRefreshTrigger(next);
      },
    );
    
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          ),
        ),
      );
    }

    if (_hasError) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 56),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage ?? 'データの取得に失敗しました',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    text: '再試行',
                    onPressed: _loadGoalData,
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final hasCountdownAccess = EntitlementRules.canUse(
      subscriptionStatus,
      PremiumFeature.countdown,
    );
    final hasMultiGoalAccess = EntitlementRules.canUse(
      subscriptionStatus,
      PremiumFeature.multipleGoals,
    );
    final goals = ref.watch(goalsListProvider);
    final isGoalLimitReached = !hasMultiGoalAccess && goals.isNotEmpty;

    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ScrollableContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // やる気の出る名言バナー
                  _buildQuoteSection(),

                  SizedBox(height: AppSpacing.md),

                  // 目標メモ
                  _buildGoalMemoSection(),

                  SizedBox(height: AppSpacing.md),

                  // カウントダウン表示
                  _buildCountdownSection(
                    context,
                    ref,
                    hasCountdownAccess,
                  ),

                  SizedBox(height: AppSpacing.md),

                  // 目標一覧
                  _buildGoalsList(context, goals),
                  if (isGoalLimitReached) ...[
                    SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: const PremiumLockCard(
                        feature: PremiumFeature.multipleGoals,
                      ),
                    ),
                  ],

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
                    _showAddEditDialog(
                      context,
                      ref,
                      hasCountdownAccess: hasCountdownAccess,
                    );
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 350,
                      ),
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

  Widget _buildCountdownSection(
    BuildContext context,
    WidgetRef ref,
    bool countdownUnlocked,
  ) {
    if (!countdownUnlocked) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: const PremiumLockCard(
          feature: PremiumFeature.countdown,
        ),
      );
    }
    final countdowns = ref.watch(countdownsListProvider);
    final levelState = ref.watch(levelingStateProvider);
    if (countdowns.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: RealtimeCountdownDisplay(
          eventName: 'Monthly reset',
          targetDate: levelState.nextResetAt,
          accentColor: AppColors.purple,
          borderColor: AppColors.purple.withValues(alpha: 0.35),
          backgroundColor: AppColors.blackgray,
        ),
      );
    }

    final now = DateTime.now();
    final activeCountdowns = countdowns
        .where((c) => c.targetDate.isAfter(now) && !c.isDeleted)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

    if (activeCountdowns.isEmpty) {
      return const SizedBox.shrink();
    }

    final accentPalette = [
      AppColors.blue,
      AppColors.orange,
      AppColors.purple,
      AppColors.green,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RealtimeCountdownDisplay(
            eventName: 'Monthly reset',
            targetDate: levelState.nextResetAt,
            accentColor: AppColors.purple,
            borderColor: AppColors.purple.withValues(alpha: 0.35),
            backgroundColor: AppColors.blackgray,
          ),
          SizedBox(height: AppSpacing.sm),
          ...List.generate(activeCountdowns.length, (index) {
            final countdown = activeCountdowns[index];
            final accent = accentPalette[index % accentPalette.length];
            final bottomPadding =
                index == activeCountdowns.length - 1 ? 0.0 : AppSpacing.sm;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: RealtimeCountdownDisplay(
                eventName: countdown.title,
                targetDate: countdown.targetDate,
                accentColor: accent,
                borderColor: accent.withValues(alpha: 0.35),
                backgroundColor: AppColors.black,
                titleColor: AppColors.white,
                labelColor: accent.withValues(alpha: 0.8),
                valueTextColor: AppColors.white,
                valueBackgroundColor: AppColors.middleblackgray,
                onEdit: () => _openCountdownEditor(context, ref, countdown),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, List<Goal> goals) {
    // 写真のデザインに合わせて、最初の4つの目標を表示
    final displayGoals = goals.take(4).toList();

    if (displayGoals.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
    final endDate =
        goal.periodEndDate ?? goal.startDate.add(Duration(days: goal.durationDays));
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

  /// 秒単位の値を表示用の文字列に変換（秒/分/時間単位）
  String _formatSecondsToDisplay(int seconds) {
    if (seconds < 60) {
      // 1分未満は秒単位で表示
      return '${seconds}s';
    }
    
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

  /// 目標メモセクション
  Widget _buildGoalMemoSection() {
    final memo = ref.watch(goalMemoProvider);
    final hasContent = memo.content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => _showGoalMemoDialog(),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.purple,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '目標メモ',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasContent) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        memo.content,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'タップして目標メモを追加',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.edit_outlined,
                color: AppColors.purple.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 目標メモ編集ダイアログを表示
  Future<void> _showGoalMemoDialog() async {
    final currentMemo = ref.read(goalMemoProvider);
    final controller = TextEditingController(text: currentMemo.content);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await showDialog(
      context: context,
      builder: (context) => AppDialogBase(
        title: '目標メモ',
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'あなたの目標やモチベーションを記録しましょう...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          SecondaryButton(
            text: 'キャンセル',
            onPressed: () => Navigator.of(context).pop(),
          ),
          PrimaryButton(
            text: '保存',
            onPressed: () async {
              final newContent = controller.text.trim();
              try {
                final newMemo = currentMemo.copyWith(
                  content: newContent,
                  lastModified: DateTime.now(),
                );
                ref.read(goalMemoProvider.notifier).updateMemo(newMemo);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('目標メモを保存しました'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('保存に失敗しました'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
    
    controller.dispose();
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
        NavigationHelper.pushReplacement(context, AppRoutes.friend);
        break;
      case 4:
        NavigationHelper.pushReplacement(context, AppRoutes.settings);
        break;
    }
  }

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool hasCountdownAccess,
  }) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext, rootNavigator: true);
        void openSubscription() {
          navigator.pop();
          navigator.pushNamed(AppRoutes.subscriptionNew);
        }

        return _AddEditSelectionDialog(
          countdownLocked: !hasCountdownAccess,
          countdownEditLocked: !hasCountdownAccess,
          onCountdownAdd: () {
            if (!hasCountdownAccess) {
              openSubscription();
              return;
            }
            navigator.pop();
            _openCountdownCreationDialog(context);
          },
          onCountdownEdit: () {
            if (!hasCountdownAccess) {
              openSubscription();
              return;
            }
            navigator.pop();
            _showCountdownEditPicker(context, ref);
          },
          onGoalAdd: () {
            navigator.pop();
            showDialog(
              context: context,
              builder: (context) => const GoalSettingDialog(),
            );
          },
          onGoalEdit: () {
            navigator.pop();
            _showGoalEditPicker(context, ref);
          },
        );
      },
    );
  }

  void _openCountdownCreationDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => const CountdownSettingDialog(),
    );
  }

  void _openCountdownEditor(
      BuildContext context, WidgetRef ref, Countdown countdown) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => CountdownSettingDialog(
        isEdit: true,
        countdownId: countdown.id,
        initialEventName: countdown.title,
        initialDate: countdown.targetDate,
      ),
    );
  }

  void _showCountdownEditPicker(BuildContext context, WidgetRef ref) {
    final countdowns = ref.read(countdownsListProvider);
    final now = DateTime.now();
    final activeCountdowns = countdowns
        .where((c) => c.targetDate.isAfter(now) && !c.isDeleted)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

    if (activeCountdowns.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('編集できるカウントダウンがありません'),
            backgroundColor: AppColors.gray,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CountdownPickerDialog(
        countdowns: activeCountdowns,
        onCountdownSelected: (countdown) {
          Navigator.of(context).pop();
          _openCountdownEditor(context, ref, countdown);
        },
      ),
    );
  }

  void _showGoalEditPicker(BuildContext context, WidgetRef ref) {
    final goals = ref.read(goalsListProvider);

    if (goals.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('編集できる目標がありません'),
            backgroundColor: AppColors.gray,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _GoalPickerDialog(
        goals: goals,
        onGoalSelected: (goal) {
          Navigator.of(context).pop();
          _openGoalEditor(context, ref, goal);
        },
      ),
    );
  }

  void _openGoalEditor(
      BuildContext context, WidgetRef ref, Goal goal) {
    if (!mounted) return;
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
}

/// 追加/編集選択ダイアログ
class _AddEditSelectionDialog extends StatelessWidget {
  final VoidCallback onCountdownAdd;
  final VoidCallback onCountdownEdit;
  final VoidCallback onGoalAdd;
  final VoidCallback onGoalEdit;
  final bool countdownLocked;
  final bool countdownEditLocked;

  const _AddEditSelectionDialog({
    required this.onCountdownAdd,
    required this.onCountdownEdit,
    required this.onGoalAdd,
    required this.onGoalEdit,
    this.countdownLocked = false,
    this.countdownEditLocked = false,
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
              isLocked: countdownLocked,
            ),
            SizedBox(height: AppSpacing.md),
            _buildOptionButton(
              context: context,
              icon: Icons.edit,
              label: 'Edit Countdown',
              iconColor: AppColors.purple,
              onTap: onCountdownEdit,
              isLocked: countdownEditLocked,
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
    bool isLocked = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isLocked
                ? AppColors.lightblackgray.withValues(alpha: 0.5)
                : AppColors.lightblackgray,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLocked
                  ? AppColors.gray.withValues(alpha: 0.2)
                  : AppColors.gray.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLocked ? AppColors.textSecondary : iconColor,
                size: 24,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.white,
                  ),
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.chevron_right,
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

class _CountdownPickerDialog extends StatelessWidget {
  final List<Countdown> countdowns;
  final ValueChanged<Countdown> onCountdownSelected;

  const _CountdownPickerDialog({
    required this.countdowns,
    required this.onCountdownSelected,
  });

  String _formatCountdownDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}/${two(date.month)}/${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: 'Select Countdown',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: countdowns
            .map(
              (countdown) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  color: AppColors.lightblackgray,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: ListTile(
                    onTap: () => onCountdownSelected(countdown),
                    title: Text(
                      countdown.title,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _formatCountdownDate(countdown.targetDate),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GoalPickerDialog extends StatelessWidget {
  final List<Goal> goals;
  final ValueChanged<Goal> onGoalSelected;

  const _GoalPickerDialog({
    required this.goals,
    required this.onGoalSelected,
  });

  String _getCategoryLabel(DetectionItem item) {
    switch (item) {
      case DetectionItem.book:
        return 'Study';
      case DetectionItem.pc:
        return 'Computer';
      case DetectionItem.smartphone:
        return 'Smartphone';
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

  String _formatGoalInfo(Goal goal) {
    final category = _getCategoryLabel(goal.detectionItem);
    final periodLabel = _getPeriodLabelFromDurationDays(goal.durationDays);
    return '$category • $periodLabel';
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: 'Select Goal',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: goals
            .map(
              (goal) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  color: AppColors.lightblackgray,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: ListTile(
                    onTap: () => onGoalSelected(goal),
                    title: Text(
                      goal.title,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _formatGoalInfo(goal),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
