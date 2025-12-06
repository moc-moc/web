import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// SecureStorage関連の汎用的な基本関数
/// 
/// 認証情報を安全に保存・取得するための関数群
/// 認証状態の復元機能も含む
/// 
/// Webプラットフォームでは、HTTPSまたはlocalhost環境でのみ動作します。
/// それ以外の環境では、OperationErrorが発生する可能性があります。
/// 
/// 注意: Webプラットフォームでは、`flutter_secure_storage_web`が自動的に使用されます。
/// WebCrypto APIを使用してデータを暗号化し、localStorageに保存します。
class SecureStorageMk {
  // FlutterSecureStorageのインスタンス
  // Webプラットフォームでは、デフォルト設定でWeb用の実装が自動的に使用されます
  // Webプラットフォームでは、HTTPSまたはlocalhost環境でのみ動作します
  static const _storage = FlutterSecureStorage();
  
  // キー定数
  static const String _userIdKey = 'user_id';
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _displayNameKey = 'display_name';
  static const String _photoUrlKey = 'photo_url';
  
  /// キーバリューペアでSecureStorageに保存
  /// 
  /// 指定されたキーと値のペアをSecureStorageに保存する
  /// 汎用的な保存関数として使用可能
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱う
  static Future<void> saveToSecureStorage(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('✅ SecureStorageに保存: $key');
    } catch (e) {
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ SecureStorage保存警告（Web）: $key - $errorMessage');
      } else {
        debugPrint('❌ SecureStorage保存エラー: $key - $errorMessage');
      }
    }
  }
  
  /// キーから値をSecureStorageから取得
  /// 
  /// 指定されたキーに対応する値をSecureStorageから取得する
  /// キーが存在しない場合はnullを返す
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱い、nullを返す
  static Future<String?> readFromSecureStorage(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // Webプラットフォームでは、OperationErrorは通常の動作の一部として扱う
      // キーが存在しない場合や、SecureStorageが利用できない場合に発生する可能性がある
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ SecureStorage読み込み警告（Web）: $key - $errorMessage');
      } else {
        debugPrint('❌ SecureStorage読み込みエラー: $key - $errorMessage');
      }
      return null;
    }
  }
  
  /// 特定のキーをSecureStorageから削除
  /// 
  /// 指定されたキーとその値をSecureStorageから削除する
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱う
  static Future<void> deleteFromSecureStorage(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint('✅ SecureStorageから削除: $key');
    } catch (e) {
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ SecureStorage削除警告（Web）: $key - $errorMessage');
      } else {
        debugPrint('❌ SecureStorage削除エラー: $key - $errorMessage');
      }
    }
  }
  
  /// 全データをSecureStorageから削除
  /// 
  /// SecureStorageに保存されている全てのデータを削除する
  /// ログアウト時などに使用する
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱う
  static Future<void> deleteAllSecureStorage() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ SecureStorage全データ削除完了');
    } catch (e) {
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ SecureStorage全削除警告（Web）: $errorMessage');
      } else {
        debugPrint('❌ SecureStorage全削除エラー: $errorMessage');
      }
    }
  }
  
  /// ユーザー情報を一括でSecureStorageに保存
  /// 
  /// 認証に必要なユーザー情報を一括で保存する
  /// 個別のキーで並列保存を行う
  static Future<void> saveUserInfoToStorage({
    required String userId,
    required String email,
    required String displayName,
    String? token,
    String? photoUrl,
  }) async {
    try {
      await Future.wait([
        saveToSecureStorage(_userIdKey, userId),
        saveToSecureStorage(_emailKey, email),
        saveToSecureStorage(_displayNameKey, displayName),
        if (token != null) saveToSecureStorage(_tokenKey, token),
        if (photoUrl != null) saveToSecureStorage(_photoUrlKey, photoUrl),
      ]);
      debugPrint('✅ ユーザー情報一括保存完了');
    } catch (e) {
      debugPrint('❌ ユーザー情報一括保存エラー: $e');
    }
  }
  
  /// ユーザー情報を一括でSecureStorageから取得
  /// 
  /// 保存されているユーザー情報を一括で取得する
  /// 各キーを並列で読み込んでMap形式で返す
  static Future<Map<String, String?>> getUserInfoFromStorage() async {
    try {
      final results = await Future.wait([
        readFromSecureStorage(_userIdKey),
        readFromSecureStorage(_emailKey),
        readFromSecureStorage(_displayNameKey),
        readFromSecureStorage(_tokenKey),
        readFromSecureStorage(_photoUrlKey),
      ]);
      
      return {
        'userId': results[0],
        'email': results[1],
        'displayName': results[2],
        'token': results[3],
        'photoUrl': results[4],
      };
    } catch (e) {
      debugPrint('❌ ユーザー情報一括取得エラー: $e');
      return {};
    }
  }
  
  /// 有効な認証情報が保存されているかチェック
  /// 
  /// SecureStorageに有効な認証情報（userIdとtoken）が保存されているか確認する
  /// 両方が存在する場合のみtrueを返す
  static Future<bool> hasValidStoredAuth() async {
    try {
      final userInfo = await getUserInfoFromStorage();
      final hasUserId = userInfo['userId'] != null && userInfo['userId']!.isNotEmpty;
      final hasToken = userInfo['token'] != null && userInfo['token']!.isNotEmpty;
      return hasUserId && hasToken;
    } catch (e) {
      debugPrint('❌ 認証情報チェックエラー: $e');
      return false;
    }
  }
  
  /// トークンのみを更新
  /// 
  /// 既存のユーザー情報は保持したまま、トークンのみを更新する
  static Future<void> updateToken(String token) async {
    try {
      await saveToSecureStorage(_tokenKey, token);
      debugPrint('✅ トークンのみ更新完了');
    } catch (e) {
      debugPrint('❌ トークン更新エラー: $e');
    }
  }
  
  /// SecureStorageから認証状態を復元
  /// 
  /// 保存されている認証情報を確認し、有効な場合はtrueを返す
  /// 実際のFirebase認証状態の復元は行わない（確認のみ）
  static Future<bool> restoreAuthFromStorage() async {
    try {
      final hasValidAuth = await hasValidStoredAuth();
      if (hasValidAuth) {
        debugPrint('✅ 保存された認証状態を確認しました');
        return true;
      } else {
        debugPrint('ℹ️ 保存された認証情報が見つからないか無効です');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 認証状態復元エラー: $e');
      return false;
    }
  }
  
  /// 特定のキーが存在するかチェック
  /// 
  /// 指定されたキーがSecureStorageに存在するか確認する
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱い、falseを返す
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ キー存在チェック警告（Web）: $key - $errorMessage');
      } else {
        debugPrint('❌ キー存在チェックエラー: $key - $errorMessage');
      }
      return false;
    }
  }
  
  /// 全てのキーを取得
  /// 
  /// SecureStorageに保存されている全てのキーを取得する
  /// デバッグ用途などで使用
  /// Webプラットフォームでは、SecureStorageが完全にサポートされていない場合があるため、
  /// OperationErrorは警告として扱い、空のMapを返す
  static Future<Map<String, String>> getAllKeys() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      final errorMessage = e.toString();
      if (kIsWeb && errorMessage.contains('OperationError')) {
        // Webプラットフォームでは警告レベルに下げる（デバッグ時のみ表示）
        debugPrint('⚠️ 全キー取得警告（Web）: $errorMessage');
      } else {
        debugPrint('❌ 全キー取得エラー: $errorMessage');
      }
      return {};
    }
  }
}
