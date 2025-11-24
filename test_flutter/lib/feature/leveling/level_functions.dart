import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_flutter/feature/leveling/level_data_manager.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';

part 'level_functions.g.dart';

@Riverpod(keepAlive: true)
class LevelingStateNotifier extends _$LevelingStateNotifier {
  @override
  LevelingState build() {
    return LevelingState.initial(now: DateTime.now());
  }

  void updateState(LevelingState state) {
    this.state = state;
  }
}

final LevelingDataManager _levelingManager = LevelingDataManager();

Future<LevelingState> loadLevelingStateHelper(dynamic ref) async {
  final current = await _levelingManager.getOrCreateCurrentState(DateTime.now());
  ref.read(levelingStateProvider.notifier).updateState(current);
  return current;
}

Future<LevelingState> syncLevelingStateHelper(dynamic ref) async {
  final current = await _levelingManager.getOrCreateCurrentState(DateTime.now());
  ref.read(levelingStateProvider.notifier).updateState(current);
  return current;
}

Future<void> updateLevelingStateInProvider(LevelingState state, dynamic ref) async {
  ref.read(levelingStateProvider.notifier).updateState(state);
}


