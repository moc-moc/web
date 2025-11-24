import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// FlutterFire CLI が生成する `DefaultFirebaseOptions` の手動バージョン。
/// 実プロジェクトの値と異なる場合は `flutterfire configure` で再生成してください。
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'このプラットフォーム(${defaultTargetPlatform.name})用のFirebase設定がありません。',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBVBVMlfK7jabroCYjgstsrCUam8Mn4so',
    appId: '1:451402739791:web:20142f01659f02b9f0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    authDomain: 'test-flutter-4b625.firebaseapp.com',
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBVBVMlfK7jabroCYjgstsrCUam8Mn4so',
    appId: '1:451402739791:android:e0433f28dc5effa5f0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA76cLYgPJvqPAEoTc98HZrpLElKGGbRvg',
    appId: '1:451402739791:ios:2afbe6301c0bfb3ff0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
    iosClientId: '451402739791-vnih0uu3ol85v7mlahs5imeab4qqdhpe.apps.googleusercontent.com',
    iosBundleId: 'com.mindnew.timeplus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA76cLYgPJvqPAEoTc98HZrpLElKGGbRvg',
    appId: '1:451402739791:ios:73bec93c9e324598f0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
    iosClientId: '451402739791-drpuc3a3rrb4u0h1bjmi674cq5e9p50u.apps.googleusercontent.com',
    iosBundleId: 'com.example.testFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBBVBVMlfK7jabroCYjgstsrCUam8Mn4so',
    appId: '1:451402739791:web:9b5bf5dd8c0e9facf0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
    authDomain: 'test-flutter-4b625.firebaseapp.com',
  );
}
