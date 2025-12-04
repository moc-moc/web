import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/models/subscription_status.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';

typedef SubscriptionContentBuilder = Widget Function(
  BuildContext context,
  SubscriptionStatus status,
);

enum PremiumFeature {
  extendedReports,
  multipleGoals,
  countdown,
  powerSavingMode,
}

class PremiumFeatureDetail {
  const PremiumFeatureDetail({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  static PremiumFeatureDetail resolve(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.extendedReports:
        return const PremiumFeatureDetail(
          title: '月/年レポートを解放',
          description: 'プレミアムで長期レポート・分析・グラフを閲覧できます。',
          icon: Icons.insights,
        );
      case PremiumFeature.multipleGoals:
        return const PremiumFeatureDetail(
          title: '複数目標を追加',
          description: '同時に複数の学習・作業目標を管理できます。',
          icon: Icons.flag,
        );
      case PremiumFeature.countdown:
        return const PremiumFeatureDetail(
          title: 'カウントダウンを作成',
          description: '重要なイベントまでの残り時間を管理できます。',
          icon: Icons.hourglass_bottom,
        );
      case PremiumFeature.powerSavingMode:
        return const PremiumFeatureDetail(
          title: '省電力モードを解放',
          description: 'トラッキング中の低消費電力モードを利用できます。',
          icon: Icons.bolt,
        );
    }
  }
}

class EntitlementRules {
  const EntitlementRules._();

  static bool canUse(
    SubscriptionStatus status,
    PremiumFeature feature,
  ) {
    switch (feature) {
      case PremiumFeature.extendedReports:
      case PremiumFeature.multipleGoals:
      case PremiumFeature.countdown:
      case PremiumFeature.powerSavingMode:
        return status.hasPremiumAccess;
    }
  }
}

class EntitlementGate extends ConsumerWidget {
  const EntitlementGate({
    super.key,
    required this.feature,
    required this.builder,
    this.lockBuilder,
  });

  final PremiumFeature feature;
  final SubscriptionContentBuilder builder;
  final WidgetBuilder? lockBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionStatusProvider);
    final isUnlocked = EntitlementRules.canUse(status, feature);
    if (isUnlocked) {
      return builder(context, status);
    }
    return lockBuilder?.call(context) ?? PremiumLockCard(feature: feature);
  }
}

class PremiumLockCard extends StatelessWidget {
  const PremiumLockCard({
    super.key,
    required this.feature,
  });

  final PremiumFeature feature;

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.subscriptionNew);
  }

  @override
  Widget build(BuildContext context) {
    final detail = PremiumFeatureDetail.resolve(feature);
    return InkWell(
      onTap: () => _navigateToSubscription(context),
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.blackgray,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                detail.icon,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.title,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    detail.description,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.blue),
              ),
              child: Text(
                'プレミアムへ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


