import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/sources/secure_storage_source.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';
import 'package:test_flutter/feature/streak/streak_functions.dart';
import 'package:test_flutter/feature/goals/goal_functions.dart';
import 'package:test_flutter/feature/setting/settings_functions.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/feature/total/total_functions.dart';
import 'package:test_flutter/feature/tracking/tracking_data_functions.dart';
import 'package:test_flutter/feature/statistics/statistics_functions.dart';

/// アプリ全体で1回だけ呼び出すグローバル初期化関数
class AppInitUN {
  static ProviderContainer? _globalContainer;
  // 初期化状態を管理するフラグ
  static bool _isInitializing = false;
  static bool _isCriticalDataLoading = false;
  static String? _initializingUserId; // 初期化中のユーザーID

  /// グローバルなProviderContainerを設定
  static void setGlobalContainer(ProviderContainer container) {
    _globalContainer = container;
  }

  /// グローバルなProviderContainerを取得
  static ProviderContainer? getGlobalContainer() {
    return _globalContainer;
  }
  
  /// 初期化フラグをリセット（サインアウト時などに呼び出す）
  static void resetInitializationFlags() {
    _isInitializing = false;
    _isCriticalDataLoading = false;
    _initializingUserId = null;
    debugPrint('🔄 [AppInitUN] 初期化フラグをリセットしました');
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

      final appContext = await initialize();

      // 優先度1のデータのみを起動時に同期（並列実行）
      await loadCriticalData();

      // 古い統計データを削除（バックグラウンドで実行、エラーは無視）
      deleteOldStatisticsDataHelper().then((_) {
        debugPrint('✅ 古い統計データ削除完了');
      }).catchError((e) {
        debugPrint('❌ 古い統計データ削除エラー: $e');
      });

      return appContext;
    } catch (e) {
      debugPrint('❌ アプリ包括的初期化エラー: $e');
      return null;
    }
  }

  /// 優先度1のデータを並列同期（起動時に必須）
  /// 
  /// カウントダウン、ストリーク、ゴール、トータル、トラッキングを並列実行します。
  /// アプリ起動時に呼び出されます。
  static Future<void> loadCriticalData() async {
    // 既に初期化中の場合はスキップ
    if (_isCriticalDataLoading) {
      debugPrint('⚠️ [loadCriticalData] 既に初期化中のため、スキップします');
      return;
    }
    
    try {
      _isCriticalDataLoading = true;
      debugPrint('🔄 [loadCriticalData] 開始');
      final container = getGlobalContainer();
      if (container == null) {
        debugPrint('❌ [loadCriticalData] Container is null');
        _isCriticalDataLoading = false;
        return;
      }
      debugPrint('✅ [loadCriticalData] Container取得完了');
      
      final results = <String, bool>{};
      final errors = <String, String>{};

      // 優先度1のデータを並列実行（各処理に20秒のタイムアウトを設定）
      debugPrint('🔄 [loadCriticalData] 並列処理開始');
      const timeoutDuration = Duration(seconds: 20);
      
      final futures = [
        _syncCountdownData()
            .timeout(timeoutDuration, onTimeout: () {
              debugPrint('⏱️ [loadCriticalData] カウントダウンタイムアウト（20秒）');
              throw TimeoutException('カウントダウン同期がタイムアウトしました', timeoutDuration);
            })
            .then((_) {
              debugPrint('✅ [loadCriticalData] カウントダウン完了');
              return {'カウントダウン': true};
            })
            .catchError((e, stackTrace) {
              errors['カウントダウン'] = e.toString();
              debugPrint('❌ [loadCriticalData] カウントダウンエラー: $e');
              debugPrint('   - スタックトレース: $stackTrace');
              return {'カウントダウン': false};
            }),
        _syncStreakData()
            .timeout(timeoutDuration, onTimeout: () {
              debugPrint('⏱️ [loadCriticalData] ストリークタイムアウト（20秒）');
              throw TimeoutException('ストリーク同期がタイムアウトしました', timeoutDuration);
            })
            .then((_) {
              debugPrint('✅ [loadCriticalData] ストリーク完了');
              return {'ストリーク': true};
            })
            .catchError((e, stackTrace) {
              errors['ストリーク'] = e.toString();
              debugPrint('❌ [loadCriticalData] ストリークエラー: $e');
              debugPrint('   - スタックトレース: $stackTrace');
              return {'ストリーク': false};
            }),
        _syncGoalData()
            .timeout(timeoutDuration, onTimeout: () {
              debugPrint('⏱️ [loadCriticalData] ゴールタイムアウト（20秒）');
              throw TimeoutException('ゴール同期がタイムアウトしました', timeoutDuration);
            })
            .then((_) {
              debugPrint('✅ [loadCriticalData] ゴール完了');
              return {'ゴール': true};
            })
            .catchError((e, stackTrace) {
              errors['ゴール'] = e.toString();
              debugPrint('❌ [loadCriticalData] ゴールエラー: $e');
              debugPrint('   - スタックトレース: $stackTrace');
              return {'ゴール': false};
            }),
        _syncTotalData()
            .timeout(timeoutDuration, onTimeout: () {
              debugPrint('⏱️ [loadCriticalData] トータルタイムアウト（20秒）');
              throw TimeoutException('トータル同期がタイムアウトしました', timeoutDuration);
            })
            .then((_) {
              debugPrint('✅ [loadCriticalData] トータル完了');
              return {'トータル': true};
            })
            .catchError((e, stackTrace) {
              errors['トータル'] = e.toString();
              debugPrint('❌ [loadCriticalData] トータルエラー: $e');
              debugPrint('   - スタックトレース: $stackTrace');
              return {'トータル': false};
            }),
        _syncTrackingData()
            .timeout(timeoutDuration, onTimeout: () {
              debugPrint('⏱️ [loadCriticalData] トラッキングタイムアウト（20秒）');
              throw TimeoutException('トラッキング同期がタイムアウトしました', timeoutDuration);
            })
            .then((_) {
              debugPrint('✅ [loadCriticalData] トラッキング完了');
              return {'トラッキング': true};
            })
            .catchError((e, stackTrace) {
              errors['トラッキング'] = e.toString();
              debugPrint('❌ [loadCriticalData] トラッキングエラー: $e');
              debugPrint('   - スタックトレース: $stackTrace');
              return {'トラッキング': false};
            }),
      ];

      debugPrint('🔄 [loadCriticalData] Future.wait開始');
      // 各Futureにタイムアウトを設定しているので、Future.waitは完了するはず
      // タイムアウトしたFutureは例外を投げるが、catchErrorでキャッチされて結果が返される
      final syncResults = await Future.wait(futures, eagerError: false);
      debugPrint('✅ [loadCriticalData] Future.wait完了');
      
      // 結果をマージ
      for (final result in syncResults) {
        results.addAll(result);
      }
      
      // 完了した処理数を確認
      final successCount = results.values.where((v) => v).length;
      final totalCount = results.length;
      debugPrint('✅ [loadCriticalData] 完了: 成功=$successCount/$totalCount件');
      
      // エラーのみ表示
      if (errors.isNotEmpty) {
        debugPrint('❌ [loadCriticalData] エラー: ${errors.keys.join(", ")}');
        for (final entry in errors.entries) {
          debugPrint('   - ${entry.key}: ${entry.value}');
        }
      }
      
      // タイムアウトした処理がある場合の警告
      if (totalCount < 5) {
        debugPrint('⚠️ [loadCriticalData] 一部の処理が完了しませんでした（完了: $totalCount/5件）');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [loadCriticalData] エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
    } finally {
      _isCriticalDataLoading = false;
    }
  }

  /// 優先度2のデータを並列同期（起動後すぐ）
  /// 
  /// 設定データ（アカウント、通知、表示、時間）を並列実行します。
  /// アプリ起動後に呼び出されます。
  static Future<void> loadSecondaryData() async {
    try {
      final results = <String, bool>{};
      final errors = <String, String>{};
      final container = getGlobalContainer();

      if (container == null) {
        return;
      }

      // 設定データを並列実行
      final futures = [
        syncAccountSettingsHelper(container).then((_) => {'設定（アカウント）': true}).catchError((e) {
          errors['設定（アカウント）'] = e.toString();
          return {'設定（アカウント）': false};
        }),
        syncNotificationSettingsHelper(container).then((_) => {'設定（通知）': true}).catchError((e) {
          errors['設定（通知）'] = e.toString();
          return {'設定（通知）': false};
        }),
        syncDisplaySettingsHelper(container).then((_) => {'設定（表示）': true}).catchError((e) {
          errors['設定（表示）'] = e.toString();
          return {'設定（表示）': false};
        }),
        syncTimeSettingsHelper(container).then((_) => {'設定（時間）': true}).catchError((e) {
          errors['設定（時間）'] = e.toString();
          return {'設定（時間）': false};
        }),
      ];

      final syncResults = await Future.wait(futures, eagerError: false);
      
      // 結果をマージ
      for (final result in syncResults) {
        results.addAll(result);
      }

      // エラーのみ表示
      if (errors.isNotEmpty) {
        debugPrint('❌ [loadSecondaryData] エラー: ${errors.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ [loadSecondaryData] エラー: $e');
    }
  }

  /// 優先度3のデータをバックグラウンド同期
  /// 
  /// 統計データ（日次、週次、月次、年次）を並列実行します。
  /// アプリ起動後にバックグラウンドで呼び出されます。
  static Future<void> loadBackgroundData() async {
    try {
      final results = <String, bool>{};
      final errors = <String, String>{};

      // 統計データを並列実行
      final futures = [
        syncDailyStatisticsHelper().then((_) => {'統計（日次）': true}).catchError((e) {
          errors['統計（日次）'] = e.toString();
          return {'統計（日次）': false};
        }),
        syncWeeklyStatisticsHelper().then((_) => {'統計（週次）': true}).catchError((e) {
          errors['統計（週次）'] = e.toString();
          return {'統計（週次）': false};
        }),
        syncMonthlyStatisticsHelper().then((_) => {'統計（月次）': true}).catchError((e) {
          errors['統計（月次）'] = e.toString();
          return {'統計（月次）': false};
        }),
        syncYearlyStatisticsHelper().then((_) => {'統計（年次）': true}).catchError((e) {
          errors['統計（年次）'] = e.toString();
          return {'統計（年次）': false};
        }),
      ];

      final syncResults = await Future.wait(futures, eagerError: false);
      
      // 結果をマージ
      for (final result in syncResults) {
        results.addAll(result);
      }

      // エラーのみ表示
      if (errors.isNotEmpty) {
        debugPrint('❌ [loadBackgroundData] エラー: ${errors.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ [loadBackgroundData] エラー: $e');
    }
  }

  /// すべてのデータをFirestoreから差分同期で読み込む（後方互換性のため残す）
  ///
  /// 認証成功後に呼び出して、Firestoreからデータを取得します。
  /// `lastModified`フィールドを利用した差分同期を実行します。
  /// - 初回起動時（ローカルデータがない場合）: 全データを取得
  /// - 2回目以降（ローカルデータがある場合）: 変更があった部分のみ取得
  /// 
  /// アプリ起動時と認証成功時の両方で使用されます。
  /// 
  /// **注意**: このメソッドは後方互換性のため残していますが、
  /// 新しいコードでは`loadCriticalData()`、`loadSecondaryData()`、`loadBackgroundData()`を使用してください。
  static Future<void> loadAllData() async {
    try {
      final results = <String, bool>{};
      final errors = <String, String>{};

      // カウントダウン
      try {
        await _syncCountdownData();
        results['カウントダウン'] = true;
      } catch (e) {
        results['カウントダウン'] = false;
        errors['カウントダウン'] = e.toString();
      }

      // ストリーク
      try {
        await _syncStreakData();
        results['ストリーク'] = true;
      } catch (e) {
        results['ストリーク'] = false;
        errors['ストリーク'] = e.toString();
      }

      // ゴール
      try {
        await _syncGoalData();
        results['ゴール'] = true;
      } catch (e) {
        results['ゴール'] = false;
        errors['ゴール'] = e.toString();
      }

      // トータル
      try {
        await _syncTotalData();
        results['トータル'] = true;
      } catch (e) {
        results['トータル'] = false;
        errors['トータル'] = e.toString();
      }

      // トラッキング
      try {
        await _syncTrackingData();
        results['トラッキング'] = true;
      } catch (e) {
        results['トラッキング'] = false;
        errors['トラッキング'] = e.toString();
      }

      // 統計データ
      try {
        final statsResults = await _syncStatisticsData();
        results['統計（日次）'] = statsResults['daily'] ?? false;
        results['統計（週次）'] = statsResults['weekly'] ?? false;
        results['統計（月次）'] = statsResults['monthly'] ?? false;
        results['統計（年次）'] = statsResults['yearly'] ?? false;
      } catch (e) {
        results['統計（日次）'] = false;
        results['統計（週次）'] = false;
        results['統計（月次）'] = false;
        results['統計（年次）'] = false;
        errors['統計'] = e.toString();
      }

      // 設定
      try {
        final container = getGlobalContainer();
        if (container != null) {
          try {
            await syncAccountSettingsHelper(container);
            results['設定（アカウント）'] = true;
          } catch (e) {
            results['設定（アカウント）'] = false;
            errors['設定（アカウント）'] = e.toString();
          }

          try {
            await syncNotificationSettingsHelper(container);
            results['設定（通知）'] = true;
          } catch (e) {
            results['設定（通知）'] = false;
            errors['設定（通知）'] = e.toString();
          }

          try {
            await syncDisplaySettingsHelper(container);
            results['設定（表示）'] = true;
          } catch (e) {
            results['設定（表示）'] = false;
            errors['設定（表示）'] = e.toString();
          }

          try {
            await syncTimeSettingsHelper(container);
            results['設定（時間）'] = true;
          } catch (e) {
            results['設定（時間）'] = false;
            errors['設定（時間）'] = e.toString();
          }
        }
      } catch (e) {
        errors['設定'] = e.toString();
      }

      // エラーのみ表示
      if (errors.isNotEmpty) {
        debugPrint('❌ [loadAllData] エラー: ${errors.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ [loadAllData] エラー: $e');
    }
  }

  /// 同期結果を表示するヘルパーメソッド

  /// カウントダウンデータを差分同期
  static Future<void> _syncCountdownData() async {
    debugPrint('🔄 [_syncCountdownData] 開始');
    final container = getGlobalContainer();
    if (container == null) {
      debugPrint('❌ [_syncCountdownData] Container is null');
      throw Exception('Container is null');
    }
    await syncCountdownsHelper(container);
    debugPrint('✅ [_syncCountdownData] 完了');
  }

  /// ストリークデータを差分同期
  static Future<void> _syncStreakData() async {
    debugPrint('🔄 [_syncStreakData] 開始');
    final container = getGlobalContainer();
    if (container == null) {
      debugPrint('❌ [_syncStreakData] Container is null');
      throw Exception('Container is null');
    }
    await syncStreakDataHelper(container);
    debugPrint('✅ [_syncStreakData] 完了');
  }

  /// ゴールデータを差分同期
  static Future<void> _syncGoalData() async {
    debugPrint('🔄 [_syncGoalData] 開始');
    final container = getGlobalContainer();
    if (container == null) {
      debugPrint('❌ [_syncGoalData] Container is null');
      throw Exception('Container is null');
    }
    
    // 共通ヘルパー関数を使用（タイムアウト処理とエラーハンドリングは共通ヘルパー関数内で処理）
    await syncGoalsHelper(container);
    debugPrint('✅ [_syncGoalData] 完了');
  }

  /// トータルデータを差分同期
  static Future<void> _syncTotalData() async {
    debugPrint('🔄 [_syncTotalData] 開始');
    final container = getGlobalContainer();
    if (container == null) {
      debugPrint('❌ [_syncTotalData] Container is null');
      throw Exception('Container is null');
    }
    await syncTotalDataHelper(container);
    debugPrint('✅ [_syncTotalData] 完了');
  }

  /// トラッキングデータを差分同期
  static Future<void> _syncTrackingData() async {
    debugPrint('🔄 [_syncTrackingData] 開始');
    final container = getGlobalContainer();
    if (container == null) {
      debugPrint('❌ [_syncTrackingData] Container is null');
      throw Exception('Container is null');
    }
    await syncTrackingSessionsHelper(container);
    debugPrint('✅ [_syncTrackingData] 完了');
  }

  /// 統計データを差分同期
  static Future<Map<String, bool>> _syncStatisticsData() async {
    final results = <String, bool>{};
    
    try {
      await syncDailyStatisticsHelper();
      results['daily'] = true;
    } catch (e) {
      results['daily'] = false;
    }
    
    try {
      await syncWeeklyStatisticsHelper();
      results['weekly'] = true;
    } catch (e) {
      results['weekly'] = false;
    }
    
    try {
      await syncMonthlyStatisticsHelper();
      results['monthly'] = true;
    } catch (e) {
      results['monthly'] = false;
    }
    
    try {
      await syncYearlyStatisticsHelper();
      results['yearly'] = true;
    } catch (e) {
      results['yearly'] = false;
    }
    
    return results;
  }

  /// アプリの初期化処理を実行
  static Future<AppContext> initialize() async {
    // 既に初期化中の場合はスキップ（同じユーザーの場合）
    final user = AuthMk.getCurrentUser();
    if (user != null && _isInitializing && _initializingUserId == user.uid) {
      debugPrint('⚠️ [initialize] 既に初期化中のため、スキップします（ユーザー: ${user.uid}）');
      // 既存のAppContextを返す（簡易実装）
      throw Exception('既に初期化中です');
    }
    
    try {
      _isInitializing = true;
      if (user != null) {
        _initializingUserId = user.uid;
      }
      debugPrint('🔄 [initialize] 開始');
      if (user == null) {
        debugPrint('❌ [initialize] ユーザーがログインしていません');
        _isInitializing = false;
        _initializingUserId = null;
        throw Exception('ユーザーがログインしていません。先にログインしてください。');
      }
      debugPrint('✅ [initialize] ユーザー取得完了: ${user.uid}');

      final userInfo = AuthMk.getCurrentUserInfo();
      final userId = userInfo['uid'];
      debugPrint('🔄 [initialize] ユーザー情報取得: userId=$userId');

      if (userId == null || userId.isEmpty) {
        debugPrint('❌ [initialize] ユーザーIDが取得できませんでした');
        throw Exception('ユーザーIDが取得できませんでした。');
      }

      String? token;
      try {
        debugPrint('🔄 [initialize] トークン取得開始');
        token = await AuthMk.getUserIdToken();
        debugPrint('✅ [initialize] トークン取得完了');
      } catch (e) {
        debugPrint('⚠️ [initialize] トークン取得失敗: $e');
        // トークン取得失敗時はSecureStorageから取得を試みる
      }

      debugPrint('🔄 [initialize] SecureStorageからユーザー情報取得開始');
      final storedInfo = await SecureStorageMk.getUserInfoFromStorage();
      debugPrint('✅ [initialize] SecureStorageからユーザー情報取得完了: ${storedInfo.keys.join(", ")}');

      if (token == null || token.isEmpty) {
        token = storedInfo['token'];
        debugPrint('🔄 [initialize] SecureStorageからトークン取得: ${token != null ? "成功" : "失敗"}');
      }

      // メールアドレスを取得（優先順位: Firestore（AccountSettings） > Firebase Auth > SecureStorage）
      String? email;
      try {
        debugPrint('🔄 [initialize] AccountSettingsからメールアドレス取得開始');
        final accountSettings = await accountSettingsManager.getById(userId, 'account_settings');
        if (accountSettings?.email != null && accountSettings!.email!.isNotEmpty) {
          email = accountSettings.email;
          debugPrint('✅ [initialize] AccountSettingsからメールアドレス取得: $email');
        } else {
          debugPrint('⚠️ [initialize] AccountSettingsにメールアドレスがありません');
        }
      } catch (e) {
        debugPrint('⚠️ [initialize] AccountSettingsからのメールアドレス取得エラー: $e');
      }

      // AccountSettingsから取得できなかった場合は、既存の優先順位で取得
      email ??= userInfo['email'] ?? storedInfo['email'];
      debugPrint('✅ [initialize] メールアドレス確定: ${email != null ? "あり" : "なし"}');

      final appContext = AppContext(
        userId: userId,
        email: email,
        displayName: userInfo['displayName'] ?? storedInfo['displayName'],
        photoURL: userInfo['photoURL'] ?? storedInfo['photoUrl'],
        token: token,
        initializedAt: DateTime.now(),
      );
      debugPrint('✅ [initialize] AppContext作成完了');
      return appContext;
    } catch (e, stackTrace) {
      debugPrint('❌ [initialize] アプリ初期化エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      _isInitializing = false;
      _initializingUserId = null;
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
