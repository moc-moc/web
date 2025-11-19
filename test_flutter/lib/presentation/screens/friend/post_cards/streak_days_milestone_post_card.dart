import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 継続日数大台更新投稿カード
class StreakDaysMilestonePostCard extends StatefulWidget {
  final String authorName;
  final String userId;
  final int streakDays;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const StreakDaysMilestonePostCard({
    super.key,
    required this.authorName,
    required this.userId,
    required this.streakDays,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<StreakDaysMilestonePostCard> createState() => _StreakDaysMilestonePostCardState();
}

class _StreakDaysMilestonePostCardState extends State<StreakDaysMilestonePostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Incredible streak! Keep going!'},
    {'author': 'Bob', 'text': 'You are unstoppable!'},
    {'author': 'Charlie', 'text': 'This is amazing dedication!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分（プロフィール情報）
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
              // 右上に"Streak Milestone"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Streak Milestone',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          // メインの達成カード（赤系）- 幅いっぱい
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              children: [
                  // 大きな数字
                  Text(
                    '${widget.streakDays}',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // 下線（装飾的）
                  Container(
                    width: 120,
                    height: 2,
                    color: AppColors.white.withValues(alpha: 0.5),
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // "Consecutive Days"
                  Text(
                    'Consecutive Days',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // "Milestone Reached"
                  Text(
                    'Milestone Reached',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
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
                color: AppColors.red.withValues(alpha: 0.8),
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

