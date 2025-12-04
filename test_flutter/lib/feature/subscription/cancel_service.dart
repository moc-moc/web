import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart';

/// プラン変更・解約に関するユーティリティ
class SubscriptionManageService {
  SubscriptionManageService({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> openStoreManagementPage() async {
    final uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Platform.isAndroid
            ? Uri.parse(
                'https://play.google.com/store/account/subscriptions',
              )
            : null;
    if (uri == null) {
      throw Exception('このプラットフォームではストア管理ページを開けません。');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openStripePortal(String returnUrl) async {
    final callable = _functions.httpsCallable('createStripePortalSession');
    final result = await callable.call<Map<String, dynamic>>({
      'returnUrl': returnUrl,
    });
    final url = result.data['url'] as String? ?? '';
    if (url.isEmpty) {
      throw Exception('StripeポータルURLを取得できませんでした。');
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }
}

final subscriptionManageServiceProvider =
    Provider<SubscriptionManageService>((ref) {
  return SubscriptionManageService();
});

