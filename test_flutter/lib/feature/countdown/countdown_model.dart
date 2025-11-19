import 'package:freezed_annotation/freezed_annotation.dart';

part 'countdown_model.freezed.dart';
part 'countdown_model.g.dart';

/// カウントダウンモデル
/// 
/// ユーザーが設定するタイトルと目標日時を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
/// 
/// **フィールド**:
/// - `id`: カウントダウンを一意に識別するID
/// - `title`: カウントダウンのタイトル（ユーザー設定）
/// - `targetDate`: 目標日時（ユーザー設定）
/// - `isDeleted`: 論理削除フラグ（削除済みかどうか）
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class Countdown with _$Countdown {
  /// Countdownモデルのコンストラクタ
  /// 
  const factory Countdown({
    required String id,
    required String title,
    required DateTime targetDate,
    @Default(false) bool isDeleted,
    required DateTime lastModified,
  }) = _Countdown;

  /// JSONからCountdownモデルを生成
  /// 
  /// SharedPreferencesからの読み込み時に使用されます。
  factory Countdown.fromJson(Map<String, dynamic> json) =>
      _$CountdownFromJson(json);
}

