import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/route.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Web版: FirebaseOptionsを明示的に指定
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBBVBVMlfK7jabroCYjgstsrCUam8Mn4so',
          appId: '1:451402739791:web:default',
          messagingSenderId: '451402739791',
          projectId: 'test-flutter-4b625',
          storageBucket: 'test-flutter-4b625.firebasestorage.app',
          authDomain: 'test-flutter-4b625.firebaseapp.com',
        ),
      );
    } else {
      // モバイル版: デフォルト設定を使用
      await Firebase.initializeApp();
    }
    debugPrint('✅ Firebase初期化');

    final container = ProviderContainer();
    AppInitUN.setGlobalContainer(container);

    await AppInitUN.initializeWithAuth();

    runApp(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  } catch (e, stackTrace) {
    debugPrint('💥 [main] Firebase初期化エラー: $e');
    debugPrint('   - スタックトレース: $stackTrace');
    // エラーが発生してもアプリは起動する（認証機能以外は動作する可能性があるため）
    runApp(const ProviderScope(child: MyApp()));
  }
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
