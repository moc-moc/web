/// トラッキング機能用のヘルパー関数
library;

/// 時間入力値のバリデーション
///
/// 入力値が数値のみで、負の数でないかをチェックします。
///
/// [value] チェックする文字列
/// 戻り値: 有効な場合true、無効な場合false
bool validateTimeInput(String value) {
  if (value.isEmpty) {
    return true; // 空文字は許可（0として扱う）
  }

  final number = int.tryParse(value);
  if (number == null) {
    return false; // 数値に変換できない
  }

  if (number < 0) {
    return false; // 負の数は不可
  }

  return true;
}

/// 時間入力値をint型に変換
///
/// 文字列をint型に変換します。エラー時は0を返します。
///
/// [value] 変換する文字列
/// 戻り値: 変換された数値（エラー時は0）
int parseTimeInput(String value) {
  if (value.isEmpty) {
    return 0;
  }

  final number = int.tryParse(value);
  if (number == null || number < 0) {
    return 0;
  }

  return number;
}
