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
    this.fixedPrices,
    this.introductoryFixedPrices,
  });

  /// 0.5 => 50%OFF（fixedPricesが設定されている場合は無視される）
  final double discountRate;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? label;
  
  /// 通貨別の固定価格（期間限定価格）
  /// 例: {'JPY': 980, 'USD': 9, 'EUR': 8}
  /// fixedPricesが設定されている場合、discountRateではなく固定価格が使用される
  final Map<String, int>? fixedPrices;
  
  /// 通貨別の初回限定固定価格（期間限定かつ初回購入時のみ）
  /// 例: {'JPY': 980, 'USD': 9, 'EUR': 8}
  /// 期間中に初回購入する場合のみこの価格が適用される
  /// 2回目以降は通常価格（amount）が適用される
  final Map<String, int>? introductoryFixedPrices;

  bool get isActive {
    final now = DateTime.now();
    final hasStarted = startsAt == null || !now.isBefore(startsAt!);
    final notEnded = endsAt == null || !now.isAfter(endsAt!);
    return hasStarted && notEnded;
  }
  
  /// 指定された通貨の固定価格を取得
  int? fixedPriceForCurrency(String currencyCode) {
    if (fixedPrices == null) return null;
    return fixedPrices![currencyCode.toUpperCase()];
  }
  
  /// 指定された通貨の初回限定固定価格を取得
  int? introductoryFixedPriceForCurrency(String currencyCode) {
    if (introductoryFixedPrices == null) return null;
    return introductoryFixedPrices![currencyCode.toUpperCase()];
  }
  
  /// 固定価格が設定されているかどうか
  bool get hasFixedPrices => fixedPrices != null && fixedPrices!.isNotEmpty;
  
  /// 初回限定固定価格が設定されているかどうか
  bool get hasIntroductoryFixedPrices => 
      introductoryFixedPrices != null && introductoryFixedPrices!.isNotEmpty;

  factory SubscriptionPlanPromo.fromMap(Map<String, dynamic> data) {
    final fixedPricesRaw = data['fixedPrices'];
    Map<String, int>? fixedPrices;
    if (fixedPricesRaw is Map<String, dynamic>) {
      fixedPrices = {};
      fixedPricesRaw.forEach((key, value) {
        if (value is num) {
          fixedPrices![key.toUpperCase()] = value.toInt();
        }
      });
    }
    
    final introductoryFixedPricesRaw = data['introductoryFixedPrices'];
    Map<String, int>? introductoryFixedPrices;
    if (introductoryFixedPricesRaw is Map<String, dynamic>) {
      introductoryFixedPrices = {};
      introductoryFixedPricesRaw.forEach((key, value) {
        if (value is num) {
          introductoryFixedPrices![key.toUpperCase()] = value.toInt();
        }
      });
    }
    
    // startsAtとstartAtの両方に対応（後方互換性のため）
    final startsAtValue = data['startsAt'] ?? data['startAt'];
    
    return SubscriptionPlanPromo(
      discountRate: (data['discountRate'] as num?)?.toDouble() ?? 0,
      startsAt: _decodeTimestamp(startsAtValue),
      endsAt: _decodeTimestamp(data['endsAt']),
      label: data['label'] as String?,
      fixedPrices: fixedPrices,
      introductoryFixedPrices: introductoryFixedPrices,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'discountRate': discountRate,
      if (startsAt != null) 'startsAt': Timestamp.fromDate(startsAt!),
      if (endsAt != null) 'endsAt': Timestamp.fromDate(endsAt!),
      if (label != null) 'label': label,
      if (fixedPrices != null && fixedPrices!.isNotEmpty)
        'fixedPrices': fixedPrices,
      if (introductoryFixedPrices != null && introductoryFixedPrices!.isNotEmpty)
        'introductoryFixedPrices': introductoryFixedPrices,
    };
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

