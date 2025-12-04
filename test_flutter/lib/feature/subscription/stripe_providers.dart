import 'package:riverpod/riverpod.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:test_flutter/feature/subscription/stripe_service.dart';

final stripeServiceProvider = Provider<StripeService>((ref) {
  return StripeService();
});

final stripeStateProvider = Provider<StripeCheckoutState>((ref) {
  return ref.watch(stripeManagerProvider).state;
});

final stripeManagerProvider = Provider<StripeManager>((ref) {
  final service = ref.watch(stripeServiceProvider);
  return StripeManager(ref, service);
});

class StripeManager {
  StripeManager(this.ref, this._service);

  final Ref ref;
  final StripeService _service;
  StripeCheckoutState _state = const StripeCheckoutState();

  StripeCheckoutState get state => _state;

  Future<void> checkout({
    required SubscriptionPlan plan,
    required String currencyCode,
    required String successUrl,
    required String cancelUrl,
  }) async {
    _updateState(
      (current) => current.copyWith(isProcessing: true, errorMessage: null),
    );
    try {
      final session = await _service.createCheckoutSession(
        plan: plan,
        currencyCode: currencyCode,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
      await _service.redirectToCheckout(session);
      _updateState(
        (current) => current.copyWith(
          isProcessing: false,
          lastSessionId: session.sessionId,
        ),
      );
    } catch (e) {
      _updateState(
        (current) => current.copyWith(
          isProcessing: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearMessage() {
    _updateState(
      (current) => current.copyWith(
        errorMessage: null,
        lastSessionId: null,
      ),
    );
  }

  void _updateState(
    StripeCheckoutState Function(StripeCheckoutState) updater,
  ) {
    _state = updater(_state);
    ref.invalidate(stripeStateProvider);
  }
}

class StripeCheckoutState {
  const StripeCheckoutState({
    this.isProcessing = false,
    this.errorMessage,
    this.lastSessionId,
  });

  static const _unset = Object();

  final bool isProcessing;
  final String? errorMessage;
  final String? lastSessionId;

  StripeCheckoutState copyWith({
    bool? isProcessing,
    Object? errorMessage = _unset,
    Object? lastSessionId = _unset,
  }) {
    return StripeCheckoutState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      lastSessionId: identical(lastSessionId, _unset)
          ? this.lastSessionId
          : lastSessionId as String?,
    );
  }
}

