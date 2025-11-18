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
  TrackingSession convertFromJson(Map<String, dynamic> json) {
    // detectionPeriodsの要素が既にDetectionPeriodオブジェクトの場合は変換が必要
    if (json['detectionPeriods'] != null) {
      final detectionPeriods = json['detectionPeriods'] as List<dynamic>;
      final convertedPeriods = detectionPeriods.map((e) {
        if (e is DetectionPeriod) {
          // 既にDetectionPeriodオブジェクトの場合はそのまま使用
          return e;
        } else if (e is Map<String, dynamic>) {
          // Mapの場合はfromJsonで変換
          return DetectionPeriod.fromJson(e);
        } else {
          // その他の場合はエラー
          throw Exception('Invalid detectionPeriod type: ${e.runtimeType}');
        }
      }).toList();
      
      // detectionPeriodsを変換済みのリストに置き換え
      json = Map<String, dynamic>.from(json);
      json['detectionPeriods'] = convertedPeriods.map((e) => e.toJson()).toList();
    }
    
    return TrackingSession.fromJson(json);
  }

  @override
  Map<String, dynamic> convertToJson(TrackingSession item) => item.toJson();

  @override
  String get storageKey => 'tracking_sessions';

  // ===== カスタム機能（トラッキングセッション特有） =====

  /// トラッキングセッションを追加（認証自動取得版）
  /// 
  /// 新しいセッションをローカルのみに保存します。
  /// 統計集計用の一時データとして保存し、Firestoreには保存しません。
  Future<bool> addSessionWithAuth(TrackingSession session) async {
    try {
      await addLocal(session);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ローカルのみから全セッションを取得（認証自動取得版）
  /// 
  /// Firestoreには保存しないため、ローカルのみから取得します。
  @override
  Future<List<TrackingSession>> getAllWithAuth() async {
    return await getLocalAll();
  }

  /// 今日のトラッキングセッションを取得（認証自動取得版）
  /// 
  /// 今日の日付で開始されたセッションを取得します。
  /// ローカルのみから取得します。
  Future<List<TrackingSession>> getTodaySessionsWithAuth() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final allSessions = await getLocalAll();
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
  /// ローカルのみから取得します。
  Future<List<TrackingSession>> getSessionsByDateRangeWithAuth({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allSessions = await getLocalAll();
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
  /// ローカルのみから取得します。
  Future<TrackingSession?> getLatestSessionWithAuth() async {
    try {
      final allSessions = await getLocalAll();
      if (allSessions.isEmpty) {
        return null;
      }
      allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return allSessions.first;
    } catch (e) {
      return null;
    }
  }

  /// セッションIDを生成（日時ベース）
  /// 
  /// セッション開始時刻をISO8601形式の文字列に変換してIDとして使用します。
  /// これにより、Firestoreで時系列順（上から追加した順番）に並びます。
  /// 
  /// **形式**: "2024-01-15T09:00:00.123Z" (ISO8601形式、ミリ秒まで含む)
  /// 
  /// **パラメータ**:
  /// - `startTime`: セッション開始時刻
  /// 
  /// **戻り値**: ISO8601形式の日時文字列
  String generateSessionId(DateTime startTime) {
    // ISO8601形式に変換（ミリ秒まで含む）
    final year = startTime.year.toString().padLeft(4, '0');
    final month = startTime.month.toString().padLeft(2, '0');
    final day = startTime.day.toString().padLeft(2, '0');
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    final second = startTime.second.toString().padLeft(2, '0');
    final millisecond = startTime.millisecond.toString().padLeft(3, '0');
    
    // UTC時刻として扱う（Zサフィックス）
    return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
  }
  
  /// 次のセッションIDを生成（日時ベース）
  /// 
  /// セッション開始時刻からISO8601形式のIDを生成します。
  /// 同じ時刻に複数のセッションがある場合は、ミリ秒を調整します。
  /// 
  /// **パラメータ**:
  /// - `startTime`: セッション開始時刻（オプション、指定しない場合は現在時刻）
  /// 
  /// **戻り値**: ISO8601形式の日時文字列
  Future<String> getNextSessionId([DateTime? startTime]) async {
    try {
      final sessionStartTime = startTime ?? DateTime.now();
      String baseId = generateSessionId(sessionStartTime);
      
      // 既存のセッションを確認して、同じIDが存在する場合はミリ秒を調整
      final allSessions = await getAllWithAuth();
      final existingIds = allSessions.map((s) => s.id).toSet();
      
      // 同じIDが存在する場合、ミリ秒を1msずつ増やしてユニークなIDを生成
      String uniqueId = baseId;
      int counter = 0;
      while (existingIds.contains(uniqueId) && counter < 1000) {
        final adjustedTime = sessionStartTime.add(Duration(milliseconds: counter + 1));
        uniqueId = generateSessionId(adjustedTime);
        counter++;
      }
      
      return uniqueId;
    } catch (e) {
      // エラーが発生した場合は、開始時刻または現在時刻からIDを生成
      final fallbackTime = startTime ?? DateTime.now();
      return generateSessionId(fallbackTime);
    }
  }
}

