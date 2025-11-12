import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/stats_display.dart';
import 'package:test_flutter/dummy_data/user_data.dart';

/// トラッキング設定画面（新デザインシステム版）
class TrackingSettingScreenNew extends StatelessWidget {
  const TrackingSettingScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: 'Ready to Track'),
      body: SafeContent(
        child: SpacedColumn(
          spacing: AppSpacing.xl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                // プロフィールアイコン
                AvatarWidget(
                  initials: dummyUser.name[0],
                  size: 80,
                  backgroundColor: AppColors.blue,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Hi, ${dummyUser.name.split(' ')[0]}!',
                  style: AppTextStyles.h2,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Ready to start tracking your focus time?',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // タグ一覧セクション（将来実装用）
                SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: AppColors.backgroundSecondary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.label_outline,
                        color: AppColors.textDisabled,
                        size: 48,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Tags',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Coming soon',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // スタートボタン
            PrimaryButton(
              text: 'Start Tracking',
              icon: Icons.play_arrow,
              size: ButtonSize.large,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.trackingNew);
              },
            ),
          ],
        ),
      ),
    );
  }
}
