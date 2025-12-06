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
  static const double _exponentLow = 0.5; // 低いレベルの時の指数（より早く上がる）
  static const double _exponentHigh = 0.72; // 高いレベルの時の指数
  static const int _transitionLevel = 20; // 指数を切り替えるレベル

  /// レベルに応じた指数を取得（低いレベルほど小さな指数で早く上がる）
  static double _getExponentForLevel(int level) {
    if (level < _transitionLevel) {
      // 低いレベルの時は線形補間で指数を調整
      final ratio = level / _transitionLevel;
      return _exponentLow + ((_exponentHigh - _exponentLow) * ratio);
    }
    return _exponentHigh;
  }

  /// 現在の人検出時間（秒）からレベルを計算
  static LevelComputationResult computeLevel(int personSeconds) {
    final personHours = personSeconds / 3600.0;
    final normalized = max(personHours / _targetHoursForLv100, 0);

    // 低いレベルの時はより早く上がるように、段階的に指数を調整
    // まず低い指数で計算して、その後高い指数で計算し、レベルに応じて補間
    final double exactLevelLow = (normalized <= 0)
        ? 0.0
        : (pow(normalized, _exponentLow) * 100)
            .toDouble()
            .clamp(0.0, 100.0);
    
    final double exactLevelHigh = (normalized <= 0)
        ? 0.0
        : (pow(normalized, _exponentHigh) * 100)
            .toDouble()
            .clamp(0.0, 100.0);
    
    // 低いレベルの時は低い指数の結果をより多く使用
    double exactLevel;
    if (exactLevelLow < _transitionLevel) {
      // 低いレベルの時は低い指数の結果を優先（より早く上がる）
      final ratio = exactLevelLow / _transitionLevel;
      // 低いレベルの時は低い指数の結果を70%、高い指数の結果を30%使用
      exactLevel = exactLevelLow * (1.0 - ratio * 0.3) + exactLevelHigh * (ratio * 0.3);
    } else {
      // 高いレベルの時は高い指数の結果を使用
      exactLevel = exactLevelHigh;
    }
    
    exactLevel = exactLevel.clamp(0.0, 100.0);

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
    
    // レベルに応じた指数を使用
    final exponent = _getExponentForLevel(targetLevel);
    final ratio = targetLevel / 100;
    final hours = _targetHoursForLv100 * pow(ratio, 1 / exponent);
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


