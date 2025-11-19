import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/dummy_data/user_data.dart';

/// フレンド画面（投稿画面）（新デザインシステム版）
class FriendScreenNew extends StatelessWidget {
  const FriendScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: _buildPostsFeed(context),
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
          // 左上のユーザーアイコン（アカウント設定画面へ遷移）
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.accountSettingsNew);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blue,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    dummyUser.name[0],
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // 右上のボタン（フレンドリスト画面へ遷移）
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gray.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person_add,
                color: AppColors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.friendList);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsFeed(BuildContext context) {
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
          // ヘッダー
          _buildHeader(context),
          SizedBox(height: AppSpacing.md),
          ...List.generate(7, (index) {
            final postTypes = ['tracking', 'goal', 'goalSet', 'totalHoursMilestone', 'consecutiveDaysMilestone', 'tracking', 'goal'];
            final postType = postTypes[index];
            
            final timeAgo = ['Just now', '2h ago', '2h ago', '3h ago', '4h ago', '5h ago', 'Yesterday'][index];
            final authorName = ['Alex Doe', 'Alex Morgan', 'John Doe', 'John Doe', 'John Doe', 'Jane Doe', 'Sarah Smith'][index];
            final userId = ['@alexdoe', '@alexmorgan', '@johndoe', '@johndoe', '@johndoe', '@janedoe', '@sarahsmith'][index];
            final likes = [1200, 15, 12, 1500, 1200, 28, 42][index];
            final comments = [245, 3, 3, 312, 245, 7, 12][index];
            final isOwnPost = index == 0; // 最初の投稿は自分の投稿として扱う

            if (postType == 'goal') {
              // Goal Achieved投稿
              final hours = [1, 2, 3][index % 3];
              final streakDays = [21, 15, 30][index % 3];
              final category = 'study'; // カテゴリ（study, pc, smartphoneなど）
              
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildGoalAchievedPostCard(
                  authorName: authorName,
                  hours: hours,
                  streakDays: streakDays,
                  category: category,
                  likes: likes,
                  comments: comments,
                  timeAgo: timeAgo,
                  isOwnPost: isOwnPost,
                ),
              );
            } else if (postType == 'goalSet') {
              // Goal Set投稿
              final goalName = 'Read a book';
              final hours = '30 mins';
              final focusType = 'Focused';
              final targetStatus = 'Above';
              
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildGoalSetPostCard(
                  authorName: authorName,
                  userId: userId,
                  goalName: goalName,
                  hours: hours,
                  focusType: focusType,
                  targetStatus: targetStatus,
                  likes: likes,
                  comments: comments,
                  timeAgo: timeAgo,
                  isOwnPost: isOwnPost,
                ),
              );
            } else {
              // トラッキング投稿
              final totalHours = [8.75, 6.5][index % 2];
              final studyHours = [2.5, 1.75][index % 2];
              final pcHours = [2.25, 1.5][index % 2];
              final smartphoneHours = [1.5, 1.25][index % 2];
              final peopleHours = [1.25, 1.0][index % 2];
              final noDetectionHours = [1.25, 1.0][index % 2];

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildPostCard(
                  authorName: authorName,
                  totalHours: totalHours,
                  studyHours: studyHours,
                  pcHours: pcHours,
                  smartphoneHours: smartphoneHours,
                  peopleHours: peopleHours,
                  noDetectionHours: noDetectionHours,
                  likes: likes,
                  comments: comments,
                  timeAgo: timeAgo,
                  isOwnPost: isOwnPost,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String authorName,
    required double totalHours,
    required double studyHours,
    required double pcHours,
    required double smartphoneHours,
    required double peopleHours,
    required double noDetectionHours,
    required int likes,
    required int comments,
    required String timeAgo,
    required bool isOwnPost,
  }) {
    // 時間を時間と分に変換
    final totalHoursInt = totalHours.floor();
    final totalMinutes = ((totalHours - totalHoursInt) * 60).round();
    final studyHoursInt = studyHours.floor();
    final studyMinutes = ((studyHours - studyHoursInt) * 60).round();
    final pcHoursInt = pcHours.floor();
    final pcMinutes = ((pcHours - pcHoursInt) * 60).round();
    final smartphoneHoursInt = smartphoneHours.floor();
    final smartphoneMinutes = ((smartphoneHours - smartphoneHoursInt) * 60).round();

    // 時間表示のフォーマット
    final totalTimeText = totalMinutes > 0
        ? '${totalHoursInt}h ${totalMinutes}m'
        : '${totalHoursInt}h';
    final studyTimeText = studyMinutes > 0
        ? '${studyHoursInt}h ${studyMinutes}m'
        : '${studyHoursInt}h';
    final pcTimeText = pcMinutes > 0
        ? '${pcHoursInt}h ${pcMinutes}m'
        : '${pcHoursInt}h';
    final smartphoneTimeText = smartphoneMinutes > 0
        ? '${smartphoneHoursInt}h ${smartphoneMinutes}m'
        : '${smartphoneHoursInt}h';

    // 各カテゴリの割合を計算
    final studyPercentage = ((studyHours / totalHours) * 100).round();
    final pcPercentage = ((pcHours / totalHours) * 100).round();
    final smartphonePercentage = ((smartphoneHours / totalHours) * 100).round();
    final peoplePercentage = ((peopleHours / totalHours) * 100).round();
    final noDetectionPercentage = ((noDetectionHours / totalHours) * 100).round();

    // プログレスバーの各セグメントの幅
    final studyWidth = studyHours / totalHours;
    final pcWidth = pcHours / totalHours;
    final smartphoneWidth = smartphoneHours / totalHours;
    final peopleWidth = peopleHours / totalHours;
    final noDetectionWidth = noDetectionHours / totalHours;

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
          // ユーザー情報行
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー名と時間
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に"Tracking"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Tracking',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // トラッキング時間
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tracking Time: ',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                totalTimeText,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                  fontSize: (AppTextStyles.body1.fontSize ?? 16) * 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // プログレスバー（複数セグメント）- homescreen.dartのスタイルを参考
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (studyWidth > 0)
                    Expanded(
                      flex: (studyWidth * 1000).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  if (pcWidth > 0)
                    Expanded(
                      flex: (pcWidth * 1000).round(),
                      child: Container(
                        color: AppColors.blue,
                      ),
                    ),
                  if (smartphoneWidth > 0)
                    Expanded(
                      flex: (smartphoneWidth * 1000).round(),
                      child: Container(
                        color: AppColors.orange,
                      ),
                    ),
                  if (peopleWidth > 0)
                    Expanded(
                      flex: (peopleWidth * 1000).round(),
                      child: Container(
                        color: AppColors.gray,
                      ),
                    ),
                  if (noDetectionWidth > 0)
                    Expanded(
                      flex: (noDetectionWidth * 1000).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.middleblackgray,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // カテゴリリスト（2列）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryItem(
                      'Study Focus',
                      studyTimeText,
                      studyPercentage,
                      AppColors.green,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildCategoryItem(
                      'PC Focus',
                      pcTimeText,
                      pcPercentage,
                      AppColors.blue,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildCategoryItem(
                      'Smartphone',
                      smartphoneTimeText,
                      smartphonePercentage,
                      AppColors.orange,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // 右列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryItem(
                      'People',
                      _formatTime(peopleHours),
                      peoplePercentage,
                      AppColors.gray,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildCategoryItem(
                      'No Detection',
                      _formatTime(noDetectionHours),
                      noDetectionPercentage,
                      AppColors.middleblackgray,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // いいねとコメント
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite_outline,
                label: '$likes',
                onTap: () {},
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: '$comments',
                onTap: () {},
              ),
              const Spacer(),
              // 右下にシェアボタン
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  // 共有機能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    String time,
    int percentage,
    Color color,
  ) {
    return Row(
      children: [
        // 色のドット
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        // ラベルと時間
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                '$time ($percentage%)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(double hours) {
    final hoursInt = hours.floor();
    final minutes = ((hours - hoursInt) * 60).round();
    if (minutes > 0) {
      return '${hoursInt}h ${minutes}m';
    }
    return '${hoursInt}h';
  }

  Widget _buildGoalAchievedPostCard({
    required String authorName,
    required int hours,
    required int streakDays,
    required String category,
    required int likes,
    required int comments,
    required String timeAgo,
    required bool isOwnPost,
  }) {
    return _GoalAchievedPostCard(
      authorName: authorName,
      hours: hours,
      streakDays: streakDays,
      category: category,
      likes: likes,
      comments: comments,
      timeAgo: timeAgo,
      isOwnPost: isOwnPost,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 3,
      items: AppBottomNavigationBar.defaultItems,
      onTap: (index) => _handleNavigationTap(context, index),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.goal);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.report);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSetPostCard({
    required String authorName,
    required String userId,
    required String goalName,
    required String hours,
    required String focusType,
    required String targetStatus,
    required int likes,
    required int comments,
    required String timeAgo,
    required bool isOwnPost,
  }) {
    return _GoalSetPostCard(
      authorName: authorName,
      userId: userId,
      goalName: goalName,
      hours: hours,
      focusType: focusType,
      targetStatus: targetStatus,
      likes: likes,
      comments: comments,
      timeAgo: timeAgo,
      isOwnPost: isOwnPost,
    );
  }


}

class _GoalAchievedPostCard extends StatefulWidget {
  final String authorName;
  final int hours;
  final int streakDays;
  final String category;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const _GoalAchievedPostCard({
    required this.authorName,
    required this.hours,
    required this.streakDays,
    required this.category,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<_GoalAchievedPostCard> createState() => _GoalAchievedPostCardState();
}

class _GoalAchievedPostCardState extends State<_GoalAchievedPostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Great job! Keep it up!'},
    {'author': 'Bob', 'text': 'Amazing progress!'},
    {'author': 'Charlie', 'text': 'You inspire me!'},
  ];

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.category == 'study' ? 'Study' : widget.category;
    final categoryColor = widget.category == 'study' ? AppColors.green : AppColors.blue;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          widget.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に"Goal Achieved"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Goal Achieved',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // ピル型ボタン
          Row(
            children: [
              // Dailyボタン（選択状態）
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.blue,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Daily',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // カテゴリボタン（studyの場合）
              if (widget.category == 'study')
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: categoryColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        color: categoryColor,
                        size: 16,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        categoryName,
                        style: AppTextStyles.caption.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // 統計情報（同じ高さに横並び）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Hours（アイコン、数値、h）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.blue,
                    size: 32 * 1.1,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.hours}',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'h',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.blue,
                          fontSize: (AppTextStyles.body1.fontSize ?? 16) * 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Streak Days（アイコン、数値、ラベル）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.orange,
                    size: 32 * 1.1,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.streakDays}',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Streak Days',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // フッター：いいね、コメント、共有
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite,
                label: _formatNumber(widget.likes),
                onTap: () {},
                iconColor: AppColors.red,
                textColor: AppColors.white,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.comments),
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = !_isCommentsExpanded;
                  });
                },
              ),
              const Spacer(),
              // 右下にシェアボタン
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  // 共有機能
                },
              ),
            ],
          ),
          // コメント表示部分（最初のコメントのみ）
          if (_dummyComments.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String author, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.white.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  text,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final k = (number / 1000).toStringAsFixed(1);
      return k.endsWith('.0') ? '${k.substring(0, k.length - 2)}k' : '${k}k';
    }
    return number.toString();
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalSetPostCard extends StatefulWidget {
  final String authorName;
  final String userId;
  final String goalName;
  final String hours;
  final String focusType;
  final String targetStatus;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const _GoalSetPostCard({
    required this.authorName,
    required this.userId,
    required this.goalName,
    required this.hours,
    required this.focusType,
    required this.targetStatus,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<_GoalSetPostCard> createState() => _GoalSetPostCardState();
}

class _GoalSetPostCardState extends State<_GoalSetPostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Great goal! You can do it!'},
    {'author': 'Bob', 'text': 'Looking forward to your progress!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          widget.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に"Goal Setting"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Goal Setting',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // コンテンツ：2列2行のグリッド
          Row(
            children: [
              // 左列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal（左上）
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flag,
                            color: AppColors.blue,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goal',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.blue,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs / 2),
                              Text(
                                widget.goalName,
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Hours（左下）
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: AppColors.purple,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hours',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.purple,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs / 2),
                              Text(
                                widget.hours,
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // 右列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category（右上）- Study、緑
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school,
                            color: AppColors.green,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.green,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs / 2),
                              Text(
                                'Study',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Daily（右下）
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppColors.blue,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.blue,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs / 2),
                              Text(
                                'Daily',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // フッター：いいね、コメント、共有
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite,
                label: _formatNumber(widget.likes),
                onTap: () {},
                iconColor: AppColors.red,
                textColor: AppColors.white,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.comments),
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = !_isCommentsExpanded;
                  });
                },
              ),
              const Spacer(),
              // 右下にシェアボタン
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  // 共有機能
                },
              ),
            ],
          ),
          // コメント表示部分（最初のコメントのみ）
          if (_dummyComments.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String author, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.white.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  text,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final k = (number / 1000).toStringAsFixed(1);
      return k.endsWith('.0') ? '${k.substring(0, k.length - 2)}k' : '${k}k';
    }
    return number.toString();
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingPostCard extends StatefulWidget {
  final String authorName;
  final double totalHours;
  final double studyHours;
  final double pcHours;
  final double smartphoneHours;
  final double peopleHours;
  final double noDetectionHours;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const _TrackingPostCard({
    required this.authorName,
    required this.totalHours,
    required this.studyHours,
    required this.pcHours,
    required this.smartphoneHours,
    required this.peopleHours,
    required this.noDetectionHours,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<_TrackingPostCard> createState() => _TrackingPostCardState();
}

class _TrackingPostCardState extends State<_TrackingPostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Nice tracking! Keep it up!'},
    {'author': 'Bob', 'text': 'Great progress today!'},
    {'author': 'Charlie', 'text': 'You are doing amazing!'},
  ];

  @override
  Widget build(BuildContext context) {
    // 時間を時間と分に変換
    final totalHoursInt = widget.totalHours.floor();
    final totalMinutes = ((widget.totalHours - totalHoursInt) * 60).round();
    final studyHoursInt = widget.studyHours.floor();
    final studyMinutes = ((widget.studyHours - studyHoursInt) * 60).round();
    final pcHoursInt = widget.pcHours.floor();
    final pcMinutes = ((widget.pcHours - pcHoursInt) * 60).round();
    final smartphoneHoursInt = widget.smartphoneHours.floor();
    final smartphoneMinutes = ((widget.smartphoneHours - smartphoneHoursInt) * 60).round();

    // 時間表示のフォーマット
    final totalTimeText = totalMinutes > 0
        ? '${totalHoursInt}h ${totalMinutes}m'
        : '${totalHoursInt}h';
    final studyTimeText = studyMinutes > 0
        ? '${studyHoursInt}h ${studyMinutes}m'
        : '${studyHoursInt}h';
    final pcTimeText = pcMinutes > 0
        ? '${pcHoursInt}h ${pcMinutes}m'
        : '${pcHoursInt}h';
    final smartphoneTimeText = smartphoneMinutes > 0
        ? '${smartphoneHoursInt}h ${smartphoneMinutes}m'
        : '${smartphoneHoursInt}h';

    // 各カテゴリの割合を計算
    final studyWidth = widget.studyHours / widget.totalHours;
    final pcWidth = widget.pcHours / widget.totalHours;
    final smartphoneWidth = widget.smartphoneHours / widget.totalHours;
    final peopleWidth = widget.peopleHours / widget.totalHours;
    final noDetectionWidth = widget.noDetectionHours / widget.totalHours;

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
          // ユーザー情報行
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー名と時間
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          widget.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に"Tracking"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Tracking',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // トラッキング時間
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tracking Time: ',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                totalTimeText,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                  fontSize: (AppTextStyles.body1.fontSize ?? 16) * 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // プログレスバー（複数セグメント）- homescreen.dartのスタイルを参考
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.disabledGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (studyWidth > 0)
                      Expanded(
                        flex: (studyWidth * 1000).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    if (pcWidth > 0)
                      Expanded(
                        flex: (pcWidth * 1000).round(),
                        child: Container(
                          color: AppColors.blue,
                        ),
                      ),
                    if (smartphoneWidth > 0)
                      Expanded(
                        flex: (smartphoneWidth * 1000).round(),
                        child: Container(
                          color: AppColors.orange,
                        ),
                      ),
                    if (peopleWidth > 0)
                      Expanded(
                        flex: (peopleWidth * 1000).round(),
                        child: Container(
                          color: AppColors.gray,
                        ),
                      ),
                    if (noDetectionWidth > 0)
                      Expanded(
                        flex: (noDetectionWidth * 1000).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.middleblackgray,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // 時間の詳細
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRow('Study', studyTimeText, AppColors.green),
              SizedBox(height: AppSpacing.xs),
              _buildTimeRow('PC', pcTimeText, AppColors.blue),
              SizedBox(height: AppSpacing.xs),
              _buildTimeRow('Smartphone', smartphoneTimeText, AppColors.orange),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // フッター：いいね、コメント、共有
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite,
                label: _formatNumber(widget.likes),
                onTap: () {},
                iconColor: AppColors.red,
                textColor: AppColors.white,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.comments),
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = !_isCommentsExpanded;
                  });
                },
              ),
              const Spacer(),
              // 右下にシェアボタン
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  // 共有機能
                },
              ),
            ],
          ),
          // コメント表示部分（最初のコメントのみ）
          if (_dummyComments.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          time,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String author, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.white.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  text,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final k = (number / 1000).toStringAsFixed(1);
      return k.endsWith('.0') ? '${k.substring(0, k.length - 2)}k' : '${k}k';
    }
    return number.toString();
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalHoursMilestonePostCard extends StatefulWidget {
  final String authorName;
  final String userId;
  final int totalHours;
  final int nextMilestone;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const _TotalHoursMilestonePostCard({
    required this.authorName,
    required this.userId,
    required this.totalHours,
    required this.nextMilestone,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<_TotalHoursMilestonePostCard> createState() => _TotalHoursMilestonePostCardState();
}

class _TotalHoursMilestonePostCardState extends State<_TotalHoursMilestonePostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Congratulations on reaching 300 hours! Amazing dedication!'},
    {'author': 'Bob', 'text': 'You inspire me to keep going!'},
    {'author': 'Charlie', 'text': 'Incredible achievement!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          widget.userId,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に3つの点
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // 達成カード（紫色）
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              children: [
                // アイコン
                Icon(
                  Icons.emoji_events,
                  color: AppColors.white,
                  size: 48,
                ),
                SizedBox(height: AppSpacing.md),
                // 数値
                Text(
                  '${widget.totalHours}',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 72,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                // Total Hours!
                Text(
                  'Total Hours!',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                // Amazing Dedication
                Text(
                  'Amazing Dedication',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Next Milestoneカード
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                // アイコン
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.purple,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // テキスト
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Milestone',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        'Keep it up!',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 次のマイルストーン
                Text(
                  '${widget.nextMilestone} Hours',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // フッター：いいね、コメント、共有
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite,
                label: _formatNumber(widget.likes),
                onTap: () {},
                iconColor: AppColors.red,
                textColor: AppColors.white,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.comments),
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = !_isCommentsExpanded;
                  });
                },
              ),
              const Spacer(),
              // シェアボタン
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      color: AppColors.white,
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Share',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // コメント表示部分（最初のコメントのみ）
          if (_dummyComments.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String author, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.white.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs / 2),
              Text(
                text,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsecutiveDaysMilestonePostCard extends StatefulWidget {
  final String authorName;
  final String userId;
  final int consecutiveDays;
  final int nextMilestone;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const _ConsecutiveDaysMilestonePostCard({
    required this.authorName,
    required this.userId,
    required this.consecutiveDays,
    required this.nextMilestone,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<_ConsecutiveDaysMilestonePostCard> createState() => _ConsecutiveDaysMilestonePostCardState();
}

class _ConsecutiveDaysMilestonePostCardState extends State<_ConsecutiveDaysMilestonePostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': '100 days in a row! That\'s incredible dedication!'},
    {'author': 'Bob', 'text': 'You are an inspiration to us all!'},
    {'author': 'Charlie', 'text': 'Keep the streak going!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Stack(
            children: [
              Row(
                children: [
                  // プロフィール画像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          widget.userId,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 右上に3つの点
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // 達成カード（紫色）
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              children: [
                // 数値
                Text(
                  '${widget.consecutiveDays}',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 72,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                // Consecutive Days
                Text(
                  'Consecutive Days',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                // Milestone Reached
                Text(
                  'Milestone Reached',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Next Milestoneカード
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blackgray,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                // アイコン（トロフィー）
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.orange,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // テキスト
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Milestone',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        'Keep going!',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 次のマイルストーン
                Text(
                  '${widget.nextMilestone} Days',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // フッター：いいね、コメント、共有
          Row(
            children: [
              _buildPostActionButton(
                icon: Icons.favorite,
                label: _formatNumber(widget.likes),
                onTap: () {},
                iconColor: AppColors.red,
                textColor: AppColors.white,
              ),
              SizedBox(width: AppSpacing.lg),
              _buildPostActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.comments),
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = !_isCommentsExpanded;
                  });
                },
              ),
              const Spacer(),
              // シェアボタン
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      color: AppColors.white,
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Share',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // コメント表示部分（最初のコメントのみ）
          if (_dummyComments.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String author, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.white.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs / 2),
              Text(
                text,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    final effectiveTextColor = textColor ?? AppColors.textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/// フレンドリスト画面（新デザインシステム版）
