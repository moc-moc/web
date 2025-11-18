import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

/// 比較タイプ（以上/以下）
enum ComparisonType {
  /// 以上
  above,
  /// 以下
  below,
}

/// 検出項目（本/スマホ/パソコン）
enum DetectionItem {
  /// 本
  book,
  /// スマホ
  smartphone,
  /// パソコン
  pc,
}

/// 目標モデル
/// 
/// ユーザーが設定する目標を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
@freezed
abstract class Goal with _$Goal {
  /// Goalモデルのコンストラクタ
  const factory Goal({
    required String id,
    required String tag,
    required String title,
    required int targetTime,
    required ComparisonType comparisonType,
    required DetectionItem detectionItem,
    required DateTime startDate,
    required int durationDays,
    @Default(0) int targetSecondsPerDay,
    @Default(0) int consecutiveAchievements,
    int? achievedTime,
    @Default(false) bool isDeleted,
    required DateTime lastModified,
  }) = _Goal;

  /// JSONからGoalモデルを生成
  factory Goal.fromJson(Map<String, dynamic> json) =>
      _$GoalFromJson(json);
}

