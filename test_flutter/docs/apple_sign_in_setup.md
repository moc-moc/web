# Appleサインイン設定メモ

## 1. Apple Developer側の準備
1. Apple DeveloperアカウントでApp ID（iOS/macOS）とService ID（Web/Android用）を作成し、`Sign in with Apple` Capabilityを有効化する。
2. Service IDにはFirebase AuthのリダイレクトURI  
   `https://<project-id>.firebaseapp.com/__/auth/handler` を登録する。
3. Keysメニューで`Sign in with Apple`用の秘密鍵を発行し、Key IDとTeam IDを控えておく。
4. Xcodeで`Runner`ターゲットに`Sign In with Apple` Capabilityを追加（`Runner.entitlements`が自動生成される）。

## 2. Firebase側の設定
1. Firebase Console > Authentication > Sign-in method でAppleを有効化。
2. 以下を入力  
   - `Services ID`（Web用Identifier）  
   - `Apple Team ID`  
   - `Key ID`  
   - アップロードした`p8`秘密鍵ファイル
3. `Authorized domains` に `localhost` や使用するカスタムドメインを追加。
4. `firebase_options.dart` を更新する場合は `flutterfire configure` を再実行。

## 3. Flutterプロジェクト側
### 依存関係
- `pubspec.yaml` に `sign_in_with_apple` / `firebase_auth` / `cloud_firestore` を追加（済）。

### iOS
- Xcodeで`Runner.entitlements`に`com.apple.developer.applesignin`を含める。
- `Info.plist` の `CFBundleURLTypes` にFirebaseのReversed client IDを追加（すでにGoogle Sign-Inを使っている場合は流用可）。
- 実機テスト時はApple IDで「メールを非公開」にした場合でもFirebaseユーザーが作成されることを確認。

### Android
- Chrome Custom Tabs経由でWebフローが開く。Firebase Auth設定で入力したService IDのドメインがHTTPSであることを確認。
- `minSdkVersion` は21以上である必要がある（既に満たす）。

### Web
- `firebaseAuth.signInWithPopup(OAuthProvider('apple.com'))` を使用しているため追加のJS SDK設定は不要。
- Firebase Hostingまたは開発ドメインをApple Service IDに登録してから動作確認する。

## 4. Firestore
- サインイン時に `users/{uid}` ドキュメントを自動作成するようにした。既存ルール（`request.auth.uid == userId`）でAppleユーザーもアクセス可。

## 5. テストチェックリスト
- [ ] iOS実機/SimulatorでApple IDにサインインできるか
- [ ] Android端末でブラウザフローが開き、戻ってくるか
- [ ] Webのポップアップがブロックされないか（必要ならブラウザに許可を案内）
- [ ] Firestoreの`users`ドキュメントに`provider: apple.com`が記録されるか
- [ ] 初回サインイン後に`AccountSettings`へメールが同期されるか



以下は、初心者向けに書き直した `docs/apple_sign_in_setup.md` の提案です。必要に応じてファイルに貼り付けてください。

---

# Appleサインイン設定ガイド（初心者向け）

## 1. Apple Developerの準備
1. Apple Developerアカウントにログインし、以下を作成します。  
   - iOS/macOS向けの **App ID**（Bundle IDと同じ）  
   - Web/Android向けの **Service ID**（Sign in with Apple用）
2. どちらのIDも **“Sign in with Apple”** を有効にします。
3. 「Keys」から Sign in with Apple 用の秘密鍵（p8ファイル）を発行し、  
   **Key ID** と **Team ID** を控えます。
4. Xcodeで `Runner` ターゲットに Sign in with Apple Capability を追加します。  
   実行すると `Runner.entitlements` が自動で作成されます。

## 2. Firebaseでの設定
1. Firebaseコンソール → **Authentication → Sign-in method** → Apple を有効化。
2. 以下を入力します。
   - Service ID（Apple Developerで作成したもの）
   - Team ID / Key ID / 秘密鍵（p8ファイル）
