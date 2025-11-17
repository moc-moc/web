# AI検出サービス実装ガイド

このディレクトリには、Focus Trackerアプリのカメラ画像から物体を検出するAIサービスの実装が含まれています。

## 実装されたサービス

### 1. TFLiteDetectionService（TensorFlow Lite検出サービス）
- **ファイル**: `tflite_detection_service.dart`
- **プラットフォーム**: iOS/Android（モバイル版）
- **モデル**: YOLOv11n、EfficientDet-Lite2
- **説明**: モバイル端末でTensorFlow Liteを使用して物体検出を実行

### 2. ONNXDetectionService（ONNX Runtime検出サービス）
- **ファイル**: `onnx_detection_service.dart` (条件付きエクスポート)
  - モバイル版: `onnx_detection_service_mobile.dart`
  - Web版: `onnx_detection_service_web.dart`
- **プラットフォーム**: iOS/Android/Web（全プラットフォーム対応）
- **モデル**: YOLO11l（推奨）、YOLO11n、YOLOv8n
- **説明**: ONNX Runtime / ONNX Runtime Webを使用して高精度な物体検出を実行

### 3. TFJSDetectionService（TensorFlow.js検出サービス）
- **ファイル**: `tfjs_detection_service_web.dart` / `tfjs_detection_service_stub.dart` / `tfjs_detection_service.dart`
- **プラットフォーム**: Web版
- **モデル**: COCO-SSD
- **説明**: Web版でTensorFlow.jsを使用して物体検出を実行

## モデルファイルの準備

### モバイル版（TFLite / ONNX）

以下のモデルファイルを `assets/models/` ディレクトリに配置してください：

#### YOLO11モデルのサイズバリエーション

YOLO11には5つのサイズバリエーションがあります：

| モデル | ファイル名 | サイズ | 推論時間（WebGPU） | 推論時間（CPU/モバイル） | 精度 | 推奨用途 |
|--------|-----------|--------|------------------|---------------------|------|---------|
| **YOLO11n** (nano) | `yolo11n.onnx` | 約6MB | 50-100ms | 30-50ms | ⭐⭐ | 低スペック端末、超高速検出 |
| **YOLO11s** (small) | `yolo11s.onnx` | 約20MB | 80-150ms | 50-80ms | ⭐⭐⭐ | 軽量・バランス型 |
| **YOLO11m** (medium) | `yolo11m.onnx` | 約40MB | **100-200ms** | 80-120ms | ⭐⭐⭐⭐ | **精度とスピードの最適バランス（推奨）** |
| **YOLO11l** (large) | `yolo11l.onnx` | 約80MB | 200-400ms | 120-200ms | ⭐⭐⭐⭐⭐ | 最高精度、高スペック端末 |
| **YOLO11x** (xlarge) | `yolo11x.onnx` | 約130MB | 500ms+ | 200-300ms | ⭐⭐⭐⭐⭐+ | サーバー推論向け |

**現在のデフォルト**: `yolo11m.onnx`（medium版、精度とスピードの最適バランス）
**フォールバック**: 存在しない場合は`yolo11l.onnx` → `yolo11n.onnx`の順で自動選択

#### モデルファイルのダウンロード

