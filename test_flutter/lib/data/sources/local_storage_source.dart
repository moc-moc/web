import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 同期可能なモデルのインターフェース
/// 
/// このインターフェースを実装することで、ローカルストレージとFirestore間の
/// 同期が可能になります。
abstract class SyncableModel {
  /// モデルの一意なID
  String get id;
  
  /// 最終更新日時（同期の判定に使用）
  DateTime get lastModified;
  
  /// JSON形式への変換
  Map<String, dynamic> toJson();
  
  /// 削除フラグ（論理削除用）
  bool get isDeleted => false;
}

/// SharedPreferences関連の汎用的な基本関数
/// 
/// ローカルストレージの保存・取得・管理に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class SharedMk {
  // ===== SharedPreferences基本操作 =====
  
  /// キーバリューペアでSharedPreferencesに保存
  /// 
  /// 指定されたキーと値のペアをSharedPreferencesに保存する
  /// 汎用的な保存関数として使用可能
  static Future<void> saveToSharedPrefs(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      debugPrint('✅ SharedPreferencesに保存: $key');
    } catch (e) {
      debugPrint('❌ SharedPreferences保存エラー: $e');
    }
  }
  
  /// キーから値をSharedPreferencesから取得
  /// 
  /// 指定されたキーに対応する値をSharedPreferencesから取得する
  /// キーが存在しない場合はnullを返す
  static Future<String?> getFromSharedPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('❌ SharedPreferences読み込みエラー: $e');
      return null;
    }
  }
  
  /// 特定のキーをSharedPreferencesから削除
  /// 
  /// 指定されたキーとその値をSharedPreferencesから削除する
  static Future<void> removeFromSharedPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      debugPrint('✅ SharedPreferencesから削除: $key');
    } catch (e) {
      debugPrint('❌ SharedPreferences削除エラー: $e');
    }
  }
  
  /// 複数のキーバリューペアを一括保存
  /// 
  /// 複数のキーバリューペアを一度に保存する
  static Future<void> saveMultipleToSharedPrefs(Map<String, String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in data.entries) {
        await prefs.setString(entry.key, entry.value);
      }
      debugPrint('✅ SharedPreferences一括保存完了: ${data.length}件');
    } catch (e) {
      debugPrint('❌ SharedPreferences一括保存エラー: $e');
    }
  }
  
  /// 複数のキーから値を一括取得
  /// 
  /// 指定されたキーリストから値を一括取得する
  static Future<Map<String, String?>> getMultipleFromSharedPrefs(List<String> keys) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String?> result = {};
      
      for (final key in keys) {
        result[key] = prefs.getString(key);
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ SharedPreferences一括取得エラー: $e');
      return {};
    }
  }
  
  // ===== リストデータ操作 =====
  
  /// リストデータ全体をSharedPreferencesに保存
  /// 
  /// Map<String, dynamic>のリストをJSON形式で保存する
  static Future<void> saveAllToSharedPrefs(String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(items);
      await prefs.setString(key, jsonString);
      debugPrint('✅ リストデータ保存完了: $key (${items.length}件)');
    } catch (e) {
      debugPrint('❌ リストデータ保存エラー: $e');
    }
  }
  
  /// リストデータ全体をSharedPreferencesから取得
  /// 
  /// 指定されたキーからJSON形式のリストデータを取得する
  /// データが存在しない場合は空のリストを返す
  static Future<List<Map<String, dynamic>>> getAllFromSharedPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ リストデータ取得エラー: $e');
      return [];
    }
  }
  
  /// リストデータの件数を取得
  /// 
  /// 指定されたキーのリストデータの件数を取得する
  static Future<int> getListCount(String key) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      return items.length;
    } catch (e) {
      debugPrint('❌ リスト件数取得エラー: $e');
      return 0;
    }
  }
  
  // ===== 単一アイテム操作 =====
  
  /// 単一アイテムをリストに追加
  /// 
  /// 既存のリストに新しいアイテムを追加する
  /// idFieldでアイテムのIDフィールドを指定する
  static Future<void> addItemToSharedPrefs(
    String key, 
    Map<String, dynamic> item, 
    String idField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      items.add(item);
      await saveAllToSharedPrefs(key, items);
      debugPrint('✅ アイテム追加完了: $key (ID: ${item[idField]})');
    } catch (e) {
      debugPrint('❌ アイテム追加エラー: $e');
    }
  }
  
  /// 単一アイテムをリスト内で更新（存在しない場合は自動追加）
  /// 
  /// 指定されたIDのアイテムを更新する。存在しない場合は自動的に追加する。
  /// idFieldでアイテムのIDフィールドを指定する
  static Future<void> updateItemInSharedPrefs(
    String key, 
    Map<String, dynamic> item, 
    String idField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final itemId = item[idField] as String?;
      
      if (itemId == null) {
        debugPrint('❌ アイテムIDが指定されていません');
        return;
      }
      
      final index = items.indexWhere((i) => i[idField] == itemId);
      if (index != -1) {
        // 存在する場合は更新
        items[index] = item;
        await saveAllToSharedPrefs(key, items);
        debugPrint('✅ アイテム更新完了: $key (ID: $itemId)');
      } else {
        // 存在しない場合は追加
        items.add(item);
        await saveAllToSharedPrefs(key, items);
        debugPrint('✅ アイテム追加（新規作成）完了: $key (ID: $itemId)');
      }
    } catch (e) {
      debugPrint('❌ アイテム更新エラー: $e');
    }
  }
  
  /// 単一アイテムをリストから削除
  /// 
  /// 指定されたIDのアイテムをリストから削除する
  /// idFieldでアイテムのIDフィールドを指定する
  static Future<void> removeItemFromSharedPrefs(
    String key, 
    String itemId, 
    String idField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final beforeCount = items.length;
      
      items.removeWhere((item) => item[idField] == itemId);
      
      if (items.length < beforeCount) {
        await saveAllToSharedPrefs(key, items);
        debugPrint('✅ アイテム削除完了: $key (ID: $itemId)');
      } else {
        debugPrint('❌ アイテムが見つかりません: $itemId');
      }
    } catch (e) {
      debugPrint('❌ アイテム削除エラー: $e');
    }
  }
  
  /// 指定されたIDのアイテムを取得
  /// 
  /// リスト内から指定されたIDのアイテムを取得する
  static Future<Map<String, dynamic>?> getItemFromSharedPrefs(
    String key, 
    String itemId, 
    String idField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final item = items.firstWhere(
        (item) => item[idField] == itemId,
        orElse: () => <String, dynamic>{},
      );
      
      return item.isNotEmpty ? item : null;
    } catch (e) {
      debugPrint('❌ アイテム取得エラー: $e');
      return null;
    }
  }
  
  // ===== 同期時刻管理 =====
  
  /// 最終同期時刻をSharedPreferencesから取得
  /// 
  /// 指定されたキーの最終同期時刻を取得する
  /// 同期時刻は'{key}_last_sync'として保存される
  static Future<DateTime?> getLastSyncTimeFromSharedPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('${key}_last_sync');
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      debugPrint('❌ 最終同期時刻取得エラー: $e');
      return null;
    }
  }
  
  /// 最終同期時刻をSharedPreferencesに設定
  /// 
  /// 指定されたキーの最終同期時刻を設定する
  /// 同期時刻は'{key}_last_sync'として保存される
  static Future<void> setLastSyncTimeToSharedPrefs(String key, DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${key}_last_sync', time.millisecondsSinceEpoch);
      debugPrint('✅ 最終同期時刻設定完了: $key');
    } catch (e) {
      debugPrint('❌ 最終同期時刻設定エラー: $e');
    }
  }
  
  /// 現在時刻で最終同期時刻を更新
  /// 
  /// 指定されたキーの最終同期時刻を現在時刻で更新する
  static Future<void> updateLastSyncTimeToSharedPrefs(String key) async {
    await setLastSyncTimeToSharedPrefs(key, DateTime.now());
  }
  
  // ===== 差分取得 =====
  
  /// 指定時刻以降に変更されたアイテムを取得
  /// 
  /// lastModifiedFieldで指定されたフィールドが指定時刻より新しいアイテムを取得する
  static Future<List<Map<String, dynamic>>> getModifiedItemsSince(
    String key, 
    DateTime since, 
    String lastModifiedField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      return items.where((item) {
        final lastModified = item[lastModifiedField];
        if (lastModified == null) return false;
        
        DateTime? lastModifiedDate;
        if (lastModified is DateTime) {
          lastModifiedDate = lastModified;
        } else if (lastModified is String) {
          lastModifiedDate = DateTime.tryParse(lastModified);
        } else if (lastModified is int) {
          lastModifiedDate = DateTime.fromMillisecondsSinceEpoch(lastModified);
        }
        
        return lastModifiedDate != null && lastModifiedDate.isAfter(since);
      }).toList();
    } catch (e) {
      debugPrint('❌ 差分データ取得エラー: $e');
      return [];
    }
  }
  
  /// 削除されていないアイテムのみを取得
  /// 
  /// isDeletedフィールドがfalseまたは存在しないアイテムのみを取得する
  static Future<List<Map<String, dynamic>>> getActiveItemsFromSharedPrefs(
    String key, 
    String isDeletedField
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      return items.where((item) {
        final isDeleted = item[isDeletedField];
        return isDeleted != true; // nullやfalseの場合は有効とみなす
      }).toList();
    } catch (e) {
      debugPrint('❌ 有効アイテム取得エラー: $e');
      return [];
    }
  }
  
  // ===== ユーティリティ関数 =====
  
  /// キーが存在するかチェック
  /// 
  /// 指定されたキーがSharedPreferencesに存在するか確認する
  static Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      debugPrint('❌ キー存在チェックエラー: $e');
      return false;
    }
  }
  
  /// 全てのキーを取得
  /// 
  /// SharedPreferencesに保存されている全てのキーを取得する
  static Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys();
    } catch (e) {
      debugPrint('❌ 全キー取得エラー: $e');
      return <String>{};
    }
  }
  
  /// 指定されたプレフィックスのキーを取得
  /// 
  /// 指定されたプレフィックスで始まるキーを取得する
  static Future<List<String>> getKeysWithPrefix(String prefix) async {
    try {
      final allKeys = await getAllKeys();
      return allKeys.where((key) => key.startsWith(prefix)).toList();
    } catch (e) {
      debugPrint('❌ プレフィックスキー取得エラー: $e');
      return [];
    }
  }
  
  /// 指定されたプレフィックスのキーを全て削除
  /// 
  /// 指定されたプレフィックスで始まるキーを全て削除する
  static Future<void> removeKeysWithPrefix(String prefix) async {
    try {
      final keysToRemove = await getKeysWithPrefix(prefix);
      final prefs = await SharedPreferences.getInstance();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      debugPrint('✅ プレフィックスキー削除完了: $prefix (${keysToRemove.length}件)');
    } catch (e) {
      debugPrint('❌ プレフィックスキー削除エラー: $e');
    }
  }

  // ===== Phase 4: 変更追跡機能 =====

  /// アイテムに変更フラグを付与
  /// 
  /// **処理フロー**:
  /// 1. アイテムに_isDirtyフィールドを追加
  /// 2. SharedPreferencesに保存
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// - `itemId`: アイテムのID
  /// - `idField`: IDフィールド名
  /// 
  /// **注意**: アイテムが存在しない場合は何もしない
  static Future<void> markAsDirty(
    String key,
    String itemId,
    String idField,
  ) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final index = items.indexWhere((item) => item[idField] == itemId);
      
      if (index != -1) {
        items[index]['_isDirty'] = true;
        items[index]['_dirtyTimestamp'] = DateTime.now().toIso8601String();
        await saveAllToSharedPrefs(key, items);
        debugPrint('✅ 変更フラグ付与: $itemId');
      } else {
        debugPrint('⚠️ アイテムが見つかりません: $itemId');
      }
    } catch (e) {
      debugPrint('❌ 変更フラグ付与エラー: $e');
    }
  }

  /// 変更されたアイテムのみを取得
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. _isDirtyがtrueのアイテムのみをフィルタ
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// 
  /// **戻り値**: 変更されたアイテムのリスト
  static Future<List<Map<String, dynamic>>> getDirtyItems(String key) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final dirtyItems = items
          .where((item) => item['_isDirty'] == true)
          .toList();
      
      debugPrint('✅ 変更アイテム取得: ${dirtyItems.length}件');
      return dirtyItems;
    } catch (e) {
      debugPrint('❌ 変更アイテム取得エラー: $e');
      return [];
    }
  }

  /// 変更フラグをクリア
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. _isDirtyと_dirtyTimestampフィールドを削除
  /// 3. SharedPreferencesに保存
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// - `itemIds`: クリアするアイテムのIDリスト（オプション、指定しない場合は全て）
  /// - `idField`: IDフィールド名
  static Future<void> clearDirtyFlags(
    String key, {
    List<String>? itemIds,
    String idField = 'id',
  }) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      
      for (final item in items) {
        final itemId = item[idField] as String?;
        
        // itemIdsが指定されている場合は、そのIDのみクリア
        if (itemIds != null && itemId != null) {
          if (!itemIds.contains(itemId)) {
            continue;
          }
        }
        
        item.remove('_isDirty');
        item.remove('_dirtyTimestamp');
      }
      
      await saveAllToSharedPrefs(key, items);
      debugPrint('✅ 変更フラグクリア完了: ${itemIds?.length ?? items.length}件');
    } catch (e) {
      debugPrint('❌ 変更フラグクリアエラー: $e');
    }
  }

  /// 変更されたアイテムの件数を取得
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// 
  /// **戻り値**: 変更されたアイテムの件数
  static Future<int> getDirtyItemCount(String key) async {
    try {
      final dirtyItems = await getDirtyItems(key);
      return dirtyItems.length;
    } catch (e) {
      debugPrint('❌ 変更アイテム数取得エラー: $e');
      return 0;
    }
  }

  // ===== Phase 4: スキーマバージョニング機能 =====

  /// スキーマバージョンを保存
  /// 
  /// **パラメータ**:
  /// - `key`: データのキー
  /// - `version`: スキーマバージョン
  static Future<void> saveSchemaVersion(String key, int version) async {
    try {
      final versionKey = '${key}_schema_version';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(versionKey, version);
      debugPrint('✅ スキーマバージョン保存: $key v$version');
    } catch (e) {
      debugPrint('❌ スキーマバージョン保存エラー: $e');
    }
  }

  /// スキーマバージョンを取得
  /// 
  /// **パラメータ**:
  /// - `key`: データのキー
  /// 
  /// **戻り値**: スキーマバージョン（未設定の場合は0）
  static Future<int> getSchemaVersion(String key) async {
    try {
      final versionKey = '${key}_schema_version';
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(versionKey) ?? 0;
      debugPrint('✅ スキーマバージョン取得: $key v$version');
      return version;
    } catch (e) {
      debugPrint('❌ スキーマバージョン取得エラー: $e');
      return 0;
    }
  }

  /// データマイグレーション
  /// 
  /// **処理フロー**:
  /// 1. 現在のスキーマバージョンを取得
  /// 2. マイグレーション関数を実行
  /// 3. 新しいスキーマバージョンを保存
  /// 
  /// **パラメータ**:
  /// - `key`: データのキー
  /// - `targetVersion`: 目標スキーマバージョン
  /// - `migrationFunction`: マイグレーション関数
  /// 
  /// **戻り値**: マイグレーションが実行された場合はtrue
  static Future<bool> migrateData(
    String key,
    int targetVersion,
    Future<List<Map<String, dynamic>>> Function(
      List<Map<String, dynamic>> oldData,
      int currentVersion,
    ) migrationFunction,
  ) async {
    try {
      final currentVersion = await getSchemaVersion(key);
      
      if (currentVersion >= targetVersion) {
        debugPrint('ℹ️ マイグレーション不要: v$currentVersion >= v$targetVersion');
        return false;
      }
      
      debugPrint('🔄 マイグレーション開始: v$currentVersion -> v$targetVersion');
      
      // 既存データを取得
      final oldData = await getAllFromSharedPrefs(key);
      
      // マイグレーション実行
      final newData = await migrationFunction(oldData, currentVersion);
      
      // 新しいデータを保存
      await saveAllToSharedPrefs(key, newData);
      
      // 新しいバージョンを保存
      await saveSchemaVersion(key, targetVersion);
      
      debugPrint('✅ マイグレーション完了: v$currentVersion -> v$targetVersion');
      return true;
    } catch (e) {
      debugPrint('❌ マイグレーションエラー: $e');
      return false;
    }
  }

  /// バージョン管理されたデータを保存
  /// 
  /// **処理フロー**:
  /// 1. データを保存
  /// 2. スキーマバージョンを保存
  /// 
  /// **パラメータ**:
  /// - `key`: データのキー
  /// - `items`: 保存するアイテム
  /// - `version`: スキーマバージョン
  static Future<void> saveWithVersion(
    String key,
    List<Map<String, dynamic>> items,
    int version,
  ) async {
    try {
      await saveAllToSharedPrefs(key, items);
      await saveSchemaVersion(key, version);
      debugPrint('✅ バージョン付きデータ保存: $key v$version (${items.length}件)');
    } catch (e) {
      debugPrint('❌ バージョン付きデータ保存エラー: $e');
    }
  }

  // ===== Phase 6: ローカルサイズ管理機能 =====

  /// SharedPreferencesの使用サイズを取得（概算）
  /// 
  /// **処理フロー**:
  /// 1. 全キーを取得
  /// 2. 各キーの値のサイズを計算
  /// 3. 合計サイズを返す
  /// 
  /// **戻り値**: 使用サイズ（バイト単位）
  /// 
  /// **注意**: あくまで概算値です
  static Future<int> getStorageSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int totalSize = 0;
      
      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          totalSize += value.length * 2; // UTF-16エンコーディングを想定
        } else if (value is int) {
          totalSize += 8; // intは8バイト
        } else if (value is double) {
          totalSize += 8; // doubleは8バイト
        } else if (value is bool) {
          totalSize += 1; // boolは1バイト
        }
      }
      
      debugPrint('✅ ストレージサイズ取得: $totalSizeバイト (${(totalSize / 1024).toStringAsFixed(2)}KB)');
      return totalSize;
    } catch (e) {
      debugPrint('❌ ストレージサイズ取得エラー: $e');
      return 0;
    }
  }

  /// 古いデータをクリア（TTLベース）
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. timestampフィールドをチェック
  /// 3. TTLを超えたアイテムを削除
  /// 4. 更新されたデータを保存
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// - `ttl`: 保持期間（Time To Live）
  /// - `timestampField`: タイムスタンプフィールド名（デフォルト: 'timestamp'）
  /// 
  /// **戻り値**: 削除されたアイテムの数
  static Future<int> clearOldData(
    String key,
    Duration ttl, {
    String timestampField = 'timestamp',
  }) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      final now = DateTime.now();
      final cutoffTime = now.subtract(ttl);
      
      final beforeCount = items.length;
      
      // TTLを超えたアイテムを削除
      items.removeWhere((item) {
        final timestampValue = item[timestampField];
        
        if (timestampValue == null) return false;
        
        DateTime? timestamp;
        if (timestampValue is String) {
          timestamp = DateTime.tryParse(timestampValue);
        } else if (timestampValue is DateTime) {
          timestamp = timestampValue;
        }
        
        if (timestamp == null) return false;
        
        return timestamp.isBefore(cutoffTime);
      });
      
      final removedCount = beforeCount - items.length;
      
      if (removedCount > 0) {
        await saveAllToSharedPrefs(key, items);
        debugPrint('✅ 古いデータクリア完了: $removedCount件削除 (残り${items.length}件)');
      } else {
        debugPrint('ℹ️ クリア対象のデータなし');
      }
      
      return removedCount;
    } catch (e) {
      debugPrint('❌ 古いデータクリアエラー: $e');
      return 0;
    }
  }

  /// ストレージサイズが制限を超えているかチェック
  /// 
  /// **パラメータ**:
  /// - `maxSize`: 最大サイズ（バイト単位）
  /// 
  /// **戻り値**: 制限を超えている場合はtrue
  static Future<bool> isStorageOverLimit(int maxSize) async {
    try {
      final currentSize = await getStorageSize();
      final isOver = currentSize > maxSize;
      
      if (isOver) {
        debugPrint('⚠️ ストレージ容量超過: $currentSizeバイト > $maxSizeバイト');
      }
      
      return isOver;
    } catch (e) {
      debugPrint('❌ ストレージ容量チェックエラー: $e');
      return false;
    }
  }

  /// 最も古いアイテムを削除
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. timestampFieldでソート
  /// 3. 最も古いアイテムを削除
  /// 
  /// **パラメータ**:
  /// - `key`: SharedPreferencesのキー
  /// - `count`: 削除する件数（デフォルト: 1）
  /// - `timestampField`: タイムスタンプフィールド名（デフォルト: 'timestamp'）
  /// 
  /// **戻り値**: 削除されたアイテムの数
  static Future<int> clearOldestItems(
    String key,
    int count, {
    String timestampField = 'timestamp',
  }) async {
    try {
      final items = await getAllFromSharedPrefs(key);
      
      if (items.isEmpty) {
        debugPrint('ℹ️ 削除対象のデータなし');
        return 0;
      }
      
      // timestampでソート
      items.sort((a, b) {
        final aTimestamp = _parseTimestamp(a[timestampField]);
        final bTimestamp = _parseTimestamp(b[timestampField]);
        
        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        
        return aTimestamp.compareTo(bTimestamp);
      });
      
      // 最も古いcount件を削除
      final removeCount = count < items.length ? count : items.length;
      final remainingItems = items.sublist(removeCount);
      
      await saveAllToSharedPrefs(key, remainingItems);
      debugPrint('✅ 最古アイテム削除完了: $removeCount件削除 (残り${remainingItems.length}件)');
      
      return removeCount;
    } catch (e) {
      debugPrint('❌ 最古アイテム削除エラー: $e');
      return 0;
    }
  }

  // ===== プライベートヘルパー関数 =====

  /// タイムスタンプを解析
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