3. `Authorized domains` に `localhost` や利用するドメインを追加し、  
   ブラウザ経由の認証でもブロックされないようにします。
4. `firebase_options.dart` を更新する場合は `flutterfire configure` を再実行します。

## 3. Flutterプロジェクト側の準備
### 依存関係
- `pubspec.yaml` に `sign_in_with_apple`, `firebase_auth`, `cloud_firestore` を追加済み。

### iOS
- `Runner.entitlements` に `com.apple.developer.applesignin` が含まれているか確認。
- `Info.plist` の `CFBundleURLTypes` に Firebase の **Reversed client ID** を登録。  
  （Google Sign-In を使っている場合は既存の値を流用可能）
- 実機テストで、Apple IDの「メールを非公開」を選んでも Firebase ユーザーが作成されるか確認します。

### Android
- Sign in with Apple は Chrome Custom Tabs で Webフローを開く方式です。  
  Firebase側で設定した Service ID のドメインがHTTPSになっているか確認してください。
- `minSdkVersion` 21 以上が必要（既に満たしています）。

### Web
- コードでは `OAuthProvider('apple.com')` を使ったポップアップ方式を採用しています。  
  追加のJS SDK設定は不要です。
- Apple Service ID に **Firebase Hosting のドメインや開発用ドメイン** を登録した上で動作テストしてください。

## 4. Firestoreとの連携
- サインインすると `users/{uid}` ドキュメントが自動で作成されます。  
  `provider`, `email`, `displayName`, `photoURL`, `createdAt/updatedAt` などを保存。
- Firestore ルール（`request.auth.uid == userId`）は既存設定のままで Apple ユーザーも利用可能です。

## 5. テストチェックリスト
- [ ] iOS 実機または Simulator で Apple ID サインインができる
- [ ] Android 端末でブラウザ（Chrome Custom Tabs）が開き、アプリに戻れる
- [ ] Web でポップアップがブラウザにブロックされない（必要なら許可を案内）
- [ ] Firestore の `users` コレクションに `provider: apple.com` が記録される
- [ ] 初回サインイン後、AccountSettings にメールアドレスが同期される


現在のファイルを確認し、具体的な手順を追える形に更新します。


[1 tool called]


具体的な操作手順を順を追って示します。以下を `docs/apple_sign_in_setup.md` に置き換えてください。

