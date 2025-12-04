import 'package:cloud_firestore/cloud_firestore.dart';

/// 対応プランの課金周期
enum SubscriptionPlanInterval {
  weekly,
  monthly,
  yearly,
  lifetime,
}

/// 通貨別の価格設定
class SubscriptionPlanPrice {
  const SubscriptionPlanPrice({
    required this.currencyCode,
    required this.amount,
    this.introductoryAmount,
    this.introductoryDurationDays,
  });

  /// ISO 4217形式（例: JPY, USD, EUR）
  final String currencyCode;

  /// 通常価格（最小通貨単位, 例: 980 => ¥980）
  final int amount;

  /// 初回のみの割引価格（最小通貨単位）
  final int? introductoryAmount;

  /// 初回割引の適用日数（例: 7日間）
  final int? introductoryDurationDays;

  bool get hasIntroductoryPrice =>
      introductoryAmount != null && introductoryAmount! > 0;

  SubscriptionPlanPrice copyWith({
    String? currencyCode,
    int? amount,
    int? introductoryAmount,
    int? introductoryDurationDays,
  }) {
    return SubscriptionPlanPrice(
      currencyCode: currencyCode ?? this.currencyCode,
      amount: amount ?? this.amount,
      introductoryAmount: introductoryAmount ?? this.introductoryAmount,
      introductoryDurationDays:
          introductoryDurationDays ?? this.introductoryDurationDays,
    );
  }

  factory SubscriptionPlanPrice.fromMap(
    String currencyCode,
    Map<String, dynamic> data,
  ) {
    return SubscriptionPlanPrice(
      currencyCode: currencyCode.toUpperCase(),
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      introductoryAmount: (data['introductoryAmount'] as num?)?.toInt(),
      introductoryDurationDays:
          (data['introductoryDurationDays'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      if (introductoryAmount != null) 'introductoryAmount': introductoryAmount,
      if (introductoryDurationDays != null)
        'introductoryDurationDays': introductoryDurationDays,
    };
  }
}

/// 期間限定の割引情報
class SubscriptionPlanPromo {
  const SubscriptionPlanPromo({
    required this.discountRate,
    this.startsAt,
    this.endsAt,
    this.label,
  });

  /// 0.5 => 50%OFF
  final double discountRate;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? label;

  bool get isActive {
    final now = DateTime.now();
    final hasStarted = startsAt == null || !now.isBefore(startsAt!);
    final notEnded = endsAt == null || !now.isAfter(endsAt!);
    return hasStarted && notEnded;
  }

  factory SubscriptionPlanPromo.fromMap(Map<String, dynamic> data) {
    return SubscriptionPlanPromo(
      discountRate: (data['discountRate'] as num?)?.toDouble() ?? 0,
      startsAt: _decodeTimestamp(data['startsAt']),
      endsAt: _decodeTimestamp(data['endsAt']),
      label: data['label'] as String?,
    );
  }

  static DateTime? _decodeTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Firestore上の `plans/{planId}` を表現するモデル
class SubscriptionPlan {
  SubscriptionPlan({
    required this.id,
    required this.displayName,
    required this.interval,
    required this.prices,
    required this.productIds,
    this.isRecommended = false,
    this.supportsTrial = false,
    this.trialDays,
    this.promo,
    this.badge,
    this.description,
  });

  final String id;
  final String displayName;
  final SubscriptionPlanInterval interval;
  final Map<String, SubscriptionPlanPrice> prices;
  final Map<String, String> productIds;
  final bool isRecommended;
  final bool supportsTrial;
  final int? trialDays;
  final SubscriptionPlanPromo? promo;
  final String? badge;
  final String? description;

  SubscriptionPlanPrice? priceForCurrency(String currencyCode) {
    return prices[currencyCode.toUpperCase()];
  }

  String? productIdForPlatform(String platformKey) {
    return productIds[platformKey];
  }

  factory SubscriptionPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return SubscriptionPlan(
      id: snapshot.id,
      displayName: data['displayName'] as String? ?? snapshot.id,
      interval: _intervalFromString(data['interval'] as String?),
      prices: _parsePrices(data['prices']),
      productIds: _parseProductIds(data['productIds']),
      isRecommended: data['isRecommended'] as bool? ?? false,
      supportsTrial: data['supportsTrial'] as bool? ?? false,
      trialDays: (data['trialDays'] as num?)?.toInt(),
      promo: _parsePromo(data['promo']),
      badge: data['badge'] as String?,
      description: data['description'] as String?,
    );
  }

  static Map<String, SubscriptionPlanPrice> _parsePrices(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return {};
    }
    final parsed = <String, SubscriptionPlanPrice>{};
    raw.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsed[key.toUpperCase()] = SubscriptionPlanPrice.fromMap(
          key,
          value,
        );
      }
    });
    return parsed;
  }

  static Map<String, String> _parseProductIds(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return {};
    }
    final result = <String, String>{};
    raw.forEach((key, value) {
      if (value is String && value.isNotEmpty) {
        result[key] = value;
      }
    });
    return result;
  }

  static SubscriptionPlanPromo? _parsePromo(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return SubscriptionPlanPromo.fromMap(raw);
    }
    return null;
  }

  static SubscriptionPlanInterval _intervalFromString(String? value) {
    switch (value) {
      case 'weekly':
        return SubscriptionPlanInterval.weekly;
      case 'monthly':
        return SubscriptionPlanInterval.monthly;
      case 'yearly':
        return SubscriptionPlanInterval.yearly;
      case 'lifetime':
        return SubscriptionPlanInterval.lifetime;
      default:
        return SubscriptionPlanInterval.monthly;
    }
  }
}

