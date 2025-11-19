import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/navigation.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/tracking_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/goal_achieved_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/goal_set_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/countdown_set_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/countdown_ended_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/streak_days_milestone_post_card.dart';
import 'package:test_flutter/presentation/screens/friend/post_cards/total_hours_milestone_post_card.dart';

/// 投稿データのモデル
class PostData {
  final String postType;
  final String timeAgo;
  final String authorName;
  final String userId;
  final int likes;
  final int comments;
  final bool isOwnPost;
  final Map<String, dynamic>? additionalData;

  PostData({
    required this.postType,
    required this.timeAgo,
    required this.authorName,
    required this.userId,
    required this.likes,
    required this.comments,
    required this.isOwnPost,
    this.additionalData,
  });
}

/// フレンド画面（投稿画面）（新デザインシステム版）
class FriendScreenNew extends StatefulWidget {
  const FriendScreenNew({super.key});

  @override
  State<FriendScreenNew> createState() => _FriendScreenNewState();
}

class _FriendScreenNewState extends State<FriendScreenNew> {
  final ScrollController _scrollController = ScrollController();
  final List<PostData> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _initialPostCount = 7;
  static const int _loadMoreCount = 5;

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialPosts() {
    _posts.clear();
    _loadMorePosts(_initialPostCount);
  }

  void _loadMorePosts(int count) {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // シミュレートされた非同期読み込み（実際のアプリではAPI呼び出し）
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final startIndex = _posts.length;
      final newPosts = _generatePosts(startIndex, count);

      setState(() {
        _posts.addAll(newPosts);
        _isLoading = false;
        // 実際のアプリでは、APIから返されたデータに基づいて_hasMoreを設定
        // ここでは、100件まで読み込めるものとします
        _hasMore = _posts.length < 100;
      });
    });
  }

  List<PostData> _generatePosts(int startIndex, int count) {
    final postTypes = ['tracking', 'goal', 'goalSet', 'countdownSet', 'countdownEnded', 'streakDaysMilestone', 'totalHoursMilestone'];
    final timeAgoOptions = ['Just now', '2h ago', '3h ago', '1d ago', '5h ago', 'Yesterday', '2d ago', '3d ago'];
    final authorNames = ['Alex Doe', 'Alex Morgan', 'John Doe', 'Emma Wilson', 'Mike Johnson', 'Jane Doe', 'Sarah Smith', 'Tom Brown', 'Lisa White', 'David Lee'];
    final userIds = ['@alexdoe', '@alexmorgan', '@johndoe', '@emmawilson', '@mikejohnson', '@janedoe', '@sarahsmith', '@tombrown', '@lisawhite', '@davidlee'];

    return List.generate(count, (index) {
      final globalIndex = startIndex + index;
      final postType = postTypes[globalIndex % postTypes.length];
      final authorIndex = globalIndex % authorNames.length;
      
      return PostData(
        postType: postType,
        timeAgo: timeAgoOptions[globalIndex % timeAgoOptions.length],
        authorName: authorNames[authorIndex],
        userId: userIds[authorIndex],
        likes: [1200, 15, 12, 8, 25, 28, 42, 35, 19, 56][globalIndex % 10],
        comments: [245, 3, 3, 2, 5, 7, 12, 8, 4, 15][globalIndex % 10],
        isOwnPost: globalIndex == 0,
        additionalData: _getAdditionalDataForPostType(postType, globalIndex),
      );
    });
  }

  Map<String, dynamic>? _getAdditionalDataForPostType(String postType, int index) {
    switch (postType) {
      case 'goal':
        return {
          'hours': [1, 2, 3][index % 3],
          'streakDays': [21, 15, 30][index % 3],
          'category': 'study',
        };
      case 'goalSet':
        return {
          'goalName': 'Read a book',
          'hours': '30 mins',
          'focusType': 'Focused',
          'targetStatus': 'Above',
        };
      case 'countdownSet':
        return {
          'eventName': ['Mid-term Exams', 'Project Deadline', 'Birthday'][index % 3],
          'remainingDays': [15, 7, 30][index % 3],
        };
      case 'countdownEnded':
        return {
          'eventName': ['Final Exams', 'Project Deadline', 'Vacation'][index % 3],
        };
      case 'streakDaysMilestone':
        return {
          'streakDays': [30, 50, 100, 200, 365][index % 5],
        };
      case 'totalHoursMilestone':
        return {
          'totalHours': [100, 500, 1000, 2000, 5000][index % 5],
        };
      case 'tracking':
      default:
        return {
          'totalHours': [8.75, 6.5][index % 2],
          'studyHours': [2.5, 1.75][index % 2],
          'pcHours': [2.25, 1.5][index % 2],
          'smartphoneHours': [1.5, 1.25][index % 2],
          'peopleHours': [1.25, 1.0][index % 2],
          'noDetectionHours': [1.25, 1.0][index % 2],
        };
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts(_loadMoreCount);
    }
  }

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
                    'A',
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
      controller: _scrollController,
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
          // 投稿リスト
          ..._posts.map((post) => _buildPostCard(post)),
          // ローディングインジケーター
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue,
                ),
              ),
            ),
          // これ以上読み込むデータがない場合のメッセージ
          if (!_hasMore && _posts.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: Text(
                  'すべての投稿を読み込みました',
                  style: TextStyle(
                    color: AppColors.gray,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostData post) {
    final postType = post.postType;
    final data = post.additionalData ?? {};

    if (postType == 'goal') {
      // Goal Achieved投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: GoalAchievedPostCard(
          authorName: post.authorName,
          hours: data['hours'] as int,
          streakDays: data['streakDays'] as int,
          category: data['category'] as String,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else if (postType == 'goalSet') {
      // Goal Set投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: GoalSetPostCard(
          authorName: post.authorName,
          userId: post.userId,
          goalName: data['goalName'] as String,
          hours: data['hours'] as String,
          focusType: data['focusType'] as String,
          targetStatus: data['targetStatus'] as String,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else if (postType == 'countdownSet') {
      // Countdown Set投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: CountdownSetPostCard(
          authorName: post.authorName,
          userId: post.userId,
          eventName: data['eventName'] as String,
          remainingDays: data['remainingDays'] as int,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else if (postType == 'countdownEnded') {
      // Countdown Ended投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: CountdownEndedPostCard(
          authorName: post.authorName,
          userId: post.userId,
          eventName: data['eventName'] as String,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else if (postType == 'streakDaysMilestone') {
      // Streak Days Milestone投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: StreakDaysMilestonePostCard(
          authorName: post.authorName,
          userId: post.userId,
          streakDays: data['streakDays'] as int,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else if (postType == 'totalHoursMilestone') {
      // Total Hours Milestone投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: TotalHoursMilestonePostCard(
          authorName: post.authorName,
          userId: post.userId,
          totalHours: data['totalHours'] as int,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    } else {
      // トラッキング投稿
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: TrackingPostCard(
          authorName: post.authorName,
          totalHours: data['totalHours'] as double,
          studyHours: data['studyHours'] as double,
          pcHours: data['pcHours'] as double,
          smartphoneHours: data['smartphoneHours'] as double,
          peopleHours: data['peopleHours'] as double,
          noDetectionHours: data['noDetectionHours'] as double,
          likes: post.likes,
          comments: post.comments,
          timeAgo: post.timeAgo,
          isOwnPost: post.isOwnPost,
        ),
      );
    }
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
}


