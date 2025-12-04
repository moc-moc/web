import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:universal_io/io.dart';

/// in_app_purchase をラップして、プラットフォームごとの商品ID解決と
/// キャッシュを提供するサービスクラス
class PurchaseService {
  PurchaseService({
    InAppPurchase? iap,
    FirebaseFunctions? functions,
  })  : _iap = iap ?? InAppPurchase.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final InAppPurchase _iap;
  final FirebaseFunctions _functions;
  final Map<String, ProductDetails> _productCache = {};

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts(Set<String> productIds) async {
    if (productIds.isEmpty) return const [];
    final response = await _iap.queryProductDetails(productIds);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
    for (var product in response.productDetails) {
      _productCache[product.id] = product;
    }
    return response.productDetails;
  }

  Future<ProductDetails> _getProduct(String productId) async {
    if (_productCache.containsKey(productId)) {
      return _productCache[productId]!;
    }
    final products = await queryProducts({productId});
    if (products.isEmpty) {
      throw Exception('商品$productIdが見つかりませんでした。');
    }
    return products.first;
  }

  Future<void> buyPlan(SubscriptionPlan plan) async {
    final productId = _productIdForCurrentPlatform(plan);
    if (productId == null || productId.isEmpty) {
      throw UnsupportedError('このプラットフォームでは購入できません。');
    }
    final product = await _getProduct(productId);
    final param = PurchaseParam(productDetails: product);
    final success = await _iap.buyNonConsumable(purchaseParam: param);
    if (!success) {
      throw Exception('購入処理を開始できませんでした。');
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }

  Future<void> verifyWithServer(
    PurchaseDetails details,
    SubscriptionPlan? plan,
  ) async {
    final functionName = Platform.isIOS
        ? 'verifyAppleReceipt'
        : Platform.isAndroid
            ? 'verifyGooglePlayReceipt'
            : null;
    if (functionName == null) {
      return;
    }
    final callable = _functions.httpsCallable(functionName);
    final payload = Platform.isIOS
        ? {
            'planId': plan?.id,
            'receipt': details.verificationData.serverVerificationData,
          }
        : {
            'planId': plan?.id,
            'purchaseToken': details.verificationData.serverVerificationData,
          };
    await callable.call(payload);
  }

  String? _productIdForCurrentPlatform(SubscriptionPlan plan) {
    if (Platform.isIOS) {
      return plan.productIdForPlatform('ios');
    } else if (Platform.isAndroid) {
      return plan.productIdForPlatform('android');
    }
    return null;
  }
}

