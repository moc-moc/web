import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:test_flutter/data/models/subscription_status.dart';
import 'package:test_flutter/feature/subscription/cancel_service.dart';
import 'package:test_flutter/feature/subscription/purchase_providers.dart';
import 'package:test_flutter/feature/subscription/stripe_providers.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/feature/subscription/subscription_sync_service.dart';
import 'package:test_flutter/presentation/widgets/app_bars.dart';
import 'package:test_flutter/presentation/widgets/layouts.dart';

/// サブスクリプション画面（新デザインシステム版）
class SubscriptionScreenNew extends ConsumerStatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  ConsumerState<SubscriptionScreenNew> createState() =>
      _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState
    extends ConsumerState<SubscriptionScreenNew> {
  String? _manualSelectedPlanId;
  bool _hasManualSelection = false;
  bool _isManagingPlan = false;
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<PurchaseState>(
      purchaseStateProvider,
      _onPurchaseStateChanged,
    );
    ref.listen<StripeCheckoutState>(
      stripeStateProvider,
      _onStripeStateChanged,
    );
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final purchaseState = ref.watch(purchaseStateProvider);
    final stripeState = ref.watch(stripeStateProvider);
    final purchaseManager = ref.read(purchaseManagerProvider);
    final stripeManager = ref.read(stripeManagerProvider);
    final manageService = ref.read(subscriptionManageServiceProvider);
    final syncService = ref.read(subscriptionSyncServiceProvider);
    final remotePlansAsync = ref.watch(subscriptionPlansStreamProvider);
    final remotePlans = ref.watch(subscriptionPlansProvider);
    final effectivePlans = _orderedPlans(
      remotePlans.isNotEmpty ? remotePlans : _fallbackPlans(),
    );
    final currencyCode = _resolveCurrency(context, effectivePlans);
    final selectedPlan = _resolveSelectedPlan(
      effectivePlans,
      subscriptionStatus,
    );
    final highlightedPlan =
        selectedPlan ?? (effectivePlans.isNotEmpty ? effectivePlans.first : null);
    final isProcessing = purchaseState.isProcessing || stripeState.isProcessing;
    final trialAction = (highlightedPlan != null)
        ? () => _startCheckout(
              highlightedPlan,
              currencyCode,
              purchaseManager,
              stripeManager,
            )
        : null;

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
              _buildFreeTrialSection(
                subscriptionStatus,
                highlightedPlan,
                isProcessing,
                trialAction,
              ),

              // 現在のステータス
              _buildCurrentStatusCard(subscriptionStatus, effectivePlans),

              // プラン選択（フォールバックプランを即座に表示、リモートプランはバックグラウンドで読み込み）
              Stack(
                children: [
                  _buildPlanSelection(
                    subscriptionStatus,
                    effectivePlans,
                    currencyCode,
                    highlightedPlan,
                    isProcessing,
                    purchaseManager,
                    stripeManager,
                  ),
                  // リモートプラン読み込み中のインジケーター（小さく表示）
                  if (remotePlansAsync.isLoading && remotePlans.isEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.blackgray.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: AppColors.blue,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              _buildManagementSection(
                isProcessing || _isManagingPlan,
                purchaseState.isRestoring,
                _isSyncing,
                () => purchaseManager.restorePurchases(),
                () => _handleManagePlan(manageService),
                () => _handleManualSync(syncService),
              ),

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

  Widget _buildFreeTrialSection(
    SubscriptionStatus status,
    SubscriptionPlan? highlightedPlan,
    bool isProcessing,
    Future<void> Function()? onStartTrial,
  ) {
    final trialDays = highlightedPlan?.trialDays ?? 7;
    final planLabel = highlightedPlan?.displayName ?? 'Premium Plan';
    final startTrial = onStartTrial;
    final canStartTrial = !status.hasPremiumAccess &&
        !status.isTrialActive &&
        (highlightedPlan?.supportsTrial ?? true) &&
        startTrial != null;
    final VoidCallback? trialTap;
    if (!isProcessing && startTrial != null && canStartTrial) {
      trialTap = () => startTrial();
    } else {
      trialTap = null;
    }
    final buttonLabel = canStartTrial
        ? 'Start $trialDays-Day Free Trial'
        : status.isTrialActive
            ? 'Trial Active'
            : 'Premium Active';

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
            'Start Your $trialDays-Day Free Trial',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Enjoy every $planLabel feature completely free during your trial.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: canStartTrial ? AppColors.blue : AppColors.gray,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: !isProcessing ? trialTap : null,
                borderRadius: BorderRadius.circular(30.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(
    SubscriptionStatus status,
    List<SubscriptionPlan> plans,
  ) {
    final planName =
        _currentPlanName(status, plans) ?? _planDisplayName(status.planType);
    final description = status.isTrialActive
        ? 'トライアル終了: ${_formatDate(status.trialEndAt)}'
        : status.isLifetime
            ? '買い切りで全機能が永久に利用できます'
            : status.hasPremiumAccess && status.nextBillingAt != null
                ? '次回請求: ${_formatDate(status.nextBillingAt)}'
                : 'まだプレミアムに加入していません';

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blackgray,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '現在のステータス',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (status.isTrialActive)
                _buildStatusChip('Trial')
              else if (status.hasPremiumAccess)
                _buildStatusChip('Active'),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection(
    SubscriptionStatus status,
    List<SubscriptionPlan> plans,
    String currencyCode,
    SubscriptionPlan? highlightedPlan,
    bool isProcessing,
    PurchaseManager purchaseManager,
    StripeManager stripeManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Your Plan', style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.md),
        ...plans.map(
          (plan) {
            final price = plan.priceForCurrency(currencyCode) ??
                _firstAvailablePrice(plan.prices);
            final displayPrice = _PlanPriceDisplay.fromPlan(
              plan,
              price,
              currencyCode,
            );
            final isSelected = (highlightedPlan?.id ?? plans.first.id) == plan.id;
            final isCurrentPlan =
                _matchesStatus(plan, status) && status.hasPremiumAccess;
            final isTrialPlan = _matchesStatus(plan, status) && status.isTrialActive;
            Future<void> onPurchase() => _startCheckout(
                  plan,
                  currencyCode,
                  purchaseManager,
                  stripeManager,
                );

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildPlanCard(
                plan: plan,
                isSelected: isSelected,
                isCurrentPlan: isCurrentPlan,
                isTrialPlan: isTrialPlan,
                priceDisplay: displayPrice,
                periodLabel: _periodLabel(plan.interval),
                isBusy: isProcessing && isSelected,
                onTap: () => _handlePlanTap(plan.id),
                onPurchase: onPurchase,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required bool isCurrentPlan,
    required bool isTrialPlan,
    required _PlanPriceDisplay priceDisplay,
    required String periodLabel,
    required VoidCallback onTap,
    required Future<void> Function() onPurchase,
    required bool isBusy,
  }) {
    final buttonLabel = isCurrentPlan
        ? '利用中'
        : isTrialPlan
            ? 'トライアル中'
            : plan.supportsTrial
                ? 'Try for Free'
                : 'Choose Plan';
    final borderColor =
        isSelected ? AppColors.blue : AppColors.gray.withValues(alpha: 0.35);
    final badgeLabel = plan.badge ??
        (plan.isRecommended
            ? 'Recommended'
            : plan.interval == SubscriptionPlanInterval.yearly
                ? 'Best Value'
                : null);
    final badgeColor = _badgeColorForPlan(plan);

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
          onTap: onTap,
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
                              Text(plan.displayName, style: AppTextStyles.h3),
                              if (plan.description != null) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  plan.description!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              SizedBox(height: AppSpacing.xs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    priceDisplay.currentPrice,
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    periodLabel,
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
                    if (priceDisplay.originalPrice != null &&
                        priceDisplay.discountLabel != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            priceDisplay.originalPrice!,
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
                              priceDisplay.discountLabel!,
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
                    InkWell(
                      onTap: isBusy ? null : () => onPurchase(),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.blue : AppColors.blackgray,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: Center(
                          child: isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  buttonLabel,
                                  style: AppTextStyles.body2.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (badgeLabel != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        badgeLabel,
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

  Widget _buildManagementSection(
    bool isProcessing,
    bool isRestoring,
    bool isSyncing,
    VoidCallback onRestore,
    VoidCallback onManage,
    VoidCallback onSync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isProcessing ? null : onManage,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
          child: isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text('プランを変更・解約する'),
        ),
        SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: isRestoring ? null : onRestore,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            side: const BorderSide(color: AppColors.blue),
            foregroundColor: AppColors.blue,
          ),
          child: isRestoring
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
                )
              : const Text('購入状況を復元'),
        ),
        SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: isSyncing ? null : onSync,
          child: isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('最新の状態を同期'),
        ),
      ],
    );
  }

  String _planDisplayName(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.weekly:
        return 'Weekly Plan';
      case SubscriptionPlanType.monthly:
        return 'Monthly Plan';
      case SubscriptionPlanType.yearly:
        return 'Yearly Plan';
      case SubscriptionPlanType.lifetime:
        return 'Lifetime Access';
      case SubscriptionPlanType.free:
        return 'Free Plan';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.year}/${date.month}/${date.day}';
  }

  Widget _buildStatusChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _startCheckout(
    SubscriptionPlan plan,
    String currencyCode,
    PurchaseManager purchaseManager,
    StripeManager stripeManager,
  ) async {
    if (kIsWeb) {
      final successUrl = _resolveReturnUrl('subscription/success');
      final cancelUrl = _resolveReturnUrl('subscription/cancel');
      await stripeManager.checkout(
        plan: plan,
        currencyCode: currencyCode,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
    } else {
      await purchaseManager.purchasePlan(plan);
    }
  }

  void _onPurchaseStateChanged(
    PurchaseState? previous,
    PurchaseState next,
  ) {
    if (next.errorMessage != null &&
        next.errorMessage != previous?.errorMessage) {
      _showSnack(next.errorMessage!);
      ref.read(purchaseManagerProvider).clearMessage();
    } else if (next.completedPlanId != null &&
        next.completedPlanId != previous?.completedPlanId) {
      _showSnack('購入が完了しました');
      ref.read(purchaseManagerProvider).clearMessage();
    }
  }

  void _onStripeStateChanged(
    StripeCheckoutState? previous,
    StripeCheckoutState next,
  ) {
    if (next.errorMessage != null &&
        next.errorMessage != previous?.errorMessage) {
      _showSnack(next.errorMessage!);
      ref.read(stripeManagerProvider).clearMessage();
    } else if (next.lastSessionId != null &&
        next.lastSessionId != previous?.lastSessionId) {
      _showSnack('Stripe Checkoutへリダイレクトしました');
      ref.read(stripeManagerProvider).clearMessage();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _resolveReturnUrl(String path) {
    final uri = Uri.base;
    final buffer = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.host);
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      buffer.write(':${uri.port}');
    }
    buffer.write('/#$path');
    return buffer.toString();
  }

  Future<void> _handleManagePlan(
    SubscriptionManageService manageService,
  ) async {
    setState(() {
      _isManagingPlan = true;
    });
    try {
      if (kIsWeb) {
        final returnUrl = _resolveReturnUrl('subscription/manage');
        await manageService.openStripePortal(returnUrl);
      } else {
        await manageService.openStoreManagementPage();
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isManagingPlan = false;
        });
      }
    }
  }

  Future<void> _handleManualSync(
    SubscriptionSyncService syncService,
  ) async {
    setState(() {
      _isSyncing = true;
    });
    try {
      await syncService.syncNow();
      _showSnack('サブスク状態を同期しました');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _handlePlanTap(String planId) {
    setState(() {
      _manualSelectedPlanId = planId;
      _hasManualSelection = true;
    });
  }

  SubscriptionPlan? _resolveSelectedPlan(
    List<SubscriptionPlan> plans,
    SubscriptionStatus status,
  ) {
    if (plans.isEmpty) return null;
    if (_hasManualSelection && _manualSelectedPlanId != null) {
      return plans
          .firstWhere((plan) => plan.id == _manualSelectedPlanId!, orElse: () => plans.first);
    }
    final interval = _intervalFromStatus(status.planType);
    if (interval == null) {
      return plans.first;
    }
    return plans.firstWhere(
      (plan) => plan.interval == interval,
      orElse: () => plans.first,
    );
  }

  SubscriptionPlanInterval? _intervalFromStatus(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.weekly:
        return SubscriptionPlanInterval.weekly;
      case SubscriptionPlanType.monthly:
        return SubscriptionPlanInterval.monthly;
      case SubscriptionPlanType.yearly:
        return SubscriptionPlanInterval.yearly;
      case SubscriptionPlanType.lifetime:
        return SubscriptionPlanInterval.lifetime;
      case SubscriptionPlanType.free:
        return null;
    }
  }

  bool _matchesStatus(SubscriptionPlan plan, SubscriptionStatus status) {
    final interval = _intervalFromStatus(status.planType);
    if (interval == null) return false;
    return plan.interval == interval;
  }

  String? _currentPlanName(
    SubscriptionStatus status,
    List<SubscriptionPlan> plans,
  ) {
    final plan = _findPlanMatchingStatus(plans, status);
    return plan?.displayName;
  }

  SubscriptionPlan? _findPlanMatchingStatus(
    List<SubscriptionPlan> plans,
    SubscriptionStatus status,
  ) {
    final interval = _intervalFromStatus(status.planType);
    if (interval == null || plans.isEmpty) return null;
    return plans.firstWhere(
      (plan) => plan.interval == interval,
      orElse: () => plans.first,
    );
  }

  List<SubscriptionPlan> _orderedPlans(List<SubscriptionPlan> plans) {
    final order = {
      SubscriptionPlanInterval.weekly: 0,
      SubscriptionPlanInterval.monthly: 1,
      SubscriptionPlanInterval.yearly: 2,
      SubscriptionPlanInterval.lifetime: 3,
    };
    final sorted = [...plans];
    sorted.sort((a, b) {
      final orderA = order[a.interval] ?? 99;
      final orderB = order[b.interval] ?? 99;
      return orderA.compareTo(orderB);
    });
    return sorted;
  }

  List<SubscriptionPlan> _fallbackPlans() {
    return [
      SubscriptionPlan(
        id: 'weekly',
        displayName: 'Weekly',
        interval: SubscriptionPlanInterval.weekly,
        prices: {
          'JPY': const SubscriptionPlanPrice(currencyCode: 'JPY', amount: 350),
        },
        productIds: const {},
        supportsTrial: true,
        trialDays: 7,
      ),
      SubscriptionPlan(
        id: 'monthly',
        displayName: 'Monthly',
        interval: SubscriptionPlanInterval.monthly,
        prices: {
          'JPY': const SubscriptionPlanPrice(currencyCode: 'JPY', amount: 980),
        },
        productIds: const {},
        supportsTrial: true,
        trialDays: 7,
        badge: 'Limited Time Offer',
      ),
      SubscriptionPlan(
        id: 'yearly',
        displayName: 'Yearly',
        interval: SubscriptionPlanInterval.yearly,
        prices: {
          'JPY': const SubscriptionPlanPrice(currencyCode: 'JPY', amount: 14800),
        },
        productIds: const {},
        isRecommended: true,
        supportsTrial: true,
        trialDays: 7,
      ),
      SubscriptionPlan(
        id: 'lifetime',
        displayName: 'Lifetime',
        interval: SubscriptionPlanInterval.lifetime,
        prices: {
          'JPY': const SubscriptionPlanPrice(currencyCode: 'JPY', amount: 24800),
        },
        productIds: const {},
        supportsTrial: false,
        badge: 'Buy once',
      ),
    ];
  }

  String _resolveCurrency(
    BuildContext context,
    List<SubscriptionPlan> plans,
  ) {
    final locale = Localizations.maybeLocaleOf(context);
    final preferred = _currencyFromLocale(locale);
    final hasPreferred = plans.any(
      (plan) => plan.priceForCurrency(preferred) != null,
    );
    if (hasPreferred) return preferred;
    for (final plan in plans) {
      if (plan.prices.isNotEmpty) {
        return plan.prices.keys.first;
      }
    }
    return 'JPY';
  }

  String _currencyFromLocale(Locale? locale) {
    switch (locale?.countryCode) {
      case 'US':
        return 'USD';
      case 'GB':
      case 'IE':
      case 'DE':
      case 'FR':
      case 'ES':
      case 'IT':
      case 'NL':
      case 'BE':
      case 'FI':
      case 'PT':
      case 'AT':
        return 'EUR';
      case 'JP':
      default:
        return 'JPY';
    }
  }

  SubscriptionPlanPrice? _firstAvailablePrice(
    Map<String, SubscriptionPlanPrice> prices,
  ) {
    if (prices.isEmpty) return null;
    return prices.values.first;
  }

  String _periodLabel(SubscriptionPlanInterval interval) {
    switch (interval) {
      case SubscriptionPlanInterval.weekly:
        return '/week';
      case SubscriptionPlanInterval.monthly:
        return '/month';
      case SubscriptionPlanInterval.yearly:
        return '/year';
      case SubscriptionPlanInterval.lifetime:
        return 'one-time';
    }
  }

  Color _badgeColorForPlan(SubscriptionPlan plan) {
    if (plan.badge != null) {
      return AppColors.orange;
    }
    switch (plan.interval) {
      case SubscriptionPlanInterval.weekly:
        return AppColors.green;
      case SubscriptionPlanInterval.monthly:
        return AppColors.orange;
      case SubscriptionPlanInterval.yearly:
        return AppColors.blue;
      case SubscriptionPlanInterval.lifetime:
        return AppColors.purple;
    }
  }

}

class _PlanPriceDisplay {
  const _PlanPriceDisplay({
    required this.currentPrice,
    this.originalPrice,
    this.discountLabel,
  });

  final String currentPrice;
  final String? originalPrice;
  final String? discountLabel;

  static _PlanPriceDisplay fromPlan(
    SubscriptionPlan plan,
    SubscriptionPlanPrice? price,
    String fallbackCurrency,
  ) {
    if (price == null) {
      return _PlanPriceDisplay(currentPrice: '--');
    }
    final promoActive = plan.promo?.isActive ?? false;
    final hasIntro = price.hasIntroductoryPrice;
    final currencyCode = (price.currencyCode.isEmpty
            ? fallbackCurrency
            : price.currencyCode)
        .toUpperCase();

    int effectiveAmount = price.amount;
    String? originalPrice;
    String? discountLabel;

    if (promoActive && (plan.promo?.discountRate ?? 0) > 0) {
      originalPrice = _formatForDisplay(currencyCode, price.amount);
      effectiveAmount =
          (price.amount * (1 - plan.promo!.discountRate)).round();
      discountLabel = '${(plan.promo!.discountRate * 100).round()}% OFF';
    } else if (hasIntro &&
        price.introductoryAmount != null &&
        price.introductoryAmount! < price.amount) {
      originalPrice = _formatForDisplay(currencyCode, price.amount);
      effectiveAmount = price.introductoryAmount!;
      final discountRate =
          (1 - (price.introductoryAmount! / price.amount)) * 100;
      discountLabel = '${discountRate.round()}% OFF';
    }

    return _PlanPriceDisplay(
      currentPrice: _formatForDisplay(currencyCode, effectiveAmount),
      originalPrice: originalPrice,
      discountLabel: discountLabel,
    );
  }

  static String _formatForDisplay(String currencyCode, int amountMinorUnits) {
    final formatter = NumberFormat.simpleCurrency(name: currencyCode);
    final zeroDecimal =
        const {'JPY', 'KRW', 'VND'}.contains(currencyCode.toUpperCase());
    final divisor = zeroDecimal ? 1 : 100;
    final value = amountMinorUnits / divisor;
    return formatter.format(value);
  }
}
