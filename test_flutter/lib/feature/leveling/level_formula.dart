import 'dart:math';

import 'package:test_flutter/feature/leveling/level_model.dart';

class LevelComputationResult {
  const LevelComputationResult({
    required this.level,
    required this.exactLevel,
    required this.progressToNextLevel,
    required this.requiredSecondsForNextLevel,
    required this.rank,
  });

  final int level;
  final double exactLevel;
  final double progressToNextLevel;
  final int requiredSecondsForNextLevel;
  final LevelRankTier rank;
}

/// レベル計算ユーティリティ
class LevelFormula {
  static const double _targetHoursForLv100 = 250.0;
  static const double _exponent = 0.72;

  /// 現在の人検出時間（秒）からレベルを計算
  static LevelComputationResult computeLevel(int personSeconds) {
    final personHours = personSeconds / 3600.0;
    final normalized = max(personHours / _targetHoursForLv100, 0);

    // exact level（100を上限）
    final double exactLevel = (normalized <= 0)
        ? 0.0
        : (pow(normalized, _exponent) * 100)
            .toDouble()
            .clamp(0.0, 100.0);

    final level = exactLevel.floor();
    final progress =
        level >= 100 ? 0.0 : (exactLevel - level).clamp(0.0, 0.999).toDouble();

    final requiredSeconds = level >= 100
        ? personSeconds
        : _secondsForLevel(level + 1).ceil();

    final rank = _rankForLevel(level);

    return LevelComputationResult(
      level: level,
      exactLevel: exactLevel,
      progressToNextLevel: progress,
      requiredSecondsForNextLevel: requiredSeconds,
      rank: rank,
    );
  }

  /// 指定レベル到達に必要な秒数
  static double _secondsForLevel(int level) {
    final targetLevel = level.clamp(0, 100);
    if (targetLevel == 0) return 0;
    final ratio = targetLevel / 100;
    final hours = _targetHoursForLv100 * pow(ratio, 1 / _exponent);
    return hours * 3600;
  }

  /// レベルに応じたランク
  static LevelRankTier _rankForLevel(int level) {
    if (level >= 85) return LevelRankTier.diamond;
    if (level >= 70) return LevelRankTier.platinum;
    if (level >= 55) return LevelRankTier.gold;
    if (level >= 40) return LevelRankTier.silver;
    if (level >= 20) return LevelRankTier.bronze;
    return LevelRankTier.apprentice;
  }

  /// 現在日時が属する月ID
  static String periodId(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static DateTime periodStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime periodEnd(DateTime date) =>
      DateTime(date.year, date.month + 1, 1).subtract(const Duration(seconds: 1));

  static DateTime nextResetDate(DateTime date) =>
      DateTime(date.year, date.month + 1, 1);
}


