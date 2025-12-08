import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/data/services/shared_preferences_service.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';
import 'package:test_flutter/data/sources/date_utils.dart';
import 'package:test_flutter/data/repositories/tracking_count_data_manager.dart';
import 'package:test_flutter/data/models/tracking_count_model.dart';
import 'package:test_flutter/data/repositories/survey_flag_data_manager.dart';
import 'package:test_flutter/data/models/survey_flag_model.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 1日のトラッキング回数制限（無料プラン）
const int _dailyTrackingLimit = 3;

/// 1日のトラッキング回数を読み込むProvider
final dailyTrackingCountProvider = FutureProvider<int>((ref) {
  return DailyTrackingCountHelper.loadCount(ref);
});

/// 1日の残りトラッキング回数を取得するProvider
final remainingTrackingCountProvider = Provider<int>((ref) {
  final subscriptionStatus = ref.watch(subscriptionStatusProvider);
  // プレミアムユーザーは無制限
  if (subscriptionStatus.hasPremiumAccess) {
    return -1; // -1は無制限を意味する
  }
  final countAsync = ref.watch(dailyTrackingCountProvider);
  final count = countAsync.value ?? 0;
  final remaining = _dailyTrackingLimit - count;
  return remaining > 0 ? remaining : 0;
});

/// トラッキング可能かどうかを判定するProvider
final canStartTrackingProvider = Provider<bool>((ref) {
  final subscriptionStatus = ref.watch(subscriptionStatusProvider);
  // プレミアムユーザーは常に可能
  if (subscriptionStatus.hasPremiumAccess) {
    return true;
  }
  final countAsync = ref.watch(dailyTrackingCountProvider);
  final count = countAsync.value ?? 0;
  return count < _dailyTrackingLimit;
});

/// トラッキング回数管理のヘルパークラス
class DailyTrackingCountHelper {
  static const String _keyPrefix = 'daily_tracking_count_';
  static const String _dateKey = 'daily_tracking_date';
  static const String _hasShownFirstSurveyKey = 'has_shown_first_survey';

