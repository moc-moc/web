import 'package:flutter/material.dart';
import 'package:test_flutter/core/theme.dart';

/// アプリの共通Scaffold構造
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundPrimary,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// スクロール可能なコンテンツラッパー
class ScrollableContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const ScrollableContent({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: child,
    );
  }
}

/// 安全領域を考慮したコンテンツラッパー
class SafeContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const SafeContent({
    super.key,
    required this.child,
    this.padding,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// 中央配置レイアウト
class CenteredLayout extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const CenteredLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: maxWidth != null
            ? BoxConstraints(maxWidth: maxWidth!)
            : null,
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// 最大幅制限付きコンテンツ
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return center ? Center(child: content) : content;
  }
}

/// リスト用のスペースドレイアウト
class SpacedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SpacedColumn({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// 横並び用のスペースドレイアウト
class SpacedRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SpacedRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// "OR"テキスト付きの区切り線
class OrDivider extends StatelessWidget {
  final String text;
  final Color? dividerColor;
  final Color? textColor;

  const OrDivider({
    super.key,
    this.text = 'OR',
    this.dividerColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDividerColor =
        dividerColor ?? AppColors.gray.withValues(alpha: 0.35);
    final effectiveTextColor = textColor ?? AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: effectiveDividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: effectiveTextColor,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: effectiveDividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
