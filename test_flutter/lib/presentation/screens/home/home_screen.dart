import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/leveling/level_reset_service.dart';
import 'package:test_flutter/presentation/widgets/level_progress_card.dart';
import 'package:test_flutter/feature/tracking/tracking_limit_providers.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/data/services/tracking_count_debug_service.dart';

/// ホーム画面（新デザインシステム版）
class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

/// 画面サイズの分類
enum ScreenSize { small, medium, large }

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  bool _isLoading = false; // 初期値はfalse（データ更新が必要な場合のみtrueになる）
  bool _hasError = false;
  String? _errorMessage;
  int? _pendingHomeToken;
  bool _hasInitialized = false; // 初期化済みフラグ
  bool _hasCheckedLevelReset = false;

  // #region agent log
  static void _log(String location, String message, Map<String, dynamic> data, String hypothesisId) {
    // 非同期で実行してブロックを防ぐ
    Future.microtask(() async {
      try {
        final logFile = File('/Users/ki/Documents/書類 - ItoのMacBook Air/GitHub/web/test_flutter/.cursor/debug.log');
        final logEntry = jsonEncode({
          'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'location': location,
          'message': message,
          'data': data,
          'sessionId': 'debug-session',
          'runId': 'run1',
          'hypothesisId': hypothesisId,
        });
        await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
      } catch (e) {
        // ログ書き込みエラーは無視
      }
    });
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    
    // 一度だけリトライキューをクリア（古い不正なデータを削除）
    TrackingCountDebugService.clearRetryQueue();
    
    // 初期状態をチェック（最初のフレーム後）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _hasInitialized = true;
        _handleHomeRefreshTrigger(ref.read(dataRefreshProvider));
      }
    });
  }

  /// Firestoreからデータを取得してProviderを更新
  /// 
  /// アプリ起動時に`loadCriticalData()`でデータが取得されている可能性がありますが、
  /// 確実にデータを取得するために、ここでもデータを取得します。
  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // 並列でデータを同期（Firestoreとローカルを同期してからProviderを更新）
      await Future.wait([
        loadTotalDataWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [HomeScreen] TotalData取得エラー: $e');
          return loadTotalDataHelper(ref);
        }),
        loadStreakDataWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [HomeScreen] StreakData取得エラー: $e');
          return loadStreakDataHelper(ref);
        }),
        loadGoalsWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [HomeScreen] Goals取得エラー: $e');
          return loadGoalsHelper(ref);
        }),
        loadCountdownsWithBackgroundRefreshHelper(ref).catchError((e) {
          debugPrint('❌ [HomeScreen] Countdown取得エラー: $e');
          return loadCountdownsHelper(ref);
        }),
      ], eagerError: false);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await _maybeHandleLevelReset();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [HomeScreen] データ取得エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'データの取得に失敗しました。オフラインの可能性があります。';
        });
      }
    }
  }

  Future<void> _maybeHandleLevelReset() async {
    if (_hasCheckedLevelReset || !mounted) {
      return;
    }
    _hasCheckedLevelReset = true;
    await LevelResetService.ensureMonthlyReset(
      ref: ref,
      context: context,
      mounted: mounted,
    );
  }

  void _handleHomeRefreshTrigger(DataRefreshState state) {
    final token = state.homeToken;
    final ack = state.homeAckToken;

    // tokenが0または既に処理済みの場合は何もしない
    if (token == 0 || token == ack) {
      return;
    }

    // 既に同じtokenを処理中または処理済みの場合は何もしない
    if (_pendingHomeToken == token) {
      return;
    }

    // 他のtokenを処理中の場合は待つ
    if (_pendingHomeToken != null) {
      return;
    }

    // データ読み込みを開始
    _pendingHomeToken = token;
    _loadData().whenComplete(() {
      if (!mounted) return;
      markHomeHandled(ref, token);
      _pendingHomeToken = null;

      // 処理完了後、新しい更新がないか確認（再帰呼び出しを削除）
      // 新しい更新はref.listenで検知されるため、再帰呼び出しは不要
    });
  }

  /// 画面サイズを判定
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    return ScreenSize.large;
  }

  /// レスポンシブな水平パディングを取得
  double _getHorizontalPadding(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
        return AppSpacing.sm;
      case ScreenSize.medium:
        return AppSpacing.md;
      case ScreenSize.large:
        return AppSpacing.lg;
    }
  }

  /// レスポンシブなコンテンツの最大幅を取得
  double? _getMaxContentWidth(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
      case ScreenSize.medium:
        return null; // 制限なし
      case ScreenSize.large:
        return 800; // 大画面では最大800pxに制限
    }
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

        // homeTokenに変化がなければ何もしない
        if (previous.homeToken == next.homeToken) {
          return;
        }

        _handleHomeRefreshTrigger(next);
      },
    );
    
    // ローディング中はローディング表示
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.blue),
                SizedBox(height: AppSpacing.md),
                Text(
                  'データを読み込んでいます...',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // エラー時はエラーメッセージとリトライボタンを表示
    if (_hasError) {
      return AppScaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 64,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage ?? 'データの取得に失敗しました',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    text: '再試行',
                    onPressed: () => _loadData(),
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final screenSize = _getScreenSize(context);
    final maxWidth = _getMaxContentWidth(screenSize);

    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        bottom: false,
        top: true,
        left: true,
        right: true,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                // 画面サイズに応じた高さの比率を調整
                final levelHeight = screenSize == ScreenSize.large ? 0.10 : 0.12;
                final statsHeight = screenSize == ScreenSize.large ? 0.12 : 0.10;
                final settingsHeight = screenSize == ScreenSize.large ? 0.07 : 0.06;
                final startHeight = screenSize == ScreenSize.large ? 0.09 : 0.08;

                // スペーシングも画面サイズに応じて調整
                final spacing1 = screenSize == ScreenSize.large ? 0.015 : 0.01;
                final spacing2 = screenSize == ScreenSize.large ? 0.015 : 0.01;
                final spacing3 = screenSize == ScreenSize.large ? 0.015 : 0.01;
                final spacing4 = screenSize == ScreenSize.large ? 0.015 : 0.01;
                final spacing5 = screenSize == ScreenSize.large ? 0.015 : 0.01;

                // 固定部分の合計（今日の目標を除く）
                final fixedHeight = levelHeight + spacing1 + statsHeight + spacing2 +
                                   settingsHeight + spacing3 + spacing4 + startHeight + spacing5;
                // 今日の目標の高さ（残りを割り当て、合計100%になるように）
                final goalsHeight = screenHeight * (1.0 - fixedHeight);

                // デバッグ: レイアウト計算を確認
                debugPrint('📐 [HomeScreen] レイアウト計算: screenHeight=$screenHeight, fixedHeight=$fixedHeight, goalsHeight=$goalsHeight');

                // #region agent log
                _log('home_screen.dart:285', 'layout calculation', {
                  'screenHeight': screenHeight,
                  'screenSize': screenSize.toString(),
                  'levelHeight': levelHeight,
                  'statsHeight': statsHeight,
                  'settingsHeight': settingsHeight,
                  'startHeight': startHeight,
                  'spacing1': spacing1,
                  'spacing2': spacing2,
                  'spacing3': spacing3,
                  'spacing4': spacing4,
                  'spacing5': spacing5,
                  'fixedHeight': fixedHeight,
                  'goalsHeight': goalsHeight,
                  'totalRatio': fixedHeight + spacing3 + (goalsHeight / screenHeight),
                  'isFixedHeightOver1': fixedHeight > 1.0,
                  'isGoalsHeightNegative': goalsHeight < 0,
                  'isTotalOver1': (fixedHeight + spacing3 + (goalsHeight / screenHeight)) > 1.0,
                }, 'H1');
                // #endregion

                return Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: screenHeight * levelHeight,
                        child: _buildLevelSection(screenSize),
                      ),
                      SizedBox(height: screenHeight * spacing1),

                      // 統計表示セクション
                      SizedBox(
                        height: screenHeight * statsHeight,
                        child: _buildStatsSection(screenSize),
                      ),

                      SizedBox(height: screenHeight * spacing2),

                      // 今日の目標表示セクション（3つ表示される場合の高さに固定）
                      SizedBox(
                        height: goalsHeight,
                        child: _buildTodaysGoalsSection(screenSize),
                      ),

                      SizedBox(height: screenHeight * spacing3),

                      // 設定ボタン
                      SizedBox(
                        height: screenHeight * settingsHeight,
                        child: _buildSettingsButton(context, screenSize),
                      ),

                      SizedBox(height: screenHeight * spacing4),

                      // スタートボタン
                      SizedBox(
                        height: screenHeight * startHeight,
                        child: _buildStartButton(context, screenSize),
                      ),

                      SizedBox(height: screenHeight * spacing5),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection(ScreenSize screenSize) {
    final levelState = ref.watch(levelingStateProvider);
    final horizontalPadding = _getHorizontalPadding(screenSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              height: constraints.maxHeight,
              child: LevelProgressCard(
                state: levelState,
                showCountdown: false,
              ),
            ),
          ),
        );
      },
    );
  }


  /// 統計表示セクション
  Widget _buildStatsSection(ScreenSize screenSize) {
    final horizontalPadding = _getHorizontalPadding(screenSize);
    final cardSpacing = screenSize == ScreenSize.large ? AppSpacing.sm : AppSpacing.xs;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildTotalFocusedTimeCard()),
                        SizedBox(width: cardSpacing),
                        Expanded(child: _buildStreakDaysCard()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalFocusedTimeCard() {
    final totalData = ref.watch(totalDataProvider);
    final totalMinutes = totalData.totalWorkTimeMinutes;
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    final totalTimeDisplay = totalHours > 0
        ? '${totalHours}h ${remainingMinutes.toString().padLeft(2, '0')}m'
        : '${remainingMinutes}m';
    const accentColor = AppColors.blue;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final iconSize = cardHeight * 0.2;
        final titleFontSize = cardHeight * 0.12;
        final valueFontSize = cardHeight * 0.28;
        final captionFontSize = cardHeight * 0.11;
        final spacing = cardHeight * 0.02;
        
        return Container(
          height: cardHeight,
          padding: EdgeInsets.all(cardHeight * 0.08),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.blue.withValues(alpha: 0.9),
                    size: iconSize,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Total Time',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    totalTimeDisplay,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: valueFontSize,
                      color: accentColor,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Text(
                'Keep going!',
                style: AppTextStyles.caption.copyWith(
                  color: accentColor,
                  fontSize: captionFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakDaysCard() {
    final streakData = ref.watch(streakDataProvider);
    const accentColor = AppColors.orange;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final iconSize = cardHeight * 0.2;
        final titleFontSize = cardHeight * 0.12;
        final valueFontSize = cardHeight * 0.28;
        final captionFontSize = cardHeight * 0.11;
        final spacing = cardHeight * 0.02;
        
        return Container(
          height: cardHeight,
          padding: EdgeInsets.all(cardHeight * 0.08),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.orange,
                    size: iconSize,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Streak Days',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${streakData.currentStreak}',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: valueFontSize,
                          color: accentColor,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: valueFontSize * 0.125,
                          bottom: valueFontSize * 0.125,
                        ),
                        child: Text(
                          'days',
                          style: AppTextStyles.h2.copyWith(
                            fontSize: valueFontSize * 0.7,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Text(
                'Keep the flame alive!',
                style: AppTextStyles.caption.copyWith(
                  color: accentColor,
                  fontSize: captionFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 今日の目標表示セクション
  /// トラッキング設定で選択された目標のみを表示（最大3つ）
  Widget _buildTodaysGoalsSection(ScreenSize screenSize) {
    final goals = ref.watch(goalsListProvider);
    final settings = ref.watch(trackingSettingsProvider);
    final horizontalPadding = _getHorizontalPadding(screenSize);
    final containerPadding = screenSize == ScreenSize.large ? AppSpacing.md : AppSpacing.sm;
    final titleFontSize = screenSize == ScreenSize.large ? 13.0 : 11.0;

    // 選択された目標IDを取得
    final selectedStudyGoalId = settings.selectedStudyGoalId;
    final selectedPcGoalId = settings.selectedPcGoalId;
    final selectedSmartphoneGoalId = settings.selectedSmartphoneGoalId;

    // #region agent log
    _log('home_screen.dart:610', 'goals section build start', {
      'totalGoals': goals.length,
      'selectedStudyGoalId': selectedStudyGoalId,
      'selectedPcGoalId': selectedPcGoalId,
      'selectedSmartphoneGoalId': selectedSmartphoneGoalId,
    }, 'H4');
    // #endregion

    final todaysGoals = <Goal>[];

    // Study目標（選択されている場合のみ）
    if (selectedStudyGoalId != null) {
      try {
        final studyGoal = goals.firstWhere(
          (g) => g.id == selectedStudyGoalId && g.detectionItem == DetectionItem.book,
        );
        todaysGoals.add(studyGoal);
      } catch (e) {
        // 目標が見つからない場合は無視
      }
    }

    // PC目標（選択されている場合のみ）
    if (selectedPcGoalId != null && todaysGoals.length < 3) {
      try {
        final pcGoal = goals.firstWhere(
          (g) => g.id == selectedPcGoalId && g.detectionItem == DetectionItem.pc,
        );
        todaysGoals.add(pcGoal);
      } catch (e) {
        // 目標が見つからない場合は無視
      }
    }

    // Smartphone目標（選択されている場合のみ）
    if (selectedSmartphoneGoalId != null && todaysGoals.length < 3) {
      try {
        final smartphoneGoal = goals.firstWhere(
          (g) => g.id == selectedSmartphoneGoalId && g.detectionItem == DetectionItem.smartphone,
        );
        todaysGoals.add(smartphoneGoal);
      } catch (e) {
        // 目標が見つからない場合は無視
      }
    }

    // #region agent log
    _log('home_screen.dart:660', 'goals filtered', {
      'todaysGoalsCount': todaysGoals.length,
      'isEmpty': todaysGoals.isEmpty,
    }, 'H4');
    // #endregion

    // デバッグ: 目標データを確認
    debugPrint('🎯 [HomeScreen] 目標セクション: todaysGoals.length=${todaysGoals.length}, isEmpty=${todaysGoals.isEmpty}');
    debugPrint('🎯 [HomeScreen] 選択された目標ID: Study=$selectedStudyGoalId, PC=$selectedPcGoalId, Smartphone=$selectedSmartphoneGoalId');
    debugPrint('🎯 [HomeScreen] 全目標数: ${goals.length}');

    if (todaysGoals.isEmpty) {
      debugPrint('⚠️ [HomeScreen] 目標が空のため、SizedBox.shrink()を返します');
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.lightblackgray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Goals',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: titleFontSize,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final cardHeight = availableHeight / todaysGoals.length.clamp(1, 3);

                // #region agent log
                _log('home_screen.dart:687', 'goals layout calculation', {
                  'availableHeight': availableHeight,
                  'todaysGoalsCount': todaysGoals.length,
                  'cardHeight': cardHeight,
                  'isAvailableHeightZero': availableHeight <= 0,
                  'isAvailableHeightNegative': availableHeight < 0,
                }, 'H4');
                // #endregion

                return Column(
                  children: todaysGoals.map((goal) => SizedBox(
                    height: cardHeight,
                    child: _buildGoalCard(goal),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 目標カードを構築（その日の達成時間を目標のtodayAchievedTimeから取得）
  Widget _buildGoalCard(Goal goal) {
    final category = _getCategoryFromDetectionItem(goal.detectionItem);
    final color = _getGoalColor(category);
    
    // その日の達成時間（秒単位）を目標のtodayAchievedTimeから取得
    final todaySeconds = goal.todayAchievedTime ?? 0;
        
        // 目標時間は1日換算データを使用（goal.targetSecondsPerDay）
        final targetSecondsPerDay = goal.targetSecondsPerDay;
        
        // 時間フォーマット（表示時に変換、秒単位で処理）
        final currentValue = _formatSecondsToDisplay(todaySeconds);
        final targetValue = _formatSecondsToDisplay(targetSecondsPerDay);
        
        // 進捗率の計算（秒単位で計算）
        final percentage = targetSecondsPerDay > 0 
            ? (todaySeconds / targetSecondsPerDay).clamp(0.0, 1.0)
            : 0.0;
        
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xs),
          child: GoalProgressCard(
            goalName: goal.title,
            percentage: percentage,
            currentValue: currentValue,
            targetValue: targetValue,
            progressColor: color,
            labelColor: color,
            borderColor: color.withValues(alpha: 0.4),
            backgroundColor: color.withValues(alpha: 0.1),
            barBackgroundColor: AppColors.disabledGray.withValues(alpha: 0.2),
          ),
        );
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
    }

    final h = minutes ~/ 60;
    final m = minutes % 60;
    final minuteText = m.toString().padLeft(2, '0');
    return '${h}h ${minuteText}m';
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

  /// 設定ボタン
  Widget _buildSettingsButton(BuildContext context, ScreenSize screenSize) {
    final borderRadius = BorderRadius.circular(AppRadius.small);
    final horizontalPadding = _getHorizontalPadding(screenSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonHeight = constraints.maxHeight;
        final iconSize = buttonHeight * 0.4;
        final fontSize = buttonHeight * (screenSize == ScreenSize.large ? 0.28 : 0.25);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () {
                NavigationHelper.push(context, AppRoutes.trackingSettingNew);
              },
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.lightblackgray.withValues(alpha: 0.2),
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AppColors.gray.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: buttonHeight * 0.1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: AppColors.lightblackgray,
                        borderRadius: BorderRadius.circular(iconSize / 2),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.textSecondary,
                        size: iconSize * 0.5,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Settings',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.white,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// スタートボタン
  Widget _buildStartButton(BuildContext context, ScreenSize screenSize) {
    final borderRadius = BorderRadius.circular(AppRadius.small);
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final remainingCount = ref.watch(remainingTrackingCountProvider);
    final canStart = ref.watch(canStartTrackingProvider);
    final horizontalPadding = _getHorizontalPadding(screenSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonHeight = constraints.maxHeight;
        final iconSize = buttonHeight * 0.4;
        final fontSize = buttonHeight * (screenSize == ScreenSize.large ? 0.28 : 0.25);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () {
                if (!canStart) {
                  // 4回目（制限超過）の場合は課金画面に遷移
                  NavigationHelper.push(context, AppRoutes.subscriptionNew);
                } else {
                  NavigationHelper.push(context, AppRoutes.trackingNew);
                }
              },
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: buttonHeight * 0.1,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(iconSize / 2),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.blue,
                                AppColors.purple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.white,
                            size: iconSize * 0.56,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Start Tracking',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                    // 残り回数表示（無料プランの場合のみ）
                    if (!subscriptionStatus.hasPremiumAccess && remainingCount >= 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: buttonHeight * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: remainingCount > 0
                                ? AppColors.blue.withValues(alpha: 0.8)
                                : AppColors.error.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '残り回数',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontSize: fontSize * 0.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: fontSize * 0.08),
                              Text(
                                remainingCount > 0 ? '$remainingCount' : '0',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontSize: fontSize * 0.9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getGoalColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      default:
        return AppColors.blue;
    }
  }
  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 0,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 0) return;
    switch (index) {
      case 1:
        NavigationHelper.pushReplacement(context, AppRoutes.goal);
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
}
