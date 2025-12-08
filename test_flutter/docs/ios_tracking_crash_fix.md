# iOSトラッキング画面クラッシュ問題の解決方法

## 問題の概要

iOSでトラッキングを開始しようとすると、以下のエラーでアプリがクラッシュします：

```
Thread 1: signal SIGABRT
shared_preferences_foundation.LegacyUserDefaultsApi.setValue
Failed: did_send.
```

## 根本原因

`TrackingScreenNew`の`initState()`で、複数の非同期処理が同時に開始され、`SharedPreferences`への並列アクセスが発生しています。

### 問題のコード構造

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _deviceType = _getDeviceType();
  _checkTrackingLimit();          // ← SharedPreferences使用
  _loadTrackingSettings();        // ← SharedPreferences使用 + カメラ初期化
  _startAutoSaveTimer();
  _startBackgroundMonitoring();
}
```

具体的な問題：
1. `_checkTrackingLimit()` が `SharedPreferences` を読み取る
2. `_loadTrackingSettings()` が `SharedPreferences` を読み取り、カメラを初期化
3. カメラ初期化中に `ONNX Runtime` がIsolateで処理を開始
4. 複数のスレッド・Isolateから`SharedPreferences`にアクセスし、Method Channelで競合が発生

### なぜクラッシュするか

- FlutterのMethod Channelはシングルスレッドで動作
- 複数の非同期処理が同時にネイティブ側（iOS）と通信しようとすると競合
- 特に`SharedPreferences`の保存処理（`setValue`）中に別の処理が割り込むとクラッシュ

## 解決方法

### 方法1: 初期化処理を順次実行（推奨）

`lib/presentation/screens/tracking/tracking.dart`の`initState()`を修正し、非同期処理を順次実行するように変更します。

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _deviceType = _getDeviceType();
  
  // 非同期処理を順次実行
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // 1. まずトラッキング制限をチェック
    await _checkTrackingLimitAsync();
    
    if (!mounted) return;
    
    // 2. 次にトラッキング設定を読み込み（カメラ初期化含む）
    await _loadTrackingSettings();
    
    if (!mounted) return;
    
    // 3. タイマーを開始
    _startAutoSaveTimer();
    _startBackgroundMonitoring();
  });
}

/// トラッキング制限をチェック（非同期版）
Future<void> _checkTrackingLimitAsync() async {
  if (!mounted) return;
  
  try {
    final subscriptionStatus = ref.read(subscriptionStatusProvider);
    // プレミアムユーザーは制限なし
    if (subscriptionStatus.hasPremiumAccess) {
      return;
    }
    
    // Providerを無効化して再読み込み
    ref.invalidate(dailyTrackingCountProvider);
    final canStart = ref.read(canStartTrackingProvider);
    
    if (!canStart && mounted) {
      // 制限超過の場合は課金画面に遷移
      Navigator.of(context).pop();
      NavigationHelper.push(context, AppRoutes.subscriptionNew);
    }
  } catch (e) {
    LogMk.logError(
      'トラッキング制限チェックエラー: $e',
      tag: 'TrackingScreen._checkTrackingLimitAsync',
    );
  }
}
```

### 方法2: SharedPreferencesの初期化をシングルトン化

`SharedPreferences`のインスタンスを1箇所でキャッシュし、複数回の`getInstance()`呼び出しを避けます。

新しいファイル`lib/data/services/shared_preferences_service.dart`を作成：

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesのシングルトンサービス
class SharedPreferencesService {
  static SharedPreferences? _instance;
  static Future<SharedPreferences>? _initFuture;
  
  /// SharedPreferencesインスタンスを取得（キャッシュ付き）
  static Future<SharedPreferences> getInstance() async {
    // 既にインスタンスがある場合はそれを返す
    if (_instance != null) {
      return _instance!;
    }
    
    // 初期化中の場合は、その完了を待つ
    if (_initFuture != null) {
      return await _initFuture!;
    }
    
    // 初期化を開始
    _initFuture = SharedPreferences.getInstance();
    _instance = await _initFuture!;
    _initFuture = null;
    
    return _instance!;
  }
  
