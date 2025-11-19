import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/widgets/dialogs.dart';

/// ナビゲーション処理の共通ヘルパー
class NavigationHelper {
  /// 指定されたルートに遷移
  /// 
  /// [routeName]: 遷移先のルート名
  /// [arguments]: 遷移時に渡す引数
  /// 
  /// 戻り値: 遷移が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> push(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    try {
      await Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('💥 [NavigationHelper] pushエラー: $e');
      debugPrint('   - ルート名: $routeName');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(context, '画面遷移に失敗しました');
      }
      
      return false;
    }
  }

  /// 現在の画面を置き換えて遷移
  /// 
  /// [routeName]: 遷移先のルート名
  /// [arguments]: 遷移時に渡す引数
  /// 
  /// 戻り値: 遷移が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    try {
      await Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('💥 [NavigationHelper] pushReplacementエラー: $e');
      debugPrint('   - ルート名: $routeName');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(context, '画面遷移に失敗しました');
      }
      
      return false;
    }
  }

  /// 指定されたルートまでスタックをクリアして遷移
  /// 
  /// [routeName]: 遷移先のルート名
  /// [predicate]: スタックをクリアする条件（デフォルトは全てクリア）
  /// [arguments]: 遷移時に渡す引数
  /// 
  /// 戻り値: 遷移が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> pushAndRemoveUntil(
    BuildContext context,
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
    Object? arguments,
  }) async {
    try {
      await Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        predicate ?? (route) => false,
        arguments: arguments,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('💥 [NavigationHelper] pushAndRemoveUntilエラー: $e');
      debugPrint('   - ルート名: $routeName');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(context, '画面遷移に失敗しました');
      }
      
      return false;
    }
  }

  /// 現在の画面を閉じて戻る
  /// 
  /// [result]: 戻り値として渡す値
  /// 
  /// 戻り値: 画面を閉じることができた場合はtrue、失敗した場合はfalse
  static bool pop(BuildContext context, [Object? result]) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, result);
        return true;
      } else {
        debugPrint('⚠️ [NavigationHelper] pop: 戻る画面がありません');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [NavigationHelper] popエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(context, '画面を閉じることができませんでした');
      }
      
      return false;
    }
  }

  /// 現在の画面を閉じて、指定されたルートに遷移
  /// 
  /// [routeName]: 遷移先のルート名
  /// [arguments]: 遷移時に渡す引数
  /// 
  /// 戻り値: 遷移が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> popAndPush(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    try {
      await Navigator.popAndPushNamed(
        context,
        routeName,
        arguments: arguments,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('💥 [NavigationHelper] popAndPushエラー: $e');
      debugPrint('   - ルート名: $routeName');
      debugPrint('   - スタックトレース: $stackTrace');
      
      if (context.mounted) {
        showErrorSnackBar(context, '画面遷移に失敗しました');
      }
      
      return false;
    }
  }
}

