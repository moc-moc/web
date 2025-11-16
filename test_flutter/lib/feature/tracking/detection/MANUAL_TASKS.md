# 実装における手動作業リスト

このドキュメントは、AIが自動化できない、ユーザーが手動で行う必要がある作業をまとめています。

---

## ✅ 必須作業（実装前に完了）

### 1. EfficientDet-Lite2モデルファイルのダウンロード

**作業内容:**
- TensorFlow HubからEfficientDet-Lite2モデルをダウンロード

**手順:**
1. 以下のURLからモデルをダウンロード:
   - **TensorFlow Hub**: https://tfhub.dev/tensorflow/lite-model/efficientdet/lite2/detection/default/1
   - または、**TensorFlow Model Zoo**: https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf2_detection_zoo.md

2. ダウンロードしたファイルを確認:
   - ファイル名: `efficientdet_lite2.tflite` または類似の名前
   - ファイルサイズ: 約12-20MB

**注意事項:**
- COCOデータセットで学習済みのモデルを使用すること
- モデルのバージョンを確認（最新版を推奨）

---

### 2. モデルファイルの配置

**作業内容:**
- ダウンロードしたモデルファイルをプロジェクトのassetsフォルダに配置

**手順:**
1. `assets/models/` フォルダを作成（存在しない場合）
   ```bash
   mkdir -p assets/models
   ```

2. ダウンロードしたモデルファイルを `assets/models/efficientdet_lite2.tflite` に配置

3. ファイルの存在を確認:
   ```bash
   ls -lh assets/models/efficientdet_lite2.tflite
   ```

**確認事項:**
- ファイルパスが正しいか
- ファイルサイズが12-20MB程度か

---

### 3. pubspec.yamlへのassets追加

**作業内容:**
- `pubspec.yaml`の`flutter:`セクションにassetsを追加

**手順:**
1. `pubspec.yaml`を開く

2. `flutter:`セクションに以下を追加:
   ```yaml
   flutter:
     uses-material-design: true
     
     assets:
       - assets/models/efficientdet_lite2.tflite
   ```

3. 保存して、`flutter pub get`を実行

**確認事項:**
- YAMLのインデントが正しいか（2スペース）
- `flutter pub get`がエラーなく完了するか

---

### 4. Git LFSの設定（モデルファイルが大きい場合）

**作業内容:**
- モデルファイル（12-20MB）をGit LFSで管理する設定

**手順:**
1. Git LFSがインストールされているか確認:
   ```bash
   git lfs version
   ```
   - インストールされていない場合: https://git-lfs.github.com/ からインストール

2. Git LFSを初期化:
   ```bash
   git lfs install
   ```

3. `.gitattributes`ファイルを作成または編集:
   ```bash
   echo "assets/models/*.tflite filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
   ```

4. モデルファイルをGit LFSに追加:
   ```bash
   git add .gitattributes
   git add assets/models/efficientdet_lite2.tflite
   ```

5. コミット:
   ```bash
   git commit -m "Add EfficientDet-Lite2 model file with Git LFS"
   ```

**注意事項:**
- Git LFSを使用しない場合、モデルファイルはGitに含めない（`.gitignore`に追加）
- その場合、チームメンバーは各自でモデルファイルをダウンロードする必要がある

---

### 5. パッケージの追加

**作業内容:**
- `pubspec.yaml`に必要なパッケージを追加

**手順:**
1. `pubspec.yaml`の`dependencies:`セクションに以下を追加:
   ```yaml
   dependencies:
     # ... 既存のパッケージ ...
     
     # TensorFlow Lite（iOS/Android）
     tflite_flutter: ^0.10.4
     
     # TensorFlow.js（Web用、フォールバック）
     tensorflow_js: ^0.5.0
     
     # 画像処理（必要に応じて）
     image: ^4.1.3
   ```

2. `flutter pub get`を実行:
   ```bash
   flutter pub get
   ```

3. パッケージが正しくインストールされたか確認:
   ```bash
   flutter pub deps
   ```

**確認事項:**
- パッケージのバージョンが正しいか
- 依存関係の競合がないか

---

## ⚠️ オプション作業（Web対応が必要な場合）

### 6. Web用モデルの変換（Web対応が必要な場合）

**作業内容:**
- TensorFlow LiteモデルをTensorFlow.js形式に変換

**手順:**
1. `tensorflowjs_converter`をインストール:
   ```bash
   pip install tensorflowjs
   ```

2. モデルを変換:
   ```bash
   tensorflowjs_converter \
     --input_format=tf_lite \
     --output_format=tfjs_graph_model \
     assets/models/efficientdet_lite2.tflite \
     assets/models/efficientdet_lite2_web/
   ```