1. **YOLO11m ONNX**（推奨）
   - ファイル名: `yolo11m.onnx`
   - ダウンロード: [YOLOv11 公式サイト](https://github.com/ultralytics/ultralytics)
   - または、Pythonで変換:
     ```python
     from ultralytics import YOLO
     # YOLO11m（推奨：1秒間隔での検出に最適）
     model = YOLO('yolo11m.pt')
     model.export(format='onnx', simplify=True, opset=12)
     ```

2. **YOLO11l ONNX**（高精度版、オプション）
   - ファイル名: `yolo11l.onnx`
   - 最高精度が必要な場合のみ
   - Pythonで変換:
     ```python
     from ultralytics import YOLO
     # YOLO11l（最高精度、やや重い）
     model = YOLO('yolo11l.pt')
     model.export(format='onnx', simplify=True, opset=12)
     ```

3. **YOLO11 TFLite**（オプション）
   - ファイル名: `yolo11m.tflite` または `yolo11l.tflite`
   - ONNX版から変換する必要があります
   - TensorFlow Liteを優先的に使いたい場合のみ

4. **ラベルファイル**（オプション）
   - ファイル名: `labels.txt`
   - 説明: COCOデータセットの80クラスのラベル
   - 注: コードに埋め込まれているため、不要

### Web版（ONNX Runtime Web）

**現在のデフォルト設定**: Web版でもYOLO11mを使用します（WebGPU対応）

Web版では、ONNX Runtime WebをWebGPUバックエンドで使用してYOLO11mモデルを実行します。
- **推論速度**: 100-200ms（WebGPU使用時）
- **1秒間隔での検出**: 余裕を持って動作
- **省電力モード**: 10秒間隔で安定動作

#### 必要な設定

`web/index.html`に以下のスクリプトタグを追加する必要があります：

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... 他のメタタグ ... -->
  
  <!-- ONNX Runtime Web -->
  <script src="https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js"></script>
</head>
<body>
  <!-- ... -->
</body>
</html>
```

#### モデルファイルの配置

モバイル版と同じく、`assets/models/yolo11l.onnx`をプロジェクトに配置してください。Web版では、このファイルがHTTPリクエストで読み込まれます。

#### TensorFlow.jsを使用する場合（オプション）

Web版でTensorFlow.js（COCO-SSD）を使用したい場合は、以下のようにサービスタイプを指定してください：

```dart
final controller = await initializeDetection(
  serviceType: DetectionServiceType.tfjs,
);
```

`web/index.html`には以下を追加：

```html
<!-- TensorFlow.js -->
<script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs"></script>
<!-- COCO-SSDモデル -->
<script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd"></script>
```

## 使用方法

### 自動選択（推奨）

プラットフォームに応じて自動的に最適な検出サービスを選択します：

```dart
import 'package:test_flutter/feature/tracking/tracking_functions.dart';

// 自動選択（Web/モバイル共通: ONNX Runtime + YOLO11l）
final controller = await initializeDetection();
```

### 手動選択

特定の検出サービスを選択する場合：

```dart
import 'package:test_flutter/feature/tracking/tracking_functions.dart';

// ONNX Runtime（モバイル用）
final controller = await initializeDetection(
  serviceType: DetectionServiceType.onnx,
);

// TensorFlow Lite（モバイル用）
final controller = await initializeDetection(
  serviceType: DetectionServiceType.tflite,
);

// TensorFlow.js（Web用）
final controller = await initializeDetection(
  serviceType: DetectionServiceType.tfjs,
);
```

## 検出カテゴリ

検出されたラベルは、以下のカテゴリにマッピングされます：

| カテゴリ | 対応するラベル |
|---------|---------------|
| **study**（勉強） | book, pen, notebook, paper |
| **pc**（パソコン） | laptop, keyboard, mouse, computer, tv |
| **smartphone**（スマホ） | cell phone, phone, mobile |
| **personOnly**（人） | person, human |
| **nothingDetected**（検出なし） | （上記以外） |

## 検出パラメータ

- **信頼度閾値**: 0.7（70%以上の信頼度で検出を有効化）
- **入力サイズ**: 640x640ピクセル（YOLO標準）
- **IoU閾値**: 0.5（重複検出の除去用）

## パフォーマンス

### モバイル版（ONNX Runtime）

| モデル | サイズ | 推論時間（目安） | 精度 | メモリ使用量 |
|--------|--------|-----------------|------|-------------|
| YOLO11n | 6MB | 30-50ms | 中 | 低 |
| YOLO11s | 20MB | 50-80ms | 中〜高 | 中 |
| YOLO11m | 40MB | 80-120ms | 高 | 中〜高 |
| **YOLO11l** (現在使用中) | **80MB** | **120-200ms** | **最高** | **高** |
| YOLO11x | 130MB | 200-300ms | 最高+ | 非常に高 |

### Web版（ONNX Runtime Web）

| モデル | サイズ | 推論時間（目安） | 精度 | メモリ使用量 |
|--------|--------|-----------------|------|-------------|
| **YOLO11l** (現在使用中) | **80MB** | **200-400ms** | **最高** | **高** |
| YOLO11n | 6MB | 80-150ms | 中 | 低 |
| YOLO11s | 20MB | 100-200ms | 中〜高 | 中 |
| COCO-SSD (TensorFlow.js) | - | 50-150ms | 中 | 中 |

**注**: Web版の推論時間はブラウザとハードウェアによって大きく変動します。

### 推奨設定

#### モバイル版
- **高精度重視**（現在の設定）: YOLO11l + 通常モード
- **バランス型**: YOLO11s + 省電力モード
- **低スペック端末**: YOLO11n + 省電力モード
- **リアルタイム重視**: YOLO11n + 通常モード

#### Web版
- **高精度重視**（現在の設定）: YOLO11l + 省電力モード（5秒間隔推奨）
- **バランス型**: YOLO11s + 省電力モード
- **低スペック**: YOLO11n + 省電力モード、またはCOCO-SSD
- **古いブラウザ**: COCO-SSD (TensorFlow.js)

## トラブルシューティング

### モデルファイルが見つからない

**エラー**: `モデルファイルの読み込みに失敗`

**解決方法**:
1. `assets/models/`ディレクトリにモデルファイルが存在するか確認
2. `pubspec.yaml`の`assets`セクションに`assets/models/`が含まれているか確認
3. アプリを再ビルド（`flutter clean && flutter run`）

### Web版でONNX Runtime Webが読み込まれない

**エラー**: `ONNX Runtime Webが読み込まれていません`

**解決方法**:
1. `web/index.html`に以下のスクリプトタグが追加されているか確認：
   ```html
   <script src="https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js"></script>
   ```
2. ブラウザのコンソールでエラーメッセージを確認
3. CDNが利用可能か確認（ネットワーク接続）
4. ブラウザがONNX Runtime Webに対応しているか確認（Chrome、Edge、Safari推奨）

### Web版でTensorFlow.jsが読み込まれない（COCO-SSD使用時）

**エラー**: `TensorFlow.jsが読み込まれていません`

**解決方法**:
1. `web/index.html`に必要なスクリプトタグが追加されているか確認
2. ブラウザのコンソールでエラーメッセージを確認
3. CDNが利用可能か確認（ネットワーク接続）

### 検出精度が低い

**解決方法**:
1. カメラの解像度を上げる
2. 照明条件を改善する
3. より高精度なモデル（EfficientDet-Lite2）を使用する
4. 信頼度閾値を調整する（`detection_service.dart`内）

## 参考資料

- [YOLOv11 公式ドキュメント](https://github.com/ultralytics/ultralytics)
- [TensorFlow Lite 公式ドキュメント](https://www.tensorflow.org/lite)
- [ONNX Runtime 公式ドキュメント](https://onnxruntime.ai/)
- [TensorFlow.js 公式ドキュメント](https://www.tensorflow.org/js)
- [COCO-SSD モデル](https://github.com/tensorflow/tfjs-models/tree/master/coco-ssd)

## ライセンス

各モデルは、それぞれのライセンスに従います：
- YOLOv11: AGPL-3.0 License
- TensorFlow Lite: Apache 2.0 License
- ONNX Runtime: MIT License
- TensorFlow.js: Apache 2.0 License

