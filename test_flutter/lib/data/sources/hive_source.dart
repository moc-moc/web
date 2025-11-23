import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive関連の汎用的な基本関数
/// 
/// ローカルデータベース（Hive）の保存・取得・管理に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
/// 
/// **使用方法**:
/// 1. アプリ起動時に`HiveMk.initialize()`を呼び出す
/// 2. 各機能で`HiveMk`の関数を使用する
/// 3. 必要に応じて`HiveMk.close()`でクリーンアップ
class HiveMk {
  /// Hiveを初期化
  /// 
  /// アプリ起動時に1度だけ呼び出す必要がある
  /// すでに初期化されている場合は何もしない
  static Future<void> initialize() async {
    try {
      // すでに初期化されている場合はスキップ
      if (Hive.isBoxOpen('_hive_init_check')) {
        debugPrint('ℹ️ Hive初期化済み');
        return;
      }
      
      await Hive.initFlutter();
      
      // 初期化確認用のボックスを開く
      await Hive.openBox('_hive_init_check');
      
      debugPrint('✅ Hive初期化完了');
    } catch (e) {
      debugPrint('❌ Hive初期化エラー: $e');
      rethrow;
    }
  }
  
  /// Hiveをクローズ
  /// 
  /// アプリ終了時やテスト後に呼び出す
  static Future<void> close() async {
    try {
      await Hive.close();
      debugPrint('✅ Hiveクローズ完了');
    } catch (e) {
      debugPrint('❌ Hiveクローズエラー: $e');
    }
  }
  
  // ===== Hive基本操作 =====
  
  /// リストデータ全体をHiveに保存
  /// 
  /// Map<String, dynamic>のリストをJSON形式で保存する
  static Future<void> saveAllToHive(String boxName, List<Map<String, dynamic>> items) async {
    try {
      final box = await Hive.openBox(boxName);
      final jsonString = json.encode(items);
      await box.put('data', jsonString);
      
      // ボックス名を登録（getAllBoxNamesで取得できるようにする）
      await _registerBoxName(boxName);
    } catch (e) {
      debugPrint('❌ Hiveリストデータ保存エラー: $e');
    }
  }
  
  /// リストデータ全体をHiveから取得
  /// 
  /// 指定されたボックス名のデータをJSON形式で取得する
  /// データが存在しない場合は空のリストを返す
  static Future<List<Map<String, dynamic>>> getAllFromHive(String boxName) async {
    try {
      final box = await Hive.openBox(boxName);
      final jsonString = box.get('data') as String?;
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Hiveリストデータ取得エラー: $e');
      return [];
    }
  }
  
  /// リストデータの件数を取得
  /// 
  /// 指定されたボックス名のデータ件数を取得する
  static Future<int> getListCount(String boxName) async {
    try {
      final items = await getAllFromHive(boxName);
      return items.length;
    } catch (e) {
      debugPrint('❌ Hiveリスト件数取得エラー: $e');
      return 0;
    }
  }
  
  // ===== 単一アイテム操作 =====
  
