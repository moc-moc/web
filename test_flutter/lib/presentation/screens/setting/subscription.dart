import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';

/// サブスクリプション画面（新デザインシステム版）
class SubscriptionScreenNew extends StatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  State<SubscriptionScreenNew> createState() => _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState extends State<SubscriptionScreenNew> {
  int _selectedPlanIndex = 1; // 0: Weekly, 1: Monthly, 2: Yearly

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppBarWithBack(title: 'Upgrade to Premium'),
      body: SafeArea(
        child: ScrollableContent(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SpacedColumn(
            spacing: AppSpacing.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 無料トライアルセクション
              _buildFreeTrialSection(),

              // プラン選択
              _buildPlanSelection(),

              // 機能比較テーブル
              _buildFeatureComparisonTable(),

              // 利用規約リンク
              _buildLegalText(),

              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeTrialSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            'Start Your 1-Week Free Trial',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Enjoy all premium features for a week, absolutely free.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // ダミー: トライアル開始
                },
                borderRadius: BorderRadius.circular(30.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    'Start Free Trial',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Your Plan', style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.md),

        // Weekly Plan
        _buildPlanCard(
          index: 0,
          title: 'Weekly',
          currentPrice: '¥480',
          period: '/week',
        ),

        SizedBox(height: AppSpacing.md),

        // Monthly Plan
        _buildPlanCard(
          index: 1,
          title: 'Monthly',
          originalPrice: '¥1,480',
          currentPrice: '¥980',
          period: '/month',
          discount: '34% OFF',
          badge: 'Limited Time Offer',
          badgeColor: AppColors.orange,
        ),

        SizedBox(height: AppSpacing.md),

        // Yearly Plan
        _buildPlanCard(
          index: 2,
          title: 'Yearly',
          currentPrice: '¥14,800',
          period: '/year',
          badge: 'Best Value',
          badgeColor: AppColors.blue,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String currentPrice,
    required String period,
    String? originalPrice,
    String? discount,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = _selectedPlanIndex == index;
    final borderColor = isSelected
        ? AppColors.blue
        : AppColors.gray.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPlanIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTextStyles.h3),
                              SizedBox(height: AppSpacing.xs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currentPrice,
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Text(
                                    period,
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (originalPrice != null && discount != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            originalPrice,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textDisabled,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text(
                              discount,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blue
                            : AppColors.blackgray,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Text(
                        'Choose Plan',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.yellow,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        badge,
                        style: AppTextStyles.caption.copyWith(
                          color: badgeColor == AppColors.blue
                              ? AppColors.white
                              : AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparisonTable() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Feature',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Free',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Paid',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.gray.withValues(alpha: 0.35)),
          SizedBox(height: AppSpacing.sm),

          // 機能行
          _buildFeatureRow('Daily views', true, true),
          _buildFeatureRow('Single goal creation', true, true),
          _buildFeatureRow('Reports, analytics, and graphs', false, true),
          _buildFeatureRow('Weekly, monthly, and yearly views', false, true),
          _buildFeatureRow('Multiple goal creation', false, true),
          _buildFeatureRow('Countdown feature', false, true),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool freeHas, bool paidHas) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: AppTextStyles.body2,
            ),
          ),
          Expanded(
            child: Center(
              child: _buildCheckmark(freeHas),
            ),
          ),
          Expanded(
            child: Center(
              child: _buildCheckmark(paidHas),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckmark(bool has) {
    if (has) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: AppColors.white,
          size: 16,
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.gray.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          color: AppColors.white,
          size: 16,
        ),
      );
    }
  }

  Widget _buildLegalText() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy.',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
