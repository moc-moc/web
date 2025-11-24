import 'package:test_flutter/data/sources/local_storage_source.dart';

/// 端末ごとに最後にアクティブだったユーザーIDを追跡するサービス。
class UserSessionService {
  static const _activeUserKey = 'active_user_uid';

  /// 最後に使用したユーザーIDを保存。
  static Future<void> setActiveUser(String userId) async {
    await SharedMk.saveToSharedPrefs(_activeUserKey, userId);
  }

  /// 保存されているユーザーIDを取得。
  static Future<String?> getActiveUser() async {
    return SharedMk.getFromSharedPrefs(_activeUserKey);
  }

  /// 保存値を削除。
  static Future<void> clearActiveUser() async {
    await SharedMk.removeFromSharedPrefs(_activeUserKey);
  }
}

