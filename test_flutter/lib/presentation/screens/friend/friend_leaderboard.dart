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
    _LeaderboardEntry('Aurora Dev', '@aurora', LevelRankTier.diamond, 96, 228),
    _LeaderboardEntry('Code Sage', '@sage', LevelRankTier.platinum, 88, 201),
    _LeaderboardEntry('FocusNinja', '@ninja', LevelRankTier.gold, 74, 160),
    _LeaderboardEntry('StudyWave', '@wave', LevelRankTier.silver, 60, 122),
  ];

  final List<_TimeLeaderboardEntry> _timeEntries = [
    _TimeLeaderboardEntry('HyperFocus', '@hyper', 672),
    _TimeLeaderboardEntry('DeepWork', '@deep', 610),
    _TimeLeaderboardEntry('NightOwl', '@owl', 544),
    _TimeLeaderboardEntry('CodeFlow', '@flow', 498),
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
    return ScrollableContent(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(_levelEntries.length, (index) {
          final entry = _levelEntries[index];
          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.white),
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
                      Text(
                        entry.name,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
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
    return ScrollableContent(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(_timeEntries.length, (index) {
          final entry = _timeEntries[index];
          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.white),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
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
  );

  final String name;
  final String handle;
  final LevelRankTier tier;
  final int level;
  final int personHours;
}

class _TimeLeaderboardEntry {
  const _TimeLeaderboardEntry(this.name, this.handle, this.totalHours);

  final String name;
  final String handle;
  final int totalHours;
}


