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

/// トラッキングセッションをローカルから読み込み
/// 
/// Firestoreには保存しないため、ローカルのみから取得します。
Future<List<TrackingSession>> loadTrackingSessionsHelper(dynamic ref) async {
  final manager = TrackingSessionDataManager();

  try {
    final items = await manager.getLocalAll();
    ref.read(trackingSessionsProvider.notifier).updateSessions(items);
    return items;
  } catch (e) {
    return [];
  }
}

/// トラッキングセッションを同期
/// 
/// Firestoreには保存しないため、ローカルのみから取得してProviderを更新します。
Future<List<TrackingSession>> syncTrackingSessionsHelper(dynamic ref) async {
  // Firestoreには保存しないため、ローカルのみから取得
  return await loadTrackingSessionsHelper(ref);
}
