import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/Feature/Total/total_functions.dart';

/// アプリ全体で1回だけ呼び出すグローバル初期化関数
class AppInitUN {
  static ProviderContainer? _globalContainer;
  
  /// グローバルなProviderContainerを設定
  static void setGlobalContainer(ProviderContainer container) {
    _globalContainer = container;
    debugPrint('✅ グローバルProviderContainerを設定しました');
  }
  
  /// グローバルなProviderContainerを取得
  static ProviderContainer? getGlobalContainer() {
    return _globalContainer;
  }

  /// アプリ起動時の包括的な初期化
  static Future<AppContext?> initializeWithAuth() async {
    try {
      final userInfo = await AuthServiceUN.initializeAuth();
      
      if (userInfo == null) {
        return null;
      }
      
      final appContext = await initialize();
      
      await _loadCountdownData();
      await _loadStreakData();
      await _loadGoalData();
      await _loadTotalData();
      await _loadSettingsData();
      
      return appContext;
    } catch (e) {
      debugPrint('❌ アプリ包括的初期化エラー: $e');
      return null;
    }
  }

  static Future<void> _loadCountdownData() async {
    try {
      debugPrint('🔍 [_loadCountdownData] 開始');
      
      final container = getGlobalContainer();
      
      if (container == null) {
        debugPrint('⚠️ [_loadCountdownData] ProviderContainerが設定されていません');
        return;
      }
      debugPrint('🔍 [_loadCountdownData] ProviderContainer取得成功');
      
      debugPrint('🔄 [_loadCountdownData] カウントダウンデータを同期中...');
      final countdowns = await syncCountdownsHelper(container);
      debugPrint('✅ [_loadCountdownData] カウントダウンデータ読み込み完了: ${countdowns.length}件');
      
    } catch (e) {
      debugPrint('❌ [_loadCountdownData] カウントダウンデータ読み込みエラー: $e');
    }
  }

  static Future<void> _loadStreakData() async {
    try {
      debugPrint('🔍 [_loadStreakData] 開始');
      
      final container = getGlobalContainer();
      
      if (container == null) {
        debugPrint('⚠️ [_loadStreakData] ProviderContainerが設定されていません');
        return;
      }
      debugPrint('🔍 [_loadStreakData] ProviderContainer取得成功');
      
      debugPrint('🔄 [_loadStreakData] Streakデータを同期中...');
      final streakData = await syncStreakDataHelper(container);
      debugPrint('✅ [_loadStreakData] Streakデータ読み込み完了: ${streakData.currentStreak}日連続');
      
    } catch (e) {
      debugPrint('❌ [_loadStreakData] Streakデータ読み込みエラー: $e');
    }
  }

  static Future<void> _loadGoalData() async {
    try {
      debugPrint('🔍 [_loadGoalData] 開始');
      
      final container = getGlobalContainer();
      
      if (container == null) {
        debugPrint('⚠️ [_loadGoalData] ProviderContainerが設定されていません');
        return;
      }
      debugPrint('🔍 [_loadGoalData] ProviderContainer取得成功');
      
      debugPrint('🔄 [_loadGoalData] Goalデータを同期中...');
      final goals = await syncGoalsHelper(container);
      debugPrint('✅ [_loadGoalData] Goalデータ読み込み完了: ${goals.length}件');
      
    } catch (e) {
      debugPrint('❌ [_loadGoalData] Goalデータ読み込みエラー: $e');
    }
  }

  static Future<void> _loadTotalData() async {
    try {
      debugPrint('🔍 [_loadTotalData] 開始');
      
      final container = getGlobalContainer();
      
      if (container == null) {
        debugPrint('⚠️ [_loadTotalData] ProviderContainerが設定されていません');
        return;
      }
      debugPrint('🔍 [_loadTotalData] ProviderContainer取得成功');
      
      debugPrint('🔄 [_loadTotalData] Totalデータを同期中...');
      final totalData = await syncTotalDataHelper(container);
      debugPrint('✅ [_loadTotalData] Totalデータ読み込み完了: ${totalData.totalLoginDays}日、${totalData.totalWorkTimeMinutes}分');
      
    } catch (e) {
      debugPrint('❌ [_loadTotalData] Totalデータ読み込みエラー: $e');
    }
  }

  static Future<void> _loadSettingsData() async {
    try {
      debugPrint('🔍 [_loadSettingsData] 開始');
      
      final container = getGlobalContainer();
      
      if (container == null) {
        debugPrint('⚠️ [_loadSettingsData] ProviderContainerが設定されていません');
        return;
      }
      debugPrint('🔍 [_loadSettingsData] ProviderContainer取得成功');
      
      debugPrint('🔄 [_loadSettingsData] アカウント設定を同期中...');
      await syncAccountSettingsHelper(container);
      
      debugPrint('🔄 [_loadSettingsData] 通知設定を同期中...');
      await syncNotificationSettingsHelper(container);
      
      debugPrint('🔄 [_loadSettingsData] 表示設定を同期中...');
      await syncDisplaySettingsHelper(container);
      
      debugPrint('🔄 [_loadSettingsData] 時間設定を同期中...');
      await syncTimeSettingsHelper(container);
      
      debugPrint('✅ [_loadSettingsData] 設定データ読み込み完了');
      
    } catch (e) {
      debugPrint('❌ [_loadSettingsData] 設定データ読み込みエラー: $e');
    }
  }

  /// アプリの初期化処理を実行
  static Future<AppContext> initialize() async {
    try {
      final user = AuthMk.getCurrentUser();
      if (user == null) {
        throw Exception('ユーザーがログインしていません。先にログインしてください。');
      }

      final userInfo = AuthMk.getCurrentUserInfo();
      final userId = userInfo['uid'];
      
      if (userId == null || userId.isEmpty) {
        throw Exception('ユーザーIDが取得できませんでした。');
      }

      String? token;
      try {
        token = await AuthMk.getUserIdToken();
      } catch (e) {
        debugPrint('⚠️ トークン取得に失敗しました。SecureStorageから取得を試みます: $e');
      }

      final storedInfo = await SecureStorageMk.getUserInfoFromStorage();
      
      if (token == null || token.isEmpty) {
        token = storedInfo['token'];
        if (token == null || token.isEmpty) {
          debugPrint('⚠️ トークンが取得できませんでした。一部機能が制限される可能性があります。');
        }
      }

      return AppContext(
        userId: userId,
        email: userInfo['email'] ?? storedInfo['email'],
        displayName: userInfo['displayName'] ?? storedInfo['displayName'],
        photoURL: userInfo['photoURL'] ?? storedInfo['photoUrl'],
        token: token,
        initializedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ アプリ初期化エラー: $e');
      rethrow;
    }
  }
}

/// アプリのコンテキスト情報を保持するデータクラス
class AppContext {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? token;
  final DateTime initializedAt;

  const AppContext({
    required this.userId,
    this.email,
    this.displayName,
    this.photoURL,
    this.token,
    required this.initializedAt,
  });

  bool get isAuthenticated {
    return userId.isNotEmpty && (token?.isNotEmpty ?? false);
  }

  @override
  String toString() {
    return 'AppContext('
        'userId: $userId, '
        'email: $email, '
        'displayName: $displayName, '
        'photoURL: $photoURL, '
        'hasToken: ${token != null}, '
        'initializedAt: $initializedAt'
        ')';
  }

  AppContext copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoURL,
    String? token,
    DateTime? initializedAt,
  }) {
    return AppContext(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      token: token ?? this.token,
      initializedAt: initializedAt ?? this.initializedAt,
    );
  }
}
