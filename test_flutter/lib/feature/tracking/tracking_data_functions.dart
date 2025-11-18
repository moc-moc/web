// Flutter / Riverpod
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project files
import 'package:test_flutter/feature/base/data_helper_functions.dart';
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

  /// Firestore/ローカルから取得したセッションでリスト全体を更新
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

/// トラッキングセッションをFirestoreから読み込み（Firestore優先）
Future<List<TrackingSession>> loadTrackingSessionsHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  return await loadListDataHelper<TrackingSession>(
    ref: ref,
    manager: manager,
    getAllWithAuth: () => manager.getAllWithAuth(),
    getLocalAll: () => manager.getLocalAll(),
    saveLocal: (items) => manager.saveLocal(items),
    updateProvider: (items) =>
        ref.read(trackingSessionsProvider.notifier).updateSessions(items),
    functionName: 'loadTrackingSessionsHelper',
  );
}

/// トラッキングセッションをFirestoreとローカルで同期
Future<List<TrackingSession>> syncTrackingSessionsHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  return await syncListDataHelper<TrackingSession>(
    ref: ref,
    manager: manager,
    syncWithAuth: () => manager.syncWithAuth(),
    updateProvider: (items) =>
        ref.read(trackingSessionsProvider.notifier).updateSessions(items),
    functionName: 'syncTrackingSessionsHelper',
  );
}
