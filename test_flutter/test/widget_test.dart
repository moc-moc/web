import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_flutter/presentation/screens/Home/homescreen.dart';
import 'package:test_flutter/core/route.dart';



void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // HomeScreenをビルドするように変更
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    
    // HomeScreen内にScaffoldが1つあるかどうかをテスト
    expect(find.byType(Scaffold), findsOneWidget);
  });


   // テストグループ: ルーティング関連のテストをまとめる
  group('Routing Tests', () {
    // --- HomeScreen のルートをテスト ---
    test('RouteGenerator generates HomeScreen for home route', () {
      final route = RouteGenerator.generateRoute(
        const RouteSettings(name: AppRoutes.home),
      );
      expect(route.settings.name, AppRoutes.home);
    });

    // --- Report 画面のルートをテスト ---
    test('RouteGenerator generates Report for report route', () {
      final route = RouteGenerator.generateRoute(
        const RouteSettings(name: AppRoutes.report),
      );

      // 正しいルート名か？
      expect(route.settings.name, AppRoutes.report);

      // MaterialPageRouteが返されることを確認
      expect(route, isA<MaterialPageRoute>());
    });

    // --- 存在しないルートをテスト ---
    test('RouteGenerator returns error route for unknown route', () {
      final route = RouteGenerator.generateRoute(
        const RouteSettings(name: '/unknown'),
      );
      expect(route.settings.name, isNot(AppRoutes.home));
    });
  });
}