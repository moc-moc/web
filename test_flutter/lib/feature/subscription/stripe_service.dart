import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeCheckoutSession {
  const StripeCheckoutSession({
    required this.sessionId,
    required this.checkoutUrl,
  });

  final String sessionId;
  final String checkoutUrl;

  factory StripeCheckoutSession.fromMap(Map<String, dynamic> data) {
    return StripeCheckoutSession(
      sessionId: data['sessionId'] as String? ?? '',
      checkoutUrl: data['checkoutUrl'] as String? ?? '',
    );
  }
}

class StripeService {
  StripeService({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<StripeCheckoutSession> createCheckoutSession({
    required SubscriptionPlan plan,
    required String currencyCode,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final callable = _functions.httpsCallable('createStripeCheckoutSession');
    final result = await callable.call<Map<String, dynamic>>({
      'planId': plan.id,
      'currency': currencyCode,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    });
    final data = Map<String, dynamic>.from(result.data);
    return StripeCheckoutSession.fromMap(data);
  }

  Future<void> redirectToCheckout(StripeCheckoutSession session) async {
    final url = session.checkoutUrl;
    if (url.isEmpty) {
      throw Exception('Stripe Checkout URLが取得できませんでした。');
    }
    final uri = Uri.parse(url);
    final mode =
        kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;
    final launched = await launchUrl(uri, mode: mode);
    if (!launched) {
      throw Exception('Stripe Checkoutを開けませんでした。');
    }
  }
}

