import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';
import 'package:test_flutter/presentation/widgets/navigation/navigation_helper.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/statistics/statistics_aggregation_service.dart';
import 'package:test_flutter/feature/tracking/state_management.dart';
import 'package:test_flutter/feature/setting/tracking_settings_notifier.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';
import 'package:test_flutter/feature/streak/streak_data_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// トラッキング終了画面（新デザインシステム版）
class TrackingFinishedScreenNew extends ConsumerStatefulWidget {
  const TrackingFinishedScreenNew({super.key});

  @override
  ConsumerState<TrackingFinishedScreenNew> createState() => _TrackingFinishedScreenNewState();
}

class _TrackingFinishedScreenNewState extends ConsumerState<TrackingFinishedScreenNew> {
  SessionInfo? _sessionInfo;
  bool _isLoading = true;
  final StatisticsAggregationService _aggregationService = StatisticsAggregationService();
  final StreakDataManager _streakManager = StreakDataManager();
  bool _isAggregating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator引数からSessionInfoを取得
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is SessionInfo) {
      _sessionInfo = arguments;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // 画面表示後に集計処理を開始（バックグラウンドで実行）
        _aggregateSessionData(_sessionInfo!);
        }
    } else {
      // 引数がない場合はエラー表示
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// セッションデータの集計処理
  /// 
  /// 画面表示後にバックグラウンドで実行されます。
  Future<void> _aggregateSessionData(SessionInfo sessionInfo) async {
    if (_isAggregating) return;
    
    setState(() {
      _isAggregating = true;
    });

    try {
      // SessionInfoをTrackingSessionに変換（統計集計サービス用）
      final trackingSession = TrackingSession(
        id: sessionInfo.id,
        startTime: sessionInfo.startTime,
        endTime: sessionInfo.endTime,
        categorySeconds: Map<String, int>.from(sessionInfo.categorySeconds),
        detectionPeriods: List<DetectionPeriod>.from(sessionInfo.detectionPeriods),
        lastModified: sessionInfo.lastModified,
      );
      
      // 統計集計処理を実行
      final success = await _aggregationService.aggregateSessionData(trackingSession);
      
      // ストリーク更新を実行
      try {
        await _streakManager.trackFinished();
      } catch (e) {
        LogMk.logError(
          '❌ ストリーク更新エラー: $e',
          tag: 'TrackingFinishedScreen._aggregateSessionData',
        );
      }
      
      if (!success && mounted) {
        // エラー時はユーザーに通知
        showSnackBarMessage(
          context,
          '統計データの更新中にエラーが発生しました',
          mounted: mounted,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          '統計データの更新中にエラーが発生しました',
          mounted: mounted,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAggregating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final sessionInfo = _sessionInfo;
    if (sessionInfo == null) {
      return AppScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: Center(
          child: Text(
            'セッションデータが見つかりません',
            style: AppTextStyles.body1,
          ),
        ),
      );
    }
    
    // SessionInfoをTrackingSessionに変換（表示用）
    final session = TrackingSession(
      id: sessionInfo.id,
      startTime: sessionInfo.startTime,
      endTime: sessionInfo.endTime,
      categorySeconds: Map<String, int>.from(sessionInfo.categorySeconds),
      detectionPeriods: List<DetectionPeriod>.from(sessionInfo.detectionPeriods),
      lastModified: sessionInfo.lastModified,
    );

    return AppScaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: ScrollableContent(
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCongratulations(),
              _buildTimeRange(session),
              _buildSummaryCards(session),
              _buildBreakdownCard(session),
              _buildGoalUpdates(session),
              SizedBox(height: AppSpacing.md),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratulations() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withValues(alpha: 0.3),
            AppColors.purple.withValues(alpha: 0.3),
            AppColors.green.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Great Work!',
        style: AppTextStyles.h1.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRange(TrackingSession session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.gray,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            _formatTimeRange(session),
            style: AppTextStyles.body1.copyWith(
              color: AppColors.gray,
              fontFeatures: [const FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TrackingSession session) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.blue,
                icon: Icons.timer_rounded,
                title: 'Session Total',
                value: '${session.duration.inSeconds}秒',
                subtitle: '',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                accentColor: AppColors.orange,
                icon: Icons.work_history_rounded,
                title: 'Work Total',
                value: '${(session.categorySeconds['study'] ?? 0) + (session.categorySeconds['pc'] ?? 0)}秒',
                subtitle: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required Color accentColor,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 30),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: accentColor,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(TrackingSession session) {
    final categories = [
      _CategoryStat(
        label: 'Study',
        icon: Icons.menu_book,
        color: AppColors.green,
        hours: session.getStudyHours(),
      ),
      _CategoryStat(
        label: 'Computer',
        icon: Icons.computer,
        color: AppColors.blue,
        hours: session.getPcHours(),
      ),
      _CategoryStat(
        label: 'Smartphone',
        icon: Icons.smartphone,
        color: AppColors.orange,
        hours: session.getSmartphoneHours(),
      ),
      _CategoryStat(
        label: 'People',
        icon: Icons.person,
        color: AppColors.gray,
        hours: session.getPersonOnlyHours(),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[0]),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildCategoryCard(categories[1]),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(categories[2]),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildCategoryCard(categories[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryStat data) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: data.color.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 24,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            data.label,
            style: AppTextStyles.body2.copyWith(
              color: data.color.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${(data.hours * 3600).round()}秒',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: data.color,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalUpdates(TrackingSession session) {
    final goals = ref.watch(goalsListProvider);
    final settings = ref.watch(trackingSettingsProvider);
    
    // 選択された目標IDを取得
    final selectedStudyGoalId = settings.selectedStudyGoalId;
    final selectedPcGoalId = settings.selectedPcGoalId;
    final selectedSmartphoneGoalId = settings.selectedSmartphoneGoalId;
    
    // 各カテゴリーの目標を取得
    final studyGoals = goals.where((g) => g.detectionItem == DetectionItem.book).toList();
    final pcGoals = goals.where((g) => g.detectionItem == DetectionItem.pc).toList();
    final smartphoneGoals = goals.where((g) => g.detectionItem == DetectionItem.smartphone).toList();
    
    // 選択された目標を取得（存在しない場合は最初の目標を自動選択）
    final todaysGoals = <Goal>[];
    
    // Study目標
    if (studyGoals.isNotEmpty) {
      Goal? studyGoal;
      if (selectedStudyGoalId != null) {
        studyGoal = studyGoals.firstWhere(
          (g) => g.id == selectedStudyGoalId,
          orElse: () => studyGoals[0],
        );
      } else {
        studyGoal = studyGoals[0];
      }
      todaysGoals.add(studyGoal);
    }
    
    // PC目標
    if (pcGoals.isNotEmpty) {
      Goal? pcGoal;
      if (selectedPcGoalId != null) {
        pcGoal = pcGoals.firstWhere(
          (g) => g.id == selectedPcGoalId,
          orElse: () => pcGoals[0],
        );
      } else {
        pcGoal = pcGoals[0];
      }
      todaysGoals.add(pcGoal);
    }
    
    // Smartphone目標
    if (smartphoneGoals.isNotEmpty) {
      Goal? smartphoneGoal;
      if (selectedSmartphoneGoalId != null) {
        smartphoneGoal = smartphoneGoals.firstWhere(
          (g) => g.id == selectedSmartphoneGoalId,
          orElse: () => smartphoneGoals[0],
        );
      } else {
        smartphoneGoal = smartphoneGoals[0];
      }
      todaysGoals.add(smartphoneGoal);
    }
    
    if (todaysGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    // 秒単位でカテゴリ別時間を取得
    final plusSecondsByCategory = <String, int>{
      'study': session.categorySeconds['study'] ?? 0,
      'pc': session.categorySeconds['pc'] ?? 0,
      'smartphone': session.categorySeconds['smartphone'] ?? 0,
      'person': session.categorySeconds['personOnly'] ?? 0,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Goal Progress',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          ...todaysGoals.asMap().entries.map((entry) {
            final goal = entry.value;
            final category = _getCategoryFromDetectionItem(goal.detectionItem);
            // 秒単位で計算
            final plusSeconds = plusSecondsByCategory[category] ?? 0;
            final previousSeconds = goal.achievedTime ?? 0;
            final targetSeconds = goal.targetTime;
            // パーセンテージ計算（秒単位で計算）
            final previousPercent = targetSeconds > 0
                ? (previousSeconds / targetSeconds * 100).clamp(0.0, 999.0)
                : 0.0;
            final plusPercent = targetSeconds > 0
                ? (plusSeconds / targetSeconds * 100).clamp(0.0, 999.0)
                : 0.0;

            final isLast = entry.key == todaysGoals.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: _buildGoalUpdateRow(
                goal: goal,
                category: category,
                previousSeconds: previousSeconds,
                previousPercent: previousPercent,
                plusSeconds: plusSeconds,
                plusPercent: plusPercent,
                targetSeconds: targetSeconds,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalUpdateRow({
    required Goal goal,
    required String category,
    required int previousSeconds,
    required double previousPercent,
    required int plusSeconds,
    required double plusPercent,
    required int targetSeconds,
  }) {
    final color = _getGoalColor(category);
    // 秒単位で計算
    final afterSeconds = previousSeconds + plusSeconds;
    final afterPercent = targetSeconds > 0
        ? (afterSeconds / targetSeconds * 100).clamp(0.0, 999.0)
        : 0.0;
    final progress = targetSeconds > 0
        ? (afterSeconds / targetSeconds).clamp(0.0, 1.0)
        : 0.0;
    
    // 表示用に時間単位に変換
    final targetHours = targetSeconds / 3600.0;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 1.0),
                ),
              ),
              Text(
                '目標: ${targetHours.toStringAsFixed(1)}h',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          LinearProgressBar(
            percentage: progress,
            height: 12,
            progressColor: color,
            backgroundColor: AppColors.blackgray,
            barBackgroundColor: AppColors.gray.withValues(alpha: 0.4),
            showFlowAnimation: false,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '$previousSeconds秒 → $afterSeconds秒',
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+$plusSeconds秒',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${previousPercent.toStringAsFixed(1)}% → ${afterPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.body2,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+${plusPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.body2.copyWith(
                      color: color.withValues(alpha: 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context) {
    final borderRadiusValue = BorderRadius.circular(30.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.gray.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Material(
              color: AppColors.blackgray,
              borderRadius: borderRadiusValue,
              elevation: 2,
              shadowColor: AppColors.black.withValues(alpha: 0.2),
              child: InkWell(
                onTap: () {
                  // 将来実装
                },
                borderRadius: borderRadiusValue,
                child: Container(
                  height: 56.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: AppColors.gray,
                          size: 18.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Share on Social Media',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: AppColors.blue.withValues(alpha: 0.5),
              borderRadius: borderRadiusValue,
              elevation: 4,
              shadowColor: AppColors.blue.withValues(alpha: 0.3),
              child: InkWell(
                onTap: () {
                  NavigationHelper.pushAndRemoveUntil(
                    context,
                    AppRoutes.home,
                  );
                },
                borderRadius: borderRadiusValue,
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 20.0,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'OK',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  String _formatTimeRange(TrackingSession session) {
    final start = _formatTime(session.startTime);
    final end = _formatTime(session.endTime);
    return '$start - $end';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _CategoryStat {
  const _CategoryStat({
    required this.label,
    required this.icon,
    required this.color,
    required this.hours,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double hours;
}
