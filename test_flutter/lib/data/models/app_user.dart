import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/data/models/subscription_status.dart';

/// Firestore上の `users/{uid}` ドキュメントをアプリ内で扱うためのモデル。
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.nickname,
    this.goalMinutes,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.subscription = const SubscriptionStatus.free(),
    this.roles = const [],
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? nickname;
  final int? goalMinutes;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionStatus subscription;
  final List<String> roles;

  bool get isAdmin => roles.contains('admin');

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final subscriptionData =
        (data['subscription'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final mapForStatus = {
      if (subscriptionData.isEmpty) ...{
        'planType': data['planType'],
        'trialStartAt': data['trialStartAt'],
        'trialEndAt': data['trialEndAt'],
        'nextBillingAt': data['nextBillingAt'],
        'isLifetime': data['isLifetime'],
        'promoLabel': data['promoLabel'],
      } else
        ...subscriptionData,
    };
    return AppUser(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      displayName: data['displayName'] as String?,
      nickname: data['nickname'] as String?,
      goalMinutes: (data['goalMinutes'] as num?)?.toInt(),
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: _decodeTimestamp(data['createdAt']),
      updatedAt: _decodeTimestamp(data['updatedAt']),
      subscription: SubscriptionStatus.fromMap(mapForStatus),
      roles: (data['roles'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'nickname': nickname,
      'goalMinutes': goalMinutes,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'planType': subscription.planType.name,
      'trialStartAt': subscription.trialStartAt != null
          ? Timestamp.fromDate(subscription.trialStartAt!)
          : null,
      'trialEndAt': subscription.trialEndAt != null
          ? Timestamp.fromDate(subscription.trialEndAt!)
          : null,
      'nextBillingAt': subscription.nextBillingAt != null
          ? Timestamp.fromDate(subscription.nextBillingAt!)
          : null,
      'isLifetime': subscription.isLifetime,
      if (subscription.promoLabel != null) 'promoLabel': subscription.promoLabel,
      'roles': roles,
      'subscription': subscription.toMap(),
    };
  }

  AppUser copyWith({
    String? email,
    String? displayName,
    String? nickname,
    int? goalMinutes,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionStatus? subscription,
    List<String>? roles,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscription: subscription ?? this.subscription,
      roles: roles ?? this.roles,
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

