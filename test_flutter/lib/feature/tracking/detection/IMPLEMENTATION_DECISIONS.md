# EfficientDet-Lite2実装における決定事項

## 決定事項一覧

### 1. モデルファイルの取得方法・配置場所

#### 決定: ✅ アプリに同梱（assetsフォルダに配置）

**理由:**
- オフラインでも動作する
- 初回起動時のダウンロード待ちが不要
- モデルファイルのバージョン管理が容易

**実装:**
- `assets/models/efficientdet_lite2.tflite` に配置
- `pubspec.yaml`にassetsを追加
- モデルファイルサイズ: 12-20MB

**代替案（却下）:**
- 初回起動時にダウンロード: ネットワーク依存、初回起動が遅い
- クラウドストレージから動的取得: 複雑、オフライン不可

---

### 2. パッケージの選定

#### iOS/Android: ✅ `tflite_flutter`

**決定理由:**
- TensorFlow Lite公式推奨パッケージ
- 活発なメンテナンス
- 豊富なドキュメントとサンプル

**バージョン:**
- `tflite_flutter: ^0.10.4`（最新安定版）

#### Web: ✅ `tflite_flutter_web`（優先）または `tensorflow_js`

**決定理由:**
- `tflite_flutter_web`: tflite_flutterと同じAPIで統一可能
- `tensorflow_js`: フォールバック用（より柔軟だが実装が異なる）

**実装方針:**
- まず`tflite_flutter_web`を試す
- 問題があれば`tensorflow_js`にフォールバック

**バージョン:**
- `tflite_flutter_web: ^0.10.0`（優先）
- `tensorflow_js: ^0.5.0`（フォールバック）

---

### 3. モデルファイルの形式

#### 決定: ✅ `.tflite`形式

**理由:**
- EfficientDet-Lite2はTensorFlow Lite形式で提供
- `tflite_flutter`が直接サポート
- 変換不要

**モデル取得先:**
- TensorFlow Hub: `https://tfhub.dev/tensorflow/lite-model/efficientdet/lite2/detection/default/1`
- または、TensorFlow Model Zooからダウンロード

**注意事項:**
- COCOデータセットで学習済みのモデルを使用
- カスタムモデルは将来の拡張として検討

---

### 4. 画像前処理の仕様

#### リサイズサイズ: ✅ 320x320（EfficientDet-Lite2の推奨入力サイズ）

**理由:**
- EfficientDet-Lite2の標準入力サイズ
- バランスの取れた精度と速度
- メモリ使用量が適切

**代替案（却下）:**
- 640x640: 精度向上するが速度低下、メモリ消費増加
- 256x256: 速度向上するが精度低下

#### 正規化方法: ✅ 0-255の値を0.0-1.0に正規化

**実装:**
```dart
// 画像を320x320にリサイズ
// RGB値を0-255から0.0-1.0に正規化
final normalizedImage = imageBytes.map((b) => b / 255.0).toList();
```

**理由:**
- EfficientDet-Lite2の標準前処理
- TensorFlow Liteの推奨方法

#### 画像フォーマット: ✅ RGB（3チャンネル）

**理由:**
- EfficientDet-Lite2の標準入力
- カメラからの画像は通常RGB形式

---

### 5. 検出結果の後処理

#### NMS（Non-Maximum Suppression）: ✅ 実装する

**理由:**
- 同じ物体が複数検出されるのを防ぐ
- 精度向上に必須

**実装方針:**
- IoU閾値: 0.5（標準値）
- 信頼度閾値: 0.5（NMS前のフィルタリング）

#### 信頼度フィルタリング: ✅ 0.7以上のみ有効化（既存実装を維持）

**理由:**
- 既存の`DetectionProcessor`で実装済み
- APP_OVERVIEW.mdの要件と一致

**実装場所:**
- `DetectionProcessor.processImage()`で既に実装済み

#### 検出結果の最大数: ✅ 10個まで

**理由:**
- 1フレームで検出される物体は通常10個以下
- メモリ使用量とパフォーマンスのバランス

---

### 6. エラーハンドリング方針

#### モデル読み込み失敗: ✅ エラーログ出力 + falseを返す

**実装:**
```dart
try {
  _interpreter = await Interpreter.fromAsset('models/efficientdet_lite2.tflite');
  return true;
} catch (e, stackTrace) {
  LogMk.logError('モデル読み込み失敗: $e', tag: 'TensorFlowLiteDetectionService', stackTrace: stackTrace);
  return false;
}
```

