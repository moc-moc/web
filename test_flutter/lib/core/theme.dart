import 'package:flutter/material.dart';

/// アプリケーション全体で使用するカラーパレット
class AppColors {
  AppColors._();

  // ===== 基本色 =====
  static const Color blue = Color.fromRGBO(96, 165, 250, 1);
  static const Color purple = Color.fromRGBO(158, 102, 213, 1);
  static const Color green = Color.fromRGBO(73, 222, 128, 1);
  static const Color yellow = Color.fromRGBO(252, 206, 21, 1);
  static const Color red = Color.fromRGBO(248, 113, 113, 1);
  static const Color blackgray = Color.fromRGBO(31, 41, 55, 1);
  static const Color black = Color.fromRGBO(16, 28, 34, 1);
  static const Color white = Color.fromRGBO(214, 216, 217, 1);
  static const Color gray = Color.fromRGBO(115, 127, 151, 1);

  // ===== 背景色 =====
  /// メイン背景色（濃いグレー）
  static const Color backgroundPrimary = Color.fromRGBO(31, 41, 55, 1);

  /// より濃い背景色
  static const Color backgroundSecondary = Color.fromRGBO(17, 24, 39, 1);

  /// カード背景色
  static const Color backgroundCard = Color.fromRGBO(55, 65, 81, 1);

  // ===== テキスト色 =====
  /// メインテキスト（白）
  static const Color textPrimary = Color.fromRGBO(255, 255, 255, 1);

  /// セカンダリテキスト（グレー）
  static const Color textSecondary = Color.fromRGBO(156, 163, 175, 1);

  /// 無効テキスト（薄いグレー）
  static const Color textDisabled = Color.fromRGBO(107, 114, 128, 1);

  // ===== 機能色 =====
  /// 成功（緑）
  static const Color success = Color.fromRGBO(73, 222, 128, 1);

  /// 警告（黄色）
  static const Color warning = Color.fromRGBO(252, 206, 21, 1);

  /// エラー（赤）
  static const Color error = Color.fromRGBO(248, 113, 113, 1);

  /// 情報（青）
  static const Color info = Color.fromRGBO(96, 165, 250, 1);
}

/// グラフ表示用のカラーパレット
class AppChartColors {
  AppChartColors._();

  // ===== 勉強カテゴリー =====
  /// 勉強（オレンジ）
  static const Color study = Color.fromRGBO(255, 140, 66, 1);

  /// 勉強集中（濃いオレンジ）
  static const Color studyFocused = Color.fromRGBO(255, 107, 26, 1);

  // ===== パソコンカテゴリー =====
  /// パソコン（青緑）
  static const Color pc = Color.fromRGBO(20, 184, 166, 1);

  /// パソコン集中（濃い青緑）
  static const Color pcFocused = Color.fromRGBO(13, 148, 136, 1);

  // ===== その他カテゴリー =====
  /// スマートフォン（黄色）
  static const Color smartphone = Color.fromRGBO(252, 206, 21, 1);

  /// 人のみ（明るい緑）
  static const Color personOnly = Color.fromRGBO(134, 239, 172, 1);

  /// 検出なし（灰色）
  static const Color nothingDetected = Color.fromRGBO(115, 127, 151, 1);
}

/// 角丸の標準値
class AppRadius {
  AppRadius._();

  /// 小さな角丸（8.0） - 小さなボタン、チップ
  static const double small = 8.0;

  /// 中程度の角丸（12.0） - 通常のボタン、カード
  static const double medium = 12.0;

  /// 大きな角丸（16.0） - 大きなカード、ダイアログ
  static const double large = 16.0;
}

/// 余白の標準値
class AppSpacing {
  AppSpacing._();

  /// 極小余白（4.0）
  static const double xs = 4.0;

  /// 小余白（8.0）
  static const double sm = 8.0;

  /// 中余白（16.0）
  static const double md = 16.0;

  /// 大余白（24.0）
  static const double lg = 24.0;

  /// 特大余白（32.0）
  static const double xl = 32.0;

  /// 超特大余白（48.0）
  static const double xxl = 48.0;
}

/// テキストスタイルの標準値
class AppTextStyles {
  AppTextStyles._();

  // ===== 見出し =====
  /// 大見出し（32px, Bold）
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// 中見出し（24px, Bold）
  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// 小見出し（20px, Bold）
  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // ===== 本文 =====
  /// 通常テキスト（16px）
  static const TextStyle body1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// 小さいテキスト（14px）
  static const TextStyle body2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // ===== キャプション =====
  /// キャプション（12px）
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// オーバーライン（10px, Letter Spacing 1.5）
  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
}
