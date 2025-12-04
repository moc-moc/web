# 第2段階サブスクリプション実装ガイド

本ドキュメントは、第2段階で追加された決済・検証フローを本番運用するためのセットアップ手順をまとめたものです。アプリは iOS/Android では in_app_purchase、Web では Stripe Checkout/Billing Portal を使用し、Cloud Functions がレシート検証と同期を担います。

---

## 1. アプリストア側の準備

### App Store Connect
1. **App Store Connect > My Apps > 対象アプリ** を開く。
2. 「サブスクリプション」セクションで以下の Product ID を作成  
   - `weekly_premium`, `monthly_premium`, `yearly_premium`, `lifetime_premium`（命名は Firebase `plans/{planId}.productIds.ios` と一致させる）
3. それぞれに「7日間の無料トライアル」と「初回 50%OFF」の価格設定を付与する。  
   - トライアル/プロモ価格は App Store 側で管理する。
4. サンドボックステスターを作成し、テスト端末でサインインしておく。

### Google Play Console
1. **Play Console > 定期購入**で同一 Product ID を作成（Firebase 側と一致させる）。
2. ベネフィット、価格、無料トライアル（7日）、初回割引（50%）を設定。
3. ライセンステスターを追加して動作確認用アカウントを登録。

---

## 2. Stripe の準備 (Web 決済)

**詳細な手順は `docs/stripe_web_setup_guide.md` を参照してください。**

### 概要

1. Stripe ダッシュボードでアカウントを作成し、テストモードに切り替える
2. Products（Weekly/Monthly/Yearly/Lifetime）を作成
3. API キー (Secret) と Webhook Signing Secret を取得
4. Billing Portal を有効化し、キャンセル/プラン変更を許可
5. Webhook エンドポイントを追加（`checkout.session.completed`, `invoice.paid`, `customer.subscription.deleted`）
6. Cloud Functions の環境変数を設定
7. Firestore の `plans` コレクションにプラン情報を登録

**初心者の方は、上記の詳細ガイド（`stripe_web_setup_guide.md`）を参照して、ステップバイステップで進めてください。**

---

## 3. Firebase / Cloud Functions

1. `functions/env.example` をコピーして `functions/.env` を作成。
   ```env
   STRIPE_SECRET_KEY=sk_live_xxx
   STRIPE_WEBHOOK_SECRET=whsec_xxx
   APPLE_SHARED_SECRET=xxxx
   GOOGLE_SERVICE_ACCOUNT_BASE64=<ServiceAccount JSON を Base64 でエンコード>
   ```
2. `cd functions && npm install` を実行し依存関係を取得。
3. `npm run build` で TypeScript をコンパイルし、`firebase deploy --only functions` でデプロイ。
4. Firestore の `plans/{planId}` ドキュメントに以下フィールドを用意
   ```jsonc
   {
     "displayName": "Monthly",
     "interval": "monthly",
     "prices": {
       "JPY": { "amount": 980, "introductoryAmount": 490 },
       "USD": { "amount": 9800, "introductoryAmount": 4900 }
     },
     "productIds": {
       "ios": "monthly_premium_ios",
       "android": "monthly_premium_android"
     },
     "supportsTrial": true,
     "trialDays": 7,
     "promo": { "discountRate": 0.5, "label": "50% OFF" }
   }
   ```

---

## 4. アプリ側の設定

1. `pubspec.yaml` の依存関係を取得済み (`flutter pub get`) にする。
2. iOS/Android でアプリ内課金を行うため、Xcode/Gradle プロジェクト側で IAP/Billing の権限が有効になっていることを確認。
3. Flutter Web ビルドでは Stripe Checkout に遷移するため、ホストドメインを Stripe Dashboard の `success_url/cancel_url` と一致させる。
4. `functions/env.example` を更新した場合は再デプロイし、`firebase.json` の functions 設定が最新であることを確認。

---

## 5. テスト手順

1. `docs/subscription_test_plan.md` の各ケースに従って手動テストを実施。
2. 端末別のポイント
   - **iOS/Android**: サンドボックス用 Apple ID / ライセンステスターで購入 → Cloud Functions の `verifyAppleReceipt` / `verifyGooglePlayReceipt` が呼ばれること。
   - **Web (Stripe)**: Checkout → Webhook で Firestore `users/{uid}.subscription` が更新されることを確認。
   - **キャンセル**: Web は Billing Portal、モバイルは各ストアのサブスク管理画面に遷移すること。
3. `subscription_sync_service` の「最新の状態を同期」ボタンで、Cloud Functions `syncSubscriptionStatus` が成功すること。

---

以上で、第2段階サブスク機能を本番に導入するための基本セットアップは完了です。必要に応じて新しいプランやキャンペーンの値を Firestore `plans/{planId}` に追加し、アプリ側はリモート定義を自動的に取得します。

