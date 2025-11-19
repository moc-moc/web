# Web版でのYOLO11l実装ガイド

## 実装完了内容

Web版でYOLO11l（large版）モデルを使用できるようにしました。

## 追加されたファイル

### 1. `onnx_detection_service_web.dart`
- Web版用のONNX Runtime検出サービス
- ONNX Runtime Webを使用してYOLO11lモデルを実行
- Canvas APIを使用した画像の前処理
- JavaScriptとの連携（Promise処理）

### 2. `onnx_detection_service_stub.dart`
- スタブファイル（実際には使用されない）
- 条件付きエクスポート用

### 3. `onnx_detection_service.dart`（更新）
- 条件付きエクスポートを使用
- Web版: `onnx_detection_service_web.dart`
- モバイル版: `onnx_detection_service_mobile.dart`

### 4. `onnx_detection_service_mobile.dart`（リネーム）
- 元の`onnx_detection_service.dart`をリネーム
- モバイル版専用の実装

## アーキテクチャ

```
onnx_detection_service.dart (条件付きエクスポート)
├── Web版
│   └── onnx_detection_service_web.dart
│       ├── ONNX Runtime Web
│       ├── Canvas API (画像前処理)
│       ├── JavaScript連携
│       └── yolo11l.onnx (HTTPリクエストで読み込み)
│
└── モバイル版
    └── onnx_detection_service_mobile.dart
        ├── ONNX Runtime
        ├── Image package (画像前処理)
        └── yolo11l.onnx (assetから読み込み)
```

## 主な機能

### Web版の特徴

1. **ONNX Runtime Web**: JavaScriptライブラリを使用
2. **Canvas API**: 画像のリサイズと正規化
3. **Float32Array**: 効率的なデータ転送
4. **Promise処理**: 非同期処理のDart変換
5. **NMS**: 重複検出の除去

### 共通機能

- YOLO11lモデルの推論
- 80クラスのCOCOデータセット対応
- 信頼度閾値: 0.7
- カテゴリマッピング（study, pc, smartphone, personOnly）

## 必要な設定

### 1. `web/index.html`

以下のスクリプトタグを追加（✅ 既に追加済み）：

```html
<!-- ONNX Runtime Web for YOLO11 object detection -->
<script src="https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js"></script>
```

### 2. モデルファイル

`assets/models/yolo11l.onnx`を配置（✅ 既に配置済み）

### 3. pubspec.yaml

`assets/models/`がassetsセクションに含まれているか確認：

```yaml
flutter:
  assets:
    - assets/models/
```

## 使用方法

### 自動選択（推奨）

```dart
import 'package:test_flutter/feature/tracking/tracking_functions.dart';

// Web版/モバイル版共通でYOLO11lを使用
final controller = await initializeDetection();
```

### 手動選択

```dart
// 明示的にONNXを指定
final controller = await initializeDetection(
  serviceType: DetectionServiceType.onnx,
);

// TensorFlow.js（COCO-SSD）を使用する場合
final controller = await initializeDetection(
  serviceType: DetectionServiceType.tfjs,
);
```

## パフォーマンス

### Web版の推論時間

| ブラウザ | 推論時間（目安） |
|---------|-----------------|
| Chrome (最新) | 200-300ms |
| Edge (最新) | 200-300ms |
| Safari (最新) | 250-400ms |
| Firefox | 300-500ms |

**注**: 
- 推論時間はハードウェア（GPU/CPU）に依存します
- WebGLが有効な場合、より高速になります
- 省電力モード（5秒間隔）の使用を推奨

## トラブルシューティング

### エラー: "ONNX Runtime Webが読み込まれていません"

**原因**: `web/index.html`にスクリプトタグが追加されていない

**解決方法**: 
1. `web/index.html`を確認
2. スクリプトタグを追加
3. アプリを再ビルド

### エラー: "モデルファイルの読み込みに失敗"

**原因**: `assets/models/yolo11l.onnx`が見つからない

**解決方法**:
1. モデルファイルが配置されているか確認
2. `pubspec.yaml`のassetsセクションを確認
3. `flutter clean && flutter run`

### パフォーマンスが遅い

**解決方法**:
1. 省電力モード（5秒間隔）を使用
2. より軽量なモデル（YOLO11n）を使用
3. ブラウザのハードウェアアクセラレーションを有効化

## ブラウザ互換性

| ブラウザ | 対応状況 | 推奨 |
|---------|---------|------|
| Chrome | ✅ 完全対応 | ⭐⭐⭐⭐⭐ |
| Edge | ✅ 完全対応 | ⭐⭐⭐⭐⭐ |
| Safari | ✅ 対応 | ⭐⭐⭐⭐ |
| Firefox | ✅ 対応 | ⭐⭐⭐ |
| Opera | ✅ 対応 | ⭐⭐⭐ |

## 今後の改善案

1. **WebGPU対応**: より高速な推論
2. **Web Worker**: UIスレッドの負荷軽減
3. **モデルキャッシング**: 初回読み込みの高速化
4. **軽量モデル**: YOLO11n/sのオプション追加

## 参考資料

- [ONNX Runtime Web 公式ドキュメント](https://onnxruntime.ai/docs/tutorials/web/)
- [YOLO11 公式サイト](https://github.com/ultralytics/ultralytics)
- [Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)

