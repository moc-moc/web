import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';

/// カウントダウン設定投稿カード
class CountdownSetPostCard extends StatefulWidget {
  final String authorName;
  final String userId;
  final String eventName;
  final int remainingDays;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isOwnPost;

  const CountdownSetPostCard({
    super.key,
    required this.authorName,
    required this.userId,
    required this.eventName,
    required this.remainingDays,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isOwnPost,
  });

  @override
  State<CountdownSetPostCard> createState() => _CountdownSetPostCardState();
}

class _CountdownSetPostCardState extends State<CountdownSetPostCard> {
  bool _isCommentsExpanded = false;

  // ダミーコメントデータ
  final List<Map<String, String>> _dummyComments = [
    {'author': 'Alice', 'text': 'Good luck with your countdown!'},
    {'author': 'Bob', 'text': 'You\'ve got this!'},
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
              // 右上に"Countdown Set"を配置
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  'Countdown Set',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray,
                    fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // コンテンツ：カウントダウン表示
          CountdownDisplay(
            eventName: widget.eventName,
            days: widget.remainingDays,
            hours: 0,
            minutes: 0,
            seconds: 0,
            accentColor: AppColors.blue,
            borderColor: AppColors.blue.withValues(alpha: 0.8),
            backgroundColor: AppColors.blue.withValues(alpha: 0.5),
            titleColor: AppColors.textPrimary,
            labelColor: AppColors.gray,
            valueTextColor: AppColors.white,
            valueBackgroundColor: AppColors.blue.withValues(alpha: 0.8),
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

