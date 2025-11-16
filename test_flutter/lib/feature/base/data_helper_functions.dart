import 'package:flutter/foundation.dart';

/// リストデータを読み込む共通ヘルパー関数
/// 
/// Firestoreから最新のリストを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルを使用します。
/// 
/// **型パラメータ**:
/// - `T`: データモデルの型
/// 
/// **パラメータ**:
/// - `ref`: Provider操作用のRef
/// - `manager`: DataManagerのインスタンス
/// - `getAllWithAuth`: Firestoreから全データを取得する関数
/// - `getLocalAll`: ローカルから全データを取得する関数
/// - `saveLocal`: ローカルに保存する関数
/// - `updateProvider`: Providerを更新する関数（NotifierのupdateListを呼び出す）
/// - `filter`: フィルタリング関数（デフォルト: isDeleted=falseのもののみ）
/// - `functionName`: デバッグ用の関数名
/// 
/// **戻り値**: 読み込んだデータリスト
Future<List<T>> loadListDataHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<List<T>> Function() getAllWithAuth,
  required Future<List<T>> Function() getLocalAll,
  required Future<void> Function(List<T>) saveLocal,
  required void Function(List<T>) updateProvider,
  bool Function(T)? filter,
  String functionName = 'loadListDataHelper',
}) async {
  debugPrint('🔍 [$functionName] 開始');
  
  // デフォルトフィルタ: isDeleted=falseのもののみ（isDeletedプロパティがある場合）
  final effectiveFilter = filter ?? ((item) {
    try {
      final dynamic itemDynamic = item;
      if (itemDynamic is Map) {
        return itemDynamic['isDeleted'] != true;
      }
      // isDeletedプロパティがない場合はすべて含める
      return true;
    } catch (e) {
      return true;
    }
  });

  // Firestoreから取得を試みる（Firestore優先）
  try {
    final items = await getAllWithAuth();
    debugPrint('🔍 [$functionName] Firestoreから取得: ${items.length}件');
    
    // ローカルにも保存
    await saveLocal(items);
    debugPrint('✅ [$functionName] ローカルに保存完了');
    
    // フィルタリング
    final filteredItems = items.where(effectiveFilter).toList();
    debugPrint('🔍 [$functionName] フィルタ後: ${filteredItems.length}件');

    // Providerを更新
    updateProvider(filteredItems);
    debugPrint('🔍 [$functionName] Provider更新完了');
    
    return filteredItems;
  } catch (e) {
    debugPrint('⚠️ [$functionName] Firestore取得失敗（オフライン？）: $e');
  }

  // Firestoreから取得できない場合はローカルを使用
  debugPrint('📱 [$functionName] ローカルデータを使用');
  final items = await getLocalAll();
  debugPrint('🔍 [$functionName] ローカルから取得: ${items.length}件');

  // フィルタリング
  final filteredItems = items.where(effectiveFilter).toList();
  debugPrint('🔍 [$functionName] フィルタ後: ${filteredItems.length}件');

  // Providerを更新
  updateProvider(filteredItems);
  debugPrint('🔍 [$functionName] Provider更新完了');

  return filteredItems;
}

/// リストデータを同期する共通ヘルパー関数
/// 
/// Firestoreとローカルストレージを同期し、Providerを最新の状態に更新します。
/// 
/// **型パラメータ**:
/// - `T`: データモデルの型
/// 
/// **パラメータ**:
/// - `ref`: Provider操作用のRef
/// - `manager`: DataManagerのインスタンス
/// - `syncWithAuth`: Firestoreと同期する関数
/// - `updateProvider`: Providerを更新する関数（NotifierのupdateListを呼び出す）
/// - `filter`: フィルタリング関数（デフォルト: isDeleted=falseのもののみ）
/// - `functionName`: デバッグ用の関数名
/// 
/// **戻り値**: 同期されたデータリスト
Future<List<T>> syncListDataHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<List<T>> Function() syncWithAuth,
  required void Function(List<T>) updateProvider,
  bool Function(T)? filter,
  String functionName = 'syncListDataHelper',
}) async {
  debugPrint('🔍 [$functionName] 開始');
  
  // デフォルトフィルタ: isDeleted=falseのもののみ
  final effectiveFilter = filter ?? ((item) {
    try {
      final dynamic itemDynamic = item;
      if (itemDynamic is Map) {
        return itemDynamic['isDeleted'] != true;
      }
      return true;
    } catch (e) {
      return true;
    }
  });

  // Firestoreと同期（認証自動取得版）
  final items = await syncWithAuth();
  debugPrint('🔍 [$functionName] 同期で取得: ${items.length}件');

  // フィルタリング
  final filteredItems = items.where(effectiveFilter).toList();
  debugPrint('🔍 [$functionName] フィルタ後: ${filteredItems.length}件');

  // Providerを更新
  updateProvider(filteredItems);
  debugPrint('🔍 [$functionName] Provider更新完了');

  return filteredItems;
}

