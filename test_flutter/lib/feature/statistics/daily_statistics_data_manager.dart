import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';

/// 日次統計用データマネージャー
/// 
/// BaseDataManager<DailyStatistics>を継承して、日次統計データの管理を行います。
class DailyStatisticsDataManager extends BaseDataManager<DailyStatistics> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/daily_statistics';

  @override
  DailyStatistics convertFromFirestore(Map<String, dynamic> data) {
    return DailyStatistics.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(DailyStatistics item) {
    return item.toFirestore();
  }

  @override
  DailyStatistics convertFromJson(Map<String, dynamic> json) =>
      DailyStatistics.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(DailyStatistics item) => item.toJson();

  @override
  String get storageKey => 'daily_statistics';

  // ===== カスタム機能（日次統計特有） =====

  /// 指定日付の日次統計を取得（認証自動取得版）
  /// 
  /// **パラメータ**:
  /// - `date`: 取得する日付（時刻部分は無視される）
  /// 
  /// **戻り値**: 該当日の統計データ、存在しない場合はnull
  Future<DailyStatistics?> getByDateWithAuth(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final id = _formatDateId(dateOnly);
    
    try {
      final local = await manager.getLocalById(id);
      if (local != null) {
        return local;
      }
    } catch (e) {
      debugPrint('⚠️ [getByDateWithAuth] ローカル取得エラー: $e');
    }

    try {
      final userId = AuthMk.getCurrentUserId();
      final remote = await manager.getById(userId, id);
      if (remote != null) {
        try {
          await manager.addLocal(remote);
        } catch (e) {
          debugPrint('⚠️ [getByDateWithAuth] ローカルキャッシュ保存エラー: $e');
        }
      }
      return remote;
    } catch (e) {
      debugPrint('❌ [getByDateWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 日次統計を直接保存（マージせずに上書き）
  /// 
  /// 既にマージ済みのデータを直接保存します。既存データとのマージは行いません。
  /// データの整合性を保証するため、保存前にvalidateAndFix()を実行します。
  /// エラー発生時はロールバック処理を実行します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する日次統計データ（既にマージ済み）
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveDirectly(DailyStatistics statistics) async {
    // ロールバック用に既存データを保存
    DailyStatistics? backupData;
    try {
      // 既存データを取得（ロールバック用に保存）
      final existing = await getByDateWithAuth(statistics.date);
      if (existing != null) {
        backupData = existing;
      }
      
      // デバッグ: hourlyCategorySecondsの状態を確認
      final hourlyCount = statistics.hourlyCategorySeconds.entries
          .where((e) => e.value.values.any((v) => v > 0))
          .length;
      LogMk.logDebug(
        '📊 [saveDirectly] 保存前のhourlyCategorySeconds: $hourlyCount時間帯にデータあり',
        tag: 'DailyStatisticsDataManager',
      );
      
      // categorySecondsからデータを更新（マージせずに直接）
      // 重要: hourlyCategorySecondsは既に集計済みなので、updateFromCategorySecondsを呼ぶ前に保存しておく
      final originalHourlyCategorySeconds = statistics.hourlyCategorySeconds;
      var dataToSave = await updateFromCategorySeconds(statistics);
      
      // updateFromCategorySecondsでhourlyCategorySecondsが消えている可能性があるため、
      // 元のhourlyCategorySecondsを復元する
      dataToSave = dataToSave.copyWith(
        hourlyCategorySeconds: originalHourlyCategorySeconds,
      );
      
      // デバッグ: updateFromCategorySeconds後のhourlyCategorySecondsの状態を確認
      final hourlyCountAfter = dataToSave.hourlyCategorySeconds.entries
          .where((e) => e.value.values.any((v) => v > 0))
          .length;
      LogMk.logDebug(
        '📊 [saveDirectly] updateFromCategorySeconds後のhourlyCategorySeconds: $hourlyCountAfter時間帯にデータあり（復元後）',
        tag: 'DailyStatisticsDataManager',
      );
      
      // データ整合性チェック
      dataToSave = await validateAndFix(dataToSave);
      
      // ローカルに保存（即座に完了）
      try {
        await manager.addLocal(dataToSave);
        LogMk.logDebug(
          '✅ [saveDirectly] ローカル保存成功: ${dataToSave.id}',
          tag: 'DailyStatisticsDataManager',
        );
      } catch (e, stackTrace) {
        // ローカル保存失敗時はロールバック
        LogMk.logError(
          '❌ [saveDirectly] ローカル保存エラー: $e',
          tag: 'DailyStatisticsDataManager',
          stackTrace: stackTrace,
        );
        if (backupData != null) {
          try {
            await manager.addLocal(backupData);
            LogMk.logInfo(
              '🔄 [saveDirectly] ロールバック完了',
              tag: 'DailyStatisticsDataManager',
            );
          } catch (rollbackError) {
            LogMk.logError(
              '❌ [saveDirectly] ロールバック失敗: $rollbackError',
              tag: 'DailyStatisticsDataManager',
            );
          }
        }
        return false;
      }
      
      // Firestoreへの保存（awaitして確実に実行）
      try {
        // 保存前のデータ状態を詳細にログ出力
        final hourlyDataSummary = <String, int>{};
        for (final entry in dataToSave.hourlyCategorySeconds.entries) {
          final hourTotal = entry.value.values.fold(0, (sum, val) => sum + val);
          if (hourTotal > 0) {
            hourlyDataSummary[entry.key] = hourTotal;
          }
        }
        
        LogMk.logDebug(
          '🔄 [saveDirectly] Firestore保存開始: id=${dataToSave.id}, date=${dataToSave.date}',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        LogMk.logDebug(
          '📊 [saveDirectly] 保存データの詳細:',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        LogMk.logDebug(
          '  - categorySeconds: ${dataToSave.categorySeconds}',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        LogMk.logDebug(
          '  - totalWorkTimeSeconds: ${dataToSave.totalWorkTimeSeconds}',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        LogMk.logDebug(
          '  - hourlyCategorySeconds: ${hourlyDataSummary.length}時間帯にデータあり (${hourlyDataSummary.keys.join(", ")})',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        LogMk.logDebug(
          '  - trackingCount: ${dataToSave.trackingCount}',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        
        // 認証状態を確認
        final currentUser = AuthMk.getCurrentUser();
        if (currentUser == null) {
          LogMk.logError(
            '❌ [saveDirectly] Firestore保存失敗: ユーザーがログインしていません',
            tag: 'DailyStatisticsDataManager.saveDirectly',
          );
          return true; // ローカル保存は成功しているのでtrueを返す
        }
        LogMk.logDebug(
          '✅ [saveDirectly] 認証確認完了: userId=${currentUser.uid}',
          tag: 'DailyStatisticsDataManager.saveDirectly',
        );
        
        final firestoreSuccess = await manager.saveWithRetryAuth(dataToSave);
        if (firestoreSuccess) {
          LogMk.logDebug(
            '✅ [saveDirectly] Firestore保存成功: id=${dataToSave.id}, hourlyCategorySeconds=${hourlyDataSummary.length}時間帯',
            tag: 'DailyStatisticsDataManager.saveDirectly',
          );
        } else {
          LogMk.logWarning(
            '⚠️ [saveDirectly] Firestore保存失敗（リトライキューに追加済み）: id=${dataToSave.id}',
            tag: 'DailyStatisticsDataManager.saveDirectly',
          );
        }
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ [saveDirectly] Firestore保存エラー: $e',
          tag: 'DailyStatisticsDataManager.saveDirectly',
          stackTrace: stackTrace,
        );
        // ローカル保存は成功しているのでtrueを返す（Firestoreは次回同期時に再試行される）
      }
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [saveDirectly] 保存エラー: $e',
        tag: 'DailyStatisticsDataManager',
        stackTrace: stackTrace,
      );
      
      // エラー発生時はロールバック
      if (backupData != null) {
        try {
          await manager.addLocal(backupData);
          LogMk.logInfo(
            '🔄 [saveDirectly] エラー後のロールバック完了',
            tag: 'DailyStatisticsDataManager',
          );
        } catch (rollbackError) {
          LogMk.logError(
            '❌ [saveDirectly] エラー後のロールバック失敗: $rollbackError',
            tag: 'DailyStatisticsDataManager',
          );
        }
      }
      
      return false;
    }
  }

  /// 日次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあればマージして更新、なければ新規作成します。
  /// データの整合性を保証するため、保存前にvalidateAndFix()を実行します。
  /// エラー発生時はロールバック処理を実行します。
  /// 
  /// **注意**: このメソッドは既存データとマージ（加算）します。
  /// 既にマージ済みのデータを保存する場合は、saveDirectly()を使用してください。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 保存する日次統計データ
  /// 
  /// **戻り値**: 保存成功時true、失敗時false
  Future<bool> saveOrUpdateWithAuth(DailyStatistics statistics) async {
    // ロールバック用に既存データを保存
    DailyStatistics? backupData;
    try {
      // 既存データを取得（ロールバック用に保存）
      final existing = await getByDateWithAuth(statistics.date);
      if (existing != null) {
        backupData = existing;
      }
      
      DailyStatistics dataToSave;
      if (existing != null) {
        // 既存データとマージ（categorySecondsを加算）
        final mergedCategorySeconds = <String, int>{};
        for (final key in ['study', 'pc', 'smartphone', 'personOnly', 'nothingDetected']) {
          mergedCategorySeconds[key] = (existing.categorySeconds[key] ?? 0) + 
                                      (statistics.categorySeconds[key] ?? 0);
        }
        
        // hourlyCategorySecondsもマージ（既存の値と新しい値を加算）
        final mergedHourlyCategorySeconds = Map<String, Map<String, int>>.from(existing.hourlyCategorySeconds);
        
        // 新しいデータのhourlyCategorySecondsを既存のデータに加算
        for (final entry in statistics.hourlyCategorySeconds.entries) {
          final hourKey = entry.key;
          final hourData = entry.value;
          
          // 既存の時間帯データを取得（なければ空のMapを作成）
          final existingHourData = mergedHourlyCategorySeconds[hourKey] ?? <String, int>{};
          
          // 既存のデータと新しいデータをマージ（加算）
          final mergedHourData = <String, int>{};
          for (final key in ['study', 'pc', 'smartphone', 'personOnly', 'nothingDetected']) {
            mergedHourData[key] = (existingHourData[key] ?? 0) + (hourData[key] ?? 0);
          }
          
          mergedHourlyCategorySeconds[hourKey] = mergedHourData;
        }
        
        // trackingCountは最新の値を設定
        // statistics.trackingCountが0の場合は、既存の値を保持（取得に失敗した場合など）
        // statistics.trackingCountが既存の値より大きい場合は、最新の値を設定
        final mergedTrackingCount = statistics.trackingCount > existing.trackingCount
            ? statistics.trackingCount
            : (statistics.trackingCount == 0 && existing.trackingCount > 0
                ? existing.trackingCount
                : statistics.trackingCount);
        
        // マージしたデータを作成
        final mergedData = existing.copyWith(
          categorySeconds: mergedCategorySeconds,
          hourlyCategorySeconds: mergedHourlyCategorySeconds,
          trackingCount: mergedTrackingCount,
          lastModified: DateTime.now(),
        );
        
        // categorySecondsからデータを更新
        dataToSave = await updateFromCategorySeconds(mergedData);
      } else {
        // 新規データの場合も、categorySecondsからデータを更新
        dataToSave = await updateFromCategorySeconds(statistics);
      }
      
      // データ整合性チェック
      dataToSave = await validateAndFix(dataToSave);
      
      // ローカルに保存（即座に完了）
      try {
        await manager.addLocal(dataToSave);
        LogMk.logDebug(
          '✅ [saveOrUpdateWithAuth] ローカル保存成功: ${dataToSave.id}',
          tag: 'DailyStatisticsDataManager',
        );
      } catch (e, stackTrace) {
        // ローカル保存失敗時はロールバック
        LogMk.logError(
          '❌ [saveOrUpdateWithAuth] ローカル保存エラー: $e',
          tag: 'DailyStatisticsDataManager',
          stackTrace: stackTrace,
        );
        if (backupData != null) {
          try {
            await manager.addLocal(backupData);
            LogMk.logInfo(
              '🔄 [saveOrUpdateWithAuth] ロールバック完了',
              tag: 'DailyStatisticsDataManager',
            );
          } catch (rollbackError) {
            LogMk.logError(
              '❌ [saveOrUpdateWithAuth] ロールバック失敗: $rollbackError',
              tag: 'DailyStatisticsDataManager',
            );
          }
        }
        return false;
      }
      
      // Firestoreへの保存（awaitして確実に実行）
      try {
        LogMk.logDebug(
          '🔄 [saveOrUpdateWithAuth] Firestore保存開始: ${dataToSave.id}',
          tag: 'DailyStatisticsDataManager',
        );
        final firestoreSuccess = await manager.saveWithRetryAuth(dataToSave);
        if (firestoreSuccess) {
          LogMk.logDebug(
            '✅ [saveOrUpdateWithAuth] Firestore保存成功: ${dataToSave.id}',
            tag: 'DailyStatisticsDataManager',
          );
        } else {
          LogMk.logWarning(
            '⚠️ [saveOrUpdateWithAuth] Firestore保存失敗（リトライキューに追加済み）: ${dataToSave.id}',
            tag: 'DailyStatisticsDataManager',
          );
        }
      } catch (e, stackTrace) {
        LogMk.logError(
          '❌ [saveOrUpdateWithAuth] Firestore保存エラー: $e',
          tag: 'DailyStatisticsDataManager',
          stackTrace: stackTrace,
        );
        // ローカル保存は成功しているのでtrueを返す（Firestoreは次回同期時に再試行される）
      }
      
      return true;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [saveOrUpdateWithAuth] 保存エラー: $e',
        tag: 'DailyStatisticsDataManager',
        stackTrace: stackTrace,
      );
      
      // エラー発生時はロールバック
      if (backupData != null) {
        try {
          await manager.addLocal(backupData);
          LogMk.logInfo(
            '🔄 [saveOrUpdateWithAuth] エラー後のロールバック完了',
            tag: 'DailyStatisticsDataManager',
          );
        } catch (rollbackError) {
          LogMk.logError(
            '❌ [saveOrUpdateWithAuth] エラー後のロールバック失敗: $rollbackError',
            tag: 'DailyStatisticsDataManager',
          );
        }
      }
      
      return false;
    }
  }

  /// 指定日付の日次統計をローカルから取得
  /// 
  /// **パラメータ**:
  /// - `date`: 取得する日付（時刻部分は無視される）
  /// 
  /// **戻り値**: 該当日の統計データ、存在しない場合はnull
  Future<DailyStatistics?> getByDateLocal(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final id = _formatDateId(dateOnly);
      
      final allData = await manager.getLocalAll();
      return allData.where((d) => d.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByDateLocal] 取得エラー: $e');
      return null;
    }
  }

  /// 日付をID形式に変換（例: "2024-01-15"）
  String _formatDateId(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 日次統計データを更新（categorySecondsから計算）
  /// 
  /// categorySecondsからtotalWorkTimeSeconds、pieChartDataを計算して更新します。
  /// hourlyCategorySecondsは既存の値を保持します（セッション情報がないため計算不可）。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 更新する日次統計データ
  /// 
  /// **戻り値**: 更新された日次統計データ
  Future<DailyStatistics> updateFromCategorySeconds(DailyStatistics statistics) async {
    try {
      // 作業時間を計算（study + pc）
      final totalWorkTimeSeconds = (statistics.categorySeconds['study'] ?? 0) + 
                                   (statistics.categorySeconds['pc'] ?? 0);
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(statistics.categorySeconds, includeAllCategories: true);
      
      // 更新されたデータを返す（hourlyCategorySecondsは既存の値を保持）
      return statistics.copyWith(
        totalWorkTimeSeconds: totalWorkTimeSeconds,
        pieChartData: pieChartData,
        lastModified: DateTime.now(),
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [updateFromCategorySeconds] 更新エラー: $e',
        tag: 'DailyStatisticsDataManager',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// データ整合性チェックと自動修復
  /// 
  /// categorySecondsから計算した値とtotalWorkTimeSeconds等を比較し、
  /// 不整合があれば自動修復します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: チェックする日次統計データ
  /// 
  /// **戻り値**: 修復された日次統計データ
  Future<DailyStatistics> validateAndFix(DailyStatistics statistics) async {
    try {
      // 重要: hourlyCategorySecondsは既に集計済みなので保存しておく
      final originalHourlyCategorySeconds = statistics.hourlyCategorySeconds;
      
      // categorySecondsからデータを再計算
      final recalculated = await updateFromCategorySeconds(statistics);
      
      // 整合性チェック
      bool needsFix = false;
      
      // totalWorkTimeSecondsの整合性チェック
      if (statistics.totalWorkTimeSeconds != recalculated.totalWorkTimeSeconds) {
        needsFix = true;
        debugPrint(
          '⚠️ [validateAndFix] totalWorkTimeSeconds不整合検出: '
          '${statistics.totalWorkTimeSeconds} (期待値: ${recalculated.totalWorkTimeSeconds})',
        );
      }
      
      if (needsFix) {
        LogMk.logInfo(
          '🔧 [validateAndFix] データを自動修復しました',
          tag: 'DailyStatisticsDataManager',
        );
        // hourlyCategorySecondsを復元してから返す
        return recalculated.copyWith(
          hourlyCategorySeconds: originalHourlyCategorySeconds,
        );
      }
      
      return statistics;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [validateAndFix] チェックエラー: $e',
        tag: 'DailyStatisticsDataManager',
        stackTrace: stackTrace,
      );
      // エラーが発生した場合は元のデータを返す
      return statistics;
    }
  }

  /// 円グラフデータを計算
  PieChartDataModel _calculatePieChartData(
    Map<String, int> categorySeconds, {
    required bool includeAllCategories,
  }) {
    // 合計時間を計算
    int totalSeconds = categorySeconds.values.fold(0, (sum, val) => sum + val);
    
    // 各カテゴリの割合を計算
    final percentages = <String, double>{};
    final colors = <String, int>{};
    
    for (final entry in categorySeconds.entries) {
      if (entry.value > 0) {
        if (totalSeconds > 0) {
          percentages[entry.key] = (entry.value / totalSeconds) * 100;
        } else {
          percentages[entry.key] = 0.0;
        }
        
        // カテゴリに応じた色を設定
        colors[entry.key] = _getCategoryColor(entry.key).value;
      }
    }
    
    return PieChartDataModel(
      categorySeconds: categorySeconds,
      percentages: percentages,
      colors: colors,
      totalSeconds: totalSeconds,
    );
  }

  /// カテゴリに応じた色を取得
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'study':
        return AppColors.green;
      case 'pc':
        return AppColors.blue;
      case 'smartphone':
        return AppColors.orange;
      case 'personOnly':
        return AppColors.purple;
      case 'nothingDetected':
        return AppColors.red;
      default:
        return AppColors.gray;
    }
  }

  /// 古いデータを削除（90日以上経過したデータを物理削除）
  /// 
  /// Firestoreとローカルストレージの両方から削除します。
  /// 
  /// **戻り値**: 削除されたデータの数
  Future<int> deleteOldData() async {
    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 90));
      
      // 全データを取得
      final allData = await getAllWithAuth();
      
      // 古いデータをフィルタリング
      final oldData = allData.where((item) => item.date.isBefore(cutoffDate)).toList();
      
      if (oldData.isEmpty) {
        return 0;
      }
      
      // Firestoreから削除
      int deletedCount = 0;
      for (final item in oldData) {
        try {
          final success = await deleteWithAuth(item.id);
          if (success) {
            deletedCount++;
          }
        } catch (e) {
          debugPrint('❌ [deleteOldData] 削除エラー: $e');
        }
      }
      
      debugPrint('✅ [deleteOldData] $deletedCount件の古い日次統計データを削除しました');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ [deleteOldData] エラー: $e');
      return 0;
    }
  }
}

