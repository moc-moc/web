# 多ラベル分類モデル選定調査レポート

## 要件整理

### 検出対象
- **勉強カテゴリ**: 本（book）、ペン（pen）、ノート（notebook）、紙（paper）
- **PCカテゴリ**: ラップトップ（laptop）、デスクトップ（desktop）、キーボード（keyboard）、マウス（mouse）、コンピューター（computer）
- **スマホカテゴリ**: スマートフォン（smartphone）、電話（phone）、モバイル（mobile）
- **人カテゴリ**: 人（person）、人間（human）
- **検出なし**: 何も検出されない場合

### 技術要件
- **プラットフォーム**: iOS（ネイティブ）、Android（ネイティブ）、Web（ブラウザ）
- **処理方式**: 完全ローカル処理（サーバーに送信しない）
- **検出タイミング**: 
  - 省電力モード: 5秒間隔
  - 通常モード: リアルタイム検出（可能な限り高速）
- **信頼度閾値**: 0.7以上で有効
- **将来拡張**: 姿勢推定、視線推定への拡張可能性

## 選択肢の比較

### 1. TensorFlow Lite (tflite_flutter)

#### 概要
- Googleが開発したモバイル向け機械学習フレームワーク
- Flutter用パッケージ: `tflite_flutter`
- iOS/Androidでネイティブサポート

#### メリット
- ✅ **高いパフォーマンス**: モバイルデバイス向けに最適化
- ✅ **豊富なモデル**: COCOデータセットで学習済みのモデルが多数利用可能
- ✅ **軽量**: モデルサイズが小さい（数MB〜数十MB）
- ✅ **コミュニティ**: ドキュメントとサンプルコードが豊富
- ✅ **信頼性**: Googleがメンテナンス、長期的なサポートが期待できる

#### デメリット
- ❌ **Web対応**: Webでは直接使用不可（TensorFlow.jsが必要）
- ❌ **モデル変換**: カスタムモデルを使用する場合、変換作業が必要

#### 推奨モデル
1. **MobileNetV3 + SSD**
   - サイズ: 約4-8MB
   - 速度: 30-60 FPS（デバイス依存）
   - 精度: COCO mAP 約30-35%
   - 用途: リアルタイム検出に最適

2. **EfficientDet-Lite**
   - サイズ: 約5-12MB
   - 速度: 20-40 FPS
   - 精度: COCO mAP 約35-40%
   - 用途: 精度重視の場合

3. **YOLOv5n (Nano)**
   - サイズ: 約2-4MB
   - 速度: 40-80 FPS
   - 精度: COCO mAP 約28-32%
   - 用途: 速度重視の場合

#### 実装例
```dart
// pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.4

// 使用例
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowLiteDetectionService extends DetectionService {
  Interpreter? _interpreter;
  
  @override
  Future<bool> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('models/ssd_mobilenet.tflite');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    // 推論処理
  }
}
```

#### Web対応
- Webでは `tflite_flutter_web` または `tensorflow_js` を使用
- ただし、パフォーマンスはネイティブより劣る可能性がある

---

### 2. MediaPipe

#### 概要
- Googleが開発したマルチプラットフォームMLフレームワーク
- 物体検出、姿勢推定、手の検出など複数のタスクに対応
- Flutter用パッケージ: `mediapipe`（コミュニティ製）またはネイティブ実装

#### メリット
- ✅ **マルチプラットフォーム**: iOS、Android、Web、デスクトップ対応
- ✅ **将来拡張性**: 姿勢推定、視線推定への拡張が容易
- ✅ **最適化**: Googleが各プラットフォーム向けに最適化
- ✅ **統合性**: 複数のMLタスクを統合できる

#### デメリット
- ❌ **Flutter統合**: 公式Flutterパッケージが限定的
- ❌ **実装複雑度**: ネイティブコードとの連携が必要な場合がある
- ❌ **学習コスト**: ドキュメントがTensorFlow Liteより少ない

#### 推奨モデル
- **MediaPipe Object Detection**
  - サイズ: 約10-15MB
  - 速度: リアルタイム対応
  - 精度: COCO mAP 約30-35%

---

### 3. ONNX Runtime

#### 概要
- Microsoftが開発したクロスプラットフォーム推論エンジン
- 複数のMLフレームワーク（PyTorch、TensorFlowなど）のモデルを実行可能
- Flutter用パッケージ: `onnxruntime`（コミュニティ製）

#### メリット
- ✅ **クロスプラットフォーム**: iOS、Android、Web対応
- ✅ **柔軟性**: 様々なフレームワークのモデルを使用可能
- ✅ **最適化**: ハードウェアアクセラレーション対応（GPU、NPU）

