import 'package:flutter/material.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:test_flutter/feature/leveling/level_data_manager.dart';
import 'package:test_flutter/feature/leveling/level_formula.dart';
import 'package:test_flutter/feature/leveling/level_functions.dart';
import 'package:test_flutter/feature/leveling/level_model.dart';
import 'package:test_flutter/feature/statistics/monthly_statistics_data_manager.dart';

class LevelResetService {
  LevelResetService._();

  static final LevelingDataManager _levelingManager = LevelingDataManager();
  static final MonthlyStatisticsDataManager _monthlyManager =
      MonthlyStatisticsDataManager();
  static bool _isChecking = false;
  static String? _lastNotifiedPeriod;

  /// 月が変わったかを検知して、レベルをリセットする
  static Future<void> ensureMonthlyReset({
    required dynamic ref,
    required BuildContext context,
    required bool mounted,
  }) async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final currentState =
          await _levelingManager.getOrCreateCurrentState(DateTime.now());
      final now = DateTime.now();
      final currentPeriod = LevelFormula.periodId(now);

      if (_lastNotifiedPeriod == currentPeriod) {
        return;
      }

      if (currentState.periodId == currentPeriod) {
        _lastNotifiedPeriod = currentPeriod;
        return;
      }

      if (mounted) {
        await Navigator.of(context).pushNamed(
          AppRoutes.levelResetEvent,
          arguments: {
            'previousLevel': currentState.level,
            'rank': currentState.rank.name,
            'personSeconds': currentState.personSeconds,
            'periodId': currentState.periodId,
          },
        );
      }

      await _archiveSnapshot(currentState);

      final resetState = LevelingState.initial(now: now, id: currentState.id);
      await _levelingManager.saveCurrentLevel(resetState);
      await updateLevelingStateInProvider(resetState, ref);

      _lastNotifiedPeriod = currentPeriod;
    } catch (e, stackTrace) {
      LogMk.logError(
        '❌ LevelResetService error: $e',
        tag: 'LevelResetService',
        stackTrace: stackTrace,
      );
    } finally {
      _isChecking = false;
    }
  }

  static Future<void> _archiveSnapshot(LevelingState state) async {
    try {
      final year = int.parse(state.periodId.split('-').first);
      final month = int.parse(state.periodId.split('-').last);
      final snapshot = LevelSnapshot(
        level: state.level,
        exactLevel: state.exactLevel,
        rank: state.rank,
        personSeconds: state.personSeconds,
        capturedAt: state.lastUpdated,
      );

      final monthly =
          await _monthlyManager.getByMonthWithAuth(year, month);
      if (monthly == null) {
        return;
      }

      final updated = monthly.copyWith(
        levelSnapshot: snapshot,
        personDetectedSeconds: state.personSeconds,
        lastModified: DateTime.now(),
      );
      await _monthlyManager.saveOrUpdateWithAuth(updated);
    } catch (e) {
      LogMk.logError(
        '⚠️ monthly snapshot保存失敗: $e',
        tag: 'LevelResetService',
      );
    }
  }
}