```markdown
# Appleサインイン設定ガイド（詳細手順）

## 前提条件
- Apple Developerアカウント（有料メンバーシップ）
- Firebaseプロジェクト
- Flutterプロジェクト（既にFirebase設定済み）

---

## ステップ1: Apple Developerでの設定

### 1-1. App IDの作成と設定（iOS/macOS用）

1. [Apple Developer Portal](https://developer.apple.com/account) にログイン
2. 左メニューから **「Certificates, Identifiers & Profiles」** を選択
3. **「Identifiers」** をクリック
4. 左上の **「+」** ボタンをクリック
5. **「App IDs」** を選択して **「Continue」**
6. **「App」** を選択して **「Continue」**
7. 以下を入力：
   - **Description**: アプリ名（例: "My Flutter App"）
   - **Bundle ID**: 既存のBundle IDを選択、または **「Explicit」** を選んで入力（例: `com.example.test_flutter`）
8. **「Capabilities」** で **「Sign In with Apple」** にチェック
9. **「Continue」** → **「Register」** をクリック

### 1-2. Service IDの作成（Web/Android用）

1. **「Identifiers」** 画面で左上の **「+」** をクリック
2. **「Services IDs」** を選択して **「Continue」**
3. 以下を入力：
   - **Description**: サービス名（例: "My App Sign In Service"）
   - **Identifier**: 一意のID（例: `com.example.test_flutter.service`）
4. **「Continue」** → **「Register」** をクリック
5. 作成したService IDをクリック
6. **「Sign In with Apple」** にチェックして **「Configure」**
7. **「Primary App ID」** でステップ1-1で作成したApp IDを選択
8. **「Domains and Subdomains」** に以下を追加：
   - `localhost`（開発用）
   - Firebase Hostingのドメイン（例: `test-flutter-4b625.firebaseapp.com`）
9. **「Return URLs」** に以下を追加：
   ```
   https://test-flutter-4b625.firebaseapp.com/__/auth/handler
   ```
   （`test-flutter-4b625` はあなたのFirebaseプロジェクトIDに置き換えてください）
10. **「Save」** → **「Continue」** → **「Save」**

### 1-3. 秘密鍵（Key）の作成

1. 左メニューから **「Keys」** を選択
2. 左上の **「+」** をクリック
3. **「Key Name」** を入力（例: "Sign In with Apple Key"）
4. **「Sign In with Apple」** にチェック
5. **「Configure」** をクリック
6. **「Primary App ID」** でステップ1-1で作成したApp IDを選択
7. **「Save」** → **「Continue」** → **「Register」**
8. **重要**: **「Download」** をクリックして `.p8` ファイルをダウンロード（再ダウンロード不可）
9. **「Key ID」** をメモ（例: `ABC123DEF4`）
10. 右上のアカウント名をクリックして **「Team ID」** を確認（例: `XYZ9ABCDEF`）

### 1-4. Xcodeでの設定（iOS/macOS）

1. FlutterプロジェクトをXcodeで開く：
   ```bash
   open ios/Runner.xcworkspace
   ```
2. 左側のプロジェクトナビゲーターで **「Runner」** を選択
3. 中央の **「Signing & Capabilities」** タブを選択
4. **「+ Capability」** をクリック
5. **「Sign In with Apple」** を検索して追加
6. これで `ios/Runner/Runner.entitlements` が自動生成されます

---

## ステップ2: Firebase Consoleでの設定

### 2-1. Apple認証プロバイダの有効化

1. [Firebase Console](https://console.firebase.google.com/) にログイン
2. プロジェクトを選択
3. 左メニューから **「Authentication」** を選択
4. **「Sign-in method」** タブをクリック
5. **「Apple」** をクリック
6. 右上のトグルを **「有効」** にする

### 2-2. Apple認証の詳細設定

1. ステップ1-2で作成した **「Services ID」** を入力（例: `com.example.test_flutter.service`）
2. ステップ1-3で確認した **「Apple Team ID」** を入力（例: `XYZ9ABCDEF`）
3. ステップ1-3で確認した **「Key ID」** を入力（例: `ABC123DEF4`）
4. **「秘密鍵」** セクションで、ステップ1-3でダウンロードした `.p8` ファイルをアップロード
5. **「保存」** をクリック

### 2-3. 承認済みドメインの設定

1. **「Authentication」** → **「Settings」** タブ
2. **「承認済みドメイン」** セクションを確認
3. 以下が含まれているか確認（なければ追加）：
   - `localhost`
   - `test-flutter-4b625.firebaseapp.com`（あなたのプロジェクトIDに置き換え）
   - カスタムドメイン（使用する場合）

---

## ステップ3: Flutterプロジェクトの確認

### 3-1. 依存関係の確認

`pubspec.yaml` に以下が含まれているか確認：

```yaml
dependencies:
  sign_in_with_apple: ^6.1.4
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  crypto: ^3.0.6
```

含まれていない場合は追加して、以下を実行：

```bash
flutter pub get
```

### 3-2. iOS設定の確認

1. `ios/Runner/Runner.entitlements` ファイルを開く
2. 以下の内容が含まれているか確認：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

3. `ios/Runner/Info.plist` を開く
4. `CFBundleURLTypes` が存在するか確認（Google Sign-Inを使っている場合は既に存在）
5. 存在しない場合は、以下のように追加：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.451402739791-xxxxx</string>
        </array>
    </dict>
</array>
```