#### デメリット
- ❌ **Flutter統合**: コミュニティパッケージのメンテナンス状況が不明確
- ❌ **ドキュメント**: Flutter向けのドキュメントが少ない
- ❌ **モデルサイズ**: 一部のモデルが大きい可能性

---

### 4. TensorFlow.js (Web専用)

#### 概要
- JavaScript/TypeScript向けのTensorFlow実装
- Webブラウザで直接実行可能
- Flutter Webで使用可能

#### メリット
- ✅ **Webネイティブ**: Webブラウザで直接実行
- ✅ **パフォーマンス**: WebGL/WebGPUによるGPUアクセラレーション
- ✅ **モデル共有**: TensorFlow Liteと同じモデルを使用可能（変換が必要）

#### デメリット
- ❌ **プラットフォーム限定**: Web専用（iOS/Androidでは使用不可）
- ❌ **パフォーマンス**: ネイティブアプリより劣る可能性
- ❌ **統合複雑度**: プラットフォームごとに異なる実装が必要

---

### 5. Core ML (iOS) + ML Kit (Android)

#### 概要
- iOS: AppleのCore MLフレームワーク
- Android: GoogleのML Kit
- プラットフォーム固有の最適化

#### メリット
- ✅ **最適化**: 各プラットフォーム向けに最適化
- ✅ **パフォーマンス**: ネイティブアプリで高いパフォーマンス

#### デメリット
- ❌ **実装複雑度**: プラットフォームごとに異なる実装が必要
- ❌ **統合**: Flutterからの統合が複雑
- ❌ **Web対応**: Webでは使用不可

---

## 推奨案

### 推奨: TensorFlow Lite + TensorFlow.js（ハイブリッドアプローチ）

#### 理由
1. **実績と信頼性**: Googleがメンテナンス、豊富なドキュメントとコミュニティ
2. **パフォーマンス**: モバイルデバイスで高いパフォーマンス
3. **モデル選択肢**: COCOデータセットで学習済みのモデルが多数利用可能
4. **将来拡張性**: カスタムモデルの学習・変換が可能

#### 実装戦略

##### Phase 1: iOS/Android実装
- **パッケージ**: `tflite_flutter`
- **推奨モデル**: **MobileNetV3 + SSD** または **EfficientDet-Lite0**
- **理由**: 
  - バランスの取れた精度と速度
  - 検出対象（本、PC、スマホ、人）をカバー
  - モデルサイズが小さい（4-8MB）

##### Phase 2: Web実装
- **パッケージ**: `tensorflow_js` または `tflite_flutter_web`
- **推奨モデル**: MobileNetV3 + SSD（TFLiteから変換）
- **理由**:
  - モバイルと同じモデルを使用することで一貫性を保つ
  - WebGLによるGPUアクセラレーションでパフォーマンス向上

##### Phase 3: カスタムモデル（将来）
- COCOデータセットで学習済みモデルをベースに、検出対象に特化したファインチューニング
- または、独自データセットで学習したモデルを使用

#### 実装例の構造

```dart
// detection_service.dart（抽象クラス - 既存）
abstract class DetectionService {
  Future<bool> initialize();
  Future<List<DetectionResult>> detect(Uint8List imageBytes);
  Future<void> dispose();
}

// tensorflow_lite_detection_service.dart（iOS/Android用）
class TensorFlowLiteDetectionService extends DetectionService {
  // tflite_flutterを使用
}

// tensorflow_js_detection_service.dart（Web用）
class TensorFlowJsDetectionService extends DetectionService {
  // tensorflow_jsを使用
}

// detection_service_factory.dart（ファクトリー）
class DetectionServiceFactory {
  static DetectionService create() {
    if (kIsWeb) {
      return TensorFlowJsDetectionService();
    } else {
      return TensorFlowLiteDetectionService();
    }
  }
}
```

---

## モデル選定の詳細

### COCOデータセットの検出対象との対応

| 検出対象 | COCOクラス | カテゴリマッピング |
|---------|-----------|-----------------|
| 本 | book | study |
| ペン | pen | study |
| ノート | notebook | study |
| 紙 | paper | study |
| ラップトップ | laptop | pc |
| キーボード | keyboard | pc |
| マウス | mouse | pc |
| スマートフォン | cell phone | smartphone |
| 人 | person | personOnly |

### モデル性能比較（参考値）

