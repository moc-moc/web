import 'package:test_flutter/data/repositories/base/base_data_manager.dart';
import 'package:test_flutter/data/models/survey_model.dart';

/// アンケート用データマネージャー
/// 
/// BaseDataManager<Survey>を継承して、アンケートデータの管理を行います。
class SurveyDataManager extends BaseDataManager<Survey> {
  @override
  String getCollectionPath(String userId) => 'users/$userId/surveys';

  @override
  Survey convertFromFirestore(Map<String, dynamic> data) {
    return Survey.fromFirestore(data);
  }

  @override
  Map<String, dynamic> convertToFirestore(Survey item) {
    return item.toFirestore();
  }

  @override
  Survey convertFromJson(Map<String, dynamic> json) {
    return Survey.fromJson(json);
  }

  @override
  Map<String, dynamic> convertToJson(Survey item) {
    return item.toJson();
  }

  @override
  String get storageKey => 'surveys';
}

/// グローバルインスタンス
final surveyDataManager = SurveyDataManager();