  /// インスタンスをクリア（テスト用）
  static void clearInstance() {
    _instance = null;
    _initFuture = null;
  }
}
```

そして、全ての`SharedPreferences.getInstance()`を`SharedPreferencesService.getInstance()`に置き換えます。

### 方法3: カメラ初期化のエラーハンドリング強化

`lib/presentation/screens/tracking/tracking.dart`の`_initializeCamera()`メソッドにtry-catchを追加：

```dart
/// カメラの初期化
Future<void> _initializeCamera() async {
  if (!mounted) {
    return;
  }

  setState(() {
    _isCameraInitializing = true;
    _cameraError = null;
    _setupErrorMessage = null;
    if (_setupStatus != _TrackingSetupStatus.ready) {
      _setupStatus = _TrackingSetupStatus.loading;
    }
    _initStageStatuses[DetectionInitStage.camera] = DetectionInitStatus.inProgress;
    _initStageStatuses[DetectionInitStage.ai] = DetectionInitStatus.pending;
  });

  try {
    final controller = await initializeDetection(
      options: DetectionInitOptions(
        powerSavingMode: _isPowerSavingMode,
        onStageStatusChanged: (stage, status) {
          if (!mounted) {
            return;
          }
          setState(() {
            _initStageStatuses[stage] = status;
          });
        },
      ),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        LogMk.logError(
          'カメラ初期化がタイムアウトしました',
          tag: 'TrackingScreen._initializeCamera',
        );
        return null;
      },
    );

    if (!mounted) {
      await controller?.dispose();
      return;
    }

    if (controller == null) {
      setState(() {
        _isCameraInitializing = false;
        _cameraError = 'カメラの初期化に失敗しました';
        if (_setupStatus != _TrackingSetupStatus.ready) {
          _setupStatus = _TrackingSetupStatus.error;
          _setupErrorMessage = 'カメラとAIモデルの初期化に失敗しました。アプリを再起動してください。';
        }
      });
      return;
    }

    // カメラマネージャーを取得
    final cameraManager = controller.cameraManager;

    setState(() {
      _detectionController = controller;
      _cameraManager = cameraManager;
      _isCameraInitializing = false;
      _cameraError = null;
      _initStageStatuses[DetectionInitStage.camera] = DetectionInitStatus.success;
      _initStageStatuses[DetectionInitStage.ai] = DetectionInitStatus.success;
    });

    // 検出を開始
    await controller.start(powerSavingMode: _isPowerSavingMode);
    _ensureSessionTimingStarted();

    // 検出結果を直接処理
    await _detectionSubscription?.cancel();
    // ... 以下省略
  } catch (e, stackTrace) {
    LogMk.logError(
      'カメラ初期化エラー: $e',
      tag: 'TrackingScreen._initializeCamera',
      stackTrace: stackTrace,
    );
    
    if (!mounted) return;
    
    setState(() {
      _isCameraInitializing = false;
      _cameraError = 'カメラ初期化エラー: ${e.toString()}';
      if (_setupStatus != _TrackingSetupStatus.ready) {
        _setupStatus = _TrackingSetupStatus.error;
        _setupErrorMessage = 'カメラとAIモデルの初期化に失敗しました。\n\nエラー: ${e.toString()}\n\nアプリを再起動してください。';
      }
    });
  }
}
```

## 推奨される修正手順

1. **方法1を実装**（最優先）
   - `initState()`の非同期処理を順次実行に変更
   
2. **方法3を実装**（同時に実施）
   - カメラ初期化のエラーハンドリングを強化
   
3. **方法2を実装**（任意、余裕があれば）
   - SharedPreferencesをシングルトン化

## 修正後の確認事項

1. トラッキング画面が正常に起動できるか
2. カメラプレビューが表示されるか
3. AIモデルが正常に読み込まれるか（ログ確認）
4. トラッキングが開始できるか
5. アプリをバックグラウンド→フォアグラウンドに戻しても動作するか

## その他の注意事項

### ONNXモデルのサイズ

現在使用している`yolo11l.onnx`（280MB）と`yolo11m.onnx`（52MB）は非常に大きいため、初回ロード時に時間がかかります。

- **yolo11l.onnx**: 280MB（高精度）
- **yolo11m.onnx**: 52MB（バランス）

これが原因でタイムアウトする場合は、`lib/feature/tracking/detection/onnx_detection_service_mobile.dart`の`_loadModel`メソッドのタイムアウト時間を延長するか、より軽量な`yolo11n.onnx`（6MB）を使用することを検討してください。

### カメラ権限

`Info.plist`のカメラ権限設定は正しく設定されています：

```xml
<key>NSCameraUsageDescription</key>
<string>物体検出やトラッキング機能を利用するためにカメラへのアクセスが必要です。</string>
```

権限が拒否された場合は、設定アプリから手動で許可する必要があります。

## まとめ

この問題は、`SharedPreferences`への並列アクセスとMethod Channelの競合が原因です。初期化処理を順次実行することで解決できます。