| モデル | サイズ | FPS (iPhone 12) | FPS (Pixel 5) | COCO mAP | 推奨用途 |
|--------|--------|-----------------|---------------|----------|---------|
| MobileNetV3-SSD | 4-8MB | 50-60 | 40-50 | 30-32% | **バランス型（推奨）** |
| EfficientDet-Lite0 | 5-12MB | 30-40 | 25-35 | 35-38% | 精度重視（軽量） |
| **EfficientDet-Lite1** | **8-15MB** | **25-35** | **20-30** | **38-42%** | **精度重視（推奨）** |
| **EfficientDet-Lite2** | **12-20MB** | **20-30** | **15-25** | **42-45%** | **最高精度（採用方針）⭐** |
| EfficientDet-Lite3 | 18-30MB | 15-25 | 10-20 | 45-48% | 最高精度 |
| YOLOv5n | 2-4MB | 60-80 | 50-70 | 28-30% | 速度重視 |
| YOLOv8n | 3-5MB | 55-75 | 45-65 | 30-33% | バランス型 |
| YOLOv8s | 10-15MB | 35-50 | 30-45 | 38-42% | 精度重視（YOLO系） |

**バランス型推奨**: MobileNetV3-SSD または EfficientDet-Lite0  
**精度重視推奨**: **EfficientDet-Lite1** または **YOLOv8s**  
**最高精度推奨（採用方針）**: **EfficientDet-Lite2** ⭐

### 精度重視の場合の推奨

#### 🏆 第1推奨: EfficientDet-Lite1

**理由:**
- ✅ **高い精度**: COCO mAP 38-42%（EfficientDet-Lite0より約3-4%向上）
- ✅ **実用的な速度**: 25-35 FPS（iPhone 12）、リアルタイム検出に十分
- ✅ **適切なサイズ**: 8-15MB（モバイルアプリで許容範囲）
- ✅ **Google製**: 長期的なサポートと最適化が期待できる
- ✅ **省電力モード対応**: 5秒間隔なら十分な余裕がある

**検出精度の向上効果:**
- 信頼度0.7以上の検出が増加
- 誤検出の減少
- 小さな物体（ペン、マウスなど）の検出精度向上

#### 🥈 第2推奨: YOLOv8s

**理由:**
- ✅ **高い精度**: COCO mAP 38-42%（EfficientDet-Lite1と同等）
- ✅ **最新技術**: YOLOv8は2023年にリリースされた最新モデル
- ✅ **良好な速度**: 35-50 FPS（iPhone 12）
- ✅ **コミュニティ**: 活発な開発とサポート

**注意点:**
- EfficientDet-Lite1と比較して、モデルサイズがやや大きい可能性
- TensorFlow Liteへの変換が必要な場合がある

#### 🏆 最高精度推奨（採用方針）: EfficientDet-Lite2 ⭐

**採用理由:**
- ✅ **非常に高い精度**: COCO mAP 42-45%（バランス型より約12-15%向上）
- ✅ **小さい物体の検出**: ペンやマウスなどの小さな物体の検出精度が大幅に向上
- ✅ **誤検出の最小化**: 信頼度0.7以上の検出が大幅に増加
- ✅ **省電力モード対応**: 5秒間隔なら十分な余裕がある（20-30 FPS）

**実装時の注意事項:**
- ⚠️ **速度**: 20-30 FPS（iPhone 12）、リアルタイム検出にはやや重い
- ⚠️ **モデルサイズ**: 12-20MB（アプリサイズへの影響を考慮）
- ✅ **推奨使用モード**: 省電力モード（5秒間隔）を推奨
- ✅ **通常モード**: リアルタイム検出も可能だが、バッテリー消費に注意

**実装戦略:**
1. 省電力モードをデフォルトにする
2. 通常モードはオプションとして提供（ユーザーが選択可能）
3. モデル読み込みは遅延読み込みで実装
4. メモリ管理を最適化（検出処理後のメモリ解放）

### 精度重視の選択フローチャート

```
精度を最優先しますか？
├─ YES → 最高精度が必要？
│   ├─ YES → EfficientDet-Lite2 ⭐（採用方針）
│   └─ NO → EfficientDet-Lite1 または YOLOv8s
│
└─ NO → バランス重視 → MobileNetV3-SSD または EfficientDet-Lite0
```

### EfficientDet-Lite2採用時の実装方針

#### 1. 検出タイミングの最適化
- **省電力モード（デフォルト）**: 5秒間隔での検出
  - 20-30 FPSの性能で十分な余裕がある
  - バッテリー消費を最小限に抑制
- **通常モード（オプション）**: 可能な限り高速検出
  - ユーザーが明示的に選択した場合のみ有効化
  - バッテリー消費が増加することを警告表示

#### 2. パフォーマンス最適化
- **画像前処理の最適化**: リサイズ、正規化を効率的に実装
- **非同期処理**: 検出処理を非同期で実行し、UIをブロックしない
- **フレームスキップ**: 通常モードでも必要に応じてフレームをスキップ
- **メモリ管理**: 検出処理後のメモリ解放を確実に実行

