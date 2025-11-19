import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

/// アカウント設定モデル
/// 
/// ユーザーのアカウント情報を管理します。
/// アイコンは色+頭文字で表示します。
@freezed
abstract class AccountSettings with _$AccountSettings {
  const AccountSettings._();

  const factory AccountSettings({
    /// 固定ID（'account_settings'）
    required String id,
    /// アカウント名
    required String accountName,
    /// アバターの色（'blue', 'red', 'green', 'purple', 'orange', 'pink'）
    required String avatarColor,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _AccountSettings;

  /// デフォルト値を持つコンストラクタ
  factory AccountSettings.defaultSettings() => AccountSettings(
        id: 'account_settings',
        accountName: 'ユーザー',
        avatarColor: 'blue',
        lastModified: DateTime.now(),
      );

  /// JSON形式から生成
  factory AccountSettings.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingsFromJson(json);

  /// JSON形式から生成（null安全版）
  /// 
  /// null値が含まれている場合でもデフォルト値で補完して生成します。
  factory AccountSettings.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return AccountSettings.fromJson(json);
    } catch (e) {
      // null値が含まれている場合はデフォルト値で補完
      return AccountSettings(
        id: json['id'] as String? ?? 'account_settings',
        accountName: json['accountName'] as String? ?? 'ユーザー',
        avatarColor: json['avatarColor'] as String? ?? 'blue',
        lastModified: json['lastModified'] != null
            ? (json['lastModified'] is String
                ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
                : DateTime.now())
            : DateTime.now(),
      );
    }
  }

