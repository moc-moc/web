// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_model.freezed.dart';
part 'level_model.g.dart';

/// レベルランクの段階
enum LevelRankTier {
  apprentice,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// 月次レベル状態
@freezed
abstract class LevelingState with _$LevelingState {
  const factory LevelingState({
    /// Firestore上のドキュメントID（原則 `current_level` 固定）
    required String id,

    /// 対象期間ID（例: `2025-11`）
    required String periodId,

    /// 現在のレベル（整数）
    required int level,

    /// 小数を含む厳密なレベル
    required double exactLevel,

    /// 次のレベルまでの進捗率 (0-1)
    required double progressToNextLevel,

    /// 人が検出されていた累計秒数（当月）
    @Default(0) int personSeconds,

    /// 次のレベル到達に必要な累計秒数
    required int requiredSecondsForNextLevel,

    /// 現在のランク
    @JsonKey(
      unknownEnumValue: LevelRankTier.apprentice,
    )
    required LevelRankTier rank,

    /// 月の開始日
    required DateTime periodStart,

    /// 月の終了日
    required DateTime periodEnd,

    /// 次回リセット日時（通常は periodEnd + 1日 0:00）
    required DateTime nextResetAt,

    /// 最終更新日時
    required DateTime lastUpdated,
  }) = _LevelingState;

  const LevelingState._();

  factory LevelingState.fromJson(Map<String, dynamic> json) =>
      _$LevelingStateFromJson(json);

  factory LevelingState.initial({
    required DateTime now,
    String id = 'current_level',
  }) {
    final periodStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final periodEnd = nextMonth.subtract(const Duration(seconds: 1));
    final periodId = '${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}';
    return LevelingState(
      id: id,
      periodId: periodId,
      level: 0,
      exactLevel: 0,
      progressToNextLevel: 0,
      personSeconds: 0,
      requiredSecondsForNextLevel: 3600,
      rank: LevelRankTier.apprentice,
      periodStart: periodStart,
      periodEnd: periodEnd,
      nextResetAt: nextMonth,
      lastUpdated: now,
    );
  }

  bool get isMaxLevel => level >= 100;
}

/// 月次スナップショット（履歴用）
@freezed
abstract class LevelSnapshot with _$LevelSnapshot {
  const factory LevelSnapshot({
    required int level,
    required double exactLevel,
    required LevelRankTier rank,
    required int personSeconds,
    required DateTime capturedAt,
  }) = _LevelSnapshot;

  factory LevelSnapshot.fromJson(Map<String, dynamic> json) =>
      _$LevelSnapshotFromJson(json);
}


