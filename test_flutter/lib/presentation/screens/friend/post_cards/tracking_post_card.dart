import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// トラッキング投稿カード
class TrackingPostCard extends StatefulWidget {
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

  const TrackingPostCard({
    super.key,
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
  State<TrackingPostCard> createState() => _TrackingPostCardState();
}

class _TrackingPostCardState extends State<TrackingPostCard> {
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
    
    // work time = study + pc
    final workHours = widget.studyHours + widget.pcHours;
    final workHoursInt = workHours.floor();
    final workMinutes = ((workHours - workHoursInt) * 60).round();

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
    final workTimeText = workMinutes > 0
        ? '${workHoursInt}h ${workMinutes}m'
        : '${workHoursInt}h';

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
          color: AppColors.blue.withValues(alpha: 0.8),
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
          // プログレスバー（複数セグメント）
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
          SizedBox(height: AppSpacing.md),
          // 時間の詳細（2x2グリッド）
          Column(
            children: [
              // 上段：Study（左）とPC（右）
              Row(
                children: [
                  Expanded(
                    child: _buildTimeRow('Study', studyTimeText, AppColors.green),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTimeRow('PC', pcTimeText, AppColors.blue),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              // 下段：Smartphone（左）とWork Time（右）
              Row(
                children: [
                  Expanded(
                    child: _buildTimeRow('Smartphone', smartphoneTimeText, AppColors.orange),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTimeRow('Work Time', workTimeText, AppColors.purple),
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

  Widget _buildTimeRow(String label, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 10.4, // 8 * 1.3
          height: 10.4, // 8 * 1.3
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.sm * 1.3),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
          ),
        ),
        Text(
          time,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white,
            fontSize: (AppTextStyles.caption.fontSize ?? 12) * 1.3,
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

