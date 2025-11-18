import 'package:flutter/material.dart';

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
  // デフォルトフィルタ: isDeleted=falseのもののみ（型チェックを事前実行）
  bool Function(T) effectiveFilter;
  if (filter != null) {
    effectiveFilter = filter;
  } else {
    // 型チェックを1回だけ実行してフィルタ関数を決定
    final sampleItem = await getLocalAll().then((items) => items.isNotEmpty ? items.first : null);
    if (sampleItem != null) {
      // SyncableModelインターフェースを実装しているかチェック
      final dynamic itemDynamic = sampleItem;
      if (itemDynamic is Map) {
        // Map型の場合
        effectiveFilter = (item) {
          final dynamic d = item;
          return d is Map ? (d['isDeleted'] != true) : true;
        };
      } else {
        // オブジェクト型の場合、isDeletedプロパティの存在を確認
        try {
          final hasIsDeleted = (itemDynamic as dynamic).isDeleted != null;
          if (hasIsDeleted) {
            effectiveFilter = (item) {
              try {
                return ((item as dynamic).isDeleted as bool?) != true;
              } catch (e) {
                return true;
              }
            };
          } else {
            effectiveFilter = (_) => true;
          }
        } catch (e) {
          effectiveFilter = (_) => true;
        }
      }
    } else {
      effectiveFilter = (_) => true;
    }
  }

  // Firestoreから取得を試みる（Firestore優先）
  try {
    final items = await getAllWithAuth();
    
    // ローカルにも保存
    await saveLocal(items);
    
    // フィルタリング（1回の走査で実行）
    final filteredItems = <T>[];
    for (final item in items) {
      if (effectiveFilter(item)) {
        filteredItems.add(item);
      }
    }

    // Providerを更新
    updateProvider(filteredItems);
    
    return filteredItems;
  } catch (e) {
    // Firestoreから取得できない場合はローカルを使用
    final items = await getLocalAll();

    // フィルタリング（1回の走査で実行）
    final filteredItems = <T>[];
    for (final item in items) {
      if (effectiveFilter(item)) {
        filteredItems.add(item);
      }
    }

    // Providerを更新
    updateProvider(filteredItems);

    return filteredItems;
  }
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
  // Firestoreと同期（認証自動取得版）
  final items = await syncWithAuth();

  // デフォルトフィルタ: isDeleted=falseのもののみ（型チェックを事前実行）
  bool Function(T) effectiveFilter;
  if (filter != null) {
    effectiveFilter = filter;
  } else {
    // 型チェックを1回だけ実行してフィルタ関数を決定
    if (items.isNotEmpty) {
      final sampleItem = items.first;
      final dynamic itemDynamic = sampleItem;
      if (itemDynamic is Map) {
        // Map型の場合
        effectiveFilter = (item) {
          final dynamic d = item;
          return d is Map ? (d['isDeleted'] != true) : true;
        };
      } else {
        // オブジェクト型の場合、isDeletedプロパティの存在を確認
        try {
          final hasIsDeleted = (itemDynamic as dynamic).isDeleted != null;
          if (hasIsDeleted) {
            effectiveFilter = (item) {
              try {
                return ((item as dynamic).isDeleted as bool?) != true;
              } catch (e) {
                return true;
              }
            };
          } else {
            effectiveFilter = (_) => true;
          }
        } catch (e) {
          effectiveFilter = (_) => true;
        }
      }
    } else {
      effectiveFilter = (_) => true;
    }
  }

  // フィルタリング（1回の走査で実行）
  final filteredItems = <T>[];
  for (final item in items) {
    if (effectiveFilter(item)) {
      filteredItems.add(item);
    }
  }

  // Providerを更新
  updateProvider(filteredItems);

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
  // Firestoreから取得を試みる（Firestore優先）
  final data = await getWithAuth();
  
  if (data != null) {
    // Providerを更新
    updateProvider(data);
    return data;
  } else {
    // Firestoreから取得できない場合はデフォルト値
    final defaultData = await getDefault();
    
    // Providerを更新
    updateProvider(defaultData);
    
    return defaultData;
  }
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
  // Firestoreと同期（認証自動取得版）
  final syncedList = await syncWithAuth();

  // 単一データは1つだけなので、リストから取得またはデフォルト値
  final data = syncedList.isNotEmpty 
      ? syncedList.first 
      : await getDefault();

  // Providerを更新
  updateProvider(data);

  return data;
}