  /// 現在の日付を文字列で取得（YYYY-MM-DD形式、reset time settingを考慮）
  static String _getTodayString(dynamic ref) {
    final today = DateUtils.getTodayDate(ref);
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  /// カウントを読み込む
  static Future<int> loadCount(dynamic ref) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final todayString = _getTodayString(ref);
      final savedDate = prefs.getString(_dateKey);
      
      // 日付が変わったらリセット
      if (savedDate != todayString) {
        await prefs.setString(_dateKey, todayString);
        await prefs.setInt(_keyPrefix + todayString, 0);
        // Firestoreもリセット
        await _saveToFirestore(todayString, 0);
        return 0;
      } else {
        // まずFirestoreから読み込みを試みる
        final firestoreCount = await _loadFromFirestore(todayString);
        if (firestoreCount != null) {
          // Firestoreから取得できた場合は、SharedPreferencesも同期
          await prefs.setInt(_keyPrefix + todayString, firestoreCount);
          return firestoreCount;
        }
        // Firestoreから取得できない場合は、SharedPreferencesから読み込む
        final count = prefs.getInt(_keyPrefix + todayString) ?? 0;
        // SharedPreferencesの値をFirestoreにも保存（同期）
        if (count > 0) {
          await _saveToFirestore(todayString, count);
        }
        return count;
      }
    } catch (e) {
      LogMk.logError(
        'トラッキング回数の読み込みエラー: $e',
        tag: 'DailyTrackingCountHelper.loadCount',
      );
      // エラー時は0にリセット
      return 0;
    }
  }

  /// トラッキング回数を増やす
  static Future<int> increment(dynamic ref) async {
    try {
      LogMk.logDebug('トラッキング回数のインクリメント開始', tag: 'DailyTrackingCountHelper.increment');
      
      final prefs = await SharedPreferencesService.getInstance();
      final todayString = _getTodayString(ref);
      final currentCount = await loadCount(ref);
      final newCount = currentCount + 1;
      
      LogMk.logDebug('現在のカウント: $currentCount → 新しいカウント: $newCount', tag: 'DailyTrackingCountHelper.increment');
      
      await prefs.setString(_dateKey, todayString);
      await prefs.setInt(_keyPrefix + todayString, newCount);
      
      LogMk.logDebug('SharedPreferencesに保存完了', tag: 'DailyTrackingCountHelper.increment');
      
      // Firestoreにも保存（tracking_countsコレクション）
      // 注意: daily_statisticsへの保存は、StatisticsAggregationServiceでトラッキング終了時に行われる
      await _saveToFirestore(todayString, newCount);
      
      LogMk.logDebug('トラッキング回数のインクリメント完了: $newCount', tag: 'DailyTrackingCountHelper.increment');
      
      return newCount;
    } catch (e, stackTrace) {
      LogMk.logError(
        'トラッキング回数の増加エラー: $e',
        tag: 'DailyTrackingCountHelper.increment',
        error: e,
        stackTrace: stackTrace,
      );
      // エラー時は現在のカウントを返す
      return await loadCount(ref);
    }
  }

  /// カウントをリセット（テスト用）
  static Future<int> reset(dynamic ref) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final todayString = _getTodayString(ref);
      await prefs.setString(_dateKey, todayString);
      await prefs.setInt(_keyPrefix + todayString, 0);
      // Firestoreもリセット
      await _saveToFirestore(todayString, 0);
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Firestoreからカウントを読み込む
  static Future<int?> _loadFromFirestore(String dateString) async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser == null) {
        return null;
      }
      final userId = currentUser.uid;
      final trackingCount = await trackingCountDataManager.getById(userId, dateString);
      return trackingCount?.count;
    } catch (e) {
      LogMk.logError(
        'Firestoreからのトラッキング回数読み込みエラー: $e',
        tag: 'DailyTrackingCountHelper._loadFromFirestore',
      );
      return null;
    }
  }

  /// Firestoreにカウントを保存
  static Future<void> _saveToFirestore(String dateString, int count) async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser == null) {
        LogMk.logWarning('ユーザーIDが取得できません。Firestoreに保存をスキップします。', tag: 'DailyTrackingCountHelper._saveToFirestore');
        return;
      }
      final userId = currentUser.uid;
      
      // デバッグ: countの型と値を確認
      LogMk.logDebug('count型: ${count.runtimeType}, 値: $count', tag: 'DailyTrackingCountHelper._saveToFirestore');
      
      final trackingCount = TrackingCount(
        id: dateString,
        count: count,
        lastModified: DateTime.now(),
      );
      
      // デバッグ: TrackingCountオブジェクトの内容を確認
      LogMk.logDebug('TrackingCount作成: id=$dateString, count=${trackingCount.count} (型: ${trackingCount.count.runtimeType})', tag: 'DailyTrackingCountHelper._saveToFirestore');
      
      // デバッグ: toFirestore()の結果を確認
      final firestoreData = trackingCount.toFirestore();
      LogMk.logDebug('toFirestore()結果: $firestoreData', tag: 'DailyTrackingCountHelper._saveToFirestore');
      LogMk.logDebug('count フィールド型: ${firestoreData['count'].runtimeType}', tag: 'DailyTrackingCountHelper._saveToFirestore');
      
      final success = await trackingCountDataManager.saveWithRetry(userId, trackingCount);
      if (success) {
        LogMk.logDebug('トラッキング回数をFirestoreに保存しました: $dateString, count: $count', tag: 'DailyTrackingCountHelper._saveToFirestore');
      } else {
        LogMk.logWarning('トラッキング回数の保存に失敗しました（リトライキューに追加済み）: $dateString', tag: 'DailyTrackingCountHelper._saveToFirestore');
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        'Firestoreへのトラッキング回数保存エラー: $e',
        tag: 'DailyTrackingCountHelper._saveToFirestore',
        error: e,
        stackTrace: stackTrace,
      );
      // エラーでも処理を続行（SharedPreferencesは保存済み）
    }
  }

  /// 初回アンケートを表示済みかどうかを確認
  static Future<bool> hasShownFirstSurvey() async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser != null) {
        // まずFirestoreから読み込みを試みる
        final userId = currentUser.uid;
        final surveyFlag = await surveyFlagDataManager.getById(userId, 'survey_flag');
        if (surveyFlag != null) {
          // Firestoreから取得できた場合は、SharedPreferencesも同期
          final prefs = await SharedPreferencesService.getInstance();
          await prefs.setBool(_hasShownFirstSurveyKey, surveyFlag.hasShownFirstSurvey);
          return surveyFlag.hasShownFirstSurvey;
        }
      }
      
      // Firestoreから取得できない場合は、SharedPreferencesから読み込む
      final prefs = await SharedPreferencesService.getInstance();
      final hasShown = prefs.getBool(_hasShownFirstSurveyKey) ?? false;
      
      // SharedPreferencesの値をFirestoreにも保存（同期）
      if (hasShown && currentUser != null) {
        await _saveSurveyFlagToFirestore(currentUser.uid, hasShown);
      }
      
      return hasShown;
    } catch (e) {
      LogMk.logError(
        '初回アンケート表示済みフラグの読み込みエラー: $e',
        tag: 'DailyTrackingCountHelper.hasShownFirstSurvey',
      );
      return false;
    }
  }

  /// 初回アンケートを表示済みとしてマーク
  static Future<void> markFirstSurveyAsShown() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.setBool(_hasShownFirstSurveyKey, true);
      
      // Firestoreにも保存
      final currentUser = AuthMk.getCurrentUser();
      if (currentUser != null) {
        await _saveSurveyFlagToFirestore(currentUser.uid, true);
      }
    } catch (e) {
      LogMk.logError(
        '初回アンケート表示済みフラグの保存エラー: $e',
        tag: 'DailyTrackingCountHelper.markFirstSurveyAsShown',
      );
    }
  }

  /// Firestoreにアンケートフラグを保存
  static Future<void> _saveSurveyFlagToFirestore(String userId, bool hasShown) async {
    try {
      final surveyFlag = SurveyFlag(
        id: 'survey_flag',
        hasShownFirstSurvey: hasShown,
        lastModified: DateTime.now(),
      );
      final success = await surveyFlagDataManager.saveWithRetry(userId, surveyFlag);
      if (success) {
        LogMk.logDebug('アンケートフラグをFirestoreに保存しました: hasShown=$hasShown', tag: 'DailyTrackingCountHelper._saveSurveyFlagToFirestore');
      } else {
        LogMk.logWarning('アンケートフラグの保存に失敗しました（リトライキューに追加済み）', tag: 'DailyTrackingCountHelper._saveSurveyFlagToFirestore');
      }
    } catch (e, stackTrace) {
      LogMk.logError(
        'Firestoreへのアンケートフラグ保存エラー: $e',
        tag: 'DailyTrackingCountHelper._saveSurveyFlagToFirestore',
        error: e,
        stackTrace: stackTrace,
      );
      // エラーでも処理を続行（SharedPreferencesは保存済み）
    }
  }

  /// 3回目のトラッキング終了かどうかを確認
  static Future<bool> isThirdTrackingCompletion(dynamic ref) async {
    try {
      final count = await loadCount(ref);
      return count == 3;
    } catch (e) {
      return false;
    }
  }
}
