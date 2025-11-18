// Flutter / Riverpod
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project files
import 'package:test_flutter/feature/tracking/tracking_session_data_manager.dart';
import 'package:test_flutter/feature/tracking/tracking_session_model.dart';

part 'tracking_data_functions.g.dart';

/// トラッキングセッションのリストを管理するNotifier
@Riverpod(keepAlive: true)
class TrackingSessionsNotifier extends _$TrackingSessionsNotifier {
  @override
  List<TrackingSession> build() {
    return const [];
  }

  /// ローカルから取得したセッションでリスト全体を更新
  void updateSessions(List<TrackingSession> sessions) {
    state = sessions;
  }

  /// 最新セッションを先頭に追加（IDが重複する場合は置き換え）
  void upsertSession(TrackingSession session) {
    final existingIndex = state.indexWhere((item) => item.id == session.id);
    if (existingIndex >= 0) {
      final newList = [...state];
      newList[existingIndex] = session;
      state = newList;
    } else {
      state = [session, ...state];
    }
  }
}

/// トラッキングセッションを読み込み（ローカルのみ）
/// 
/// ローカルストレージ（Hive）からのみデータを取得します。
/// Firestoreは使用しません（統計データはdaily_statistics等に集計済み）。
Future<List<TrackingSession>> loadTrackingSessionsHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  try {
    // ローカルのみから取得
    final items = await manager.getLocalAll();
    ref.read(trackingSessionsProvider.notifier).updateSessions(items);
    return items;
  } catch (e) {
    // エラー時は空のリストを返す
    ref.read(trackingSessionsProvider.notifier).updateSessions([]);
    return [];
  }
}

/// トラッキングセッションを読み込むヘルパー関数（ローカルのみ）
/// 
/// ローカルストレージ（Hive）からのみデータを取得します。
/// Firestoreは使用しません（統計データはdaily_statistics等に集計済み）。
Future<List<TrackingSession>> loadTrackingSessionsWithBackgroundRefreshHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  try {
    // ローカルのみから取得
    final items = await manager.getLocalAll();
    ref.read(trackingSessionsProvider.notifier).updateSessions(items);
    return items;
  } catch (e) {
    // エラー時は空のリストを返す
    ref.read(trackingSessionsProvider.notifier).updateSessions([]);
    return [];
  }
}

/// トラッキングセッションを同期（ローカルのみ）
/// 
/// ローカルストレージ（Hive）のデータのみを使用します。
/// Firestoreは使用しません（統計データはdaily_statistics等に集計済み）。
Future<List<TrackingSession>> syncTrackingSessionsHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  try {
    // ローカルのみから取得
    final localSessions = await manager.getLocalAll();
    ref.read(trackingSessionsProvider.notifier).updateSessions(localSessions);
    return localSessions;
  } catch (e) {
    // エラー時は空のリストを返す
    ref.read(trackingSessionsProvider.notifier).updateSessions([]);
    return [];
  }
}