/// リストデータをバックグラウンド更新で読み込む共通ヘルパー関数
/// 
/// まずローカルからデータを取得して即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
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
/// **戻り値**: 読み込んだデータリスト（ローカルデータ）
Future<List<T>> loadListDataWithBackgroundRefreshHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<List<T>> Function() getAllWithAuth,
  required Future<List<T>> Function() getLocalAll,
  required Future<void> Function(List<T>) saveLocal,
  required void Function(List<T>) updateProvider,
  bool Function(T)? filter,
  String functionName = 'loadListDataWithBackgroundRefreshHelper',
}) async {
  // デフォルトフィルタ: isDeleted=falseのもののみ（型チェックを事前実行）
  bool Function(T) effectiveFilter;
  if (filter != null) {
    effectiveFilter = filter;
  } else {
    // 型チェックを1回だけ実行してフィルタ関数を決定
    final sampleItem = await getLocalAll().then((items) => items.isNotEmpty ? items.first : null);
    if (sampleItem != null) {
      // SyncableModelインターフェースを実装しているかチェック
      final dynamic itemDynamic = sampleItem;
      if (itemDynamic is Map) {
        // Map型の場合
        effectiveFilter = (item) {
          final dynamic d = item;
          return d is Map ? (d['isDeleted'] != true) : true;
        };
      } else {
        // オブジェクト型の場合、isDeletedプロパティの存在を確認
        try {
          final hasIsDeleted = (itemDynamic as dynamic).isDeleted != null;
          if (hasIsDeleted) {
            effectiveFilter = (item) {
              try {
                return ((item as dynamic).isDeleted as bool?) != true;
              } catch (e) {
                return true;
              }
            };
          } else {
            effectiveFilter = (_) => true;
          }
        } catch (e) {
          effectiveFilter = (_) => true;
        }
      }
    } else {
      effectiveFilter = (_) => true;
    }
  }

  // Phase 1: ローカルから即座に表示
  final localItems = await getLocalAll();
  
  // フィルタリング（1回の走査で実行）
  final filteredLocalItems = <T>[];
  for (final item in localItems) {
    if (effectiveFilter(item)) {
      filteredLocalItems.add(item);
    }
  }

  // Providerを更新（即座に表示）
  updateProvider(filteredLocalItems);

  // Phase 2: バックグラウンドでFirestoreから最新データを取得
  Future<void> refreshFromFirestore() async {
    try {
      final items = await getAllWithAuth();
      
      // ローカルにも保存
      await saveLocal(items);
      
      // フィルタリング（1回の走査で実行）
      final filteredItems = <T>[];
      for (final item in items) {
        if (effectiveFilter(item)) {
          filteredItems.add(item);
        }
      }

      // Providerを更新（UIが自動的に最新データに更新される）
      updateProvider(filteredItems);
    } catch (e) {
      // エラー時はローカルデータのまま（既存の動作を維持）
      // エラーログを出力してデバッグ可能にする
      debugPrint('❌ [$functionName] Firestore取得エラー: $e');
    }
  }

  // バックグラウンドで更新（awaitしない）
  refreshFromFirestore();

  return filteredLocalItems;
}

/// 単一データをバックグラウンド更新で読み込む共通ヘルパー関数
/// 
/// まずローカルまたはデフォルト値で即座に表示し、
/// その後バックグラウンドでFirestoreから最新データを取得して更新します。
/// 
/// **型パラメータ**:
/// - `T`: データモデルの型
/// 
/// **パラメータ**:
/// - `ref`: Provider操作用のRef
/// - `manager`: DataManagerのインスタンス
/// - `getWithAuth`: Firestoreからデータを取得する関数（nullを返す可能性あり）
/// - `getLocal`: ローカルからデータを取得する関数（nullを返す可能性あり）
/// - `getDefault`: デフォルト値を取得する関数
/// - `saveLocal`: ローカルに保存する関数
/// - `updateProvider`: Providerを更新する関数（NotifierのupdateXxxを呼び出す）
/// - `functionName`: デバッグ用の関数名
/// 
/// **戻り値**: 読み込んだデータ（ローカルまたはデフォルト値）
Future<T> loadSingleDataWithBackgroundRefreshHelper<T>({
  required dynamic ref,
  required dynamic manager,
  required Future<T?> Function() getWithAuth,
  required Future<T?> Function() getLocal,
  required Future<T> Function() getDefault,
  required Future<void> Function(T) saveLocal,
  required void Function(T) updateProvider,
  String functionName = 'loadSingleDataWithBackgroundRefreshHelper',
}) async {
  // Phase 1: ローカルまたはデフォルト値で即座に表示
  final localData = await getLocal();
  final initialData = localData ?? await getDefault();
  
  // Providerを更新（即座に表示）
  updateProvider(initialData);

  // Phase 2: バックグラウンドでFirestoreから最新データを取得
  Future<void> refreshFromFirestore() async {
    try {
      final data = await getWithAuth();
      
      if (data != null) {
        // ローカルにも保存
        await saveLocal(data);
        
        // Providerを更新（UIが自動的に最新データに更新される）
        updateProvider(data);
      }
    } catch (e) {
      // エラー時はローカルデータのまま（既存の動作を維持）
      // エラーログを出力してデバッグ可能にする
      debugPrint('❌ [$functionName] Firestore取得エラー: $e');
    }
  }

  // バックグラウンドで更新（awaitしない）
  refreshFromFirestore();

  return initialData;
}

