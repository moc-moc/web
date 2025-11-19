import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';

/// フレンドリスト画面（新デザインシステム版）
class FriendListScreenNew extends StatelessWidget {
  const FriendListScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildFriendsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return ScrollableContent(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          SizedBox(height: AppSpacing.md),
          ...List.generate(2, (index) {
            final usernames = ['StudyPro123', 'CodeNinja'];
            final quotes = [
              'Mastering Quantum Physics',
              'Building the future, one line at a time.'
            ];
            final bios = [
              'Loves coffee, code, and conquering exams. Let\'s connect and motivate each other!',
              'Full-stack dev student. Join my study group for late-night coding sessions!'
            ];
            final followers = [1200, 2500];
            final following = [500, 890];
            final streaks = [120, 250];
            final focusHours = [500, 1200];

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildFriendCard(
                username: usernames[index],
                quote: quotes[index],
                bio: bios[index],
                followers: followers[index],
                following: following[index],
                streak: streaks[index],
                focusHours: focusHours[index],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              style: AppTextStyles.body2.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search friends...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard({
    required String username,
    required String quote,
    required String bio,
    required int followers,
    required int following,
    required int streak,
    required int focusHours,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上部：アバター、ユーザー情報、フレンド追加ボタン
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // アバター
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.purple,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ユーザー名
                        Text(
                          username,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        // ステータス/引用（緑の枠と背景で囲む）
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                            border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            quote,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        // 自己紹介
                        Text(
                          bio,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上のフレンド追加ボタン（右上に配置）
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // フレンド追加機能
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: Icon(
                          Icons.person_add,
                          color: AppColors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // 統計情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: _formatNumber(followers),
                label: 'Followers',
                color: AppColors.purple,
              ),
              _buildStatItem(
                value: _formatNumber(following),
                label: 'Following',
                color: AppColors.green,
              ),
              _buildStatItem(
                value: '$streak',
                label: 'Streak',
                color: AppColors.orange,
              ),
              _buildStatItem(
                value: '${focusHours}h',
                label: 'Focus',
                color: AppColors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xs / 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final k = (number / 1000).toStringAsFixed(1);
      return k.endsWith('.0') ? '${k.substring(0, k.length - 2)}k' : '${k}k';
    }
    return number.toString();
  }
}

