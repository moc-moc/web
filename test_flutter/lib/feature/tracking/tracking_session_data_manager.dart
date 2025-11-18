import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';

/// トラッキングセッション用データマネージャー
/// 
/// BaseDataManager<TrackingSession>を継承して、トラッキングセッションデータの管理を行います。
/// 
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
class TrackingSessionDataManager extends BaseDataManager<TrackingSession> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/tracking_sessions';

  @override
  TrackingSession convertFromFirestore(Map<String, dynamic> data) {
    return TrackingSession.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(TrackingSession item) {
    return item.toFirestore();
  }

  @override
  TrackingSession convertFromJson(Map<String, dynamic> json) =>
      TrackingSession.fromJson(json);

  @override
  Map<String, dynamic> convertToJson(TrackingSession item) => item.toJson();

  @override
  String get storageKey => 'tracking_sessions';

  // ===== カスタム機能（トラッキングセッション特有） =====

  /// トラッキングセッションを追加（認証自動取得版）
  /// 
  /// 新しいセッションをFirestoreとローカルに保存します。
  Future<bool> addSessionWithAuth(TrackingSession session) async {
    return await addWithAuth(session);
  }

  /// 今日のトラッキングセッションを取得（認証自動取得版）
  /// 
  /// 今日の日付で開始されたセッションを取得します。
  Future<List<TrackingSession>> getTodaySessionsWithAuth() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final allSessions = await getAllWithAuth();
      return allSessions.where((session) {
        return session.startTime.isAfter(startOfDay) &&
            session.startTime.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 指定期間のトラッキングセッションを取得（認証自動取得版）
  /// 
  /// 開始日時と終了日時を指定してセッションを取得します。
  Future<List<TrackingSession>> getSessionsByDateRangeWithAuth({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allSessions = await getAllWithAuth();
      return allSessions.where((session) {
        return session.startTime.isAfter(startDate) &&
            session.startTime.isBefore(endDate);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 最新のトラッキングセッションを取得（認証自動取得版）
  /// 
  /// 最も最近のセッションを1つ取得します。
  Future<TrackingSession?> getLatestSessionWithAuth() async {
    try {
      final allSessions = await getAllWithAuth();
      if (allSessions.isEmpty) {
        return null;
      }
      allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return allSessions.first;
    } catch (e) {
      return null;
    }
  }

  /// 次のセッションIDを生成（連番の数字）
  /// 
  /// 既存のセッションの最大IDを取得し、次のIDを生成します。
  /// IDは数字の文字列として返されます（例: "1", "2", "3"）。
  Future<String> getNextSessionId() async {
    try {
      final allSessions = await getAllWithAuth();
      
      if (allSessions.isEmpty) {
        return '1';
      }
      
      // 既存のセッションIDから最大値を取得
      int maxId = 0;
      for (final session in allSessions) {
        // IDが数字の文字列かどうかをチェック
        final idAsInt = int.tryParse(session.id);
        if (idAsInt != null && idAsInt > maxId) {
          maxId = idAsInt;
        }
      }
      
      // 次のIDを返す
      return (maxId + 1).toString();
    } catch (e) {
      // エラーが発生した場合は、タイムスタンプベースのIDを生成
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }
}