#### 3. モデル管理
- **遅延読み込み**: トラッキング開始時にモデルを読み込む
- **モデルキャッシュ**: 一度読み込んだモデルはメモリに保持
- **エラーハンドリング**: モデル読み込み失敗時のフォールバック処理

### 精度重視モデルの比較表

| モデル | COCO mAP | 速度（FPS） | サイズ | 推奨シーン |
|--------|----------|------------|--------|-----------|
| **EfficientDet-Lite2** | **42-45%** | **20-30** | **12-20MB** | **✅ 省電力モード + 最高精度（採用方針）⭐** |
| EfficientDet-Lite1 | 38-42% | 25-35 | 8-15MB | ✅ リアルタイム + 高精度 |
| YOLOv8s | 38-42% | 35-50 | 10-15MB | ✅ リアルタイム + 高精度（最新技術） |
| EfficientDet-Lite3 | 45-48% | 15-25 | 18-30MB | ❌ 通常は非推奨（重すぎる） |

---

## 実装の考慮事項

### 1. モデルの準備
- COCOデータセットで学習済みのモデルをダウンロード
- または、TensorFlow Hubから事前学習済みモデルを取得
- 必要に応じて、検出対象に特化したファインチューニング

### 2. パフォーマンス最適化
- **画像前処理**: リサイズ、正規化を効率的に実装
- **非同期処理**: 検出処理を非同期で実行し、UIをブロックしない
- **フレームスキップ**: 省電力モードでは5秒間隔、通常モードでは可能な限り高速

### 3. メモリ管理
- モデルの遅延読み込み
- 検出処理後のメモリ解放
- 画像バッファの適切な管理

### 4. エラーハンドリング
- モデル読み込み失敗時のフォールバック
- 検出失敗時のリトライロジック
- デバイス性能に応じたモデル選択

---

## 次のステップ

1. **プロトタイプ実装**: TensorFlow LiteでMobileNetV3-SSDを使用したプロトタイプを作成
2. **パフォーマンステスト**: 実機でのFPS、メモリ使用量、バッテリー消費を測定
3. **精度評価**: 検出対象（本、PC、スマホ、人）の検出精度を評価
4. **Web実装**: TensorFlow.jsを使用したWeb版の実装
5. **カスタムモデル検討**: 必要に応じて、検出対象に特化したモデルの学習

---

## 参考リンク

- [TensorFlow Lite公式ドキュメント](https://www.tensorflow.org/lite)
- [tflite_flutterパッケージ](https://pub.dev/packages/tflite_flutter)
- [TensorFlow.js公式ドキュメント](https://www.tensorflow.org/js)
- [COCOデータセット](https://cocodataset.org/)
- [TensorFlow Hub](https://tfhub.dev/)
- [MediaPipe公式ドキュメント](https://mediapipe.dev/)

---

## 結論

### バランス型（推奨）
**推奨アプローチ**: TensorFlow Lite（iOS/Android）+ TensorFlow.js（Web）のハイブリッドアプローチ

**推奨モデル**: MobileNetV3-SSD または EfficientDet-Lite0

**理由**: 
- 実績と信頼性が高い
- モバイルデバイスで高いパフォーマンス
- Web対応も可能
- 将来のカスタムモデルへの拡張が容易
- 豊富なドキュメントとコミュニティサポート

### 最高精度重視（採用方針）⭐
**推奨アプローチ**: TensorFlow Lite（iOS/Android）+ TensorFlow.js（Web）のハイブリッドアプローチ

**採用モデル**: **EfficientDet-Lite2**

**理由**:
- ✅ **最高精度**: COCO mAP 42-45%（バランス型より約12-15%向上）
- ✅ **誤検出の最小化**: 信頼度0.7以上の検出が大幅に増加
- ✅ **小さな物体の検出**: ペン、マウスなどの小さな物体の検出精度が大幅に向上
- ✅ **省電力モード対応**: 5秒間隔なら十分な余裕がある（20-30 FPS）
- ✅ **実用的なサイズ**: 12-20MB（モバイルアプリで許容範囲）

**実装時の注意事項:**
- ⚠️ **速度**: 20-30 FPS（リアルタイム検出にはやや重い）
- ✅ **推奨使用モード**: 省電力モード（5秒間隔）をデフォルトにする
- ✅ **通常モード**: オプションとして提供（バッテリー消費に注意）

### 精度重視（参考）
**推奨モデル**: EfficientDet-Lite1 または YOLOv8s

**理由**:
- ✅ **高い精度**: COCO mAP 38-42%（バランス型より約8-10%向上）
- ✅ **実用的な速度**: リアルタイム検出に十分な25-50 FPS
- ✅ **実用的なサイズ**: 8-15MB（モバイルアプリで許容範囲）

