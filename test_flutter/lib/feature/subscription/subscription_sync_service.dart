import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubscriptionSyncService {
  SubscriptionSyncService({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> syncNow() async {
    final callable = _functions.httpsCallable('syncSubscriptionStatus');
    await callable.call();
  }
}

final subscriptionSyncServiceProvider =
    Provider<SubscriptionSyncService>((ref) {
  return SubscriptionSyncService();
});

