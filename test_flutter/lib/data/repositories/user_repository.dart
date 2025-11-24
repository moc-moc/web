import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/models/app_user.dart';

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  Future<AppUser?> fetchUser(String uid) async {
    final snapshot = await _collection.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return AppUser.fromMap(snapshot.id, data);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> createOrUpdateUser(AppUser user) async {
    await _collection.doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> writeInitialProfile({
    required User firebaseUser,
    String? nickname,
    int? goalMinutes,
  }) async {
    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      nickname: nickname,
      goalMinutes: goalMinutes,
      emailVerified: firebaseUser.emailVerified,
    );
    await createOrUpdateUser(appUser);
  }

  Future<void> updateProfileFields(
    String uid, {
    String? nickname,
    int? goalMinutes,
    bool? emailVerified,
  }) async {
    final payload = <String, dynamic>{
      if (nickname != null) 'nickname': nickname,
      if (goalMinutes != null) 'goalMinutes': goalMinutes,
      if (emailVerified != null) 'emailVerified': emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _collection.doc(uid).set(payload, SetOptions(merge: true));
  }
}

