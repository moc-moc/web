import 'package:test_flutter/feature/setting/time_settings_notifier.dart';

/// 日付判定のユーティリティ関数
/// 
/// reset time settingに基づいて日付を判定する関数群を提供します。
class DateUtils {
  /// reset time settingに基づいて「今日」の日付を取得
  /// 
  /// reset timeで日付の境界を定義します。
  /// 例: reset timeが22:00の場合、「12月6日」は「12/5 22:00～12/6 22:00」の範囲を指します。
  ///   - 12月6日16時 → 12月6日に属する（12/5 22:00～12/6 22:00の範囲内）
  ///   - 12月6日23時 → 12月7日に属する（12/6 22:00～12/7 22:00の範囲内）
  /// 
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用）
  /// - `now`: 現在時刻（デフォルト: DateTime.now()）
  /// 
  /// **戻り値**: reset time settingに基づく「今日」の日付（時刻は00:00:00）
  static DateTime getTodayDate(dynamic ref, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final timeSettings = ref.read(timeSettingsProvider);
    final dayBoundaryTime = timeSettings.dayBoundaryTime;
    
    // dayBoundaryTimeを解析（例: "04:00"）
    final timeParts = dayBoundaryTime.split(':');
    if (timeParts.length != 2) {
      // パースエラーの場合は、デフォルトで00:00を使用
      return DateTime(currentTime.year, currentTime.month, currentTime.day);
    }
    
    final resetHour = int.tryParse(timeParts[0]) ?? 0;
    final resetMinute = int.tryParse(timeParts[1]) ?? 0;
    
    // 今日のリセット時刻を計算
    final todayResetTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      resetHour,
      resetMinute,
    );
    
