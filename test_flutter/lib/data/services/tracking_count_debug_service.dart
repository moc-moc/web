import 'package:test_flutter/data/repositories/tracking_count_data_manager.dart';
import 'package:test_flutter/data/repositories/survey_flag_data_manager.dart';
import 'package:test_flutter/data/repositories/survey_data_manager.dart';
import 'package:test_flutter/data/sources/auth_source.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// トラッキングカウントのデバッグサービス
/// 
/// Firestoreへの保存状態を確認するためのサービス
class TrackingCountDebugService {
  /// トラッキングカウントの保存状態を確認
  static Future<void> checkTrackingCountStatus() async {
    try {
      final currentUser = AuthMk.getCurrentUser();
      LogMk.logDebug('=== トラッキングカウント保存状態チェック ===', tag: 'TrackingCountDebug');
      LogMk.logDebug('ユーザーID: ${currentUser?.uid ?? "未ログイン"}', tag: 'TrackingCountDebug');
      
      if (currentUser == null) {
        LogMk.logWarning('ユーザーがログインしていません', tag: 'TrackingCountDebug');
        return;
      }
      
      final userId = currentUser.uid;
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // トラッキングカウントを取得
      final trackingCount = await trackingCountDataManager.getById(userId, todayString);
      if (trackingCount != null) {
        LogMk.logDebug('トラッキングカウント（Firestore）: ${trackingCount.count}回, 最終更新: ${trackingCount.lastModified}', tag: 'TrackingCountDebug');
      } else {
        LogMk.logWarning('トラッキングカウントがFirestoreに見つかりません', tag: 'TrackingCountDebug');
      }
      
      // アンケートフラグを取得
      final surveyFlag = await surveyFlagDataManager.getById(userId, 'survey_flag');
      if (surveyFlag != null) {
        LogMk.logDebug('アンケートフラグ（Firestore）: 表示済み=${surveyFlag.hasShownFirstSurvey}, 最終更新: ${surveyFlag.lastModified}', tag: 'TrackingCountDebug');
      } else {
        LogMk.logWarning('アンケートフラグがFirestoreに見つかりません', tag: 'TrackingCountDebug');
      }
      
      // アンケート結果を取得
      final surveys = await surveyDataManager.getAllWithAuth();
      LogMk.logDebug('アンケート結果（Firestore）: ${surveys.length}件', tag: 'TrackingCountDebug');
      for (final survey in surveys) {
        LogMk.logDebug('  - ID: ${survey.id}, 評価: ${survey.rating}★, 作成日時: ${survey.createdAt}', tag: 'TrackingCountDebug');
      }
      
      // リトライキューの状態を確認
      final queueStats = await trackingCountDataManager.manager.getQueueStats();
      LogMk.logDebug('リトライキュー統計: $queueStats', tag: 'TrackingCountDebug');
      
      LogMk.logDebug('=== チェック完了 ===', tag: 'TrackingCountDebug');
    } catch (e, stackTrace) {
      LogMk.logError('保存状態チェックエラー', tag: 'TrackingCountDebug', error: e, stackTrace: stackTrace);
    }
  }
  
  /// リトライキューをクリア
  /// 
  /// 古いデータが残っている場合に使用
  static Future<void> clearRetryQueue() async {
    try {
      LogMk.logDebug('リトライキューをクリアします', tag: 'TrackingCountDebug');
      
      await trackingCountDataManager.manager.clearQueue();
      await surveyFlagDataManager.manager.clearQueue();
      await surveyDataManager.manager.clearQueue();
      
      LogMk.logDebug('✅ リトライキューをクリアしました', tag: 'TrackingCountDebug');
    } catch (e, stackTrace) {
      LogMk.logError('リトライキュークリアエラー', tag: 'TrackingCountDebug', error: e, stackTrace: stackTrace);
    }
  }
}