（`xxxxx` の部分は `GoogleService-Info.plist` の `REVERSED_CLIENT_ID` の値）

### 3-3. Android設定の確認

1. `android/app/build.gradle.kts` を開く
2. `minSdkVersion` が21以上であることを確認（既に満たしているはず）

### 3-4. Web設定の確認

特に追加設定は不要です。コードで `OAuthProvider('apple.com')` を使用しているため、自動的にポップアップ方式で動作します。

---

## ステップ4: 動作確認

### 4-1. iOSでのテスト

1. 実機またはシミュレーターでアプリを起動：
   ```bash
   flutter run -d <device-id>
   ```
2. サインイン画面で **「Sign in with Apple」** ボタンをタップ
3. Apple IDの認証画面が表示される
4. Apple IDでログイン
5. **「メールを非公開にする」** を選択しても動作することを確認
6. アプリに戻り、ホーム画面が表示されることを確認

### 4-2. Androidでのテスト

1. Android端末でアプリを起動
2. **「Sign in with Apple」** ボタンをタップ
3. Chrome Custom Tabsが開き、Appleの認証画面が表示される
4. Apple IDでログイン
5. アプリに自動的に戻ることを確認

### 4-3. Webでのテスト

1. Webブラウザでアプリを起動：
   ```bash
   flutter run -d chrome
   ```
2. **「Sign in with Apple」** ボタンをクリック
3. ポップアップがブロックされていないか確認（ブロックされた場合は許可）
4. Apple IDでログイン
5. アプリに戻り、認証が完了することを確認

### 4-4. Firestoreの確認

1. Firebase Console → **「Firestore Database」** を開く
2. `users` コレクションを確認
3. 新しく作成されたドキュメントを開く
4. 以下のフィールドが存在することを確認：
   - `provider: "apple.com"`
   - `email`: メールアドレス（非公開の場合は空の可能性あり）
   - `displayName`: 表示名
   - `createdAt`: 作成日時
   - `updatedAt`: 更新日時

### 4-5. AccountSettingsの確認

1. アプリ内の設定画面を開く
2. アカウント設定でメールアドレスが表示されることを確認
3. Firestoreの `users/{uid}/settings/account_settings` ドキュメントを確認
4. `email` フィールドにメールアドレスが保存されていることを確認

---

## トラブルシューティング

### エラー: "Sign in with Apple is not available"

- **原因**: デバイスがSign in with Appleに対応していない、またはCapabilityが正しく設定されていない
- **解決策**: 
  - iOS 13以上、macOS 10.15以上であることを確認
  - XcodeでCapabilityが正しく追加されているか確認

### エラー: "Invalid client"

- **原因**: Service IDまたはリダイレクトURIが正しく設定されていない
- **解決策**: 
  - Apple Developer PortalでService IDの設定を再確認
  - Firebase ConsoleのService IDが正しいか確認

### エラー: "Invalid key"

- **原因**: 秘密鍵（.p8ファイル）が正しくない、または期限切れ
- **解決策**: 
  - 新しいKeyを作成して再アップロード
  - Key IDが正しいか確認

### Webでポップアップが開かない

- **原因**: ブラウザがポップアップをブロックしている
- **解決策**: 
  - ブラウザの設定でポップアップを許可
  - 開発者ツールのコンソールでエラーを確認

---

## チェックリスト

設定完了後、以下を確認してください：

