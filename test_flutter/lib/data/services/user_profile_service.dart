import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore上の`users/{uid}`ドキュメントを管理するサービス
class UserProfileService {
  UserProfileService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// サインイン直後にユーザードキュメントを作成または更新する
  static Future<void> upsertUserDocument(
    User user, {
    required String providerId,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final now = FieldValue.serverTimestamp();

    final payload = <String, dynamic>{
      'provider': providerId,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'updatedAt': now,
    };

    if (snapshot.exists) {
      await docRef.set(payload, SetOptions(merge: true));
    } else {
      await docRef.set({...payload, 'createdAt': now});
    }
  }
}
