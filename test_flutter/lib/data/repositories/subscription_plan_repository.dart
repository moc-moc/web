import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';

/// Firestore上のプラン設定を取得するリポジトリ
class SubscriptionPlanRepository {
  SubscriptionPlanRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('plans');

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => SubscriptionPlan.fromFirestore(doc))
        .toList();
  }

  Stream<List<SubscriptionPlan>> watchPlans() {
    return _collection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => SubscriptionPlan.fromFirestore(doc))
            .toList();
      },
    );
  }

  Future<SubscriptionPlan?> fetchPlan(String planId) async {
    final doc = await _collection.doc(planId).get();
    if (!doc.exists) return null;
    return SubscriptionPlan.fromFirestore(doc);
  }
}

