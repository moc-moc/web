import 'package:freezed_annotation/freezed_annotation.dart';

part 'total_model.freezed.dart';
part 'total_model.g.dart';

/// 累計データモデル
/// 
/// ユーザーの総作業時間を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **フィールド**:
/// - `id`: 固定値 'user_total'（ユーザーごとに1つのドキュメント）
/// - `totalWorkTimeMinutes`: 総作業時間（分単位）
/// - `lastTrackedDate`: 最後にトラッキングした日
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class TotalData with _$TotalData {
  /// TotalDataモデルのコンストラクタ
  /// 
  /// **パラメータ**:
  /// - `id`: 固定値 'user_total'
  /// - `totalWorkTimeMinutes`: 総作業時間（分単位）
  /// - `lastTrackedDate`: 最後にトラッキングした日
  /// - `lastModified`: 最終更新日時
  const factory TotalData({
    required String id,
    required int totalWorkTimeMinutes,
    required DateTime lastTrackedDate,
    required DateTime lastModified,
  }) = _TotalData;

  /// JSONからTotalDataモデルを生成
  /// 
  /// SharedPreferencesからの読み込み時に使用されます。
  factory TotalData.fromJson(Map<String, dynamic> json) =>
      _$TotalDataFromJson(json);
}