    // 現在時刻がリセット時刻以降の場合は、次の日の日付を返す
    // リセット時刻より前の場合は、今日の日付を返す
    if (currentTime.isAfter(todayResetTime) || currentTime.isAtSameMomentAs(todayResetTime)) {
      final nextDay = currentTime.add(const Duration(days: 1));
      return DateTime(nextDay.year, nextDay.month, nextDay.day);
    } else {
      return DateTime(currentTime.year, currentTime.month, currentTime.day);
    }
  }
  
  /// 2つの日付が同じ日かどうかを判定（reset time settingを考慮）
  /// 
  /// reset time settingに基づいて日付を判定します。
  /// 
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用）
  /// - `date1`: 比較する日付1
  /// - `date2`: 比較する日付2
  /// 
  /// **戻り値**: 同じ日の場合true
  static bool isSameDay(dynamic ref, DateTime date1, DateTime date2) {
    final today1 = getTodayDate(ref, now: date1);
    final today2 = getTodayDate(ref, now: date2);
    
    return today1.year == today2.year &&
           today1.month == today2.month &&
           today1.day == today2.day;
  }
  
  /// 指定された日付が「今日」かどうかを判定（reset time settingを考慮）
  /// 
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用）
  /// - `date`: 判定する日付
  /// 
  /// **戻り値**: 今日の場合true
  static bool isToday(dynamic ref, DateTime date) {
    final today = getTodayDate(ref);
    final dateToday = getTodayDate(ref, now: date);
    
    return today.year == dateToday.year &&
           today.month == dateToday.month &&
           today.day == dateToday.day;
  }
  
  /// 指定された日付が「昨日」かどうかを判定（reset time settingを考慮）
  /// 
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用）
  /// - `date`: 判定する日付
  /// 
  /// **戻り値**: 昨日の場合true
  static bool isYesterday(dynamic ref, DateTime date) {
    final today = getTodayDate(ref);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToday = getTodayDate(ref, now: date);
    
    return yesterday.year == dateToday.year &&
           yesterday.month == dateToday.month &&
           yesterday.day == dateToday.day;
  }
  
  /// reset time settingに基づいて「今日」の日付を取得（refなし版）
  /// 
  /// `dayBoundaryTime`を直接指定して日付を計算します。
  /// `StatisticsAggregationService`など、`ref`が使えない場所で使用します。
  /// 
  /// reset timeで日付の境界を定義します。
  /// 例: reset timeが22:00の場合、「12月6日」は「12/5 22:00～12/6 22:00」の範囲を指します。
  ///   - 12月6日16時 → 12月6日に属する（12/5 22:00～12/6 22:00の範囲内）
  ///   - 12月6日23時 → 12月7日に属する（12/6 22:00～12/7 22:00の範囲内）
  /// 
  /// **パラメータ**:
  /// - `dayBoundaryTime`: リセット時刻（例: "04:00"）
  /// - `now`: 現在時刻（デフォルト: DateTime.now()）
  /// 
  /// **戻り値**: reset time settingに基づく「今日」の日付（時刻は00:00:00）
  static DateTime getTodayDateFromBoundaryTime(String dayBoundaryTime, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    
    // dayBoundaryTimeを解析（例: "04:00"）
    final timeParts = dayBoundaryTime.split(':');
    if (timeParts.length != 2) {
      // パースエラーの場合は、デフォルトで00:00を使用
      return DateTime(currentTime.year, currentTime.month, currentTime.day);
    }
    
    final resetHour = int.tryParse(timeParts[0]) ?? 0;
    final resetMinute = int.tryParse(timeParts[1]) ?? 0;
    
    // 今日のリセット時刻を計算
    final todayResetTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      resetHour,
      resetMinute,
    );
    
    // 現在時刻がリセット時刻以降の場合は、次の日の日付を返す
    // リセット時刻より前の場合は、今日の日付を返す
    if (currentTime.isAfter(todayResetTime) || currentTime.isAtSameMomentAs(todayResetTime)) {
      final nextDay = currentTime.add(const Duration(days: 1));
      return DateTime(nextDay.year, nextDay.month, nextDay.day);
    } else {
      return DateTime(currentTime.year, currentTime.month, currentTime.day);
    }
  }

  /// reset time settingに基づいてリセットが必要かどうかを判定
  /// 
  /// 前回のリセット時刻から現在時刻がリセット時刻を過ぎている場合、リセットが必要と判定します。
  /// 
  /// **パラメータ**:
  /// - `ref`: WidgetRef（Provider操作用）
  /// - `lastResetDate`: 前回のリセット日付
  /// 
  /// **戻り値**: リセットが必要な場合true
  static bool needsReset(dynamic ref, DateTime? lastResetDate) {
    if (lastResetDate == null) {
      return true;
    }
    
    final now = DateTime.now();
    final timeSettings = ref.read(timeSettingsProvider);
    final dayBoundaryTime = timeSettings.dayBoundaryTime;
    
    // dayBoundaryTimeを解析
    final timeParts = dayBoundaryTime.split(':');
    if (timeParts.length != 2) {
      // パースエラーの場合は、デフォルトで00:00を使用
      final today = DateTime(now.year, now.month, now.day);
      final lastReset = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
      return !isSameDay(ref, today, lastReset);
    }
    
    final resetHour = int.tryParse(timeParts[0]) ?? 0;
    final resetMinute = int.tryParse(timeParts[1]) ?? 0;
    
    // 前回のリセット時刻を計算
    var lastResetDateTime = DateTime(
      lastResetDate.year,
      lastResetDate.month,
      lastResetDate.day,
      resetHour,
      resetMinute,
    );
    
    // 前回のリセット時刻が前回の日付より後の場合、前日のリセット時刻として扱う
    if (lastResetDateTime.isAfter(lastResetDate)) {
      lastResetDateTime = lastResetDateTime.subtract(const Duration(days: 1));
    }
    
    // 現在時刻が前回のリセット時刻より後の場合、リセットが必要
    return now.isAfter(lastResetDateTime) && !isSameDay(ref, lastResetDate, now);
  }
}

