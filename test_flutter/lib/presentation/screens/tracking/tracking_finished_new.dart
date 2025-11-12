import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/dummy_data/tracking_data.dart';

/// トラッキング終了画面（新デザインシステム版）
class TrackingFinishedScreenNew extends StatelessWidget {
  const TrackingFinishedScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    final session = completedTrackingSession;

    return AppScaffold(
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.lg),
              // タイトル
              Text(
                'Great Work!',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'You\'ve completed your tracking session',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.md),

              // セッション時間
              StandardCard(
                child: Column(
                  children: [
                    Icon(Icons.timer, color: AppColors.blue, size: 48),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      '${session.totalHours.toStringAsFixed(1)} Hours',
                      style: AppTextStyles.h1.copyWith(color: AppColors.blue),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')} - ${session.endTime.hour}:${session.endTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // カテゴリー別集計
              StandardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Breakdown',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildCategoryRow(
                      'Study',
                      Icons.menu_book,
                      AppChartColors.study,
                      session.studyHours,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildCategoryRow(
                      'Computer',
                      Icons.computer,
                      AppChartColors.pc,
                      session.pcHours,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildCategoryRow(
                      'Smartphone',
                      Icons.smartphone,
                      AppChartColors.smartphone,
                      session.smartphoneHours,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildCategoryRow(
                      'Person Only',
                      Icons.person,
                      AppChartColors.personOnly,
                      session.personOnlyHours,
                    ),
                  ],
                ),
              ),

              // 目標達成状況
              StandardCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goal Achievement',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            '+25% above target',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.success,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 48,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // SNSシェアボタン（将来実装）
              OutlineButton(
                text: 'Share on Social Media',
                icon: Icons.share,
                size: ButtonSize.medium,
                borderColor: AppColors.textSecondary,
                onPressed: () {
                  // 将来実装
                },
              ),

              SizedBox(height: AppSpacing.md),

              // OKボタン
              PrimaryButton(
                text: 'OK',
                size: ButtonSize.large,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),

              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    String label,
    IconData icon,
    Color color,
    double hours,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: AppTextStyles.body2)),
        Text(
          '${hours.toStringAsFixed(1)}h',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
