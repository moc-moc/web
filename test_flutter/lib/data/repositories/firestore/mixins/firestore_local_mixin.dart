import 'package:test_flutter/data/sources/local_storage_source.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// ローカル操作のMixin
/// 
/// SharedPreferencesへのローカル操作を提供
mixin FirestoreLocalMixin<T> {
  // 必要なフィールドとメソッド
  String get storageKey;
  String get idField;
  T Function(Map<String, dynamic> json) get fromJson;
  Map<String, dynamic> Function(T item) get toJson;
  String _getItemId(T item);

  /// ローカルから全アイテムを取得
  /// 
  Future<List<T>> getLocalAll() async {
    try {
      // 1. ローカルデータを取得
      final dataList = await SharedMk.getAllFromSharedPrefs(storageKey);
      
      // 2. 各データをモデルに変換
      final items = <T>[];
      for (final data in dataList) {
        try {
          final item = fromJson(data);
          items.add(item);
        } catch (e) {
          await LogMk.logWarning(' ローカルデータ変換エラー: $e');
          // 変換に失敗したアイテムはスキップ
        }
      }
      
      await LogMk.logInfo('✅ ローカルアイテム取得完了: ${items.length}件');
      return items;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム取得エラー: $e');
      return [];
    }
  }

  /// ローカルから指定IDのアイテムを取得
  /// 
  Future<T?> getLocalById(String id) async {
    try {
      // 1. ローカルからデータを取得
      final data = await SharedMk.getItemFromSharedPrefs(
        storageKey,
        id,
        idField,
      );
      
      if (data == null) {
        await LogMk.logInfo('ℹ️ ローカルアイテムが見つかりません: $id');
        return null;
      }
      
      // 2. モデルに変換
      final item = fromJson(data);
      
      await LogMk.logInfo('✅ ローカルアイテム取得完了: $id');
      return item;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム取得エラー: $e');
      return null;
    }
  }

  /// ローカルに全アイテムを保存
  /// 
  Future<void> saveLocal(List<T> items) async {
    try {
      // 1. 各アイテムをMapに変換
      final dataList = items.map((item) => toJson(item)).toList();
      
      // 2. ローカルに保存
      await SharedMk.saveAllToSharedPrefs(storageKey, dataList);
      
      await LogMk.logInfo('✅ ローカルアイテム保存完了: ${items.length}件');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム保存エラー: $e');
    }
  }

  /// ローカルにアイテムを追加
  /// 
  Future<void> addLocal(T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toJson(item);
      
      // 2. ローカルに追加
      await SharedMk.addItemToSharedPrefs(
        storageKey,
        data,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム追加完了: ${_getItemId(item)}');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム追加エラー: $e');
    }
  }

  /// ローカルのアイテムを更新
  /// 
  Future<void> updateLocal(T item) async {
    try {
      // 1. モデルをMapに変換
      final data = toJson(item);
      
      // 2. ローカルを更新
      await SharedMk.updateItemInSharedPrefs(
        storageKey,
        data,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム更新完了: ${_getItemId(item)}');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム更新エラー: $e');
    }
  }

  /// ローカルからアイテムを削除
  /// 
  Future<void> deleteLocal(String id) async {
    try {
      // 1. ローカルから削除
      await SharedMk.removeItemFromSharedPrefs(
        storageKey,
        id,
        idField,
      );
      
      await LogMk.logInfo('✅ ローカルアイテム削除完了: $id');
    } catch (e) {
      await LogMk.logError(' ローカルアイテム削除エラー: $e');
    }
  }

  /// ローカルデータを全てクリア
  /// 
  Future<void> clearLocal() async {
    try {
      // 1. ローカルデータをクリア
      await SharedMk.removeFromSharedPrefs(storageKey);
      
      await LogMk.logInfo('✅ ローカルデータクリア完了: $storageKey');
    } catch (e) {
      await LogMk.logError(' ローカルデータクリアエラー: $e');
    }
  }

  /// ローカルのアイテム数を取得
  /// 
  Future<int> getLocalCount() async {
    try {
      // 1. ローカルのアイテム数を取得
      final count = await SharedMk.getListCount(storageKey);
      
      await LogMk.logInfo('✅ ローカルアイテム数取得完了: $count件');
      return count;
    } catch (e) {
      await LogMk.logError(' ローカルアイテム数取得エラー: $e');
      return 0;
    }
  }
}

