import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 目標設定投稿カード
class GoalSetPostCard extends StatefulWidget {
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

  const GoalSetPostCard({
    super.key,
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
  State<GoalSetPostCard> createState() => _GoalSetPostCardState();
}

class _GoalSetPostCardState extends State<GoalSetPostCard> {
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
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Hours（左下）
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Daily（右下）
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
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

