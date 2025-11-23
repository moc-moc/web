import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/goals/goal_model.dart';
import 'package:test_flutter/feature/setting/settings_data_manager.dart';
import 'package:test_flutter/data/models/settings_models.dart';

/// 目標用データマネージャー
/// 
/// BaseDataManager<Goal>を継承して、目標データの管理を行います。
/// SharedPreferencesを使用してローカルデータを保存します。
/// 
class GoalDataManager extends BaseDataManager<Goal> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/goals';

  @override
  Goal convertFromFirestore(Map<String, dynamic> data) {
    final now = DateTime.now();
    final rawId = _readString(data['id']);
    final rawTag = _readString(data['tag']);
    final rawTitle = _readString(data['title']);
    final targetTime = _readInt(data['targetTime']) ?? 0;
    final durationDays = (_readInt(data['durationDays']) ?? 1).clamp(1, 3650);
    final computedTargetPerDay =
        targetTime > 0 ? (targetTime ~/ durationDays) : 0;
    final targetSecondsPerDay =
        _readInt(data['targetSecondsPerDay']) ?? computedTargetPerDay;

    final comparisonType = _parseComparisonType(
      data['comparisonType'],
      fallback: ComparisonType.above,
    );

    final detectionItem = _parseDetectionItem(
      data['detectionItem'],
      fallback: DetectionItem.book,
    );

    final startDate = _readDateTime(data['startDate']) ?? now;
    final periodEndDate = _readDateTime(data['periodEndDate']) ??
        startDate.add(Duration(days: durationDays));

    return Goal(
      id: rawId.isNotEmpty ? rawId : 'goal_${now.microsecondsSinceEpoch}',
      tag: rawTag.isNotEmpty ? rawTag : 'goal_${detectionItem.name}',
      title: rawTitle.isNotEmpty ? rawTitle : 'Untitled Goal',
      targetTime: targetTime,
      comparisonType: comparisonType,
      detectionItem: detectionItem,
      startDate: startDate,
      durationDays: durationDays,
      periodEndDate: periodEndDate,
      targetSecondsPerDay: targetSecondsPerDay,
      consecutiveAchievements: _readInt(data['consecutiveAchievements']) ?? 0,
      consecutivePeriodAchievements:
          _readInt(data['consecutivePeriodAchievements']) ?? 0,
      achievedTime: _readInt(data['achievedTime']),
      todayAchievedTime: _readInt(data['todayAchievedTime']),
      lastResetDate: _readDateTime(data['lastResetDate']),
      lastAchievedEventShownAt:
          _readDateTime(data['lastAchievedEventShownAt']),
      isDeleted: _readBool(data['isDeleted']) ?? false,
      lastModified: _readDateTime(data['lastModified']) ?? now,
    );
  }

  @override
  Map<String, dynamic> convertToFirestore(Goal item) {
    // targetSecondsPerDayを自動計算（既に設定されている場合はそれを使用）
    final targetSecondsPerDay = item.targetSecondsPerDay > 0 
        ? item.targetSecondsPerDay 
        : (item.durationDays > 0 ? item.targetTime ~/ item.durationDays : 0);
    
    return {
      'id': item.id,
      'tag': item.tag,
      'title': item.title,
      'targetTime': item.targetTime,
      'comparisonType': item.comparisonType.name,
      'detectionItem': item.detectionItem.name,
      'startDate': Timestamp.fromDate(item.startDate),
      'durationDays': item.durationDays,
      'periodEndDate': Timestamp.fromDate(
        (item.periodEndDate ?? item.startDate.add(Duration(days: item.durationDays))).toLocal(),
      ),
      'targetSecondsPerDay': targetSecondsPerDay,
      'consecutiveAchievements': item.consecutiveAchievements,
      'consecutivePeriodAchievements': item.consecutivePeriodAchievements,
      'achievedTime': item.achievedTime,
      'todayAchievedTime': item.todayAchievedTime,
      if (item.lastResetDate != null)
        'lastResetDate': Timestamp.fromDate(item.lastResetDate!),
      if (item.lastAchievedEventShownAt != null)
        'lastAchievedEventShownAt': Timestamp.fromDate(item.lastAchievedEventShownAt!),
      'isDeleted': item.isDeleted,
      'lastModified': Timestamp.fromDate(item.lastModified),
    };
  }

  @override
  Goal convertFromJson(Map<String, dynamic> json) {
    final goal = Goal.fromJson(json);
    // periodEndDateがnullの場合は自動的に計算して設定
    if (goal.periodEndDate == null) {
      return goal.copyWith(
        periodEndDate: goal.startDate.add(Duration(days: goal.durationDays)),
      );
    }
    return goal;
  }

  @override
  Map<String, dynamic> convertToJson(Goal item) => item.toJson();

  @override
  String get storageKey => 'goals';

  // ===== カスタム機能（目標特有） =====

  /// 目標を追加（認証自動取得版）
  Future<bool> addGoalWithAuth(Goal goal) async {
    return await manager.addWithAuth(goal);
  }

  /// 全目標を取得（認証自動取得版）
  Future<List<Goal>> getAllGoalsWithAuth() async {
    return await manager.getAllWithAuth();
  }

  /// 目標を更新（認証自動取得版）
  Future<bool> updateGoalWithAuth(Goal goal) async {
    return await manager.updateWithAuth(goal);
  }

  /// 目標を更新（認証自動取得版・リトライ機能付き）
  /// 
  /// ネットワークエラー時は自動的にリトライキューに追加され、後で再試行されます。
  /// saveWithRetryAuthを使用することで、存在しない場合は新規作成、存在する場合は更新（upsert）を行います。
  Future<bool> updateGoalWithRetryWithAuth(Goal goal) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ [updateGoalWithRetryWithAuth] 認証エラー: ユーザーがログインしていません');
      return false;
    }
    // saveWithRetryAuthを使用してupsert（存在確認付き）を実行
    // これにより、Firestoreに存在しない場合は新規作成、存在する場合は更新されます
    debugPrint('🔄 [updateGoalWithRetryWithAuth] 目標を保存開始: ${goal.id} (${goal.title})');
    final success = await manager.saveWithRetryAuth(goal);
    if (success) {
      debugPrint('✅ [updateGoalWithRetryWithAuth] 目標保存成功: ${goal.id} (${goal.title})');
    } else {
      debugPrint('⚠️ [updateGoalWithRetryWithAuth] 目標保存失敗（リトライキューに追加済み）: ${goal.id} (${goal.title})');
    }
    return success;
  }

  /// ローカルから全目標を取得
  Future<List<Goal>> getLocalGoals() async {
    return await manager.getLocalAll();
  }

  /// ローカルに目標を保存
  Future<void> saveLocalGoals(List<Goal> goals) async {
    await manager.saveLocal(goals);
  }

  /// 目標を削除（認証自動取得版・物理削除）
  Future<bool> deleteGoalWithAuth(String id) async {
    return await manager.deleteWithAuth(id);
  }

  /// アクティブな目標のみを取得（認証自動取得版）
  /// 
  /// 全目標を取得します（物理削除のため、削除済みは存在しません）
  Future<List<Goal>> getActiveGoalsWithAuth() async {
    return await getAllGoalsWithAuth();
  }

  /// Firestoreから直接目標を取得（認証自動取得版）
  /// 
  /// ローカルキャッシュを無視して、Firestoreから最新データを取得します。
  Future<List<Goal>> getGoalsFromFirestoreWithAuth() async {
    try {
      return await manager.getAllWithAuth();
    } catch (e) {
      debugPrint('❌ [getGoalsFromFirestoreWithAuth] 取得エラー: $e');
      return [];
    }
  }

  /// 目標を同期（認証自動取得版）
  /// 
  /// Firestoreとローカルストレージを同期します。
  Future<List<Goal>> syncGoalsWithAuth() async {
    return await manager.syncWithAuth();
  }

  /// 達成記録を更新
  /// 
  /// 連続達成回数をインクリメントし、達成時間を記録します。
  Future<bool> recordAchievement(String userId, String id, int achievedTime) async {
    try {
      // 現在の目標を取得
      final goal = await manager.getById(userId, id);
      if (goal == null) {
        return false;
      }

      // 連続達成回数をインクリメント
      final updatedGoal = goal.copyWith(
        consecutiveAchievements: goal.consecutiveAchievements + 1,
        achievedTime: achievedTime,
        lastModified: DateTime.now(),
      );

      // オプティミスティック更新: まずローカルデータを更新
      final localGoals = await getLocalGoals();
      final updatedGoals = localGoals.map((g) => g.id == id ? updatedGoal : g).toList();
      await saveLocalGoals(updatedGoals);

      // Firestoreを更新（リトライ機能付き）
      return await manager.updateWithRetry(userId, updatedGoal);
    } catch (e) {
      debugPrint('❌ 達成記録更新エラー: $e');
      return false;
    }
  }

  /// 達成記録を更新（認証自動取得版）
  Future<bool> recordAchievementWithAuth(String id, int achievedTime) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    }
    return await recordAchievement(currentUser.uid, id, achievedTime);
  }

  /// その日の達成時間をリセット（必要に応じて）
  /// 
  /// TimeSettings.dayBoundaryTimeに基づいて、リセット時刻を過ぎていたら
  /// todayAchievedTimeを0にリセットします。
  Future<void> resetTodayAchievedTimeIfNeeded(List<Goal> goals) async {
    try {
      // TimeSettingsを取得
      final timeSettingsManager = TimeSettingsDataManager();
      final timeSettingsList = await timeSettingsManager.getAllWithAuth();
      TimeSettings? timeSettings;
      
      if (timeSettingsList.isNotEmpty) {
        timeSettings = timeSettingsList.first;
      } else {
        // ローカルから取得を試みる
        final localTimeSettings = await timeSettingsManager.getLocalById('time_settings');
        timeSettings = localTimeSettings ?? TimeSettings.defaultSettings();
      }
      
      // リセット時刻を解析（'HH:mm'形式、例: '24:00', '00:00', '04:00'）
      final resetTimeParts = timeSettings.dayBoundaryTime.split(':');
      final resetHour = int.tryParse(resetTimeParts[0]) ?? 0;
      final resetMinute = int.tryParse(resetTimeParts.length > 1 ? resetTimeParts[1] : '0') ?? 0;
      
      final now = DateTime.now();
      final goalsToReset = <Goal>[];
      
      for (final goal in goals) {
        final shouldReset = _shouldResetTodayAchievedTime(
          goal.lastResetDate,
          now,
          resetHour,
          resetMinute,
        );
        
        if (shouldReset) {
          final updatedGoal = goal.copyWith(
            todayAchievedTime: 0,
            lastResetDate: now,
            lastModified: now,
          );
          goalsToReset.add(updatedGoal);
          
          debugPrint('🔄 目標のその日達成時間をリセット: ${goal.id}');
        }
      }
      
      // バッチ更新
      if (goalsToReset.isNotEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // 各目標の更新結果を確認
          final updateResults = await Future.wait(
            goalsToReset.map((goal) async {
              try {
                final success = await updateWithRetry(currentUser.uid, goal);
                return {'goal': goal, 'success': success};
              } catch (e) {
                debugPrint('❌ 目標リセット更新エラー: ${goal.id}: $e');
                return {'goal': goal, 'success': false};
              }
            }),
          );
          
          // 成功した目標のみローカルデータを更新
          final successfulGoals = <Goal>[];
          for (final result in updateResults) {
            final goal = result['goal'] as Goal;
            final success = result['success'] as bool;
            if (success) {
              successfulGoals.add(goal);
            }
          }
          
          if (successfulGoals.isNotEmpty) {
            // 現在のローカル目標リストを取得
            final localGoals = await getLocalGoals();
            
            // 成功した目標でローカルデータを更新
            final updatedLocalGoals = localGoals.map((localGoal) {
              final updatedGoal = successfulGoals.firstWhere(
                (g) => g.id == localGoal.id,
                orElse: () => localGoal,
              );
              return updatedGoal.id == localGoal.id ? updatedGoal : localGoal;
            }).toList();
            
            // 新規追加された目標（ローカルに存在しない）を追加
            for (final updatedGoal in successfulGoals) {
              if (!updatedLocalGoals.any((g) => g.id == updatedGoal.id)) {
                updatedLocalGoals.add(updatedGoal);
              }
            }
            
            // ローカルに保存
            await saveLocalGoals(updatedLocalGoals);
            
            debugPrint('✅ その日達成時間のリセット完了: 成功${successfulGoals.length}件/${goalsToReset.length}件');
          } else {
            debugPrint('⚠️ その日達成時間のリセット失敗: すべての更新に失敗しました（リトライキューに追加済み）');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ その日達成時間のリセットエラー: $e');
    }
  }

  /// リセットが必要かどうかを判定
  /// 
  /// [lastResetDate]がnullの場合、またはリセット時刻を過ぎていた場合にtrueを返します。
  bool _shouldResetTodayAchievedTime(
    DateTime? lastResetDate,
    DateTime now,
    int resetHour,
    int resetMinute,
  ) {
    if (lastResetDate == null) {
      // 初回はリセット不要（todayAchievedTimeがnullの可能性があるため）
      return false;
    }
    
    // リセット時刻を解析（24:00は0:00として扱う）
    final actualResetHour = resetHour == 24 ? 0 : resetHour;
    
    // 今日のリセット時刻を計算
    var resetDateTime = DateTime(now.year, now.month, now.day, actualResetHour, resetMinute);
    
    // リセット時刻が現在時刻より前の場合、次の日のリセット時刻として扱う
    if (resetDateTime.isBefore(now)) {
      resetDateTime = resetDateTime.add(const Duration(days: 1));
    }
    
    // 前回のリセット時刻を計算
    var lastResetDateTime = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day, actualResetHour, resetMinute);
    if (lastResetDateTime.isAfter(lastResetDate)) {
      // 前回のリセット時刻が前回の日付より後の場合、前日のリセット時刻として扱う
      lastResetDateTime = lastResetDateTime.subtract(const Duration(days: 1));
    }
    
    // 現在時刻が前回のリセット時刻より後の場合、リセットが必要
    return now.isAfter(lastResetDateTime) && !_isSameDay(lastResetDate, now);
  }

  /// 同じ日かどうかを判定（リセット時刻を考慮）
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static String _readString(dynamic value) {
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static ComparisonType _parseComparisonType(
    dynamic value, {
    required ComparisonType fallback,
  }) {
    final stringValue = _readString(value);
    if (stringValue.isNotEmpty) {
      final match = ComparisonType.values.firstWhere(
        (e) => e.name.toLowerCase() == stringValue.toLowerCase(),
        orElse: () => fallback,
      );
      return match;
    }
    return fallback;
  }

  static DetectionItem _parseDetectionItem(
    dynamic value, {
    required DetectionItem fallback,
  }) {
    final stringValue = _readString(value);
    if (stringValue.isNotEmpty) {
      final match = DetectionItem.values.firstWhere(
        (e) => e.name.toLowerCase() == stringValue.toLowerCase(),
        orElse: () => fallback,
      );
      return match;
    }
    return fallback;
  }
}
