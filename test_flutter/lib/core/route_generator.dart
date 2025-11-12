import 'package:flutter/material.dart';

/// 汎用的なルート生成関数群
class RouteMk {
  /// MaterialPageRouteを生成する汎用関数
  /// 
  /// [widget] 表示するウィジェット
  /// [settings] ルート設定
  /// 戻り値: MaterialPageRoute
  static Route<dynamic> createMaterialPageRoute({
    required Widget widget,
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
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
      widget: Scaffold(
        body: Center(
          child: Text(errorMessage),
        ),
      ),
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

    return route ?? createNotFoundRoute(
      settings: settings,
      errorMessage: errorMessage,
    );
  }
}