  /// Firestoreデータから生成
  factory AccountSettings.fromFirestore(Map<String, dynamic> data) {
    return AccountSettings(
      id: data['id'] as String? ?? 'account_settings',
      accountName: data['accountName'] as String? ?? 'ユーザー',
      avatarColor: data['avatarColor'] as String? ?? 'blue',
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'accountName': accountName,
      'avatarColor': avatarColor,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

/// 通知設定モデル
/// 
/// アプリの通知に関する設定を管理します。
@freezed
abstract class NotificationSettings with _$NotificationSettings {
  const NotificationSettings._();

  const factory NotificationSettings({
    /// 固定ID（'notification_settings'）
    required String id,
    /// カウントダウン通知
    required bool countdownNotification,
    /// 目標期限通知
    required bool goalDeadlineNotification,
    /// 継続日数途切れ通知
    required bool streakBreakNotification,
    /// 昨日の報告通知
    required bool dailyReportNotification,
    /// 通知回数（'both', 'morning', 'evening'）
    required String notificationFrequency,
    /// 朝の通知時間（例: '08:30'）
    required String morningTime,
    /// 夜の通知時間（例: '22:00'）
    required String eveningTime,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _NotificationSettings;

  /// デフォルト値を持つコンストラクタ
  factory NotificationSettings.defaultSettings() => NotificationSettings(
        id: 'notification_settings',
        countdownNotification: true,
        goalDeadlineNotification: true,
        streakBreakNotification: true,
        dailyReportNotification: true,
        notificationFrequency: 'both',
        morningTime: '08:30',
        eveningTime: '22:00',
        lastModified: DateTime.now(),
      );

  /// JSON形式から生成
  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  /// JSON形式から生成（null安全版）
  /// 
  /// null値が含まれている場合でもデフォルト値で補完して生成します。
  factory NotificationSettings.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return NotificationSettings.fromJson(json);
    } catch (e) {
      // null値が含まれている場合はデフォルト値で補完
      return NotificationSettings(
        id: json['id'] as String? ?? 'notification_settings',
        countdownNotification: json['countdownNotification'] as bool? ?? true,
        goalDeadlineNotification: json['goalDeadlineNotification'] as bool? ?? true,
        streakBreakNotification: json['streakBreakNotification'] as bool? ?? true,
        dailyReportNotification: json['dailyReportNotification'] as bool? ?? true,
        notificationFrequency: json['notificationFrequency'] as String? ?? 'both',
        morningTime: json['morningTime'] as String? ?? '08:30',
        eveningTime: json['eveningTime'] as String? ?? '22:00',
        lastModified: json['lastModified'] != null
            ? (json['lastModified'] is String
                ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
                : DateTime.now())
            : DateTime.now(),
      );
    }
  }

  /// Firestoreデータから生成
  factory NotificationSettings.fromFirestore(Map<String, dynamic> data) {
    return NotificationSettings(
      id: data['id'] as String? ?? 'notification_settings',
      countdownNotification: data['countdownNotification'] as bool? ?? true,
      goalDeadlineNotification: data['goalDeadlineNotification'] as bool? ?? true,
      streakBreakNotification: data['streakBreakNotification'] as bool? ?? true,
      dailyReportNotification: data['dailyReportNotification'] as bool? ?? true,
      notificationFrequency: data['notificationFrequency'] as String? ?? 'both',
      morningTime: data['morningTime'] as String? ?? '08:30',
      eveningTime: data['eveningTime'] as String? ?? '22:00',
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'countdownNotification': countdownNotification,
      'goalDeadlineNotification': goalDeadlineNotification,
      'streakBreakNotification': streakBreakNotification,
      'dailyReportNotification': dailyReportNotification,
      'notificationFrequency': notificationFrequency,
      'morningTime': morningTime,
      'eveningTime': eveningTime,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

/// 表示設定モデル
/// 
/// カテゴリ名など、アプリの表示に関する設定を管理します。
@freezed
abstract class DisplaySettings with _$DisplaySettings {
  const DisplaySettings._();

  const factory DisplaySettings({
    /// 固定ID（'display_settings'）
    required String id,
    /// カテゴリ1の名前
    required String category1Name,
    /// カテゴリ2の名前
    required String category2Name,
    /// カテゴリ3の名前
    required String category3Name,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _DisplaySettings;

  /// デフォルト値を持つコンストラクタ
  factory DisplaySettings.defaultSettings() => DisplaySettings(
        id: 'display_settings',
        category1Name: '勉強',
        category2Name: 'スマホ',
        category3Name: 'パソコン',
        lastModified: DateTime.now(),
      );

  /// JSON形式から生成
  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      _$DisplaySettingsFromJson(json);

  /// JSON形式から生成（null安全版）
  /// 
  /// null値が含まれている場合でもデフォルト値で補完して生成します。
  factory DisplaySettings.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return DisplaySettings.fromJson(json);
    } catch (e) {
      // null値が含まれている場合はデフォルト値で補完
      return DisplaySettings(
        id: json['id'] as String? ?? 'display_settings',
        category1Name: json['category1Name'] as String? ?? '勉強',
        category2Name: json['category2Name'] as String? ?? 'スマホ',
        category3Name: json['category3Name'] as String? ?? 'パソコン',
        lastModified: json['lastModified'] != null
            ? (json['lastModified'] is String
                ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
                : DateTime.now())
            : DateTime.now(),
      );
    }
  }

  /// Firestoreデータから生成
  factory DisplaySettings.fromFirestore(Map<String, dynamic> data) {
    return DisplaySettings(
      id: data['id'] as String? ?? 'display_settings',
      category1Name: data['category1Name'] as String? ?? '勉強',
      category2Name: data['category2Name'] as String? ?? 'スマホ',
      category3Name: data['category3Name'] as String? ?? 'パソコン',
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'category1Name': category1Name,
      'category2Name': category2Name,
      'category3Name': category3Name,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

/// 時間設定モデル
/// 
/// 一日の区切り時刻など、時間に関する設定を管理します。
@freezed
abstract class TimeSettings with _$TimeSettings {
  const TimeSettings._();

  const factory TimeSettings({
    /// 固定ID（'time_settings'）
    required String id,
    /// 一日の区切り時刻（例: '24:00', '00:00', '04:00'）
    required String dayBoundaryTime,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _TimeSettings;

  /// デフォルト値を持つコンストラクタ
  factory TimeSettings.defaultSettings() => TimeSettings(
        id: 'time_settings',
        dayBoundaryTime: '24:00',
        lastModified: DateTime.now(),
      );

  /// JSON形式から生成
  factory TimeSettings.fromJson(Map<String, dynamic> json) =>
      _$TimeSettingsFromJson(json);

  /// JSON形式から生成（null安全版）
  /// 
  /// null値が含まれている場合でもデフォルト値で補完して生成します。
  factory TimeSettings.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return TimeSettings.fromJson(json);
    } catch (e) {
      // null値が含まれている場合はデフォルト値で補完
      return TimeSettings(
        id: json['id'] as String? ?? 'time_settings',
        dayBoundaryTime: json['dayBoundaryTime'] as String? ?? '24:00',
        lastModified: json['lastModified'] != null
            ? (json['lastModified'] is String
                ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
                : DateTime.now())
            : DateTime.now(),
      );
    }
  }

  /// Firestoreデータから生成
  factory TimeSettings.fromFirestore(Map<String, dynamic> data) {
    return TimeSettings(
      id: data['id'] as String? ?? 'time_settings',
      dayBoundaryTime: data['dayBoundaryTime'] as String? ?? '24:00',
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'dayBoundaryTime': dayBoundaryTime,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

/// トラッキング設定モデル
/// 
/// トラッキング画面の設定（カメラのオン/オフ、省電力モード）を管理します。
@freezed
abstract class TrackingSettings with _$TrackingSettings {
  const TrackingSettings._();

  const factory TrackingSettings({
    /// 固定ID（'tracking_settings'）
    required String id,
    /// カメラのオン/オフ状態
    required bool isCameraOn,
    /// 省電力モードのオン/オフ状態
    required bool isPowerSavingMode,
    /// 選択されたStudy目標のID
    String? selectedStudyGoalId,
    /// 選択されたPC目標のID
    String? selectedPcGoalId,
    /// 選択されたSmartphone目標のID
    String? selectedSmartphoneGoalId,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _TrackingSettings;

  /// デフォルト値を持つコンストラクタ
  factory TrackingSettings.defaultSettings() => TrackingSettings(
        id: 'tracking_settings',
        isCameraOn: true,
        isPowerSavingMode: false,
        selectedStudyGoalId: null,
        selectedPcGoalId: null,
        selectedSmartphoneGoalId: null,
        lastModified: DateTime.now(),
      );

  /// JSON形式から生成
  factory TrackingSettings.fromJson(Map<String, dynamic> json) =>
      _$TrackingSettingsFromJson(json);

  /// JSON形式から生成（null安全版）
  /// 
  /// null値が含まれている場合でもデフォルト値で補完して生成します。
  factory TrackingSettings.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return TrackingSettings.fromJson(json);
    } catch (e) {
      // null値が含まれている場合はデフォルト値で補完
      return TrackingSettings(
        id: json['id'] as String? ?? 'tracking_settings',
        isCameraOn: json['isCameraOn'] as bool? ?? true,
        isPowerSavingMode: json['isPowerSavingMode'] as bool? ?? false,
        selectedStudyGoalId: json['selectedStudyGoalId'] as String?,
        selectedPcGoalId: json['selectedPcGoalId'] as String?,
        selectedSmartphoneGoalId: json['selectedSmartphoneGoalId'] as String?,
        lastModified: json['lastModified'] != null
            ? (json['lastModified'] is String
                ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
                : DateTime.now())
            : DateTime.now(),
      );
    }
  }

  /// Firestoreデータから生成
  factory TrackingSettings.fromFirestore(Map<String, dynamic> data) {
    return TrackingSettings(
      id: data['id'] as String? ?? 'tracking_settings',
      isCameraOn: data['isCameraOn'] as bool? ?? true,
      isPowerSavingMode: data['isPowerSavingMode'] as bool? ?? false,
      selectedStudyGoalId: data['selectedStudyGoalId'] as String?,
      selectedPcGoalId: data['selectedPcGoalId'] as String?,
      selectedSmartphoneGoalId: data['selectedSmartphoneGoalId'] as String?,
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'isCameraOn': isCameraOn,
      'isPowerSavingMode': isPowerSavingMode,
      'selectedStudyGoalId': selectedStudyGoalId,
      'selectedPcGoalId': selectedPcGoalId,
      'selectedSmartphoneGoalId': selectedSmartphoneGoalId,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}

