import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// 戻るボタン付きアプリバー
class AppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  const AppBarWithBack({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.backgroundCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: Text(title, style: AppTextStyles.h3),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// アクションボタン付きアプリバー
class AppBarWithActions extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Widget? leading;

  const AppBarWithActions({
    super.key,
    required this.title,
    required this.actions,
    this.backgroundColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.backgroundCard,
      elevation: 0,
      leading: leading,
      title: Text(title, style: AppTextStyles.h3),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// シンプルなアプリバー（タイトルのみ）
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final bool centerTitle;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.backgroundCard,
      elevation: 0,
      centerTitle: centerTitle,
      title: Text(title, style: AppTextStyles.h3),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 透明なアプリバー（画像やグラデーション背景の上に配置する用）
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String? title;

  const TransparentAppBar({super.key, this.leading, this.actions, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      title: title != null ? Text(title!, style: AppTextStyles.h3) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
