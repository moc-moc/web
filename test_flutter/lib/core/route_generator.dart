import 'package:flutter/material.dart';

/// 画面遷移アニメーションのタイプ
enum TransitionType { fade, slide, scale, slideUp, none }

/// 汎用的なルート生成関数群
class RouteMk {
  /// カスタムトランジション付きPageRouteを生成する関数
  ///
  /// [widget] 表示するウィジェット
  /// [settings] ルート設定
  /// [transitionType] 遷移アニメーションのタイプ
  /// [duration] アニメーション時間
  /// 戻り値: PageRouteBuilder
  static Route<dynamic> createCustomPageRoute({
    required Widget widget,
    required RouteSettings settings,
    TransitionType transitionType = TransitionType.fade,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);

          case TransitionType.slide:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );

          case TransitionType.slideUp:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );

          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );

          case TransitionType.none:
            return child;
        }
      },
    );
  }

  /// MaterialPageRouteを生成する汎用関数
  ///
  /// [widget] 表示するウィジェット
  /// [settings] ルート設定
  /// 戻り値: MaterialPageRoute
  static Route<dynamic> createMaterialPageRoute({
    required Widget widget,
    required RouteSettings settings,
  }) {
    // デフォルトでフェードトランジションを使用
    return createCustomPageRoute(
      widget: widget,
      settings: settings,
      transitionType: TransitionType.fade,
    );
  }

  /// ルート名とウィジェットのマッピングから適切なルートを生成する汎用関数
  ///
  /// [routeName] ルート名
  /// [routeMap] ルート名とウィジェットのマッピング
  /// [settings] ルート設定
  /// 戻り値: 対応するルート、見つからない場合はnull
  static Route<dynamic>? generateRouteFromMap({
    required String routeName,
    required Map<String, Widget Function()> routeMap,
    required RouteSettings settings,
  }) {
    final widgetBuilder = routeMap[routeName];
    if (widgetBuilder != null) {
      return createMaterialPageRoute(
        widget: widgetBuilder(),
        settings: settings,
      );
    }
    return null;
  }

  /// 404エラーページを生成する汎用関数
  ///
  /// [settings] ルート設定
  /// [errorMessage] エラーメッセージ（デフォルト: 'Page not found'）
  /// 戻り値: 404エラーページのMaterialPageRoute
  static Route<dynamic> createNotFoundRoute({
    required RouteSettings settings,
    String errorMessage = 'Page not found',
  }) {
    return createMaterialPageRoute(
      widget: Scaffold(body: Center(child: Text(errorMessage))),
      settings: settings,
    );
  }

  /// ルート生成のメイン関数
  ///
  /// [settings] ルート設定
  /// [routeMap] ルート名とウィジェットのマッピング
  /// [errorMessage] 404エラーメッセージ
  /// 戻り値: 生成されたルート
  static Route<dynamic> generateRoute({
    required RouteSettings settings,
    required Map<String, Widget Function()> routeMap,
    String errorMessage = 'Page not found',
  }) {
    final route = generateRouteFromMap(
      routeName: settings.name ?? '',
      routeMap: routeMap,
      settings: settings,
    );

    return route ??
        createNotFoundRoute(settings: settings, errorMessage: errorMessage);
  }
}