  /// 単一アイテムをリストに追加
  /// 
  /// 既存のリストに新しいアイテムを追加する
  /// idFieldでアイテムのIDフィールドを指定する
  static Future<void> addItemToHive(
    String boxName,
    Map<String, dynamic> item,
    String idField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      items.add(item);
      await saveAllToHive(boxName, items);
      debugPrint('✅ Hiveアイテム追加完了: $boxName (ID: ${item[idField]})');
    } catch (e) {
      debugPrint('❌ Hiveアイテム追加エラー: $e');
    }
  }
  
  /// 単一アイテムをリスト内で更新
  /// 
  /// 指定されたIDのアイテムを更新する
  /// idFieldでアイテムのIDフィールドを指定する
  static Future<void> updateItemInHive(
    String boxName,
    Map<String, dynamic> item,
    String idField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      final itemId = item[idField] as String?;
      
      if (itemId == null) {
        debugPrint('❌ アイテムIDが指定されていません');
        return;
      }
      
      final index = items.indexWhere((i) => i[idField] == itemId);
      if (index != -1) {
        items[index] = item;
        await saveAllToHive(boxName, items);
        debugPrint('✅ Hiveアイテム更新完了: $boxName (ID: $itemId)');
      } else {
        debugPrint('❌ アイテムが見つかりません: $itemId');
      }
    } catch (e) {
      debugPrint('❌ Hiveアイテム更新エラー: $e');
    }
  }
  
  /// 単一アイテムをリストから削除
  /// 
  /// 指定されたIDのアイテムをリストから削除する
  /// idFieldでアイテムのIDフィールドを指定する
  /// 
  /// **戻り値**: 削除が成功した場合はtrue、アイテムが見つからない場合はfalse
  static Future<bool> removeItemFromHive(
    String boxName,
    String itemId,
    String idField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      final beforeCount = items.length;
      
      items.removeWhere((item) => item[idField] == itemId);
      
      if (items.length < beforeCount) {
        await saveAllToHive(boxName, items);
        debugPrint('✅ Hiveアイテム削除完了: $boxName (ID: $itemId)');
        return true;
      } else {
        // 既に存在しない場合は正常な状態の可能性がある（INFOレベル）
        debugPrint('ℹ️ アイテムが見つかりません（既に削除済みの可能性）: $itemId');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Hiveアイテム削除エラー: $e');
      return false;
    }
  }
  
  /// 指定されたIDのアイテムを取得
  /// 
  /// リスト内から指定されたIDのアイテムを取得する
  static Future<Map<String, dynamic>?> getItemFromHive(
    String boxName,
    String itemId,
    String idField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      final item = items.firstWhere(
        (item) => item[idField] == itemId,
        orElse: () => <String, dynamic>{},
      );
      
      return item.isNotEmpty ? item : null;
    } catch (e) {
      debugPrint('❌ Hiveアイテム取得エラー: $e');
      return null;
    }
  }
  
  /// ボックス全体を削除
  /// 
  /// 指定されたボックス名の全データを削除する
  static Future<void> removeFromHive(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.clear();
        await box.close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      debugPrint('✅ Hiveボックス削除完了: $boxName');
    } catch (e) {
      debugPrint('❌ Hiveボックス削除エラー: $e');
    }
  }
  
  // ===== 同期時刻管理 =====
  
  /// 最終同期時刻をHiveから取得
  /// 
  /// 指定されたキーの最終同期時刻を取得する
  /// 同期時刻は'{boxName}_last_sync'として保存される
  static Future<DateTime?> getLastSyncTimeFromHive(String boxName) async {
    try {
      final box = await Hive.openBox('_hive_metadata');
      final timestamp = box.get('${boxName}_last_sync') as int?;
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      debugPrint('❌ Hive最終同期時刻取得エラー: $e');
      return null;
    }
  }
  
  /// 最終同期時刻をHiveに設定
  /// 
  /// 指定されたキーの最終同期時刻を設定する
  /// 同期時刻は'{boxName}_last_sync'として保存される
  static Future<void> setLastSyncTimeToHive(String boxName, DateTime time) async {
    try {
      final box = await Hive.openBox('_hive_metadata');
      await box.put('${boxName}_last_sync', time.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Hive最終同期時刻設定エラー: $e');
    }
  }
  
  /// 現在時刻で最終同期時刻を更新
  /// 
  /// 指定されたキーの最終同期時刻を現在時刻で更新する
  static Future<void> updateLastSyncTimeToHive(String boxName) async {
    await setLastSyncTimeToHive(boxName, DateTime.now());
  }
  
  // ===== 差分取得 =====
  
  /// 指定時刻以降に変更されたアイテムを取得
  /// 
  /// lastModifiedFieldで指定されたフィールドが指定時刻より新しいアイテムを取得する
  static Future<List<Map<String, dynamic>>> getModifiedItemsSince(
    String boxName,
    DateTime since,
    String lastModifiedField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
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
      debugPrint('❌ Hive差分データ取得エラー: $e');
      return [];
    }
  }
  
  /// 削除されていないアイテムのみを取得
  /// 
  /// isDeletedフィールドがfalseまたは存在しないアイテムのみを取得する
  static Future<List<Map<String, dynamic>>> getActiveItemsFromHive(
    String boxName,
    String isDeletedField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      return items.where((item) {
        final isDeleted = item[isDeletedField];
        return isDeleted != true; // nullやfalseの場合は有効とみなす
      }).toList();
    } catch (e) {
      debugPrint('❌ Hive有効アイテム取得エラー: $e');
      return [];
    }
  }
  
  // ===== ユーティリティ関数 =====
  
  /// ボックスが存在するかチェック
  /// 
  /// 指定されたボックス名のデータが存在するか確認する
  static Future<bool> containsBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        return box.containsKey('data');
      }
      
      final box = await Hive.openBox(boxName);
      final exists = box.containsKey('data');
      return exists;
    } catch (e) {
      debugPrint('❌ Hiveボックス存在チェックエラー: $e');
      return false;
    }
  }
  
  /// 全てのボックス名を取得
  /// 
  /// Hiveに保存されている全てのボックス名を取得する
  /// メタデータボックスは除外する
  static Future<List<String>> getAllBoxNames() async {
    try {
      // Hiveのボックス一覧を取得
      // 注意: Hive 2.x以降ではボックス一覧を直接取得できないため、
      // メタデータボックスに登録されたボックス名を返す
      final metadataBox = await Hive.openBox('_hive_metadata');
      final boxNames = metadataBox.get('_box_names') as List<dynamic>?;
      
      if (boxNames == null) return [];
      
      return boxNames.cast<String>().where((name) => 
        !name.startsWith('_hive_')
      ).toList();
    } catch (e) {
      debugPrint('❌ Hive全ボックス名取得エラー: $e');
      return [];
    }
  }
  
  /// ボックス名を登録（内部使用）
  /// 
  /// saveAllToHiveで新しいボックスを作成した際に自動的に登録する
  static Future<void> _registerBoxName(String boxName) async {
    try {
      final metadataBox = await Hive.openBox('_hive_metadata');
      final boxNames = metadataBox.get('_box_names') as List<dynamic>? ?? [];
      final boxNamesList = boxNames.cast<String>();
      
      if (!boxNamesList.contains(boxName)) {
        boxNamesList.add(boxName);
        await metadataBox.put('_box_names', boxNamesList);
      }
    } catch (e) {
      debugPrint('❌ Hiveボックス名登録エラー: $e');
    }
  }
  
  /// 指定されたプレフィックスのボックスを全て削除
  /// 
  /// 指定されたプレフィックスで始まるボックスを全て削除する
  static Future<void> removeBoxesWithPrefix(String prefix) async {
    try {
      final boxNames = await getAllBoxNames();
      final matchingBoxes = boxNames.where((name) => name.startsWith(prefix)).toList();
      
      for (final boxName in matchingBoxes) {
        await removeFromHive(boxName);
      }
      
      debugPrint('✅ Hiveプレフィックスボックス削除完了: $prefix (${matchingBoxes.length}件)');
    } catch (e) {
      debugPrint('❌ Hiveプレフィックスボックス削除エラー: $e');
    }
  }
  
  // ===== Phase 4: 変更追跡機能 =====
  
  /// アイテムに変更フラグを付与
  /// 
  /// **処理フロー**:
  /// 1. アイテムに_isDirtyフィールドを追加
  /// 2. Hiveに保存
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// - `itemId`: アイテムのID
  /// - `idField`: IDフィールド名
  /// 
  /// **注意**: アイテムが存在しない場合は何もしない
  static Future<void> markAsDirty(
    String boxName,
    String itemId,
    String idField,
  ) async {
    try {
      final items = await getAllFromHive(boxName);
      final index = items.indexWhere((item) => item[idField] == itemId);
      
      if (index != -1) {
        items[index]['_isDirty'] = true;
        items[index]['_dirtyTimestamp'] = DateTime.now().toIso8601String();
        await saveAllToHive(boxName, items);
        debugPrint('✅ Hive変更フラグ付与: $itemId');
      } else {
        debugPrint('⚠️ アイテムが見つかりません: $itemId');
      }
    } catch (e) {
      debugPrint('❌ Hive変更フラグ付与エラー: $e');
    }
  }
  
  /// 変更されたアイテムのみを取得
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. _isDirtyがtrueのアイテムのみをフィルタ
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// 
  /// **戻り値**: 変更されたアイテムのリスト
  static Future<List<Map<String, dynamic>>> getDirtyItems(String boxName) async {
    try {
      final items = await getAllFromHive(boxName);
      final dirtyItems = items
          .where((item) => item['_isDirty'] == true)
          .toList();
      
      debugPrint('✅ Hive変更アイテム取得: ${dirtyItems.length}件');
      return dirtyItems;
    } catch (e) {
      debugPrint('❌ Hive変更アイテム取得エラー: $e');
      return [];
    }
  }
  
  /// 変更フラグをクリア
  /// 
  /// **処理フロー**:
  /// 1. 全アイテムを取得
  /// 2. _isDirtyと_dirtyTimestampフィールドを削除
  /// 3. Hiveに保存
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// - `itemIds`: クリアするアイテムのIDリスト（オプション、指定しない場合は全て）
  /// - `idField`: IDフィールド名
  static Future<void> clearDirtyFlags(
    String boxName, {
    List<String>? itemIds,
    String idField = 'id',
  }) async {
    try {
      final items = await getAllFromHive(boxName);
      
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
      
      await saveAllToHive(boxName, items);
      debugPrint('✅ Hive変更フラグクリア完了: ${itemIds?.length ?? items.length}件');
    } catch (e) {
      debugPrint('❌ Hive変更フラグクリアエラー: $e');
    }
  }
  
  /// 変更されたアイテムの件数を取得
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// 
  /// **戻り値**: 変更されたアイテムの件数
  static Future<int> getDirtyItemCount(String boxName) async {
    try {
      final dirtyItems = await getDirtyItems(boxName);
      return dirtyItems.length;
    } catch (e) {
      debugPrint('❌ Hive変更アイテム数取得エラー: $e');
      return 0;
    }
  }
  
  // ===== Phase 4: スキーマバージョニング機能 =====
  
  /// スキーマバージョンを保存
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// - `version`: スキーマバージョン
  static Future<void> saveSchemaVersion(String boxName, int version) async {
    try {
      final metadataBox = await Hive.openBox('_hive_metadata');
      final versionKey = '${boxName}_schema_version';
      await metadataBox.put(versionKey, version);
      debugPrint('✅ Hiveスキーマバージョン保存: $boxName v$version');
    } catch (e) {
      debugPrint('❌ Hiveスキーマバージョン保存エラー: $e');
    }
  }
  
  /// スキーマバージョンを取得
  /// 
  /// **パラメータ**:
  /// - `boxName`: ボックス名
  /// 
  /// **戻り値**: スキーマバージョン（未設定の場合は0）
  static Future<int> getSchemaVersion(String boxName) async {
    try {
      final metadataBox = await Hive.openBox('_hive_metadata');
      final versionKey = '${boxName}_schema_version';
      final version = metadataBox.get(versionKey) as int? ?? 0;
      debugPrint('✅ Hiveスキーマバージョン取得: $boxName v$version');
      return version;
    } catch (e) {
      debugPrint('❌ Hiveスキーマバージョン取得エラー: $e');
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
  /// - `boxName`: ボックス名
  /// - `targetVersion`: 目標スキーマバージョン
  /// - `migrationFunction`: マイグレーション関数
  /// 
  /// **戻り値**: マイグレーションが実行された場合はtrue
  static Future<bool> migrateData(
    String boxName,
    int targetVersion,
    Future<List<Map<String, dynamic>>> Function(
      List<Map<String, dynamic>> oldData,
      int currentVersion,
    ) migrationFunction,
  ) async {
    try {
      final currentVersion = await getSchemaVersion(boxName);
      
      if (currentVersion >= targetVersion) {
        debugPrint('ℹ️ マイグレーション不要: v$currentVersion >= v$targetVersion');
        return false;
      }
      
      debugPrint('🔄 マイグレーション開始: v$currentVersion -> v$targetVersion');
      
      // 既存データを取得
      final oldData = await getAllFromHive(boxName);
      
      // マイグレーション実行
      final newData = await migrationFunction(oldData, currentVersion);
      
      // 新しいデータを保存
      await saveAllToHive(boxName, newData);
      
      // 新しいバージョンを保存
      await saveSchemaVersion(boxName, targetVersion);
      
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
  /// - `boxName`: ボックス名
  /// - `items`: 保存するアイテム
  /// - `version`: スキーマバージョン
  static Future<void> saveWithVersion(
    String boxName,
    List<Map<String, dynamic>> items,
    int version,
  ) async {
    try {
      await saveAllToHive(boxName, items);
      await saveSchemaVersion(boxName, version);
      debugPrint('✅ Hiveバージョン付きデータ保存: $boxName v$version (${items.length}件)');
    } catch (e) {
      debugPrint('❌ Hiveバージョン付きデータ保存エラー: $e');
    }
  }
  
  // ===== Phase 6: ローカルサイズ管理機能 =====
  
  /// Hiveの使用サイズを取得（概算）
  /// 
  /// **処理フロー**:
  /// 1. 全ボックスを取得
  /// 2. 各ボックスのデータサイズを計算
  /// 3. 合計サイズを返す
  /// 
  /// **戻り値**: 使用サイズ（バイト単位）
  /// 
  /// **注意**: あくまで概算値です
  static Future<int> getStorageSize() async {
    try {
      int totalSize = 0;
      
      // 開いているボックスのサイズを計算
      final boxNames = await getAllBoxNames();
      
      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final data = box.get('data') as String?;
            if (data != null) {
              totalSize += data.length * 2; // UTF-16エンコーディングを想定
            }
          } else {
            final box = await Hive.openBox(boxName);
            final data = box.get('data') as String?;
            if (data != null) {
              totalSize += data.length * 2;
            }
          }
        } catch (e) {
          debugPrint('⚠️ ボックスサイズ計算エラー: $boxName - $e');
        }
      }
      
      debugPrint('✅ Hiveストレージサイズ取得: $totalSizeバイト (${(totalSize / 1024).toStringAsFixed(2)}KB)');
      return totalSize;
    } catch (e) {
      debugPrint('❌ Hiveストレージサイズ取得エラー: $e');
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
  /// - `boxName`: ボックス名
  /// - `ttl`: 保持期間（Time To Live）
  /// - `timestampField`: タイムスタンプフィールド名（デフォルト: 'timestamp'）
  /// 
  /// **戻り値**: 削除されたアイテムの数
  static Future<int> clearOldData(
    String boxName,
    Duration ttl, {
    String timestampField = 'timestamp',
  }) async {
    try {
      final items = await getAllFromHive(boxName);
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
        } else if (timestampValue is int) {
          timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue);
        }
        
        if (timestamp == null) return false;
        
        return timestamp.isBefore(cutoffTime);
      });
      
      final removedCount = beforeCount - items.length;
      
      if (removedCount > 0) {
        await saveAllToHive(boxName, items);
        debugPrint('✅ Hive古いデータクリア完了: $removedCount件削除 (残り${items.length}件)');
      } else {
        debugPrint('ℹ️ クリア対象のデータなし');
      }
      
      return removedCount;
    } catch (e) {
      debugPrint('❌ Hive古いデータクリアエラー: $e');
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
        debugPrint('⚠️ Hiveストレージ容量超過: $currentSizeバイト > $maxSizeバイト');
      }
      
      return isOver;
    } catch (e) {
      debugPrint('❌ Hiveストレージ容量チェックエラー: $e');
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
  /// - `boxName`: ボックス名
  /// - `count`: 削除する件数（デフォルト: 1）
  /// - `timestampField`: タイムスタンプフィールド名（デフォルト: 'timestamp'）
  /// 
  /// **戻り値**: 削除されたアイテムの数
  static Future<int> clearOldestItems(
    String boxName,
    int count, {
    String timestampField = 'timestamp',
  }) async {
    try {
      final items = await getAllFromHive(boxName);
      
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
      
      await saveAllToHive(boxName, remainingItems);
      debugPrint('✅ Hive最古アイテム削除完了: $removeCount件削除 (残り${remainingItems.length}件)');
      
      return removeCount;
    } catch (e) {
      debugPrint('❌ Hive最古アイテム削除エラー: $e');
      return 0;
    }
  }
  
  // ===== プライベートヘルパー関数 =====
  
  /// タイムスタンプを解析
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
  
}

