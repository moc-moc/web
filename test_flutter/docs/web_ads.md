# Flutter Web での広告掲載方法（Google AdSense）

Google Mobile Ads プラグインは Web をサポートしていないため、Web版は **Google AdSense** を直接組み込みます。  
このドキュメントでは、AdSenseアカウントの作成から実装まで、初心者でも迷わないよう手順を詳しく説明します。

---

## 目次
1. [AdSenseアカウントの作成](#1-adsenseアカウントの作成)
2. [サイトの追加と審査](#2-サイトの追加と審査)
3. [広告ユニットの作成](#3-広告ユニットの作成)
4. [Flutter Webへの実装](#4-flutter-webへの実装)
5. [収益の確認方法](#5-収益の確認方法)
6. [トラブルシューティング](#6-トラブルシューティング)

---

## 1. AdSenseアカウントの作成

### 1-1. アカウント作成
1. [Google AdSense](https://www.google.com/adsense/) にアクセス
2. **「今すぐ始める」** をクリック
3. Googleアカウントでログイン（業務用アカウント推奨）
4. 利用規約を読み、**「同意する」** をクリック

### 1-2. 初期設定
1. **国・地域** を選択（日本を選択）
2. **支払い方法** を選択
   - **銀行口座** を推奨（振込手数料が安い）
   - 口座情報は後からでも設定可能
3. **「次へ」** をクリック

> **重要**: 支払い情報を設定しないと、収益が蓄積されても送金されません。必ず設定してください。

---

## 2. サイトの追加と審査

### 2-1. サイトを追加
1. AdSenseダッシュボードの左メニューから **「サイト」** をクリック
2. **「サイトを追加」** ボタンをクリック
3. **サイトのURL** を入力
   - 例: `https://your-app-domain.com`
   - 開発中でも、公開されているURLが必要です
4. **「続行」** をクリック

### 2-2. サイトの確認コードを追加
AdSenseから **サイト確認コード** が表示されます。これをWebサイトに追加する必要があります。

#### Flutter Webの場合
1. `web/index.html` を開く
2. `<head>` タグ内に確認コードを追加
   ```html
   <head>
     <!-- 既存のコード -->
     
     <!-- AdSenseサイト確認コード -->
     <meta name="google-adsense-account" content="ca-pub-xxxxxxxx">
   </head>
   ```
3. 変更を保存し、Webサイトをデプロイ

### 2-3. 審査の申請
1. AdSenseダッシュボードに戻る
2. **「サイトを確認」** ボタンをクリック
3. 審査が開始されます（通常 **1〜2週間** かかります）

### 2-4. 審査通過の確認
- メール通知が届きます
- AdSenseダッシュボードで **「承認済み」** と表示されます
- 審査が通るまで広告は表示されません

> **注意**: 審査中は広告コードを追加しても広告は表示されません。審査通過後に表示されます。

---

## 3. 広告ユニットの作成

### 3-1. 広告ユニットを作成
1. AdSenseダッシュボードの左メニューから **「広告」** → **「広告ユニット」** をクリック
2. **「新しい広告ユニット」** ボタンをクリック
3. 以下の情報を入力：
   - **名前**: わかりやすい名前を付ける（例: `フレンドフィードネイティブ広告`）
   - **広告の種類**: **「表示広告」** を選択
   - **広告サイズ**: **「レスポンシブ」** を推奨（画面サイズに自動調整）
4. **「作成」** をクリック

### 3-2. 広告コードを取得
広告ユニット作成後、以下の情報が表示されます：

- **広告クライアントID**: `ca-pub-xxxxxxxx` の形式
- **広告スロットID**: 数字のみ（例: `1234567890`）

これらをメモしておいてください。

### 3-3. 必要な広告ユニット
このアプリでは以下の3種類の広告ユニットが必要です：

| 用途 | 推奨サイズ | 名前の例 |
|------|-----------|---------|
| フレンドフィード | レスポンシブ（ネイティブ） | `friend_feed_native` |
| トラッキング画面（カメラOFF） | レスポンシブ（ネイティブ） | `tracking_camera_off_native` |
| トラッキング画面（カメラON） | バナー（320x100） | `tracking_camera_on_banner` |

それぞれ同じ手順で作成してください。

---

## 4. Flutter Webへの実装

### 4-1. `web/index.html` にAdSenseスクリプトを追加
1. `web/index.html` を開く
2. `<head>` タグの末尾に以下を追加：

```html
<head>
  <!-- 既存のコード -->
  
  <!-- Google AdSense -->
  <script async 
          src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-xxxxxxxx"
          crossorigin="anonymous"></script>
</head>
```

> **重要**: `ca-pub-xxxxxxxx` の部分を、AdSenseで取得した実際のクライアントIDに置き換えてください。

### 4-2. Widgetに広告ユニットIDを設定

#### フレンドフィードの広告
`lib/presentation/screens/friend/post_cards/friend_native_ad_card.dart` を開き、以下のように修正：

```dart
// Web版の場合はWeb広告Widgetを表示
if (kIsWeb) {
  return const WebNativeAd(
    adClientId: 'ca-pub-xxxxxxxx',  // 実際のクライアントID
    adSlotId: '1234567890',          // フレンドフィード用のスロットID
  );
}
```

#### トラッキング画面の広告
`lib/presentation/screens/tracking/tracking.dart` を開き、以下の2箇所を修正：

**カメラOFF時の広告:**
```dart
if (kIsWeb) {
  return Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: const WebNativeAd(
        height: 280,
        adClientId: 'ca-pub-xxxxxxxx',  // 実際のクライアントID
        adSlotId: '1234567890',          // カメラOFF用のスロットID
      ),
    ),
  );
}
```

**カメラON時のバナー広告:**
```dart
if (kIsWeb) {
  return Container(
    // ... 既存のコード ...
    child: const Center(
      child: WebBannerAd(
        height: 100,
        width: 320,
        adClientId: 'ca-pub-xxxxxxxx',  // 実際のクライアントID
        adSlotId: '0987654321',          // カメラON用のスロットID
      ),
    ),
  );
}
```

### 4-3. 実装済みのWidget
以下のWidgetが既に実装されています：

- `lib/presentation/widgets/web_banner_ad.dart` - バナー広告用
- `lib/presentation/widgets/web_native_ad.dart` - ネイティブ広告用

これらは `adClientId` と `adSlotId` を設定するだけで使用できます。

### 4-4. 動作確認
1. `flutter run -d chrome` でWebアプリを起動
2. ブラウザの開発者ツール（F12）を開く
3. **Console** タブでエラーがないか確認
4. 広告が表示されるか確認

> **注意**: 審査通過前は広告は表示されません。プレースホルダー（「広告を読み込み中...」）が表示されます。

---

## 5. 収益の確認方法

### 5-1. AdSenseダッシュボードで確認
1. [AdSenseダッシュボード](https://www.google.com/adsense/) にログイン
2. トップページに **今日の収益** と **今月の収益** が表示されます
3. 左メニューの **「レポート」** から詳細な統計を確認できます

### 5-2. 支払いの確認
1. 左メニューの **「支払い」** をクリック
2. **支払い閾値**（通常 $100）に達すると、毎月21日頃に送金されます
3. 支払い情報が未設定の場合は、ここで設定してください

### 5-3. 収益の振込先
- **AdSense（Web版）**: AdSenseアカウントに設定した銀行口座に送金
- **AdMob（モバイル版）**: AdMobアカウントに設定した銀行口座に送金

> **重要**: AdSenseとAdMobは別々のアカウントとして管理されます。収益も別々に集計されます。

---

## 6. トラブルシューティング

### 6-1. 広告が表示されない

**原因1: 審査がまだ通っていない**
- 解決策: 審査通過まで待つ（1〜2週間）

**原因2: 広告ユニットIDが間違っている**
- 解決策: `adClientId` と `adSlotId` が正しいか確認

**原因3: スクリプトが読み込まれていない**
- 解決策: `web/index.html` にAdSenseスクリプトが正しく追加されているか確認
- ブラウザの開発者ツール（F12）→ Networkタブで `adsbygoogle.js` が読み込まれているか確認

**原因4: CSP（Content Security Policy）の制限**
- 解決策: CSPを設定している場合、`pagead2.googlesyndication.com` を許可リストに追加

### 6-2. エラーメッセージの確認方法

1. ブラウザの開発者ツール（F12）を開く
2. **Console** タブを確認
3. 以下のようなエラーが出ていないか確認：
   - `adsbygoogle.push() failed` → スクリプトの読み込みに失敗
   - `Invalid ad client` → クライアントIDが間違っている
   - `Invalid ad slot` → スロットIDが間違っている

### 6-3. デバッグモードの有効化

URLに `?google_console=1&google_debug=1` を付けると、詳細なログが表示されます：

```
https://your-app-domain.com/?google_console=1&google_debug=1
```

### 6-4. よくあるエラー

| エラー | 原因 | 解決策 |
|--------|------|--------|
| `adsbygoogle is not defined` | スクリプトが読み込まれていない | `web/index.html` にスクリプトを追加 |
| `Invalid ad client` | クライアントIDが間違っている | AdSenseダッシュボードで正しいIDを確認 |
| `Invalid ad slot` | スロットIDが間違っている | 広告ユニット作成画面で正しいIDを確認 |
| 広告が空白 | 審査が通っていない | 審査通過まで待つ |

---

## 7. 実装例（参考コード）

### 7-1. バナー広告の実装例

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/widgets/web_banner_ad.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // コンテンツ
          Expanded(child: YourContent()),
          
          // バナー広告（Web版のみ）
          if (kIsWeb)
            Padding(
              padding: EdgeInsets.all(16),
              child: WebBannerAd(
                height: 100,
                width: 320,
                adClientId: 'ca-pub-xxxxxxxx',  // 実際のID
                adSlotId: '1234567890',          // 実際のID
              ),
            ),
        ],
      ),
    );
  }
}
```

### 7-2. ネイティブ広告の実装例

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/widgets/web_native_ad.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // コンテンツ1
          YourContent1(),
          
          // ネイティブ広告（Web版のみ）
          if (kIsWeb)
            Padding(
              padding: EdgeInsets.all(16),
              child: WebNativeAd(
                height: 260,
                adClientId: 'ca-pub-xxxxxxxx',  // 実際のID
                adSlotId: '1234567890',          // 実際のID
              ),
            ),
          
          // コンテンツ2
          YourContent2(),
        ],
      ),
    );
  }
}
```

---

## まとめ

1. **AdSenseアカウントを作成** → 支払い情報を設定
2. **サイトを追加** → 審査を申請（1〜2週間）
3. **広告ユニットを作成** → クライアントIDとスロットIDを取得
4. **Flutter Webに実装** → `web/index.html` にスクリプト追加、WidgetにIDを設定
5. **動作確認** → ブラウザの開発者ツールでエラーを確認

これで Web 版にも広告を表示できるようになります！

















プロジェクト構造を確認し、URL設定箇所を特定中です。


[3 tools called]


設定ファイルを確認中です。


[4 tools called]


現在、`test-flutter-4b625.firebaseapp.com` という仮のURLが使われています。カスタムドメインに切り替える手順です。

## カスタムドメイン設定の手順

### ステップ1: ドメインを準備する
- 使用するドメインを用意（例: `example.com` や `app.example.com`）
- ドメインのDNS設定を管理できる状態にする

### ステップ2: Firebase Hostingにカスタムドメインを追加
1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクト `test-flutter-4b625` を選択
3. 左メニューから「Hosting」を選択
4. 「カスタムドメインを追加」をクリック
5. ドメインを入力（例: `app.example.com`）
6. 表示されるDNSレコード（AレコードやCNAME）を控える

### ステップ3: DNS設定を更新
1. ドメインのDNS管理画面を開く
2. Firebaseが示したレコードを追加
   - タイプ: A または CNAME
   - 値: Firebaseが指定した値
3. 反映まで数分〜数時間かかることがあります

### ステップ4: Firebase Authenticationの承認済みドメインを追加
1. Firebase Consoleで「Authentication」を開く
2. 「設定」タブ → 「承認済みドメイン」
3. 「ドメインを追加」をクリック
4. カスタムドメインを追加（例: `app.example.com`）

### ステップ5: Google OAuthのリダイレクトURIを更新
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクト `test-flutter-4b625` を選択
3. 「APIとサービス」→「認証情報」
4. OAuth 2.0 クライアントID（`658668060147-rf2r75ns0qdj2h2sd5176nsaj64asksc`）を開く
5. 「承認済みのリダイレクト URI」に以下を追加:
   - `https://あなたのドメイン.com/__/auth/handler`
   - 例: `https://app.example.com/__/auth/handler`
6. 「保存」をクリック

### ステップ6: Firebase設定を更新（コード側）
`lib/firebase_options.dart` の `authDomain` をカスタムドメインに変更します：

```dart:lib/firebase_options.dart
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBVBVMlfK7jabroCYjgstsrCUam8Mn4so',
    appId: '1:451402739791:web:20142f01659f02b9f0fa3a',
    messagingSenderId: '451402739791',
    projectId: 'test-flutter-4b625',
    authDomain: 'app.example.com', // ← ここを変更（あなたのドメインに）
    storageBucket: 'test-flutter-4b625.firebasestorage.app',
  );
```

同様に、`windows` の設定も更新：

```dart:lib/firebase_options.dart
  static const FirebaseOptions windows = FirebaseOptions(
    // ... existing code ...
    authDomain: 'app.example.com', // ← ここも変更
  );
```

### ステップ7: Stripe Webhook URLを更新（Stripeを使用している場合）
1. [Stripe Dashboard](https://dashboard.stripe.com/) にアクセス
2. 「開発者」→「Webhook」
3. 既存のWebhookを編集
4. エンドポイントURLを新しいドメインに更新:
   - 旧: `https://asia-northeast1-test-flutter-4b625.cloudfunctions.net/stripeWebhook`
   - 新: カスタムドメインを使用する場合は、Cloud FunctionsのURLは変更不要（Firebase Hostingとは別）

### ステップ8: アプリを再ビルド・デプロイ
1. ターミナルで以下を実行:
```bash
flutter build web
firebase deploy --only hosting
```

### ステップ9: 動作確認
1. カスタムドメインでアプリにアクセス
2. Google Sign-Inが正常に動作するか確認
3. 認証フローが問題なく完了するか確認

## 注意点
- DNSの反映には時間がかかることがあります（最大48時間、通常は数時間）
- すべての設定を完了してから再ビルド・デプロイしてください
- 本番環境では、まずテスト環境で動作確認することを推奨します

不明点があれば知らせてください。

















お名前.comでサブドメイン focustracker.locomort.com を作成し、WordPressをそのサブドメインに移動する手順です。
お名前.comでのサブドメイン設定手順
ステップ1: お名前.comの管理画面にログイン
お名前.com にログイン
「ドメイン設定」→「DNS関連機能の設定」を開く
ステップ2: サブドメインのCNAMEレコードを追加
「DNSレコード設定を利用する」を選択
新しいレコードを追加：
タイプ: CNAME
ホスト名: focustracker（または www.focustracker）
値: WordPressがホスティングされているサーバーのホスト名
お名前.comのレンタルサーバーを使っている場合: サーバー情報を確認
他のホスティングサービスを使っている場合: そのサービスのホスト名
TTL: 3600（デフォルトでOK）
「設定する」をクリック
ステップ3: www版も設定する場合
www.focustracker.locomort.com も使いたい場合、追加で設定：
もう1つレコードを追加：
タイプ: CNAME
ホスト名: www.focustracker
値: focustracker.locomort.com（または同じサーバーのホスト名）
TTL: 3600
WordPressの設定変更
ステップ1: WordPressのURLを変更
WordPressの管理画面にログイン
「設定」→「一般設定」を開く
以下のURLを変更：
WordPressアドレス（URL）: https://focustracker.locomort.com
サイトアドレス（URL）: https://focustracker.locomort.com
「変更を保存」をクリック
ステップ2: データベースのURLを更新（必要に応じて）
WordPressのデータベース内の古いURLを新しいURLに一括置換する必要がある場合があります。プラグイン（例: Better Search Replace）を使うか、データベースを直接編集します。
重要な注意点
1. SSL証明書の設定
HTTPSを使う場合は、SSL証明書の設定が必要です
お名前.comのレンタルサーバーを使っている場合、無料SSL（Let's Encrypt）が利用できることがあります
サーバー管理画面でSSL証明書を有効化してください
2. リダイレクトの設定
古いURL（http://www.locomort.com/locomofocustracker/）から新しいURL（https://focustracker.locomort.com）へのリダイレクトを設定することを推奨します。
WordPressの.htaccessファイルに以下を追加：
# 古いURLから新しいURLへのリダイレクトRedirect 301 /locomofocustracker/ https://focustracker.locomort.com/
3. 反映時間
DNS設定の反映には数分〜数時間かかることがあります
最大48時間かかる場合があります
確認方法
ステップ1: DNS設定の確認
ターミナルで以下を実行：
nslookup focustracker.locomort.com
または
dig focustracker.locomort.com
正しいIPアドレスまたはホスト名が表示されればOKです。
ステップ2: ブラウザで確認
https://focustracker.locomort.com にアクセス
WordPressサイトが表示されることを確認
まとめ
お名前.comで focustracker のCNAMEレコードを追加
WordPressのURL設定を新しいサブドメインに変更
SSL証明書を設定（HTTPSを使う場合）
古いURLから新しいURLへのリダイレクトを設定（推奨）
DNS反映を待つ（数分〜数時間）
現在、WordPressはどのホスティングサービスで動いていますか？お名前.comのレンタルサーバーですか？それによって、CNAMEレコードの値が変わります。