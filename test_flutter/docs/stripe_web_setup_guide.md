# Stripe Web決済セットアップ完全ガイド

このドキュメントでは、Web決済（Stripe）を動作させるための詳細な手順を、初心者でも理解できるようにステップバイステップで説明します。

---

## 前提条件

- Firebase プロジェクトが作成済みであること
- Cloud Functions が有効化されていること
- Firestore データベースが作成済みであること

---

## ステップ1: Stripeアカウントの作成とテストモード設定

### 1-1. Stripeアカウントの作成

1. ブラウザで [https://stripe.com/jp](https://stripe.com/jp) にアクセスします
2. 右上の「アカウントを作成」ボタンをクリックします
3. メールアドレス、パスワード、会社名などを入力してアカウントを作成します
4. メール認証を完了します

### 1-2. テストモードに切り替え

1. Stripeダッシュボードにログインします
2. 画面右上の「**テストモード**」というトグルスイッチを確認します
   - **重要**: 開発中は必ず「テストモード」がONになっていることを確認してください
   - テストモードでは実際の決済は発生せず、テスト用のカード番号を使用できます

---

## ステップ2: Products（商品）の作成

Stripeでは、まず「Product（商品）」を作成し、その後に「Price（価格）」を設定します。

### 2-1. Weeklyプランの作成

1. Stripeダッシュボードの左メニューから「**製品**」をクリックします
2. 右上の「**製品を追加**」ボタンをクリックします
3. 以下の情報を入力します：
   - **名前**: `Weekly Premium`
   - **説明**: `週間プレミアムプラン`（任意）
4. 「**保存**」をクリックします
5. 作成されたProductのページで、**「価格を追加」**ボタンをクリックします
6. 価格設定画面で以下を入力します：
   - **価格**: `980`（円）
   - **通貨**: `JPY`（日本円）
   - **請求頻度**: `週次` を選択
   - **価格タイプ**: `定期` を選択
7. 「**価格を追加**」をクリックして保存します
8. 同様に、USDとEURの価格も追加します：
   - **USD**: `9.80`（ドル）、通貨: `USD`、請求頻度: `週次`
   - **EUR**: `8.50`（ユーロ）、通貨: `EUR`、請求頻度: `週次`
9. 各価格の**Price ID**（`price_xxxxx`という形式）をメモしておきます

### 2-2. Monthlyプランの作成

1. 同様に「製品を追加」から以下を作成します：
   - **名前**: `Monthly Premium`
   - **説明**: `月間プレミアムプラン`
2. 価格を追加します：
   - **JPY**: `980`円、請求頻度: `月次`
   - **USD**: `9.80`ドル、請求頻度: `月次`
   - **EUR**: `8.50`ユーロ、請求頻度: `月次`
3. 各Price IDをメモします

### 2-3. Yearlyプランの作成

1. 「製品を追加」から以下を作成：
   - **名前**: `Yearly Premium`
   - **説明**: `年間プレミアムプラン`
2. 価格を追加：
   - **JPY**: `9800`円、請求頻度: `年次`
   - **USD**: `98.00`ドル、請求頻度: `年次`
   - **EUR**: `85.00`ユーロ、請求頻度: `年次`
3. 各Price IDをメモします

### 2-4. Lifetimeプランの作成

1. 「製品を追加」から以下を作成：
   - **名前**: `Lifetime Premium`
   - **説明**: `買い切りプレミアムプラン`
2. 価格を追加：
   - **価格タイプ**: `一回限り` を選択（定期ではない）
   - **JPY**: `24800`円
   - **USD**: `248.00`ドル
   - **EUR**: `215.00`ユーロ
3. 各Price IDをメモします

**重要**: ここで発行された**Price ID（`price_xxxxx`）はCloud Functionsでそのまま利用**します。Firestoreのプラン情報にもPrice IDを保存し、Checkoutセッション作成時にQuickstart推奨の「事前作成したPriceを参照する方式」で決済を行います。

---

## ステップ3: APIキーの取得

### 3-1. シークレットキーの取得

1. Stripeダッシュボードの左メニューから「**開発者**」→「**API キー**」をクリックします
2. 「**シークレットキーを表示**」ボタンをクリックします
3. 表示されたキー（`sk_test_xxxxx`という形式）をコピーします
   - **重要**: このキーは他人に知られないようにしてください
   - テストモードのキーは `sk_test_` で始まります
   - 本番モードのキーは `sk_live_` で始まります

### 3-2. 公開可能キーの確認（参考）

- 公開可能キー（`pk_test_xxxxx`）も表示されますが、Web決済では使用しません
- Cloud Functions側でシークレットキーを使用します

---

## ステップ3.5: Stripe Billing Quickstartの反映

Stripe公式の[Billing Quickstart](https://docs.stripe.com/billing/quickstart)に沿って、Checkoutを使った継続課金のベース設定を完了させます。

1. Stripeダッシュボードで**Billingを有効化**し、「構築済みの決済フォーム（Checkout）」を選択
2. プロダクトとPriceを作成し（ステップ2で実施済み）、**Price IDを控える**
3. Sandboxでテスト用サブスクリプションを作成し、ダッシュボード（例: `https://dashboard.stripe.com/.../subscriptions?status=active`）で状態を確認
4. Quickstart内の「Configure subscription events」に従い、`checkout.session.completed` / `invoice.paid` / `customer.subscription.deleted`の3イベントをWebhookに設定

このステップを完了すると、以降の手順（Webhook設定、Firestore登録、Cloud Functionsのデプロイ）がStripe推奨構成と一致します。

---

## ステップ4: Billing Portal（請求ポータル）の設定

Billing Portalは、ユーザーがサブスクリプションを管理（キャンセル、プラン変更など）するための画面です。

### 4-1. Billing Portalの有効化

1. Stripeダッシュボードの左メニューから「**請求ポータル**」をクリックします
2. 「**請求ポータルを有効化**」ボタンをクリックします
3. 設定画面で以下を確認・設定します：
   - **顧客がキャンセルできる**: ✅ チェックを入れる
   - **顧客がプランを変更できる**: ✅ チェックを入れる
   - **請求ポータルのブランディング**: 必要に応じてロゴや色を設定（任意）
4. 「**保存**」をクリックします

---

## ステップ5: Webhookエンドポイントの設定

Webhookは、StripeからCloud Functionsに決済イベントを通知するための仕組みです。

### 5-1. Cloud Functionsのデプロイ（初回のみ）

まず、WebhookエンドポイントのURLを取得するために、Cloud Functionsを一度デプロイする必要があります。

1. ターミナルでプロジェクトのルートディレクトリに移動します：
   ```bash
   cd /Users/ki/Documents/GitHub/web/test_flutter
   ```

2. `functions`ディレクトリに移動して依存関係をインストールします：
   ```bash
   cd functions
   npm install
   ```

3. TypeScriptをコンパイルします：
   ```bash
   npm run build
   ```

4. Firebase CLIでログインしていることを確認します：
   ```bash
   firebase login
   ```

5. プロジェクトを選択します：
   ```bash
   firebase use --add
   ```
   - プロジェクトIDを選択または入力します（例: `test-flutter-4b625`）

6. **注意**: この時点では環境変数が設定されていないため、エラーが出る可能性がありますが、一旦スキップして続行します

### 5-2. WebhookエンドポイントURLの確認

Cloud Functionsをデプロイすると、以下のようなURLが生成されます：
```
https://<region>-<project-id>.cloudfunctions.net/stripeWebhook
```

例：
```
https://asia-northeast1-test-flutter-4b625.cloudfunctions.net/stripeWebhook
```

**確認方法**:
1. `firebase.json`を確認して、プロジェクトIDを確認します
2. リージョンは通常 `asia-northeast1`（東京）または `us-central1`（米国）です
3. 実際のURLは、次回のデプロイ後にFirebase Consoleで確認できます

### 5-3. StripeダッシュボードでWebhookを追加

1. Stripeダッシュボードの左メニューから「**開発者**」→「**Webhook**」をクリックします
2. 「**エンドポイントを追加**」ボタンをクリックします
3. エンドポイントURLを入力します：
   - 上記で確認したURLを入力します（例: `https://asia-northeast1-test-flutter-4b625.cloudfunctions.net/stripeWebhook`）
4. 「**イベントを選択**」セクションで、以下の3つのイベントを選択します：
   - ✅ `checkout.session.completed` - チェックアウトが完了した時
   - ✅ `invoice.paid` - 請求書が支払われた時
   - ✅ `customer.subscription.deleted` - サブスクリプションがキャンセルされた時
5. 「**エンドポイントを追加**」をクリックします
6. 作成されたWebhookの詳細ページで、「**署名シークレット**」をコピーします
   - `whsec_xxxxx`という形式の文字列です
   - この値は後で環境変数に設定します

---

## ステップ6: Cloud Functionsの環境変数設定

### 6-1. 環境変数ファイルの作成

1. `functions`ディレクトリに移動します：
   ```bash
   cd functions
   ```

2. `env.example`ファイルをコピーして`.env`ファイルを作成します：
   ```bash
   cp env.example .env
   ```

3. `.env`ファイルを開いて、以下のように編集します：
   ```env
   STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxx
   STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx
   APPLE_SHARED_SECRET=
   GOOGLE_SERVICE_ACCOUNT_BASE64=
   ```

   **値の説明**:
   - `STRIPE_SECRET_KEY`: ステップ3-1で取得したシークレットキーを貼り付けます
   - `STRIPE_WEBHOOK_SECRET`: ステップ5-3で取得した署名シークレットを貼り付けます
   - `APPLE_SHARED_SECRET`: iOS決済用（今回は空欄でOK）
   - `GOOGLE_SERVICE_ACCOUNT_BASE64`: Android決済用（今回は空欄でOK）

### 6-2. 環境変数をFirebaseに設定

`.env`ファイルはローカル開発用です。本番環境（Cloud Functions）には、Firebase CLIで環境変数を設定する必要があります。

1. ターミナルで以下を実行します：
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_xxxxxxxxxxxxxxxxxxxxx"
   firebase functions:config:set stripe.webhook_secret="whsec_xxxxxxxxxxxxxxxxxxxxx"
   ```

   **注意**: 実際の値に置き換えてください

2. 設定を確認します：
   ```bash
   firebase functions:config:get
   ```

**重要**: Firebase Functions v2以降では、環境変数の設定方法が異なる場合があります。エラーが出た場合は、Firebase Consoleから直接設定することもできます：
1. Firebase Console → プロジェクトを選択
2. 「Functions」→「設定」→「環境変数」で追加

---

## ステップ7: Firestoreのplansコレクション設定

Firestoreにプラン情報を登録します。アプリはこの情報を読み取って価格を表示します。

### 7-1. Firestore Consoleを開く

1. [Firebase Console](https://console.firebase.google.com/) にアクセスします
2. プロジェクトを選択します
3. 左メニューから「**Firestore Database**」をクリックします

### 7-2. plansコレクションの作成

1. 「**コレクションを開始**」をクリックします
2. コレクションIDに `plans` と入力します
3. ドキュメントIDに `weekly` と入力します
4. 以下のフィールドを追加します（「フィールドを追加」をクリックして追加）：

   **フィールド1**:
   - フィールド名: `displayName`
   - タイプ: `文字列`
   - 値: `Weekly`

   **フィールド2**:
   - フィールド名: `interval`
   - タイプ: `文字列`
   - 値: `weekly`

   **フィールド3**:
   - フィールド名: `prices`
   - タイプ: `マップ`
   - 値: 以下の構造で追加します：
     ```
     prices (マップ)
       ├─ JPY (マップ)
       │   ├─ amount (数値): 980
       │   ├─ introductoryAmount (数値): 490
       │   └─ priceId (文字列): price_xxxxx（Stripeで発行されたID）
       ├─ USD (マップ)
       │   ├─ amount (数値): 980
       │   ├─ introductoryAmount (数値): 490
       │   └─ priceId (文字列): price_xxxxx
       └─ EUR (マップ)
           ├─ amount (数値): 850
           ├─ introductoryAmount (数値): 425
           └─ priceId (文字列): price_xxxxx
     ```

   **フィールド4**:
   - フィールド名: `productIds`
   - タイプ: `マップ`
   - 値: （今回は空のマップでOK、後でiOS/Android用に追加可能）

   **フィールド5**:
   - フィールド名: `supportsTrial`
   - タイプ: `ブール値`
   - 値: `true`

   **フィールド6**:
   - フィールド名: `trialDays`
   - タイプ: `数値`
   - 値: `7`

   **フィールド7**:
   - フィールド名: `promo`
   - タイプ: `マップ`
   - 値:
     ```
     promo (マップ)
       ├─ discountRate (数値): 0.5
       └─ label (文字列): 50% OFF
     ```

5. 「**保存**」をクリックします

### 7-3. 他のプランの作成

同様に、以下のドキュメントIDでプランを作成します：

**`monthly`**:
- `displayName`: `Monthly`
- `interval`: `monthly`
- `prices`: JPY `980` / `490`, USD `980` / `490`, EUR `850` / `425`
- `supportsTrial`: `true`
- `trialDays`: `7`
- `promo`: `discountRate` `0.5`, `label` `50% OFF`

**`yearly`**:
- `displayName`: `Yearly`
- `interval`: `yearly`
- `prices`: JPY `9800` / `4900`, USD `98.00` / `49.00`, EUR `85.00` / `42.50`
- `supportsTrial`: `true`
- `trialDays`: `7`
- `promo`: `discountRate` `0.5`, `label` `50% OFF`

**`lifetime`**:
- `displayName`: `Lifetime`
- `interval`: `lifetime`
- `prices`: JPY `24800` / `12400`, USD `248.00` / `124.00`, EUR `215.00` / `107.50`
- `supportsTrial`: `false`
- `trialDays`: （設定なし）
- `promo`: `discountRate` `0.5`, `label` `50% OFF`

**注意**: 
- `amount`は通常価格（最小通貨単位、例: 980 = ¥980）
- `introductoryAmount`は初回割引価格（50%OFFの場合、通常価格の半分）
- `priceId`にはStripeダッシュボードで取得したIDを入力します
- USDとEURの場合は、小数点以下2桁を考慮してください（例: $9.80 = 980セント）

---

## ステップ8: Cloud Functionsのデプロイ

### 8-1. デプロイの実行

1. `functions`ディレクトリで、TypeScriptをコンパイルします：
   ```bash
   npm run build
   ```

2. エラーがないことを確認します

3. プロジェクトのルートディレクトリに戻ります：
   ```bash
   cd ..
   ```

4. Cloud Functionsをデプロイします：
   ```bash
   firebase deploy --only functions
   ```

5. デプロイが完了するまで待ちます（数分かかることがあります）

6. デプロイが成功すると、以下のようなメッセージが表示されます：
   ```
   ✔  functions[createStripeCheckoutSession(us-central1)] Successful create operation.
   ✔  functions[stripeWebhook(us-central1)] Successful create operation.
   ✔  functions[createStripePortalSession(us-central1)] Successful create operation.
   ```

### 8-2. デプロイ後の確認

1. Firebase Console → 「Functions」を開きます
2. 以下の関数が表示されていることを確認します：
   - `createStripeCheckoutSession`
   - `stripeWebhook`
   - `createStripePortalSession`

---

## ステップ9: アプリ側の設定確認

### 9-1. 依存関係の確認

1. `pubspec.yaml`に以下の依存関係が含まれていることを確認します：
   ```yaml
   dependencies:
     cloud_functions: ^6.0.3
     flutter_stripe: ^12.1.1
     url_launcher: ^6.3.2
   ```

2. 依存関係をインストールします：
   ```bash
   flutter pub get
   ```

### 9-2. Firebase設定の確認

1. `lib/firebase_options.dart`が存在することを確認します
2. Firebaseプロジェクトが正しく設定されていることを確認します

---

## ステップ10: テスト実行

### 10-1. テスト用カード番号

Stripeのテストモードでは、以下のテスト用カード番号を使用できます：

- **成功するカード**: `4242 4242 4242 4242`
- **有効期限**: 未来の日付（例: `12/34`）
- **CVC**: 任意の3桁（例: `123`）
- **郵便番号**: 任意（例: `12345`）

### 10-2. Webアプリでテスト

1. Flutter Webアプリを起動します：
   ```bash
   flutter run -d chrome
   ```

2. アプリでログインします

3. 設定画面から「サブスクリプション」画面に遷移します

4. プランを選択して「購入」ボタンをクリックします

5. Stripe Checkout画面が表示されることを確認します

6. テスト用カード番号を入力して決済を完了します

7. 成功画面にリダイレクトされることを確認します

### 10-3. Firestoreで確認

1. Firebase Console → Firestore Databaseを開きます
2. `users/{uid}`ドキュメントを開きます
3. `subscription`フィールドが更新されていることを確認します：
   ```json
   {
     "planType": "monthly",
     "planId": "monthly",
     "hasPremiumAccess": true,
     "stripeCustomerId": "cus_xxxxx",
     "stripeSubscriptionId": "sub_xxxxx",
     ...
   }
   ```

### 10-4. Webhookの動作確認

1. Stripeダッシュボード → 「開発者」→「Webhook」を開きます
2. 作成したWebhookエンドポイントをクリックします
3. 「**イベント**」タブで、最近のイベントが表示されていることを確認します
4. 各イベントの詳細を確認して、正常に処理されていることを確認します

---

## トラブルシューティング

### エラー: "Stripe is not configured"

**原因**: Cloud Functionsの環境変数が設定されていない

**解決方法**:
1. `firebase functions:config:get`で環境変数を確認
2. 設定されていない場合は、ステップ6-2を再実行

### エラー: "Webhook verification failed"

**原因**: Webhookの署名シークレットが間違っている

**解決方法**:
1. StripeダッシュボードでWebhookの署名シークレットを再確認
2. 環境変数を更新して再デプロイ

### エラー: "Plan not found"

**原因**: Firestoreの`plans`コレクションにプランが登録されていない

**解決方法**:
1. Firestore Consoleで`plans`コレクションを確認
2. ステップ7を再実行してプランを登録

### Checkout画面が表示されない

**原因**: Cloud Functionsのデプロイが失敗している、またはURLが間違っている

**解決方法**:
1. Firebase ConsoleでFunctionsのログを確認
2. `createStripeCheckoutSession`関数が正常にデプロイされているか確認
3. 必要に応じて再デプロイ

---

## 次のステップ

Web決済が動作することを確認したら：

1. **本番環境への移行**:
   - Stripeダッシュボードで「本番モード」に切り替え
   - 本番用のAPIキーを取得して環境変数を更新
   - 本番用のWebhookエンドポイントを追加

2. **iOS/Android決済の追加**:
   - App Store Connect / Google Play Consoleでプランを作成
   - Cloud Functionsの`verifyAppleReceipt` / `verifyGooglePlayReceipt`を実装

3. **エラーハンドリングの強化**:
   - オフライン時のエラーメッセージ
   - レシート検証失敗時の再試行機能

---

以上で、Stripe Web決済のセットアップは完了です！

