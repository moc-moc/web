import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/route.dart';
import 'feature/Countdown/countdown_functions.dart';
import 'data/repositories/initialization_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive初期化
  await Hive.initFlutter();
  debugPrint('✅ Hive初期化完了');

  final container = ProviderContainer();
  AppInitUN.setGlobalContainer(container); // グローバルに保存
  
  // アプリ起動時刻を記録（FuncUs層のProviderを使用）
  container.read(appStartTimeProvider);
  
  // アプリ初期化（認証 + コンテキスト作成）
  await AppInitUN.initializeWithAuth();
  
  // TODO: 認証状態を初期化（実装後に有効化）
  // container.read(authProvider);
  
  // TODO: アプリ初期化（認証状態復元 + カウントダウン読み込み）
  // final authService = AuthService();
  // await authService.initializeAppWithContainer(container);
  
  // TODO: 送信キュー管理を開始（実装後に有効化）
  // final retryManager = RetryManager();
  // retryManager.startRetryManager();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}