#### 検出処理失敗: ✅ nullを返す + エラーログ出力

**実装:**
- `DetectionService.detect()`で例外をキャッチ
- エラーログを出力
- nullまたは空リストを返す

#### フォールバック処理: ✅ 検出失敗時は`nothingDetected`を返す

**理由:**
- アプリがクラッシュしないようにする
- ユーザー体験を損なわない

---

### 7. パフォーマンス最適化の方針

#### 画像前処理の最適化: ✅ 非同期処理 + メモリプール

**実装:**
- `compute()`関数を使用して別スレッドで前処理
- 画像バッファの再利用（メモリプール）

#### 検出処理の非同期化: ✅ Future/asyncで実装

**理由:**
- UIスレッドをブロックしない
- 既存の`DetectionService.detect()`が`Future`を返す

#### フレームスキップ: ✅ 省電力モードで5秒間隔、通常モードで可能な限り高速

**実装:**
- `DetectionController`で既に実装済み
- タイマーまたはストリームで制御

#### メモリ管理: ✅ 検出処理後のメモリ解放

**実装:**
- `dispose()`メソッドで確実にリソースを解放
- 画像バッファの適切な管理

---

### 8. Web対応の方針

#### 実装アプローチ: ✅ プラットフォーム別に実装クラスを分ける

**ファイル構成:**
```
lib/feature/tracking/detection/
├── detection_service.dart              # 抽象クラス（既存）
├── tensorflow_lite_detection_service.dart  # iOS/Android用
├── tensorflow_js_detection_service.dart    # Web用
└── detection_service_factory.dart         # ファクトリー
```

