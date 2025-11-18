import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/tracking/tracking_data_functions.dart';
import 'package:test_flutter/feature/statistics/statistics_functions.dart';

/// アプリ全体で1回だけ呼び出すグローバル初期化関数
class AppInitUN {
  static ProviderContainer? _globalContainer;

  /// グローバルなProviderContainerを設定
  static void setGlobalContainer(ProviderContainer container) {
    _globalContainer = container;
  }

  /// グローバルなProviderContainerを取得
  static ProviderContainer? getGlobalContainer() {
    return _globalContainer;
  }

  /// アプリ起動時の包括的な初期化
  static Future<AppContext?> initializeWithAuth() async {
    try {
      // 認証復元
      final userInfo = await AuthServiceUN.initializeAuth();
      if (userInfo == null) {
        debugPrint('❌ 認証復元');
        return null;
      }
      debugPrint('✅ 認証復元');
      debugPrint('✅ ${userInfo.email}');

      final appContext = await initialize();

      // データ読み込みを実行（カテゴリーごとに結果を表示）
      await loadAllData();

      return appContext;
    } catch (e) {
      debugPrint('❌ アプリ包括的初期化エラー: $e');
      return null;
    }
  }

  /// すべてのデータをFirestoreから読み込む
  ///
  /// 認証成功後に呼び出して、Firestoreからデータを取得します。
  /// アプリ起動時と認証成功時の両方で使用されます。
  static Future<void> loadAllData() async {
    try {
      // 各カテゴリーの読み込み結果を追跡
      bool countdownSuccess = false;
      bool streakSuccess = false;
      bool goalSuccess = false;
      bool totalSuccess = false;
      bool trackingSuccess = false;

      // カウントダウン
      try {
        await _loadCountdownData();
        countdownSuccess = true;
      } catch (e) {
        debugPrint('⚠️ データカウントダウン');
      }

      // ストリーク
      try {
        await _loadStreakData();
        streakSuccess = true;
      } catch (e) {
        debugPrint('⚠️ データストリーク');
      }

      // ゴール
      try {
        await _loadGoalData();
        goalSuccess = true;
      } catch (e) {
        debugPrint('⚠️ データゴール');
      }

      // トータル
      try {
        await _loadTotalData();
        totalSuccess = true;
      } catch (e) {
        debugPrint('⚠️ データトータル');
      }

      // トラッキング
      try {
        await _loadTrackingData();
        trackingSuccess = true;
      } catch (e) {
        debugPrint('⚠️ データトラッキング');
      }

      // 統計データ（個別に追跡）
      bool dailyStatisticsSuccess = false;
      bool weeklyStatisticsSuccess = false;
      bool monthlyStatisticsSuccess = false;
      bool yearlyStatisticsSuccess = false;

      try {
        final results = await _loadStatisticsData();
        dailyStatisticsSuccess = results['daily'] ?? false;
        weeklyStatisticsSuccess = results['weekly'] ?? false;
        monthlyStatisticsSuccess = results['monthly'] ?? false;
        yearlyStatisticsSuccess = results['yearly'] ?? false;
      } catch (e) {
        debugPrint('⚠️ データ統計');
      }

      // 設定（個別に追跡）
      bool accountSettingsSuccess = false;
      bool notificationSettingsSuccess = false;
      bool displaySettingsSuccess = false;
      bool timeSettingsSuccess = false;

      try {
        final container = getGlobalContainer();
        if (container != null) {
          try {
            await syncAccountSettingsHelper(container);
            accountSettingsSuccess = true;
          } catch (e) {}

          try {
            await syncNotificationSettingsHelper(container);
            notificationSettingsSuccess = true;
          } catch (e) {}

          try {
            await syncDisplaySettingsHelper(container);
            displaySettingsSuccess = true;
          } catch (e) {}

          try {
            await syncTimeSettingsHelper(container);
            timeSettingsSuccess = true;
          } catch (e) {}
        }
      } catch (e) {
        debugPrint('⚠️ 設定');
      }

      // 結果を表示
      debugPrint(countdownSuccess ? '✅ データカウントダウン' : '❌ データカウントダウン');
      debugPrint(streakSuccess ? '✅ データストリーク' : '❌ データストリーク');
      debugPrint(goalSuccess ? '✅ データゴール' : '❌ データゴール');
      debugPrint(totalSuccess ? '✅ データトータル' : '❌ データトータル');
      debugPrint(trackingSuccess ? '✅ データトラッキング' : '❌ データトラッキング');
      debugPrint(dailyStatisticsSuccess ? '✅ データ統計日次' : '❌ データ統計日次');
      debugPrint(weeklyStatisticsSuccess ? '✅ データ統計週次' : '❌ データ統計週次');
      debugPrint(monthlyStatisticsSuccess ? '✅ データ統計月次' : '❌ データ統計月次');
      debugPrint(yearlyStatisticsSuccess ? '✅ データ統計年次' : '❌ データ統計年次');
      debugPrint(accountSettingsSuccess ? '✅ 設定アカウント' : '❌ 設定アカウント');
      debugPrint(notificationSettingsSuccess ? '✅ 設定通知' : '❌ 設定通知');
      debugPrint(displaySettingsSuccess ? '✅ 設定表示' : '❌ 設定表示');
      debugPrint(timeSettingsSuccess ? '✅ 設定時間' : '❌ 設定時間');
    } catch (e) {
      debugPrint('❌ [loadAllData] データ読み込みエラー: $e');
    }
  }

  static Future<void> _loadCountdownData() async {
    final container = getGlobalContainer();
    if (container == null) throw Exception('Container is null');
    await syncCountdownsHelper(container);
  }

  static Future<void> _loadStreakData() async {
    final container = getGlobalContainer();
    if (container == null) throw Exception('Container is null');
    await syncStreakDataHelper(container);
  }

  static Future<void> _loadGoalData() async {
    final container = getGlobalContainer();
    if (container == null) throw Exception('Container is null');
    await syncGoalsHelper(container);
  }

  static Future<void> _loadTotalData() async {
    final container = getGlobalContainer();
    if (container == null) throw Exception('Container is null');
    await syncTotalDataHelper(container);
  }

  static Future<void> _loadTrackingData() async {
    final container = getGlobalContainer();
    if (container == null) throw Exception('Container is null');
    await syncTrackingSessionsHelper(container);
  }

  static Future<Map<String, bool>> _loadStatisticsData() async {
    return await syncAllStatisticsHelper();
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
        // トークン取得失敗時はSecureStorageから取得を試みる
      }

      final storedInfo = await SecureStorageMk.getUserInfoFromStorage();

      if (token == null || token.isEmpty) {
        token = storedInfo['token'];
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
