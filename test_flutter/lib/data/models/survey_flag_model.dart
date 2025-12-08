import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_flag_model.freezed.dart';
part 'survey_flag_model.g.dart';

/// アンケート実施フラグモデル
/// 
/// ユーザーが初回アンケートを実施したかどうかを管理します。
@freezed
abstract class SurveyFlag with _$SurveyFlag {
  const SurveyFlag._();

  const factory SurveyFlag({
    /// 固定ID（'survey_flag'）
    required String id,
    /// 初回アンケートを実施済みかどうか
    required bool hasShownFirstSurvey,
    /// 最終更新日時
    required DateTime lastModified,
  }) = _SurveyFlag;

  /// JSON形式から生成
  factory SurveyFlag.fromJson(Map<String, dynamic> json) =>
      _$SurveyFlagFromJson(json);

  /// Firestoreデータから生成
  factory SurveyFlag.fromFirestore(Map<String, dynamic> data) {
    return SurveyFlag(
      id: data['id'] as String? ?? 'survey_flag',
      hasShownFirstSurvey: data['hasShownFirstSurvey'] as bool? ?? false,
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'hasShownFirstSurvey': hasShownFirstSurvey,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  /// デフォルト値を持つコンストラクタ
  factory SurveyFlag.defaultFlag() => SurveyFlag(
        id: 'survey_flag',
        hasShownFirstSurvey: false,
        lastModified: DateTime.now(),
      );
}