3. 変換されたファイルを確認:
   - `model.json`（モデル構造）
   - `*.bin`ファイル（重みデータ）

4. `pubspec.yaml`にWeb用モデルを追加:
   ```yaml
   flutter:
     assets:
       - assets/models/efficientdet_lite2.tflite
       - assets/models/efficientdet_lite2_web/
   ```

**注意事項:**
- Web対応が不要な場合はスキップ可能
- 変換にはPython環境が必要

---

## 🧪 テスト・検証作業（実装後に実施）

### 7. 実機での動作確認

**作業内容:**
- 実際のデバイスで検出機能をテスト

**テスト項目:**
- [ ] モデルが正しく読み込まれるか
- [ ] 本（book）が検出されるか
- [ ] PC（laptop）が検出されるか
- [ ] スマホ（cell phone）が検出されるか
- [ ] 人（person）が検出されるか
- [ ] 信頼度0.7以上の検出が正しく動作するか
- [ ] 省電力モード（5秒間隔）が正しく動作するか
- [ ] 通常モードが正しく動作するか
- [ ] エラーハンドリングが正しく動作するか
- [ ] メモリリークがないか

**テストデバイス:**
- iOS実機（推奨: iPhone 12以降）
- Android実機（推奨: Pixel 5以降）
- Webブラウザ（Chrome、Safari）

---

### 8. パフォーマンステスト

**作業内容:**
- 検出処理のパフォーマンスを測定

**測定項目:**
- 検出処理時間（FPS）
- メモリ使用量
- バッテリー消費量

**測定方法:**
- Flutter DevToolsを使用
- ログ出力で処理時間を計測

**目標値:**
- 検出処理時間: 50ms以下（20 FPS以上）
- メモリ使用量: 100MB以下（モデル読み込み後）
- バッテリー消費: 省電力モードで1時間あたり5%以下

---

### 9. 精度テスト

**作業内容:**
- 検出精度を確認

**テスト項目:**
- [ ] 本、ペン、ノートが正しく「study」カテゴリに分類されるか
- [ ] ラップトップ、キーボード、マウスが正しく「pc」カテゴリに分類されるか
- [ ] スマホが正しく「smartphone」カテゴリに分類されるか
- [ ] 人が正しく「personOnly」カテゴリに分類されるか
- [ ] 誤検出が少ないか（信頼度0.7以上でフィルタリング）

**テスト方法:**
- 実際の机の上に物体を配置して検出テスト
- 複数の角度、照明条件でテスト

---

## 📝 チェックリスト

実装前に以下を確認してください:

- [ ] EfficientDet-Lite2モデルファイルをダウンロード済み
- [ ] モデルファイルを`assets/models/efficientdet_lite2.tflite`に配置済み
- [ ] `pubspec.yaml`にassetsを追加済み
- [ ] Git LFSの設定完了（または`.gitignore`に追加）
- [ ] `pubspec.yaml`にパッケージを追加済み
- [ ] `flutter pub get`がエラーなく完了
- [ ] Web対応が必要な場合、Web用モデルの変換完了

実装後に以下を確認してください:

- [ ] 実機での動作確認完了
- [ ] パフォーマンステスト完了
- [ ] 精度テスト完了
- [ ] エラーハンドリングの動作確認完了

---

## 🔗 参考リンク

- [TensorFlow Hub - EfficientDet-Lite2](https://tfhub.dev/tensorflow/lite-model/efficientdet/lite2/detection/default/1)
- [TensorFlow Model Zoo](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf2_detection_zoo.md)
- [Git LFS公式サイト](https://git-lfs.github.com/)
- [tflite_flutterパッケージ](https://pub.dev/packages/tflite_flutter)
- [TensorFlow.js Converter](https://www.tensorflow.org/js/guide/conversion)

---

## 💡 トラブルシューティング

### モデルファイルが見つからない
- `pubspec.yaml`のassetsパスが正しいか確認
- `flutter clean` → `flutter pub get`を実行
- アプリを再起動

### Git LFSのエラー
- Git LFSが正しくインストールされているか確認
- `.gitattributes`ファイルが正しく設定されているか確認
- `git lfs pull`を実行してモデルファイルを取得

### パッケージの依存関係エラー
- `flutter pub upgrade`を実行
- `pubspec.lock`を削除して`flutter pub get`を再実行

### モデル読み込みエラー
- モデルファイルのパスが正しいか確認
- モデルファイルが破損していないか確認
- モデルのバージョンが正しいか確認

