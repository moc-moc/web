import 'package:test_flutter/data/sources/local_storage_source.dart';

/// チュートリアル管理サービス
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';

  /// チュートリアルが完了しているかチェック
  static Future<bool> isTutorialCompleted() async {
    final value = await SharedMk.getFromSharedPrefs(_tutorialCompletedKey);
    return value == 'true';
  }

  /// チュートリアル完了フラグを設定
  static Future<void> markTutorialAsCompleted() async {
    await SharedMk.saveToSharedPrefs(_tutorialCompletedKey, 'true');
  }

  /// チュートリアル完了フラグをリセット（デバッグ用）
  static Future<void> resetTutorial() async {
    await SharedMk.removeFromSharedPrefs(_tutorialCompletedKey);
  }
}

