import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 小さいアイコンボタン（ヘッダー用）
/// 
/// セクションのヘッダーなどに配置する小さめのアイコンボタンです。
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// 細長ボタン
class CustomSnsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CustomSnsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 円形ボタン
class CustomPushButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final String routeName;
  final Color? color;

  const CustomPushButton({
    super.key,
    this.text,
    this.icon,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.green,
      shape: const CircleBorder(),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: icon != null 
              ? Icon(
                  icon,
                  color: AppColors.white,
                  size: 32,
                )
              : Text(
                  text ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
          ),
        ),
      ),
    );
  }
}

/// pushReplacementNamedを使用して画面遷移する細長ボタン
/// 現在の画面を新しい画面で置き換える（戻れない）
class CustomReplacementButton extends StatelessWidget {
  final String text;
  final String routeName;
  final Color? color;

  const CustomReplacementButton({
    super.key,
    required this.text,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// popAndPushNamedを使用して画面遷移する細長ボタン
/// 現在の画面をpopしてから新しい画面をpush（スムーズなアニメーション）
class CustomPopAndPushButton extends StatelessWidget {
  final String text;
  final String routeName;
  final Color? color;

  const CustomPopAndPushButton({
    super.key,
    required this.text,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          Navigator.popAndPushNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// pushNamedAndRemoveUntilを使用してホーム画面に戻る細長ボタン
/// 全ての履歴を削除してホーム画面に戻る
class CustomBackToHomeButton extends StatelessWidget {
  final String text;
  final Color? color;

  const CustomBackToHomeButton({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.blue,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 7,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
