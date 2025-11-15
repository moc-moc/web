import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/progress_bars.dart';

/// 写真のデザインに基づいた目標プログレスカード
class GoalProgressCardNew extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final int streakNumber;
  final List<String> labels; // 例: ['Progress Time'], ['Only Focus Time'], ['less', 'Progress Time']
  final String goalText; // 例: 'Goal: 2 hours', 'Goal: < 1 hour'
  final String progressText; // 例: 'Progress: 1h 30m', 'Focus: 1h 45m'
  final String periodLabel; // 例: 'Week', 'Month'
  final double percentage; // 0.0 ~ 1.0
  final Color progressColor;
  final String daysText; // 例: '3 days', '2 weeks', '1 month'

  const GoalProgressCardNew({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.streakNumber,
    required this.labels,
    required this.goalText,
    required this.progressText,
    required this.periodLabel,
    required this.percentage,
    required this.progressColor,
    required this.daysText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左側：アイコン + タイトルと情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1行目：アイコン + タイトル + 期間ラベル（レスポンシブ）
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 300;
                        if (isNarrow) {
                          // 幅が狭い場合：縦並び
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // アイコン（丸型、背景はblackgray、枠線は各色）
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.blackgray,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: iconColor.withValues(alpha: 0.9),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: iconColor,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  // タイトル（改行可能）
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: AppTextStyles.h3.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: iconColor.withValues(alpha: 0.9),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Padding(
                                padding: EdgeInsets.only(left: 56 + AppSpacing.md),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.middleblackgray,
                                    borderRadius: BorderRadius.circular(AppRadius.small),
                                  ),
                                  child: Text(
                                    periodLabel,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // 幅が広い場合：横並び
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // アイコン（丸型、背景はblackgray、枠線は各色）
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.blackgray,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: iconColor.withValues(alpha: 0.9),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: iconColor,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              // タイトル（改行可能）
                              Flexible(
                                child: Text(
                                  title,
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: iconColor.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              // 期間ラベル（weekly/monthly）
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.middleblackgray,
                                  borderRadius: BorderRadius.circular(AppRadius.small),
                                ),
                                child: Text(
                                  periodLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    // 2行目：時間数値（タイトルと同じ行）
                    Padding(
                      padding: EdgeInsets.only(left: 56 + AppSpacing.md),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              progressText.split('/')[0], // 2h部分
                              style: AppTextStyles.h3.copyWith(
                                fontSize: AppTextStyles.h3.fontSize! * 2.5 * 0.8,
                                fontWeight: FontWeight.bold,
                                color: iconColor.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '/${progressText.split('/')[1]}', // /5h部分
                              style: AppTextStyles.h3.copyWith(
                                fontSize: AppTextStyles.h3.fontSize! * 2.5 * 0.8 * 0.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // 右側：円グラフ
              Padding(
                padding: EdgeInsets.only(right: 60), // 炎数値に近づける
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressBar(
                    percentage: percentage,
                    progressColor: progressColor,
                    size: 120,
                    strokeWidth: 12,
                    showPercentage: true,
                  ),
                ),
              ),
            ],
          ),
          // 炎数値を円グラフの右側、枠の右上に表示
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: AppColors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.orange,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '$streakNumber',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2weeksを枠の右下に表示
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              daysText,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

