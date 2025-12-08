import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'survey_model.freezed.dart';
part 'survey_model.g.dart';

/// アンケート結果モデル
/// 
/// ユーザーのアンケート回答を管理します。
@freezed
abstract class Survey with _$Survey {
  const Survey._();

  const factory Survey({
    /// アンケートID
    required String id,
    /// 満足度（1-5）
    required int rating,
    /// フィードバック（自由記述）
    required String feedback,
    /// 作成日時
    required DateTime createdAt,
  }) = _Survey;

  /// JSON形式から生成
  factory Survey.fromJson(Map<String, dynamic> json) =>
      _$SurveyFromJson(json);

  /// Firestoreデータから生成
  factory Survey.fromFirestore(Map<String, dynamic> data) {
    return Survey(
      id: data['id'] as String? ?? const Uuid().v4(),
      rating: data['rating'] as int? ?? 0,
      feedback: data['feedback'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'rating': rating,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