/// 単一データを読み込む共通ヘルパー関数
/// 
/// Firestoreから最新データを取得し、Providerに設定します。
/// Firestoreから取得できない場合はローカルまたはデフォルト値を使用します。
/// 
/// **型パラメータ**:
/// - `T`: データモデルの型
/// 
/// **パラメータ**:
/// - `ref`: Provider操作用のRef
/// - `manager`: DataManagerのインスタンス
/// - `getWithAuth`: Firestoreからデータを取得する関数（nullを返す可能性あり）
/// - `getDefault`: デフォルト値を取得する関数
/// - `updateProvider`: Providerを更新する関数（NotifierのupdateXxxを呼び出す）
/// - `functionName`: デバッグ用の関数名
/// 
/// **戻り値**: 読み込んだデータ
Future<T> loadSingleDataHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<T?> Function() getWithAuth,
  required Future<T> Function() getDefault,
  required void Function(T) updateProvider,
  String functionName = 'loadSingleDataHelper',
}) async {
  debugPrint('🔍 [$functionName] 開始');
  
  // Firestoreから取得を試みる（Firestore優先）
  final data = await getWithAuth();
  
  if (data != null) {
    debugPrint('🔍 [$functionName] Firestoreから取得成功');
  } else {
    // Firestoreから取得できない場合はデフォルト値
    final defaultData = await getDefault();
    debugPrint('🔍 [$functionName] デフォルト値を使用');
    
    // Providerを更新
    updateProvider(defaultData);
    debugPrint('🔍 [$functionName] Provider更新完了');
    
    return defaultData;
  }

  // Providerを更新
  updateProvider(data);
  debugPrint('🔍 [$functionName] Provider更新完了');

  return data;
}

/// 単一データを同期する共通ヘルパー関数
/// 
/// Firestoreとローカルストレージを同期し、Providerを最新の状態に更新します。
/// 
/// **型パラメータ**:
/// - `T`: データモデルの型
/// 
/// **パラメータ**:
/// - `ref`: Provider操作用のRef
/// - `manager`: DataManagerのインスタンス
/// - `syncWithAuth`: Firestoreと同期する関数（リストを返す）
/// - `getDefault`: デフォルト値を取得する関数
/// - `updateProvider`: Providerを更新する関数（NotifierのupdateXxxを呼び出す）
/// - `functionName`: デバッグ用の関数名
/// 
/// **戻り値**: 同期されたデータ
Future<T> syncSingleDataHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<List<T>> Function() syncWithAuth,
  required Future<T> Function() getDefault,
  required void Function(T) updateProvider,
  String functionName = 'syncSingleDataHelper',
}) async {
  debugPrint('🔍 [$functionName] 開始');
  
  // Firestoreと同期（認証自動取得版）
  final syncedList = await syncWithAuth();
  debugPrint('🔍 [$functionName] 同期で取得: ${syncedList.length}件');

  // 単一データは1つだけなので、リストから取得またはデフォルト値
  final data = syncedList.isNotEmpty 
      ? syncedList.first 
      : await getDefault();
  
  debugPrint('🔍 [$functionName] 最終データ取得完了');

  // Providerを更新
  updateProvider(data);
  debugPrint('🔍 [$functionName] Provider更新完了');

  return data;
}

