# iOSビルド警告解決のための手動操作手順

このドキュメントは、iOS実機ビルド時に発生する警告を解決するために必要な手動操作手順をまとめています。

## 目次

### 必須の手順
1. [パッケージ更新の反映](#1-パッケージ更新の反映)
2. [ビルドテストと警告確認](#2-ビルドテストと警告確認)
3. [アプリの動作確認](#3-アプリの動作確認)

### オプションの手順（必要に応じて）
4. [キーチェーンアクセス権限の設定](#4-キーチェーンアクセス権限の設定)
5. [Xcodeでの警告設定の確認方法](#5-xcodeでの警告設定の確認方法)
6. [ビルドスクリプトの出力依存関係設定](#6-ビルドスクリプトの出力依存関係設定)
7. [パッケージ更新による破壊的変更への対応](#7-パッケージ更新による破壊的変更への対応)

---

## 必須の手順

### 1. パッケージ更新の反映

以下のパッケージが最新版に更新されました：

- `google_mobile_ads`: `^5.1.0` → `^6.0.0` (メジャーアップデート)
- `firebase_core`: `^4.2.0` → `^4.2.1`
- `firebase_auth`: `^6.1.1` → `^6.1.2`
- `cloud_firestore`: `^6.0.3` → `^6.1.0`
- `cloud_functions`: `^6.0.3` → `^6.0.4`
- `firebase_analytics`: `^12.0.3` → `^12.0.4`
- `sign_in_with_apple`: `^6.1.0` → `^7.0.1` (メジャーアップデート)

**手順**:

```bash
cd /Users/ki/Documents/GitHub/web/test_flutter
flutter pub get
cd ios
pod install
cd ..
```

**なぜ`pod install`が必要か**:
- `pubspec.yaml`を更新したため、FlutterプラグインのiOSネイティブコードも更新される可能性があります
- `Podfile`も更新したため、変更を反映する必要があります

### 2. ビルドテストと警告確認

**手順**:

```bash
# ビルドテスト（署名なし）
flutter build ios --release --no-codesign
```

**確認事項**:
- ビルドが成功するか
- 警告の数が減ったか（以前の警告と比較）

### 3. アプリの動作確認

以下の機能をテストしてください：

- **Google Mobile Ads**: 広告の表示が正常に動作するか
- **Firebase認証**: ログイン・ログアウトが正常に動作するか
- **Sign in with Apple**: Appleサインインが正常に動作するか
- **Cloud Firestore**: データの読み書きが正常に動作するか
- **Cloud Functions**: 関数の呼び出しが正常に動作するか

**エラーが発生した場合**:
- メジャーアップデート（`google_mobile_ads` と `sign_in_with_apple`）により、APIの変更が発生している可能性があります
- エラーログを確認し、必要に応じて[パッケージ更新による破壊的変更への対応](#7-パッケージ更新による破壊的変更への対応)を参照してください

---

## オプションの手順（必要に応じて）

### 4. キーチェーンアクセス権限の設定

**いつ必要か**: キーチェーンのダイアログが表示される場合のみ実行してください。

**手順**:

### 1. Xcodeでプロジェクトを開く

```bash
cd /Users/ki/Documents/GitHub/web/test_flutter/ios
open Runner.xcworkspace
```

### 2. ビルド設定の確認

1. **プロジェクトナビゲーター**で「Runner」プロジェクトを選択
2. **「Runner」ターゲット**を選択
3. **「Build Settings」タブ**を選択
4. 検索バーで以下を検索して確認：

   - `CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS`: `NO` に設定されているか
   - `GCC_WARN_DEPRECATED_FUNCTIONS`: `NO` に設定されているか
   - `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER`: `NO` に設定されているか
   - `GCC_WARN_64_TO_32_BIT_CONVERSION`: `NO` に設定されているか

### 3. 警告レベルの確認

1. **「Build Settings」タブ**で検索バーに「warning」と入力
2. 各警告設定が適切に設定されているか確認
3. 必要に応じて手動で調整

---

## キーチェーンアクセス権限の設定

1. **キーチェーンアクセスアプリを開く**
   - **アプリケーション** > **ユーティリティ** > **キーチェーンアクセス.app**
   - または Spotlight（⌘ + スペース）で「キーチェーン」と検索

2. **証明書の検索**
   - 左側のサイドバーで**「ログイン」**を選択
   - 左下の「分類」で**「証明書」**または**「自分の証明書」**を選択
   - 右上の検索ボックスに **「KOI ITO」** と入力

3. **証明書のアクセス制御設定**
   - 表示される証明書（例：「Apple Development: KOI ITO」や「Apple Distribution: KOI ITO」）を**ダブルクリック**
   - 証明書の情報ウィンドウが開きます
   - **「アクセス制御」タブ**をクリック
   - **「すべてのアプリケーションにこの項目へのアクセスを許可」**を選択
   - ウィンドウを閉じる際にパスワードの入力を求められたら、Macのログインパスワードを入力

4. **プライベートキーのアクセス制御設定**
   - 左下の「分類」で**「鍵」**（キー）を選択
   - 「KOI ITO」に関連するプライベートキーを探す
   - プライベートキーを**ダブルクリック**
   - **「アクセス制御」タブ**をクリック
   - **「すべてのアプリケーションにこの項目へのアクセスを許可」**を選択
   - 変更を保存

5. **確認**
   - 設定後、Xcodeでビルドを実行
   - キーチェーンのダイアログが表示されなくなったことを確認

### 5. Xcodeでの警告設定の確認方法

**いつ必要か**: 警告が残る場合のみ確認してください。通常は自動設定済みです。

**手順**:

1. **Xcodeでプロジェクトを開く**
   ```bash
   cd /Users/ki/Documents/GitHub/web/test_flutter/ios
   open Runner.xcworkspace
   ```

2. **ビルド設定の確認**
   - **プロジェクトナビゲーター**で「Runner」プロジェクトを選択
   - **「Runner」ターゲット**を選択
   - **「Build Settings」タブ**を選択
   - 検索バーで以下を検索して確認：
     - `CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS`: `NO` に設定されているか
     - `GCC_WARN_DEPRECATED_FUNCTIONS`: `NO` に設定されているか
     - `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER`: `NO` に設定されているか
     - `GCC_WARN_64_TO_32_BIT_CONVERSION`: `NO` に設定されているか

3. **警告レベルの確認**
   - **「Build Settings」タブ**で検索バーに「warning」と入力
   - 各警告設定が適切に設定されているか確認
   - 必要に応じて手動で調整

### 6. ビルドスクリプトの出力依存関係設定

**いつ必要か**: 「Create Symlinks to Header Folders」の警告が残る場合のみ実行してください。通常はPodfileで自動設定済みです。

**手順**:

1. **Xcodeでプロジェクトを開く**
   ```bash
   cd /Users/ki/Documents/GitHub/web/test_flutter/ios
   open Runner.xcworkspace
   ```

2. **Podsプロジェクトの設定**
   - **プロジェクトナビゲーター**で「Pods」プロジェクトを展開
   - 警告が発生しているターゲット（例：`BoringSSL-GRPC`、`gRPC-C++`、`gRPC-Core`）を選択
   - **「Build Phases」タブ**を選択
   - **「Create Symlinks to Header Folders」**スクリプトを探す
   - スクリプトを展開し、**「Output Files」**セクションに以下を追加：
     ```
     $(DERIVED_FILE_DIR)/symlinks_created
     ```
   - **「Based on dependency analysis」**のチェックを外す（オプション）

3. **確認**
   - ビルドを実行して警告が消えたか確認

### 7. パッケージ更新による破壊的変更への対応

### `google_mobile_ads` v6.0.0 への更新

**主な変更点**:
- `FLTMediationNetworkExtrasProvider`が非推奨になり、`mediationExtras`を使用するように変更

**確認事項**:
- 広告の表示が正常に動作するか
- メディエーションネットワークの設定が正しく動作するか

**対応方法**:
- コード内で`FLTMediationNetworkExtrasProvider`を使用している場合は、新しいAPIに置き換え

### `sign_in_with_apple` v7.0.1 への更新

**主な変更点**:
- Switch文の網羅性チェックが強化
- エラーハンドリングの改善

**確認事項**:
- Appleサインインが正常に動作するか
- エラーハンドリングが正しく動作するか

**対応方法**:
- エラーハンドリングのコードを確認し、新しいエラーケースに対応

---

---

## トラブルシューティング

### ビルドエラーが発生する場合

1. **クリーンビルドを実行**:
   ```bash
   flutter clean
   cd ios
   rm -rf Pods/ Podfile.lock
   pod install
   cd ..
   ```

2. **XcodeのDerivedDataを削除**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Xcodeを再起動**

### 警告が残る場合

- 一部の警告は依存パッケージ側の問題のため、完全に抑制できない場合があります
- 警告はビルドを妨げませんが、パッケージの更新を待つか、パッケージの開発者に報告してください

### パッケージの互換性問題

- メジャーアップデートにより、他のパッケージとの互換性に問題が発生する可能性があります
- 問題が発生した場合は、`pubspec.yaml`でバージョンを一時的に戻すことを検討してください

---

## 参考リンク

- [Google Mobile Ads Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Sign in with Apple Flutter Plugin](https://pub.dev/packages/sign_in_with_apple)
- [CocoaPods Documentation](https://guides.cocoapods.org/)

