import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/models/survey_flag_model.dart';

/// アンケートフラグ用データマネージャー
/// 
/// BaseDataManager<SurveyFlag>を継承して、アンケートフラグデータの管理を行います。
class SurveyFlagDataManager extends BaseDataManager<SurveyFlag> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/survey_flags';

  @override
  SurveyFlag convertFromFirestore(Map<String, dynamic> data) {
    return SurveyFlag.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(SurveyFlag item) {
    return item.toFirestore();
  }

  @override
  SurveyFlag convertFromJson(Map<String, dynamic> json) {
    return SurveyFlag.fromJson(json);
  }

  @override
  Map<String, dynamic> convertToJson(SurveyFlag item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'survey_flags';
}

/// グローバルインスタンス
final surveyFlagDataManager = SurveyFlagDataManager();

