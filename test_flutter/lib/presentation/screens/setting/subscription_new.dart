import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/cards.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';

/// サブスクリプション画面（新デザインシステム版）
class SubscriptionScreenNew extends StatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  State<SubscriptionScreenNew> createState() => _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState extends State<SubscriptionScreenNew> {
  int _selectedPlanIndex = 0; // 0: Monthly, 1: Yearly

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: 'Subscription'),
      body: ScrollableContent(
        child: SpacedColumn(
          spacing: AppSpacing.xl,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー
            _buildHeader(),

            // 無料トライアルボタン
            _buildFreeTrialButton(),

            // プラン選択
            _buildPlanSelection(),

            // 機能リスト
            _buildFeaturesList(),

            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.star, size: 80, color: AppColors.yellow),
        SizedBox(height: AppSpacing.md),
        Text(
          'Start Your 1-Week\nFree Trial',
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Unlock all premium features',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFreeTrialButton() {
    return GradientCard.yellow(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'Try Premium Free for 7 Days',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          PrimaryButton(
            text: 'Start Free Trial',
            size: ButtonSize.large,
            icon: Icons.arrow_forward,
            onPressed: () {
              // ダミー: トライアル開始
            },
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

        // Monthly Plan
        _buildPlanCard(
          index: 0,
          title: 'Monthly',
          originalPrice: '¥980',
          currentPrice: '¥480',
          period: '/month',
          discount: '51% OFF',
        ),

        SizedBox(height: AppSpacing.md),

        // Yearly Plan
        _buildPlanCard(
          index: 1,
          title: 'Yearly',
          originalPrice: '¥11,760',
          currentPrice: '¥4,800',
          period: '/year',
          discount: '59% OFF',
          badge: 'BEST VALUE',
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String originalPrice,
    required String currentPrice,
    required String period,
    required String discount,
    String? badge,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return InteractiveCard(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      backgroundColor: isSelected
          ? AppColors.blue.withValues(alpha: 0.15)
          : AppColors.backgroundCard,
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
                                color: AppColors.blue,
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
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                ],
              ),
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
                      borderRadius: BorderRadius.circular(AppRadius.small / 2),
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
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Premium Features', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),

          _buildFeatureItem('Unlimited tracking sessions'),
          _buildFeatureItem('Advanced analytics and reports'),
          _buildFeatureItem('Custom goals and categories'),
          _buildFeatureItem('Export data to CSV'),
          _buildFeatureItem('Remove all advertisements'),
          _buildFeatureItem('Priority customer support'),
          _buildFeatureItem('Cloud backup and sync'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTextStyles.body2)),
        ],
      ),
    );
  }
}
