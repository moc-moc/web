import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/route.dart';
import 'core/route_generator.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';
import 'package:test_flutter/data/repositories/auth_repository.dart';
import 'package:test_flutter/data/services/tutorial_service.dart';
import 'package:test_flutter/data/services/countdown_event_service.dart';
import 'package:test_flutter/data/services/goal_period_ended_event_service.dart';
import 'package:test_flutter/presentation/screens/auth/signup_login_screen.dart';
import 'package:test_flutter/presentation/widgets/loading/app_fullscreen_loader.dart';
import 'package:test_flutter/feature/sync/data_refresh_notifier.dart';

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

    final container = ProviderContainer();
    AppInitUN.setGlobalContainer(container);

    // 認証復元のみ実行（データ読み込みはMyApp内で実行）
    await AuthServiceUN.initializeAuth();

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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String? _initialRoute;
  bool _isLoading = true;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('🔄 [MyApp] 初期化開始');
    
    try {
      // Web版の場合、ブラウザのURLを確認して無効なルートをリセット
      String? browserRoute;
      if (kIsWeb) {
        try {
          final uri = Uri.base;
          browserRoute = uri.path;
          debugPrint('🌐 [MyApp] ブラウザのURL: $browserRoute');
          
          // ブラウザのURLが有効なルートかどうかをチェック
          final validRoutes = [
            AppRoutes.home,
            AppRoutes.homeNew,
            AppRoutes.goal,
            AppRoutes.goalNew,
            AppRoutes.report,
            AppRoutes.reportNew,
            AppRoutes.settings,
            AppRoutes.settingsNew,
            AppRoutes.signupLogin,
            AppRoutes.initialSetup,
            AppRoutes.initialGoal,
            AppRoutes.tutorial,
          ];
          
          // ブラウザのURLが有効なルートでない場合、または認証が必要なルートの場合
          // 後で認証チェックで適切なルートにリダイレクトする
          if (browserRoute.isNotEmpty && 
              browserRoute != '/' && 
              !validRoutes.contains(browserRoute)) {
            debugPrint('⚠️ [MyApp] 無効なブラウザURL: $browserRoute → ホーム画面にリダイレクト');
            browserRoute = null; // 無効なルートは無視
          }
        } catch (e) {
          debugPrint('⚠️ [MyApp] ブラウザURL取得エラー: $e');
          browserRoute = null;
        }
      }
      
      // 認証状態をチェック
      debugPrint('🔍 [MyApp] 認証状態をチェック中...');
      if (!mounted) {
        debugPrint('⚠️ [MyApp] Widgetが破棄されているため、認証状態チェックをスキップ');
        return;
      }
      
      final isAuthenticated = await AuthServiceUN.restoreAuthState()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('⚠️ [MyApp] 認証状態チェックがタイムアウト');
        return false;
      });
      
      if (!mounted) {
        debugPrint('⚠️ [MyApp] 認証状態チェック完了後、Widgetが破棄されました');
        return;
      }
      
      debugPrint('✅ [MyApp] 認証状態: $isAuthenticated');
      
      if (!isAuthenticated) {
        // ログインしていない場合は認証画面を表示
        debugPrint('📱 [MyApp] 未認証のため認証画面を表示');
        if (mounted) {
          setState(() {
            _initialRoute = AppRoutes.signupLogin;
            _isLoading = false;
          });
        } else {
          debugPrint('⚠️ [MyApp] Widgetが破棄されているため、setStateをスキップ');
        }
        return;
      }

      // ログイン済みの場合、優先度1のデータを取得するまでローディング
      debugPrint('📊 [MyApp] データ読み込み開始');
      if (!mounted) {
        debugPrint('⚠️ [MyApp] Widgetが破棄されているため、データ読み込みをスキップ');
        return;
      }
      
      try {
        // AppContextを初期化（認証状態を再確認）
        debugPrint('🔧 [MyApp] AppContextを初期化中...');
        await AppInitUN.initialize()
            .timeout(const Duration(seconds: 10), onTimeout: () {
          if (!mounted) {
            debugPrint('⚠️ [MyApp] AppContext初期化タイムアウト時、Widgetが破棄されました');
            throw TimeoutException('AppContext初期化がタイムアウト（Widget破棄）');
          }
          debugPrint('⚠️ [MyApp] AppContext初期化がタイムアウト');
          throw TimeoutException('AppContext初期化がタイムアウト');
        });
        
        if (!mounted) {
          debugPrint('⚠️ [MyApp] AppContext初期化完了後、Widgetが破棄されました');
          return;
        }
        
        debugPrint('✅ [MyApp] AppContext初期化完了');
        
        // Firebaseの認証状態を再確認
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('⚠️ [MyApp] Firebase認証が無効（ユーザーが存在しない）');
          throw Exception('Firebase認証が無効');
        }
        debugPrint('✅ [MyApp] Firebase認証確認: ${currentUser.uid}');
        
        // 優先度1のデータを取得（カウントダウン、ストリーク、ゴール、トータル、トラッキング）
        debugPrint('📥 [MyApp] 優先度1データを読み込み中...');
        await AppInitUN.loadCriticalData()
            .timeout(const Duration(seconds: 30), onTimeout: () {
          if (!mounted) {
            debugPrint('⚠️ [MyApp] データ読み込みタイムアウト時、Widgetが破棄されました');
            // タイムアウト時は例外を投げずに続行（既にログ出力済み）
            return;
          }
          debugPrint('⚠️ [MyApp] データ読み込みがタイムアウト（続行）');
          // タイムアウト時は例外を投げずに続行
        });
        
        if (!mounted) {
          debugPrint('⚠️ [MyApp] データ読み込み完了後、Widgetが破棄されました');
          return;
        }
        
        debugPrint('✅ [MyApp] データ読み込み完了');
        triggerAppLaunch(ref);
      } catch (e, stackTrace) {
        debugPrint('❌ [MyApp] データ取得エラー: $e');
        debugPrint('   - スタックトレース: $stackTrace');
        // エラーが発生した場合は認証が無効とみなし、サインイン画面に遷移
        debugPrint('🔒 [MyApp] エラーにより認証を無効化し、サインイン画面に遷移');
        if (mounted) {
          setState(() {
            _initialRoute = AppRoutes.signupLogin;
            _isLoading = false;
          });
        } else {
          debugPrint('⚠️ [MyApp] Widgetが破棄されているため、エラー時のsetStateをスキップ');
        }
        return;
      }

      // チュートリアル状態をチェック
      debugPrint('📚 [MyApp] チュートリアル状態をチェック中...');
      if (!mounted) {
        debugPrint('⚠️ [MyApp] Widgetが破棄されているため、チュートリアル状態チェックをスキップ');
        return;
      }
      
      final isCompleted = await TutorialService.isTutorialCompleted()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        if (!mounted) {
          debugPrint('⚠️ [MyApp] チュートリアル状態チェックタイムアウト時、Widgetが破棄されました');
          return true; // タイムアウト時は完了済みとみなす
        }
        debugPrint('⚠️ [MyApp] チュートリアル状態チェックがタイムアウト（デフォルト: 完了済み）');
        return true; // タイムアウト時は完了済みとみなす
      });
      
      if (!mounted) {
        debugPrint('⚠️ [MyApp] チュートリアル状態チェック完了後、Widgetが破棄されました');
        return;
      }
      
      debugPrint('✅ [MyApp] チュートリアル状態: $isCompleted');
      
      // 初期ルートを決定
      String finalRoute;
      if (isCompleted) {
        // チュートリアル完了済みの場合
        if (kIsWeb && browserRoute != null && browserRoute.isNotEmpty && browserRoute != '/') {
          // Web版でブラウザのURLが有効なルートの場合、それを使用
          finalRoute = browserRoute;
          debugPrint('🎯 [MyApp] ブラウザURLを使用: $finalRoute');
        } else {
          // デフォルトはホーム画面
          finalRoute = AppRoutes.home;
          debugPrint('🎯 [MyApp] デフォルトルートを使用: $finalRoute');
        }
      } else {
        // チュートリアル未完了の場合
        finalRoute = AppRoutes.tutorial;
        debugPrint('🎯 [MyApp] チュートリアルルートを使用: $finalRoute');
      }
      
      if (mounted) {
        setState(() {
          _initialRoute = finalRoute;
          _isLoading = false;
        });
        debugPrint('✅ [MyApp] setState完了: $_initialRoute');
      } else {
        debugPrint('⚠️ [MyApp] Widgetが破棄されているため、setStateをスキップ');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [MyApp] 初期化エラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      // エラーが発生した場合は必ずサインイン画面を表示
      debugPrint('🔒 [MyApp] エラーにより認証を無効化し、サインイン画面に遷移');
      if (mounted) {
        setState(() {
          _initialRoute = AppRoutes.signupLogin;
          _isLoading = false;
        });
        debugPrint('✅ [MyApp] エラー時のsetState完了');
      } else {
        debugPrint('⚠️ [MyApp] Widgetが破棄されているため、エラー時のsetStateをスキップ');
        // Widgetが破棄されている場合でも、次回のbuildで使用できるように値を設定
        _initialRoute = AppRoutes.signupLogin;
        _isLoading = false;
      }
    }

    // カウントダウン終了チェック（初期化完了後、データ読み込みを待ってから実行）
    // mountedチェックを追加して、Widgetが破棄されている場合は実行しない
    if (mounted) {
      CountdownEventService.scheduleCountdownCheck(
        ref: ref,
        navigator: _navigatorKey.currentState,
        mounted: mounted,
      );

      // ゴール期間終了チェック（初期化完了後、データ読み込みを待ってから実行）
      GoalPeriodEndedEventService.scheduleGoalPeriodCheck(
        ref: ref,
        navigatorKey: _navigatorKey,
        mounted: mounted,
      );
    } else {
      debugPrint('⚠️ [MyApp] Widgetが破棄されているため、イベントチェックをスキップ');
    }

    // 優先度2と3のデータをバックグラウンドで同期（起動後に実行）
    Future.microtask(() async {
      try {
        // 優先度2のデータ（設定）を同期
        await AppInitUN.loadSecondaryData();
      } catch (e) {
        debugPrint('❌ [MyApp] 優先度2データ同期エラー: $e');
      }

      try {
        // 優先度3のデータ（統計）を同期
        await AppInitUN.loadBackgroundData();
      } catch (e) {
        debugPrint('❌ [MyApp] 優先度3データ同期エラー: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Web版での再起動時のエラーを防ぐため、mountedチェックを追加
    if (!mounted) {
      debugPrint('⚠️ [MyApp] Widgetが破棄されているため、ローディング画面を表示');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppFullScreenLoader(),
      );
    }

    if (_isLoading || _initialRoute == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppFullScreenLoader(),
      );
    }

      // 初期ルートが設定されている場合のみMaterialAppを返す
      // Web版での再起動時のエラーを防ぐため、onUnknownRouteも設定
      try {
        // 初期ルートが有効なルートかどうかを確認
        final validRoutes = [
          AppRoutes.home,
          AppRoutes.homeNew,
          AppRoutes.goal,
          AppRoutes.goalNew,
          AppRoutes.report,
          AppRoutes.reportNew,
          AppRoutes.settings,
          AppRoutes.settingsNew,
          AppRoutes.signupLogin,
          AppRoutes.initialSetup,
          AppRoutes.initialGoal,
          AppRoutes.tutorial,
        ];
        
        if (_initialRoute != null && !validRoutes.contains(_initialRoute)) {
          debugPrint('⚠️ [MyApp] 無効な初期ルート: $_initialRoute → ホーム画面に変更');
          _initialRoute = AppRoutes.home;
        }
      // 初期ルートが通常画面の場合、認証状態を再確認
      if (_initialRoute != AppRoutes.signupLogin && 
          _initialRoute != AppRoutes.initialSetup && 
          _initialRoute != AppRoutes.initialGoal &&
          _initialRoute != AppRoutes.tutorial) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('🔒 [MyApp] build時: Firebase認証が無効のため、サインイン画面に変更');
          _initialRoute = AppRoutes.signupLogin;
        }
      }
      
      // Web版の場合、保護されたルートにアクセスしようとしている場合は認証状態を再確認
      // サインアウト後にブラウザのURLが/settingsのままになっている場合に対応
      if (kIsWeb && _initialRoute != AppRoutes.signupLogin && 
          _initialRoute != AppRoutes.initialSetup && 
          _initialRoute != AppRoutes.initialGoal &&
          _initialRoute != AppRoutes.tutorial) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('🔒 [MyApp] Web版: 認証が無効のため、サインイン画面に変更');
          _initialRoute = AppRoutes.signupLogin;
        }
      }
      
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        routes: RouteGenerator.materialRouteBuilders,
        onGenerateInitialRoutes: (initialRouteName) {
          // Hot restart時にブラウザURLが保持されている場合、それを無視して
          // _initialRouteを使用する（初期化ロジックで決定されたルート）
          final routeName = _initialRoute ?? AppRoutes.home;
          debugPrint('🎯 [MyApp] onGenerateInitialRoutes: ブラウザURL=$initialRouteName, 使用ルート=$routeName');
          final initialRoute = RouteGenerator.generateRoute(
            RouteSettings(name: routeName),
          );
          return [initialRoute];
        },
        onGenerateRoute: RouteGenerator.generateRoute,
        onUnknownRoute: (settings) {
          debugPrint('⚠️ [MyApp] 未知のルート: ${settings.name}');
          
          // 既知のルート名のエイリアスをチェック
          final routeName = settings.name ?? '';
          String? targetRoute;
          
          // ルート名の正規化（末尾のスラッシュを削除、大文字小文字を無視）
          final normalizedRoute = routeName.toLowerCase().replaceAll(RegExp(r'/$'), '');
          
          // よくあるルート名のエイリアスを処理
          if (normalizedRoute == 'goal' || normalizedRoute == '/goal') {
            targetRoute = AppRoutes.goal;
          } else if (normalizedRoute == 'home' || normalizedRoute == '/home' || normalizedRoute == '' || normalizedRoute == '/') {
            targetRoute = AppRoutes.home;
          } else if (normalizedRoute == 'report' || normalizedRoute == '/report') {
            targetRoute = AppRoutes.report;
          } else if (normalizedRoute == 'settings' || normalizedRoute == '/settings') {
            targetRoute = AppRoutes.settings;
          }
          
          if (targetRoute != null) {
            debugPrint('🔄 [MyApp] ルートエイリアスを解決: $routeName → $targetRoute');
            // 認証状態を確認
            final currentUser = FirebaseAuth.instance.currentUser;
            // 保護されたルートかどうかをチェック（認証不要なルートのリスト）
            const publicRoutes = [
              AppRoutes.signupLogin,
              AppRoutes.initialSetup,
              AppRoutes.initialGoal,
              AppRoutes.tutorial,
            ];
            if (currentUser == null && !publicRoutes.contains(targetRoute)) {
              debugPrint('🔒 [MyApp] 認証が必要なルートのため、サインイン画面にリダイレクト');
              return RouteMk.createMaterialPageRoute(
                widget: const SignupLoginScreen(),
                settings: const RouteSettings(name: AppRoutes.signupLogin),
              );
            }
            // 正規化されたルートで再生成
            return RouteGenerator.generateRoute(
              RouteSettings(name: targetRoute, arguments: settings.arguments),
            );
          }
          
          // 未知のルートの場合は、必ずサインイン画面にリダイレクト（認証を強制）
          debugPrint('🔒 [MyApp] 未知のルートのため、サインイン画面にリダイレクト');
          return RouteMk.createMaterialPageRoute(
            widget: const SignupLoginScreen(),
            settings: const RouteSettings(name: AppRoutes.signupLogin),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [MyApp] buildエラー: $e');
      debugPrint('   - スタックトレース: $stackTrace');
      // エラーが発生した場合は、ローディング画面を表示
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppFullScreenLoader(),
      );
    }
  }
}
