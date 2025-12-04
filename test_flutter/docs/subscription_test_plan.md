# サブスクリプション機能 手動テスト項目

## 1. 無課金ユーザー
- レポート画面で Day/Week 以外を選択するとロックカードが表示され、サブスク画面へ遷移できること。
- 目標画面で 2 件目を保存しようとするとロックカードが表示され、保存がブロックされること。
- カウントダウンセクション全体がロック表示になり、タップでサブスク画面に飛ぶこと。
- トラッキング画面の省電力ボタンがロック表示になり、タップでサブスク画面に飛ぶこと。

## 2. トライアル中ユーザー
- Firestore の `trialEndAt` を未来日に設定し、subscription 画面のヘッダーに「Trial Active」と表示されること。
- ロックされていた機能がすべて解放されること。
- 月/年レポートが表示されることを確認する。

## 3. 課金ユーザー（Monthly/Yearly/Lifetime）
- Firestore の `planType` を各プランに設定し、subscription 画面の該当カードが「利用中」と表示されること。
- `nextBillingAt` を設定した場合、ステータスカードに日付が出ること。
- Lifetime の場合、買い切りメッセージが表示されること。

## 4. 管理画面
- 管理者ロールを付与したアカウントで設定画面に「Subscription Admin」が表示されること。
- UID を指定して読み込み/保存ができること（Firestore を確認）。
- Lifetime フラグや日付をクリアした場合、該当フィールドが `null` に更新されること。

## 5. アプリ内課金（iOS/Android）
- 自分のサンドボックスアカウントでアプリにログインし、任意のプランカードのボタンをタップすると IAP ダイアログが開く。
- 購入完了後、Cloud Functions の `verifyAppleReceipt` / `verifyGooglePlayReceipt` が成功し、Firestore `users/{uid}.subscription` が更新されること。
- セカンドタップで購入しようとすると、すでに利用中のプランである旨のチップが表示される。
- 「購入状況を復元」ボタンを押し、pending → 完了のトーストが表示される（サンドボックスでレシートが存在する場合）。

## 6. Stripe (Web)
- ブラウザでログインし、プランボタンを押すと Stripe Checkout へリダイレクトされる。
- テストカード（例: `4242 4242 4242 4242`）で決済し、`stripeWebhook` が Firestore を更新すること。
- 「プランを変更・解約する」ボタンで Stripe Billing Portal に遷移し、キャンセル後は `subscription.planType` が `free` に戻ること。

## 7. 手動同期 / エラーハンドリング
- ネットワークを遮断した状態でプランボタンを押すと「Purchase failed」とトーストが表示される。
- 「最新の状態を同期」ボタンで `syncSubscriptionStatus` が実行され、完了トーストが表示される。
- Stripe でキャンセルしたサブスクに対し同期ボタンを押し、Firestore が `planType: free` に更新されることを確認。

