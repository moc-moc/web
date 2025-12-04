import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlanType {
  free,
  weekly,
  monthly,
  yearly,
  lifetime,
}

class SubscriptionStatus {
  static const _unset = Object();

  const SubscriptionStatus({
    required this.planType,
    this.trialStartAt,
    this.trialEndAt,
    this.nextBillingAt,
    this.isLifetime = false,
    this.promoLabel,
  });

  const SubscriptionStatus.free()
      : this(
          planType: SubscriptionPlanType.free,
        );

  final SubscriptionPlanType planType;
  final DateTime? trialStartAt;
  final DateTime? trialEndAt;
  final DateTime? nextBillingAt;
  final bool isLifetime;
  final String? promoLabel;

  bool get isTrialActive {
    if (trialEndAt == null) return false;
    return trialEndAt!.isAfter(DateTime.now());
  }

  bool get isRecurringPlan =>
      planType == SubscriptionPlanType.weekly ||
      planType == SubscriptionPlanType.monthly ||
      planType == SubscriptionPlanType.yearly;

  bool get hasPremiumAccess =>
      isLifetime ||
      planType == SubscriptionPlanType.lifetime ||
      planType == SubscriptionPlanType.weekly ||
      planType == SubscriptionPlanType.monthly ||
      planType == SubscriptionPlanType.yearly ||
      isTrialActive;

  SubscriptionStatus copyWith({
    SubscriptionPlanType? planType,
    Object? trialStartAt = _unset,
    Object? trialEndAt = _unset,
    Object? nextBillingAt = _unset,
    bool? isLifetime,
    Object? promoLabel = _unset,
  }) {
    return SubscriptionStatus(
      planType: planType ?? this.planType,
      trialStartAt: trialStartAt == _unset
          ? this.trialStartAt
          : trialStartAt as DateTime?,
      trialEndAt: trialEndAt == _unset
          ? this.trialEndAt
          : trialEndAt as DateTime?,
      nextBillingAt: nextBillingAt == _unset
          ? this.nextBillingAt
          : nextBillingAt as DateTime?,
      isLifetime: isLifetime ?? this.isLifetime,
      promoLabel: promoLabel == _unset ? this.promoLabel : promoLabel as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planType': planType.name,
      'trialStartAt':
          trialStartAt != null ? Timestamp.fromDate(trialStartAt!) : null,
      'trialEndAt': trialEndAt != null ? Timestamp.fromDate(trialEndAt!) : null,
      'nextBillingAt':
          nextBillingAt != null ? Timestamp.fromDate(nextBillingAt!) : null,
      'isLifetime': isLifetime,
      if (promoLabel != null) 'promoLabel': promoLabel,
    };
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const SubscriptionStatus.free();
    }
    return SubscriptionStatus(
      planType: _planTypeFromString(data['planType'] as String?),
      trialStartAt: _decodeTimestamp(data['trialStartAt']),
      trialEndAt: _decodeTimestamp(data['trialEndAt']),
      nextBillingAt: _decodeTimestamp(data['nextBillingAt']),
      isLifetime: data['isLifetime'] as bool? ?? false,
      promoLabel: data['promoLabel'] as String?,
    );
  }

  static SubscriptionPlanType _planTypeFromString(String? value) {
    if (value == null) return SubscriptionPlanType.free;
    return SubscriptionPlanType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SubscriptionPlanType.free,
    );
  }

  static DateTime? _decodeTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}


