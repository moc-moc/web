import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_model.freezed.dart';
part 'streak_model.g.dart';

/// 連続継続日数モデル
/// 
/// ユーザーのトラッキング連続日数を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **フィールド**:
/// - `id`: 固定値 'user_streak'（ユーザーごとに1つのドキュメント）
/// - `currentStreak`: 現在の連続日数
/// - `longestStreak`: 最長連続記録
/// - `lastTrackedDate`: 最後にトラッキングした日
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class StreakData with _$StreakData {
  /// StreakDataモデルのコンストラクタ
  /// 
  /// **パラメータ**:
  /// - `id`: 固定値 'user_streak'
  /// - `currentStreak`: 現在の連続日数
  /// - `longestStreak`: 最長連続記録
  /// - `lastTrackedDate`: 最後にトラッキングした日
  /// - `lastModified`: 最終更新日時
  const factory StreakData({
    required String id,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastTrackedDate,
    required DateTime lastModified,
  }) = _StreakData;

  /// JSONからStreakDataモデルを生成
  /// 
  /// SharedPreferencesからの読み込み時に使用されます。
  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);
}

