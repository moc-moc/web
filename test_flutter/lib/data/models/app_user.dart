import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? nickname;
  final int? goalMinutes;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      displayName: data['displayName'] as String?,
      nickname: data['nickname'] as String?,
      goalMinutes: (data['goalMinutes'] as num?)?.toInt(),
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: _decodeTimestamp(data['createdAt']),
      updatedAt: _decodeTimestamp(data['updatedAt']),
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

