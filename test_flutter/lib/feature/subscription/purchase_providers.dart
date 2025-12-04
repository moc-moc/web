import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:test_flutter/feature/subscription/purchase_service.dart';
import 'package:test_flutter/feature/subscription/subscription_sync_service.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

final purchaseStateProvider = Provider<PurchaseState>((ref) {
  return ref.watch(purchaseManagerProvider).state;
});

final purchaseManagerProvider = Provider<PurchaseManager>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  final syncService = ref.watch(subscriptionSyncServiceProvider);
  final manager = PurchaseManager(ref, service, syncService);
  ref.onDispose(manager.dispose);
  return manager;
});

class PurchaseManager {
  PurchaseManager(this.ref, this._service, this._syncService) {
    _subscription = _service.purchaseStream.listen(_handlePurchaseUpdates);
  }

  final Ref ref;
  final PurchaseService _service;
  final SubscriptionSyncService _syncService;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  PurchaseState _state = const PurchaseState();

  PurchaseState get state => _state;

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    _updateState(
      (current) => current.copyWith(
        isProcessing: true,
        errorMessage: null,
        pendingPlanId: plan.id,
      ),
    );
    try {
      await _service.buyPlan(plan);
    } catch (e) {
      _updateState(
        (current) => current.copyWith(
          isProcessing: false,
          errorMessage: e.toString(),
          pendingPlanId: null,
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    _updateState(
      (current) => current.copyWith(isRestoring: true, errorMessage: null),
    );
    try {
      await _service.restorePurchases();
    } catch (e) {
      _updateState(
        (current) => current.copyWith(
          isRestoring: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearMessage() {
    _updateState(
      (current) => current.copyWith(
        errorMessage: null,
        completedPlanId: null,
      ),
    );
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _updateState((current) => current.copyWith(isProcessing: true));
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _processSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _updateState(
            (current) => current.copyWith(
              isProcessing: false,
              isRestoring: false,
              errorMessage: purchase.error?.message ?? 'Purchase failed.',
              pendingPlanId: null,
            ),
          );
          break;
      }
    }
  }

  Future<void> _processSuccessfulPurchase(PurchaseDetails details) async {
    final plan = _planForProduct(details.productID);
    try {
      await _service.verifyWithServer(details, plan);
      await _service.completePurchase(details);
      await _syncService.syncNow();
      _updateState(
        (current) => current.copyWith(
          isProcessing: false,
          isRestoring: false,
          completedPlanId: plan?.id,
          pendingPlanId: null,
        ),
      );
    } catch (e) {
      _updateState(
        (current) => current.copyWith(
          isProcessing: false,
          isRestoring: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  SubscriptionPlan? _planForProduct(String productId) {
    final plans = ref.read(subscriptionPlansProvider);
    for (final plan in plans) {
      if (plan.productIds.values.contains(productId)) {
        return plan;
      }
    }
    return null;
  }

  void _updateState(PurchaseState Function(PurchaseState) updater) {
    _state = updater(_state);
    ref.invalidate(purchaseStateProvider);
  }

  void dispose() {
    _subscription.cancel();
  }
}

class PurchaseState {
  const PurchaseState({
    this.isProcessing = false,
    this.isRestoring = false,
    this.errorMessage,
    this.completedPlanId,
    this.pendingPlanId,
  });

  static const _unset = Object();

  final bool isProcessing;
  final bool isRestoring;
  final String? errorMessage;
  final String? completedPlanId;
  final String? pendingPlanId;

  PurchaseState copyWith({
    bool? isProcessing,
    bool? isRestoring,
    Object? errorMessage = _unset,
    Object? completedPlanId = _unset,
    Object? pendingPlanId = _unset,
  }) {
    return PurchaseState(
      isProcessing: isProcessing ?? this.isProcessing,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage:
          identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      completedPlanId: identical(completedPlanId, _unset)
          ? this.completedPlanId
          : completedPlanId as String?,
      pendingPlanId: identical(pendingPlanId, _unset)
          ? this.pendingPlanId
          : pendingPlanId as String?,
    );
  }
}

