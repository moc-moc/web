import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/level_badge.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';

class FriendLeaderboardScreen extends StatefulWidget {
  const FriendLeaderboardScreen({super.key});

  @override
  State<FriendLeaderboardScreen> createState() => _FriendLeaderboardScreenState();
}

class _FriendLeaderboardScreenState extends State<FriendLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_LeaderboardEntry> _levelEntries = [
    _LeaderboardEntry('Aurora Dev', '@aurora', LevelRankTier.diamond, 96, 228, false),
    _LeaderboardEntry('Code Sage', '@sage', LevelRankTier.platinum, 88, 201, false),
    _LeaderboardEntry('You', '@you', LevelRankTier.gold, 74, 160, true), // 自分のエントリ
    _LeaderboardEntry('FocusNinja', '@ninja', LevelRankTier.gold, 72, 155, false),
    _LeaderboardEntry('StudyWave', '@wave', LevelRankTier.silver, 60, 122, false),
  ];

  final List<_TimeLeaderboardEntry> _timeEntries = [
    _TimeLeaderboardEntry('HyperFocus', '@hyper', 672, false),
    _TimeLeaderboardEntry('DeepWork', '@deep', 610, false),
    _TimeLeaderboardEntry('You', '@you', 544, true), // 自分のエントリ
    _TimeLeaderboardEntry('NightOwl', '@owl', 520, false),
    _TimeLeaderboardEntry('CodeFlow', '@flow', 498, false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.white,
              indicatorColor: AppColors.blue,
              tabs: const [
                Tab(text: 'Level Ranking'),
                Tab(text: 'Total Time'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLevelTab(),
                  _buildTimeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Leaderboards',
              style: AppTextStyles.h3.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48), // symmetry
        ],
      ),
    );
  }

  Widget _buildLevelTab() {
    // 順位でソート（自分のエントリは位置を保持）
    final sortedEntries = List<_LeaderboardEntry>.from(_levelEntries);
    sortedEntries.sort((a, b) => b.level.compareTo(a.level));
    
    return ScrollableContent(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(sortedEntries.length, (index) {
          final entry = sortedEntries[index];
          final isCurrentUser = entry.isCurrentUser;
          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.blue.withValues(alpha: 0.15)
                  : AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: isCurrentUser
                    ? AppColors.blue.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isCurrentUser ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '#${index + 1}',
                    style: AppTextStyles.h3.copyWith(
                      color: isCurrentUser ? AppColors.blue : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                LevelBadge(
                  tier: entry.tier,
                  level: entry.level,
                  size: 56,
                  showGlow: true,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.name,
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                'You',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        entry.handle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.personHours}h',
                  style: AppTextStyles.h2.copyWith(
                    color: isCurrentUser ? AppColors.blue : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeTab() {
    // 順位でソート（自分のエントリは位置を保持）
    final sortedEntries = List<_TimeLeaderboardEntry>.from(_timeEntries);
    sortedEntries.sort((a, b) => b.totalHours.compareTo(a.totalHours));
    
    return ScrollableContent(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(sortedEntries.length, (index) {
          final entry = sortedEntries[index];
          final isCurrentUser = entry.isCurrentUser;
          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.blue.withValues(alpha: 0.15)
                  : AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: isCurrentUser
                    ? AppColors.blue.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isCurrentUser ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '#${index + 1}',
                    style: AppTextStyles.h3.copyWith(
                      color: isCurrentUser ? AppColors.blue : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.name,
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                'You',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        entry.handle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.totalHours}h',
                  style: AppTextStyles.h2.copyWith(
                    color: isCurrentUser ? AppColors.blue : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry(
    this.name,
    this.handle,
    this.tier,
    this.level,
    this.personHours,
    this.isCurrentUser,
  );

  final String name;
  final String handle;
  final LevelRankTier tier;
  final int level;
  final int personHours;
  final bool isCurrentUser;
}

class _TimeLeaderboardEntry {
  const _TimeLeaderboardEntry(
    this.name,
    this.handle,
    this.totalHours,
    this.isCurrentUser,
  );

  final String name;
  final String handle;
  final int totalHours;
  final bool isCurrentUser;
}


