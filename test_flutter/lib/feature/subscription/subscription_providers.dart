import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/models/subscription_plan.dart';
import 'package:test_flutter/data/models/subscription_status.dart';
import 'package:test_flutter/data/repositories/subscription_plan_repository.dart';
import 'package:test_flutter/feature/auth/auth_controller.dart';

final subscriptionStatusStreamProvider =
    StreamProvider<SubscriptionStatus>((ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.firebaseUser;
  if (user == null) {
    return Stream<SubscriptionStatus>.value(const SubscriptionStatus.free());
  }
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUser(user.uid).map(
        (appUser) => appUser?.subscription ?? const SubscriptionStatus.free(),
      );
});

final subscriptionStatusProvider = Provider<SubscriptionStatus>((ref) {
  final asyncStatus = ref.watch(subscriptionStatusStreamProvider);
  return asyncStatus.value ?? const SubscriptionStatus.free();
});

final subscriptionPlanRepositoryProvider =
    Provider<SubscriptionPlanRepository>((ref) {
  return SubscriptionPlanRepository();
});

final subscriptionPlansStreamProvider =
    StreamProvider<List<SubscriptionPlan>>((ref) {
  final repository = ref.watch(subscriptionPlanRepositoryProvider);
  return repository.watchPlans();
});

final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  final asyncPlans = ref.watch(subscriptionPlansStreamProvider);
  return asyncPlans.value ?? const <SubscriptionPlan>[];
});