**ファクトリー実装:**
```dart
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

#### Web用モデル: ✅ TensorFlow.js形式に変換

**変換方法:**
- TensorFlow LiteモデルをTensorFlow.js形式に変換
- `tensorflowjs_converter`を使用

**モデル配置:**
- `assets/models/efficientdet_lite2_web/` に配置
- 複数ファイル（model.json + バイナリファイル）になる可能性

---

### 9. モデルファイルの配布方法

#### 決定: ✅ アプリに同梱（Git LFSで管理）

**理由:**
- オフライン動作が可能
- 初回起動が速い
- バージョン管理が容易

**Git管理:**
- モデルファイルは大きいため、Git LFSを使用
- `.gitattributes`に設定を追加

**代替案（将来検討）:**
- 初回起動時にダウンロード（オプション）
- モデル更新の配布

---

### 10. デバッグ・ログ出力の方針

#### ログレベル: ✅ エラーのみ出力（本番環境）

**実装:**
- `LogMk.logError()`のみ使用
- デバッグログは開発時のみ有効化

**理由:**
- パフォーマンスへの影響を最小化
- ログの大量出力を防ぐ

#### デバッグモード: ✅ 開発時のみ詳細ログを出力

**実装:**
- 環境変数やフラグで制御
- 検出結果の詳細をログ出力（開発時のみ）

---

### 11. COCOラベルマッピング

#### 決定: ✅ 既存の`DetectionProcessor._mapToCategory()`を拡張

**COCOラベル → カテゴリマッピング:**

| COCOラベルID | COCOラベル名 | カテゴリ |
|-------------|------------|---------|
| 0 | person | personOnly |
| 64 | book | study |
| 65 | clock | - (無視) |
| 66 | vase | - (無視) |
| 67 | scissors | - (無視) |
| 68 | teddy bear | - (無視) |
| 69 | hair drier | - (無視) |
| 70 | toothbrush | - (無視) |
| 73 | laptop | pc |
| 74 | mouse | pc |
| 75 | remote | - (無視) |
| 76 | keyboard | pc |
| 77 | cell phone | smartphone |

**実装:**
- COCOラベルIDからラベル名へのマッピングテーブルを作成
- 既存の`_mapToCategory()`メソッドを拡張

---

### 12. 検出タイミングの制御

#### 省電力モード（デフォルト）: ✅ 5秒間隔

**実装:**
- `DetectionController`で既に実装済み
- `Timer.periodic(Duration(seconds: 5))`を使用

#### 通常モード: ✅ 可能な限り高速（フレームレート制限なし）

**実装:**
- カメラストリームから直接フレームを取得
- 検出処理が完了するまで次のフレームを待機

**注意事項:**
- EfficientDet-Lite2は20-30 FPS程度の性能
- バッテリー消費が増加することを警告表示

---

### 13. モデル初期化のタイミング

#### 決定: ✅ トラッキング開始時に遅延読み込み

**実装:**
- `DetectionController.start()`で`DetectionService.initialize()`を呼び出す
- 初期化中はローディング表示

**理由:**
- アプリ起動時のメモリ使用量を削減
- 必要な時だけモデルを読み込む

**代替案（却下）:**
- アプリ起動時に読み込み: メモリ使用量が増加、起動が遅い

---

### 14. メモリ管理

#### モデルキャッシュ: ✅ 一度読み込んだモデルはメモリに保持

**理由:**
- 再読み込みのオーバーヘッドを避ける
- トラッキング中はモデルを保持

#### 画像バッファ: ✅ 検出処理後に即座に解放

**実装:**
- 検出処理が完了したら画像バッファを解放
- メモリリークを防ぐ

---

### 15. パフォーマンス監視

#### 実装: ✅ 検出処理時間を計測（開発時のみ）

**実装:**
```dart
final stopwatch = Stopwatch()..start();
final results = await _detectionService.detect(imageBytes);
stopwatch.stop();
if (kDebugMode) {
  LogMk.logDebug('検出処理時間: ${stopwatch.elapsedMilliseconds}ms');
}
```

**理由:**
- パフォーマンスボトルネックの特定
- 最適化の効果測定

---

### 16. テスト方針

#### 単体テスト: ✅ DetectionServiceの各メソッドをテスト

**テスト項目:**
- モデル初期化の成功/失敗
- 検出処理の正常系/異常系
- エラーハンドリング

#### 統合テスト: ✅ 実際のカメラ画像での検出テスト

**テスト項目:**
- 本、PC、スマホ、人の検出精度
- 信頼度0.7以上の検出率
- パフォーマンス（FPS、メモリ使用量）

---

## 実装順序

1. **Phase 1**: モデルファイルの準備・配置
2. **Phase 2**: `tflite_flutter`パッケージの統合（iOS/Android）
3. **Phase 3**: `TensorFlowLiteDetectionService`の実装
4. **Phase 4**: 画像前処理の実装
5. **Phase 5**: 検出結果の後処理（NMS）実装
6. **Phase 6**: エラーハンドリングの実装
7. **Phase 7**: パフォーマンス最適化
8. **Phase 8**: Web対応（`tflite_flutter_web`または`tensorflow_js`）
9. **Phase 9**: テスト・デバッグ

---

## 依存関係の追加

### pubspec.yamlに追加するパッケージ

```yaml
dependencies:
  # TensorFlow Lite（iOS/Android）
  tflite_flutter: ^0.10.4
  
  # TensorFlow.js（Web用、フォールバック）
  tensorflow_js: ^0.5.0
  
  # 画像処理（必要に応じて）
  image: ^4.1.3

dev_dependencies:
  # テスト（必要に応じて）
  flutter_test:
    sdk: flutter
```

---

## 参考リンク

- [TensorFlow Lite公式ドキュメント](https://www.tensorflow.org/lite)
- [tflite_flutterパッケージ](https://pub.dev/packages/tflite_flutter)
- [EfficientDet-Lite2モデル（TensorFlow Hub）](https://tfhub.dev/tensorflow/lite-model/efficientdet/lite2/detection/default/1)
- [COCOデータセット](https://cocodataset.org/)
- [TensorFlow.js公式ドキュメント](https://www.tensorflow.org/js)

---

## 決定事項のまとめ

| 項目 | 決定内容 |
|------|---------|
| モデルファイル配置 | assetsフォルダに同梱 |
| iOS/Androidパッケージ | tflite_flutter ^0.10.4 |
| Webパッケージ | tflite_flutter_web（優先）またはtensorflow_js |
| モデル形式 | .tflite形式 |
| 画像リサイズ | 320x320 |
| 正規化 | 0-255 → 0.0-1.0 |
| NMS | 実装（IoU閾値: 0.5） |
| 信頼度閾値 | 0.7（既存実装を維持） |
| 検出結果最大数 | 10個 |
| エラーハンドリング | ログ出力 + フォールバック |
| モデル初期化 | トラッキング開始時に遅延読み込み |
| 省電力モード | 5秒間隔（デフォルト） |
| 通常モード | 可能な限り高速（オプション） |
| デバッグログ | 開発時のみ有効化 |

