import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/statistics/daily_statistics_model.dart';
import 'package:test_flutter/feature/statistics/session_info_model.dart';

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
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final id = _formatDateId(dateOnly);
      
      final allData = await getAllWithAuth();
      return allData.where((d) => d.id == id).firstOrNull;
    } catch (e) {
      debugPrint('❌ [getByDateWithAuth] 取得エラー: $e');
      return null;
    }
  }

  /// 日次統計を保存または更新（認証自動取得版）
  /// 
  /// 既存データがあればマージして更新、なければ新規作成します。
  /// データの整合性を保証するため、保存前にvalidateAndFix()を実行します。
  /// エラー発生時はロールバック処理を実行します。
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
        // 既存データとマージ
        // セッション情報をマージ（同じIDのセッションがあれば置き換え、なければ追加）
        final mergedSessions = List<SessionInfo>.from(existing.sessions);
        for (final session in statistics.sessions) {
          final existingIndex = mergedSessions.indexWhere((s) => s.id == session.id);
          if (existingIndex >= 0) {
            mergedSessions[existingIndex] = session;
          } else {
            mergedSessions.add(session);
          }
        }
        
        // マージしたセッションからデータを再計算
        final mergedData = existing.copyWith(
          sessions: mergedSessions,
          lastModified: DateTime.now(),
        );
        
        // セッションからデータを更新
        dataToSave = await updateFromSessions(mergedData);
      } else {
        // 新規データの場合も、セッションからデータを更新
        dataToSave = await updateFromSessions(statistics);
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

  /// セッション情報から日次統計データを更新
  /// 
  /// sessionsからcategorySeconds、totalWorkTimeSeconds、hourlyCategorySeconds、
  /// pieChartDataを計算して更新します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: 更新する日次統計データ（sessionsが含まれている必要がある）
  /// 
  /// **戻り値**: 更新された日次統計データ
  Future<DailyStatistics> updateFromSessions(DailyStatistics statistics) async {
    try {
      // カテゴリ別時間を集計
      final categorySeconds = <String, int>{
        'study': 0,
        'pc': 0,
        'smartphone': 0,
        'personOnly': 0,
        'nothingDetected': 0,
      };
      
      // 時間ごとのカテゴリ別秒数を集計
      final hourlyCategorySeconds = <String, Map<String, int>>{};
      
      // 24時間分の初期化
      for (int hour = 0; hour < 24; hour++) {
        hourlyCategorySeconds[hour.toString()] = {
          'study': 0,
          'pc': 0,
          'smartphone': 0,
          'personOnly': 0,
          'nothingDetected': 0,
        };
      }
      
      // 各セッションからデータを集計
      for (final session in statistics.sessions) {
        // categorySecondsを加算
        for (final entry in session.categorySeconds.entries) {
          if (categorySeconds.containsKey(entry.key)) {
            categorySeconds[entry.key] = 
                (categorySeconds[entry.key] ?? 0) + entry.value;
          }
        }
        
        // detectionPeriodsから時間ごとに集計
        final date = DateTime(
          statistics.date.year,
          statistics.date.month,
          statistics.date.day,
        );
        
        for (final period in session.detectionPeriods) {
          final periodStart = period.startTime.isAfter(date)
              ? period.startTime
              : date;
          final periodEnd = period.endTime;
          
          // 期間が複数の時間帯にまたがる場合を処理
          var currentTime = periodStart;
          while (currentTime.isBefore(periodEnd)) {
            final hour = currentTime.hour;
            final hourStart = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              hour,
            );
            final hourEnd = hourStart.add(const Duration(hours: 1));
            
            // この時間帯に該当する期間の開始と終了を計算
            final segmentStart = currentTime.isAfter(hourStart) ? currentTime : hourStart;
            final segmentEnd = periodEnd.isBefore(hourEnd) ? periodEnd : hourEnd;
            
            if (segmentStart.isBefore(segmentEnd)) {
              final durationSeconds = segmentEnd.difference(segmentStart).inSeconds;
              final hourKey = hour.toString();
              
              if (hourlyCategorySeconds.containsKey(hourKey)) {
                final category = period.category;
                if (hourlyCategorySeconds[hourKey]!.containsKey(category)) {
                  hourlyCategorySeconds[hourKey]![category] = 
                      (hourlyCategorySeconds[hourKey]![category] ?? 0) + durationSeconds;
                }
              }
            }
            
            currentTime = hourEnd;
          }
        }
      }
      
      // 作業時間を計算（study + pc）
      final totalWorkTimeSeconds = (categorySeconds['study'] ?? 0) + 
                                   (categorySeconds['pc'] ?? 0);
      
      // 円グラフデータを計算
      final pieChartData = _calculatePieChartData(categorySeconds, includeAllCategories: true);
      
      // 更新されたデータを返す
      return statistics.copyWith(
        categorySeconds: categorySeconds,
        totalWorkTimeSeconds: totalWorkTimeSeconds,
        hourlyCategorySeconds: hourlyCategorySeconds,
        pieChartData: pieChartData,
        lastModified: DateTime.now(),
      );
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ [updateFromSessions] 更新エラー: $e',
        tag: 'DailyStatisticsDataManager',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// データ整合性チェックと自動修復
  /// 
  /// sessionsから計算した値とcategorySeconds等を比較し、
  /// 不整合があれば自動修復します。
  /// 
  /// **パラメータ**:
  /// - `statistics`: チェックする日次統計データ
  /// 
  /// **戻り値**: 修復された日次統計データ
  Future<DailyStatistics> validateAndFix(DailyStatistics statistics) async {
    try {
      // sessionsからデータを再計算
      final recalculated = await updateFromSessions(statistics);
      
      // 整合性チェック
      bool needsFix = false;
      
      // categorySecondsの整合性チェック
      for (final entry in recalculated.categorySeconds.entries) {
        final existing = statistics.categorySeconds[entry.key] ?? 0;
        if (existing != entry.value) {
          needsFix = true;
          debugPrint(
            '⚠️ [validateAndFix] categorySeconds不整合検出: '
            '${entry.key} = $existing (期待値: ${entry.value})',
          );
        }
      }
      
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
        return recalculated;
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

