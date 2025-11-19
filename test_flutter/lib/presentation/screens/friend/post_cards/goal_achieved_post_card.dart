import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 目標達成投稿カード
class GoalAchievedPostCard extends StatefulWidget {
  final String authorName;
  final int hours;
  final int streakDays;
  final String category;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const GoalAchievedPostCard({
    super.key,
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
  State<GoalAchievedPostCard> createState() => _GoalAchievedPostCardState();
}

class _GoalAchievedPostCardState extends State<GoalAchievedPostCard> {
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
          color: AppColors.blue.withValues(alpha: 0.8),
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
            children: [
              // Hours（アイコン、数値、h）- 左半分
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: AppColors.blue,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.blue,
                        size: 35.2, // 32 * 1.1
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        '${widget.hours}',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'h',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.blue,
                            fontSize: (AppTextStyles.body1.fontSize ?? 16) * 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Streak Days（アイコン、数値、ラベル）- 右半分
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: AppColors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.orange,
                        size: 35.2, // 32 * 1.1
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        '${widget.streakDays}',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Days',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.orange,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
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
          // コメント表示部分
          if (_dummyComments.isNotEmpty) ...[
            // コメント部分の上の線
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Divider(
                color: AppColors.blue.withValues(alpha: 0.8),
                thickness: 1,
                height: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 最初のコメントは常に表示
                  _buildCommentItem(_dummyComments[0]['author']!, _dummyComments[0]['text']!),
                  // 展開されている場合は2つ目以降のコメントも表示
                  if (_isCommentsExpanded && _dummyComments.length > 1)
                    ..._dummyComments.skip(1).map((comment) => _buildCommentItem(comment['author']!, comment['text']!)),
                ],
              ),
            ),
          ],
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

