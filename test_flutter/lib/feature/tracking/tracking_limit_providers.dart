import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/feature/subscription/subscription_providers.dart';

/// 1日のトラッキング回数制限（無料プラン）
const int _dailyTrackingLimit = 3;

/// 1日のトラッキング回数を読み込むProvider
final dailyTrackingCountProvider = FutureProvider<int>((ref) {
  return DailyTrackingCountHelper.loadCount();
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

  /// 現在の日付を文字列で取得（YYYY-MM-DD形式）
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// カウントを読み込む
  static Future<int> loadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayString = _getTodayString();
      final savedDate = prefs.getString(_dateKey);
      
      // 日付が変わったらリセット
      if (savedDate != todayString) {
        await prefs.setString(_dateKey, todayString);
        await prefs.setInt(_keyPrefix + todayString, 0);
        return 0;
      } else {
        // 今日のカウントを読み込む
        final count = prefs.getInt(_keyPrefix + todayString) ?? 0;
        return count;
      }
    } catch (e) {
      // エラー時は0にリセット
      return 0;
    }
  }

  /// トラッキング回数を増やす
  static Future<int> increment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayString = _getTodayString();
      final currentCount = await loadCount();
      final newCount = currentCount + 1;
      await prefs.setString(_dateKey, todayString);
      await prefs.setInt(_keyPrefix + todayString, newCount);
      return newCount;
    } catch (e) {
      // エラー時は現在のカウントを返す
      return await loadCount();
    }
  }

  /// カウントをリセット（テスト用）
  static Future<int> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayString = _getTodayString();
      await prefs.setString(_dateKey, todayString);
      await prefs.setInt(_keyPrefix + todayString, 0);
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
