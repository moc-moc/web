import 'package:flutter/foundation.dart';
import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/sources/auth_source.dart';

/// アカウント設定データマネージャー
/// 
/// `BaseDataManager`を継承して、アカウント設定を管理します。
class AccountSettingsDataManager extends BaseDataManager<AccountSettings> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  AccountSettings convertFromFirestore(Map<String, dynamic> data) {
    return AccountSettings.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(AccountSettings item) {
    return item.toFirestore();
  }

  @override
  AccountSettings convertFromJson(Map<String, dynamic> json) {
    return AccountSettings.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(AccountSettings item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'account_settings';
}

/// 通知設定データマネージャー
/// 
/// `BaseDataManager`を継承して、通知設定を管理します。
class NotificationSettingsDataManager extends BaseDataManager<NotificationSettings> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  NotificationSettings convertFromFirestore(Map<String, dynamic> data) {
    return NotificationSettings.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(NotificationSettings item) {
    return item.toFirestore();
  }

  @override
  NotificationSettings convertFromJson(Map<String, dynamic> json) {
    return NotificationSettings.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(NotificationSettings item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'notification_settings';
}

/// 表示設定データマネージャー
/// 
/// `BaseDataManager`を継承して、表示設定を管理します。
class DisplaySettingsDataManager extends BaseDataManager<DisplaySettings> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  DisplaySettings convertFromFirestore(Map<String, dynamic> data) {
    return DisplaySettings.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(DisplaySettings item) {
    return item.toFirestore();
  }

  @override
  DisplaySettings convertFromJson(Map<String, dynamic> json) {
    return DisplaySettings.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(DisplaySettings item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'display_settings';
}

/// 時間設定データマネージャー
/// 
/// `BaseDataManager`を継承して、時間設定を管理します。
class TimeSettingsDataManager extends BaseDataManager<TimeSettings> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  TimeSettings convertFromFirestore(Map<String, dynamic> data) {
    return TimeSettings.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(TimeSettings item) {
    return item.toFirestore();
  }

  @override
  TimeSettings convertFromJson(Map<String, dynamic> json) {
    return TimeSettings.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(TimeSettings item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'time_settings';
}

/// トラッキング設定データマネージャー
/// 
/// `BaseDataManager`を継承して、トラッキング設定を管理します。
class TrackingSettingsDataManager extends BaseDataManager<TrackingSettings> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  TrackingSettings convertFromFirestore(Map<String, dynamic> data) {
    return TrackingSettings.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(TrackingSettings item) {
    return item.toFirestore();
  }

  @override
  TrackingSettings convertFromJson(Map<String, dynamic> json) {
    return TrackingSettings.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(TrackingSettings item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'tracking_settings';
}

/// 目標メモデータマネージャー
/// 
/// `BaseDataManager`を継承して、目標メモを管理します。
class GoalMemoDataManager extends BaseDataManager<GoalMemo> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/settings';

  @override
  GoalMemo convertFromFirestore(Map<String, dynamic> data) {
    return GoalMemo.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(GoalMemo item) {
    return item.toFirestore();
  }

  @override
  GoalMemo convertFromJson(Map<String, dynamic> json) {
    return GoalMemo.fromJsonSafe(json);
  }

  @override
  Map<String, dynamic> convertToJson(GoalMemo item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'goal_memo';

  Future<GoalMemo?> getGoalMemoWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      final result = await manager.getById(userId, 'goal_memo');
      debugPrint('✅ [getGoalMemoWithAuth] 取得結果: ${result != null ? "success" : "null"}');
      return result;
    } catch (e) {
      debugPrint('❌ [getGoalMemoWithAuth] エラー: $e');
      return null;
    }
  }

  Future<GoalMemo?> getLocalGoalMemo() async {
    try {
      return await manager.getLocalById('goal_memo');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocalGoalMemo(GoalMemo memo) async {
    try {
      await manager.updateLocal(memo);
    } catch (_) {
      await manager.addLocal(memo);
    }
  }
  
  /// 同期（他のデータマネージャーと統一）
  Future<GoalMemo?> syncGoalMemoWithAuth() async {
    try {
      final userId = AuthMk.getCurrentUserId();
      debugPrint('🔄 [syncGoalMemoWithAuth] 同期開始: userId=$userId');
      
      // getById()を使用して直接取得（単一ドキュメントなのでこれが最適）
      final goalMemo = await manager.getById(userId, 'goal_memo');
      
      if (goalMemo != null) {
        debugPrint('✅ [syncGoalMemoWithAuth] goal_memo取得成功: content="${goalMemo.content}"');
        // ローカルにも保存
        await saveLocalGoalMemo(goalMemo);
        debugPrint('   - ローカル保存完了');
      } else {
        debugPrint('⚠️ [syncGoalMemoWithAuth] goal_memoが見つかりません（新規作成が必要かも）');
      }
      
      return goalMemo;
    } catch (e, stackTrace) {
      debugPrint('❌ [syncGoalMemoWithAuth] エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      return null;
    }
  }
}

// ===== 後方互換性のためのグローバルインスタンス =====

/// アカウント設定データマネージャーのグローバルインスタンス
final accountSettingsManager = AccountSettingsDataManager();

/// 通知設定データマネージャーのグローバルインスタンス
final notificationSettingsManager = NotificationSettingsDataManager();

/// 表示設定データマネージャーのグローバルインスタンス
final displaySettingsManager = DisplaySettingsDataManager();

/// 時間設定データマネージャーのグローバルインスタンス
final timeSettingsManager = TimeSettingsDataManager();

/// トラッキング設定データマネージャーのグローバルインスタンス
final trackingSettingsManager = TrackingSettingsDataManager();

/// 目標メモデータマネージャーのグローバルインスタンス
final goalMemoManager = GoalMemoDataManager();

