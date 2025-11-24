import 'package:test_flutter/data/sources/local_storage_source.dart';

/// チュートリアル管理サービス
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';

  static String _keyForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _tutorialCompletedKey;
    }
    return '$_tutorialCompletedKey-$userId';
  }

  /// チュートリアルが完了しているかチェック
  static Future<bool> isTutorialCompleted({String? userId}) async {
    final value =
        await SharedMk.getFromSharedPrefs(_keyForUser(userId));
    return value == 'true';
  }

  /// チュートリアル完了フラグを設定
  static Future<void> markTutorialAsCompleted({String? userId}) async {
    await SharedMk.saveToSharedPrefs(_keyForUser(userId), 'true');
  }

  /// チュートリアル完了フラグをリセット（デバッグ用）
  static Future<void> resetTutorial({String? userId}) async {
    await SharedMk.removeFromSharedPrefs(_keyForUser(userId));
  }
}

