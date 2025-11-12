// Flutterライブラリ
import 'package:flutter/material.dart';

/// 状態管理用の汎用関数群
/// 
/// データ処理やバリデーションなどの汎用的な関数を提供します。
/// Provider関連はRiverpod Generatorを使用するため、FuncUs層で直接定義します。
/// 
/// **提供機能**:
/// - バリデーション関数
/// - UIフィードバック関数
/// - データ追加処理の基本構造

/// データ追加時の共通バリデーション関数
/// 
/// 文字列データの基本的なバリデーションを行います。
/// 空白文字のみの入力をチェックします。
/// 
/// **パラメータ**:
/// - `value`: バリデーション対象の文字列
/// 
/// **戻り値**: バリデーション成功時true、失敗時false
bool validateNonEmptyString(String value) {
  return value.trim().isNotEmpty;
}

/// SnackBarでメッセージを表示する汎用関数
/// 
/// UIフィードバックのための汎用的なメッセージ表示機能です。
/// 非同期処理後のBuildContext使用に対応した安全な実装です。
/// 
/// **パラメータ**:
/// - `context`: BuildContext
/// - `message`: 表示するメッセージ
/// - `mounted`: ウィジェットがマウントされているか
void showSnackBarMessage(
  BuildContext context,
  String message, {
  required bool mounted,
}) {
  // 非同期gap後のcontext使用を安全にする
  if (!mounted || !context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// データ追加時のエラーハンドリング用基本構造
/// 
/// データ追加処理の結果を表現するクラスです。
/// 成功/失敗の状態とメッセージを保持します。
class AddDataResult {
  /// 処理が成功したかどうか
  final bool success;
  
  /// ユーザーに表示するメッセージ
  final String message;
  
  /// オフライン状態での保存かどうか
  final bool isOffline;

  /// AddDataResultのコンストラクタ
  /// 
  /// **パラメータ**:
  /// - `success`: 成功フラグ
  /// - `message`: メッセージ
  /// - `isOffline`: オフライン保存フラグ（デフォルト: false）
  AddDataResult({
    required this.success,
    required this.message,
    this.isOffline = false,
  });

  /// 成功結果を生成
  factory AddDataResult.success({String? message}) {
    return AddDataResult(
      success: true,
      message: message ?? '追加しました',
    );
  }

  /// オフライン保存結果を生成
  factory AddDataResult.offline({String? message}) {
    return AddDataResult(
      success: true,
      message: message ?? 'オフラインのため、ローカルに保存しました',
      isOffline: true,
    );
  }

  /// 失敗結果を生成
  factory AddDataResult.failure({String? message}) {
    return AddDataResult(
      success: false,
      message: message ?? '追加に失敗しました',
    );
  }
}


