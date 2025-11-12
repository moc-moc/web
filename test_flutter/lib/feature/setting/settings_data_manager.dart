import 'package:test_flutter/data/models/settings_models.dart';
import 'package:test_flutter/data/repositories/firestore_repository.dart';

/// アカウント設定データマネージャー
/// 
/// `FirestoreDataManager`を使用してアカウント設定を管理します。
/// 
/// **使用例**:
/// ```dart
/// // アカウント設定を同期
/// final settings = await accountSettingsManager.sync(userId);
/// 
/// // アカウント設定を保存
/// await accountSettingsManager.saveWithRetry(userId, newSettings);
/// ```
final accountSettingsManager = FirestoreDataManager<AccountSettings>(
  // Firestoreのコレクションパス
  collectionPathBuilder: (userId) => 'users/$userId/settings',
  
  // Firestoreデータからモデルに変換
  fromFirestore: AccountSettings.fromFirestore,
  
  // モデルからFirestoreデータに変換
  toFirestore: (item) => item.toFirestore(),
  
  // SharedPreferencesのキー
  storageKey: 'account_settings',
  
  // モデルからJSONに変換（SharedPreferences用）
  toJson: (item) => item.toJson(),
  
  // JSONからモデルに変換（SharedPreferences用）
  fromJson: AccountSettings.fromJson,
);

/// 通知設定データマネージャー
/// 
/// `FirestoreDataManager`を使用して通知設定を管理します。
/// 
/// **使用例**:
/// ```dart
/// // 通知設定を同期
/// final settings = await notificationSettingsManager.sync(userId);
/// 
/// // 通知設定を保存
/// await notificationSettingsManager.saveWithRetry(userId, newSettings);
/// ```
final notificationSettingsManager = FirestoreDataManager<NotificationSettings>(
  // Firestoreのコレクションパス
  collectionPathBuilder: (userId) => 'users/$userId/settings',
  
  // Firestoreデータからモデルに変換
  fromFirestore: NotificationSettings.fromFirestore,
  
  // モデルからFirestoreデータに変換
  toFirestore: (item) => item.toFirestore(),
  
  // SharedPreferencesのキー
  storageKey: 'notification_settings',
  
  // モデルからJSONに変換（SharedPreferences用）
  toJson: (item) => item.toJson(),
  
  // JSONからモデルに変換（SharedPreferences用）
  fromJson: NotificationSettings.fromJson,
);

/// 表示設定データマネージャー
/// 
/// `FirestoreDataManager`を使用して表示設定を管理します。
/// 
/// **使用例**:
/// ```dart
/// // 表示設定を同期
/// final settings = await displaySettingsManager.sync(userId);
/// 
/// // 表示設定を保存
/// await displaySettingsManager.saveWithRetry(userId, newSettings);
/// ```
final displaySettingsManager = FirestoreDataManager<DisplaySettings>(
  // Firestoreのコレクションパス
  collectionPathBuilder: (userId) => 'users/$userId/settings',
  
  // Firestoreデータからモデルに変換
  fromFirestore: DisplaySettings.fromFirestore,
  
  // モデルからFirestoreデータに変換
  toFirestore: (item) => item.toFirestore(),
  
  // SharedPreferencesのキー
  storageKey: 'display_settings',
  
  // モデルからJSONに変換（SharedPreferences用）
  toJson: (item) => item.toJson(),
  
  // JSONからモデルに変換（SharedPreferences用）
  fromJson: DisplaySettings.fromJson,
);

/// 時間設定データマネージャー
/// 
/// `FirestoreDataManager`を使用して時間設定を管理します。
/// 
/// **使用例**:
/// ```dart
/// // 時間設定を同期
/// final settings = await timeSettingsManager.sync(userId);
/// 
/// // 時間設定を保存
/// await timeSettingsManager.saveWithRetry(userId, newSettings);
/// ```
final timeSettingsManager = FirestoreDataManager<TimeSettings>(
  // Firestoreのコレクションパス
  collectionPathBuilder: (userId) => 'users/$userId/settings',
  
  // Firestoreデータからモデルに変換
  fromFirestore: TimeSettings.fromFirestore,
  
  // モデルからFirestoreデータに変換
  toFirestore: (item) => item.toFirestore(),
  
  // SharedPreferencesのキー
  storageKey: 'time_settings',
  
  // モデルからJSONに変換（SharedPreferences用）
  toJson: (item) => item.toJson(),
  
  // JSONからモデルに変換（SharedPreferences用）
  fromJson: TimeSettings.fromJson,
);