- [ ] Apple Developer PortalでApp IDとService IDを作成済み
- [ ] Service IDにリダイレクトURIを登録済み
- [ ] 秘密鍵（.p8）をダウンロード済み
- [ ] Key IDとTeam IDをメモ済み
- [ ] XcodeでSign in with Apple Capabilityを追加済み
- [ ] Firebase ConsoleでApple認証を有効化済み
- [ ] Firebase ConsoleにService ID、Team ID、Key ID、秘密鍵を登録済み
- [ ] 承認済みドメインに必要なドメインを追加済み
- [ ] iOS実機/シミュレーターでテスト成功
- [ ] Android端末でテスト成功
- [ ] Webブラウザでテスト成功
- [ ] Firestoreにユーザードキュメントが作成されることを確認
- [ ] AccountSettingsにメールアドレスが同期されることを確認
```

この手順に沿って設定を進めてください。不明点があれば知らせてください。


新しいBundle IDで統一するための具体的な手順です。  
作業前に、現在の設定ファイルのバックアップをおすすめします。

---

## 1. 決めるもの
- **新しい Bundle ID**（例: `com.yourcompany.focusapp`）を確定
- Apple Developer と Firebase で同じIDを使います

---

## 2. Apple Developer ポータルの設定
1. https://developer.apple.com/account → **Certificates, Identifiers & Profiles**
2. **Identifiers > App IDs** で、新Bundle IDの App ID を作成
   - Platform: iOS（必要ならmacOSも）
   - Capabilities: Sign in with Apple を有効化
3. **Identifiers > Services IDs** で、新Bundle IDに紐付ける Service ID を作成 or 修正
   - Primary App ID に新App IDを選択
   - Domains / Return URLs を再確認（`https://<project-id>.firebaseapp.com/__/auth/handler`）
4. **Keys > Sign in with Apple** の秘密鍵（p8）は流用可。Team ID / Key ID はそのまま使えます。

---

## 3. Firebase Console の設定
1. https://console.firebase.google.com → プロジェクト設定（歯車アイコン）
2. **アプリを追加 > iOS** を選択
   - 新Bundle IDを入力
   - ニックネームやApp Store IDは任意
3. 生成された `GoogleService-Info.plist` をダウンロード
4. 同じ画面で「アプリを追加 > macOS」も必要なら登録
5. 既存の旧Bundle IDアプリは「アプリを編集」から分かりやすい名前にし、不要なら削除

---

## 4. Flutterプロジェクト側の更新
1. `ios/Runner/GoogleService-Info.plist` を新しいものに置き換え（macOSも使う場合は `macos/Runner/` にコピー）
2. `ios/Runner.xcodeproj` をXcodeで開き、Runnerターゲットの **Bundle Identifier** を新IDに設定
3. `ios/Runner/Runner.entitlements` はそのままでOK（Bundle IDは自動で参照）
4. `lib/firebase_options.dart` を更新
   - 一番確実なのは `flutterfire configure --platforms=ios,macos` を再実行（既存設定が消えないよう確認）
   - もしくは `FirebaseOptions ios` / `macos` の `iosBundleId` / `appId` などを手動編集
5. `pubspec.yaml` などは変更不要

---

## 5. 認証設定の再確認
1. Firebase Console → Authentication → Sign-in Method → Apple
   - Service ID / Team ID / Key ID / Secret が新Bundle IDに紐付いているか確認
2. `ios/Runner/Info.plist` の `CFBundleURLTypes` に含まれる `REVERSED_CLIENT_ID` が、新しい `GoogleService-Info.plist` 内の値に一致しているか確認

---

## 6. 動作確認
1. XcodeでClean Build Folder → `flutter run -d ios`
2. 新しいBundle IDでアプリがビルドされることを確認
3. Appleサインイン→Firebase Auth→Firestore書き込みをテスト
4. Firebase Console → Authentication → ユーザー一覧で、新Bundle IDでも問題なく作成されることを確認
5. Firestoreの `users/{uid}` にデータが保存されるかチェック

---

## 7. 旧Bundle IDの後処理（任意）
- Apple Developer Portalで旧App IDやService IDを削除または無効化
- Firebase Consoleで旧Bundle IDのアプリを削除（履歴を残したい場合はそのままでも可）
- Gitで `GoogleService-Info.plist` の差分をコミット

---

この手順で、新しいBundle IDに統一できます。不明点があれば教えてください。