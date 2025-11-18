# フレンド機能・トラッキング共有機能 実装リスト

このドキュメントは、フレンド機能とトラッキング内容共有機能を実装するために必要な項目をまとめたものです。

## 📋 実装項目一覧

### 1. データモデル（Feature層）

#### 1.1 ユーザープロフィールモデル
- [ ] `lib/feature/friends/user_profile_model.dart`
  - ユーザーID、表示名、アイコンURL、自己紹介文、目標文章
  - フォロー数、フォロワー数、継続日数、集中総合計時間
  - プライバシー設定（プロフィール公開/非公開）
  - Firestore変換メソッド（fromFirestore/toFirestore）
  - Freezed使用

#### 1.2 フレンド関係モデル
- [ ] `lib/feature/friends/friendship_model.dart`
  - フレンド申請者ID、申請先ID
  - ステータス（pending, accepted, rejected, blocked）
  - 申請日時、承認日時
  - Firestore変換メソッド
  - Freezed使用

#### 1.3 トラッキング共有設定モデル
- [ ] `lib/feature/friends/sharing_settings_model.dart`
  - ユーザーID
  - トラッキング共有のデフォルト設定（ON/OFF）
  - 共有対象（全員公開/フレンドのみ/非公開）
  - Firestore変換メソッド
  - Freezed使用

#### 1.4 共有トラッキング投稿モデル
- [ ] `lib/feature/friends/shared_tracking_post_model.dart`
  - 投稿ID、ユーザーID
  - セッション情報（SessionInfoまたはTrackingSessionの参照）
  - コメント、共有日時
  - いいね数、コメント数
  - プライバシー設定（公開/フレンドのみ）
  - Firestore変換メソッド
  - Freezed使用

#### 1.5 いいね・コメントモデル
- [ ] `lib/feature/friends/post_interaction_model.dart`
  - いいねモデル（Like）
    - 投稿ID、ユーザーID、いいね日時
  - コメントモデル（Comment）
    - 投稿ID、ユーザーID、コメント内容、コメント日時
  - Firestore変換メソッド
  - Freezed使用

### 2. データマネージャー（Feature層）

#### 2.1 ユーザープロフィールデータマネージャー
- [ ] `lib/feature/friends/user_profile_data_manager.dart`
  - BaseHiveDataManagerを継承
  - コレクションパス: `users/{userId}/profile`
  - CRUD操作
  - ユーザー名検索機能
  - プロフィール更新機能

#### 2.2 フレンド関係データマネージャー
- [ ] `lib/feature/friends/friendship_data_manager.dart`
  - BaseHiveDataManagerを継承
  - コレクションパス: `users/{userId}/friendships`
  - フレンド申請送信
  - フレンド申請承認/拒否
  - フレンド一覧取得
  - フレンド削除（ブロック）
  - 相互フレンド判定

#### 2.3 トラッキング共有データマネージャー
- [ ] `lib/feature/friends/shared_tracking_data_manager.dart`
  - BaseHiveDataManagerを継承
  - コレクションパス: `shared_tracking_posts`（グローバルコレクション）
  - 投稿作成
  - タイムライン取得（フレンドの投稿一覧）
  - 投稿削除
  - いいね追加/削除
  - コメント追加/削除

### 3. ビジネスロジック（Feature層）

#### 3.1 フレンド機能関数
- [ ] `lib/feature/friends/friendship_functions.dart`
  - フレンド申請送信ロジック
  - フレンド申請承認ロジック
  - フレンド削除ロジック
  - フレンド検索ロジック（ユーザー名検索）
  - 相互フレンド判定ロジック

#### 3.2 トラッキング共有関数
- [ ] `lib/feature/friends/sharing_functions.dart`
  - トラッキングセッション共有ロジック
  - 共有設定の取得/更新
  - タイムライン取得ロジック
  - 投稿へのいいね/コメント処理

### 4. 状態管理（Riverpod）

#### 4.1 フレンド関連Provider
- [ ] `lib/feature/friends/friendship_notifier.dart`
  - フレンド一覧Provider
  - フレンド申請一覧Provider
  - フレンド検索結果Provider

#### 4.2 タイムライン関連Provider
- [ ] `lib/feature/friends/timeline_notifier.dart`
  - タイムライン投稿一覧Provider
  - 投稿詳細Provider
  - いいね/コメント状態Provider

### 5. UI画面（Presentation層）

#### 5.1 フレンド一覧画面
- [ ] `lib/presentation/screens/friends/friends_list_screen.dart`
  - フレンド一覧表示
  - フレンド検索ボタン
  - フレンド申請一覧表示
  - フレンドプロフィール表示

#### 5.2 フレンド検索画面
- [ ] `lib/presentation/screens/friends/friend_search_screen.dart`
  - ユーザー名検索フォーム
  - 検索結果一覧表示
  - プロフィール表示
  - フレンド申請ボタン

#### 5.3 フレンドプロフィール画面
- [ ] `lib/presentation/screens/friends/friend_profile_screen.dart`
  - プロフィール情報表示（アイコン、名前、自己紹介、目標）
  - 統計情報表示（継続日数、集中時間）
  - フレンド申請/承認/削除ボタン
  - フレンドの投稿一覧表示

#### 5.4 タイムライン画面
- [ ] `lib/presentation/screens/friends/timeline_screen.dart`
  - フレンドのトラッキング投稿一覧
  - 投稿カード表示（セッション情報、コメント、いいね数）
  - いいね/コメント機能
  - 無限スクロール対応

#### 5.5 投稿詳細画面
- [ ] `lib/presentation/screens/friends/post_detail_screen.dart`
  - 投稿詳細表示
  - コメント一覧表示
  - コメント投稿フォーム
  - いいね機能

#### 5.6 共有設定画面
- [ ] `lib/presentation/screens/friends/sharing_settings_screen.dart`
  - トラッキング共有のデフォルト設定
  - 共有対象設定（全員公開/フレンドのみ/非公開）

### 6. トラッキング終了画面の拡張

#### 6.1 トラッキング終了画面の更新
- [ ] `lib/presentation/screens/tracking/tracking_finished.dart` の更新
  - フレンド共有のオン/オフトグル追加（既存のデフォルトON設定を実装）
  - コメント入力フィールド追加
  - 共有ボタン追加
  - 共有処理の実装

### 7. Firestoreセキュリティルール

#### 7.1 セキュリティルールの追加
- [ ] `firestore.rules` の更新
  - ユーザープロフィールの読み書き権限
  - フレンド関係の読み書き権限（申請者/申請先のみ）
  - 共有トラッキング投稿の読み書き権限（投稿者/フレンドのみ）
  - いいね・コメントの読み書き権限

#### 7.2 Firestoreインデックスの追加
- [ ] `firestore.indexes.json` の更新
  - ユーザー名検索用インデックス
  - タイムライン取得用インデックス（ユーザーID、投稿日時）
  - フレンド一覧取得用インデックス

### 8. 通知機能（オプション）

#### 8.1 プッシュ通知設定
- [ ] `lib/feature/friends/friend_notification_service.dart`
  - フレンド申請通知
  - フレンド承認通知
  - トラッキング共有通知（フレンドが投稿した場合）
  - いいね/コメント通知

### 9. データマイグレーション

#### 9.1 既存ユーザーのプロフィール作成
- [ ] `lib/feature/friends/migration_service.dart`
  - 既存ユーザーのプロフィール自動作成
  - デフォルト共有設定の適用

### 10. エラーハンドリング・バリデーション

#### 10.1 エラーハンドリング
- [ ] フレンド申請の重複チェック
- [ ] 自分自身への申請防止
- [ ] 既にフレンドの場合の申請防止
- [ ] ブロック済みユーザーへの申請防止

#### 10.2 バリデーション
- [ ] ユーザー名検索の入力バリデーション
- [ ] コメント内容のバリデーション（文字数制限など）
- [ ] プロフィール情報のバリデーション

### 11. パフォーマンス最適化

#### 11.1 データ取得の最適化
- [ ] タイムラインのページネーション実装
- [ ] フレンド一覧のキャッシュ機能
- [ ] プロフィール画像のキャッシュ

#### 11.2 リアルタイム更新
- [ ] タイムラインのリアルタイム更新（Stream）
- [ ] いいね/コメント数のリアルタイム更新

### 12. テスト

#### 12.1 ユニットテスト
- [ ] フレンド関係のロジックテスト
- [ ] トラッキング共有ロジックテスト
- [ ] データマネージャーのテスト

#### 12.2 統合テスト
- [ ] フレンド申請フローのテスト
- [ ] タイムライン表示のテスト

## 📁 ファイル構成

```
lib/
├── feature/
│   └── friends/
│       ├── models/
│       │   ├── user_profile_model.dart
│       │   ├── friendship_model.dart
│       │   ├── sharing_settings_model.dart
│       │   ├── shared_tracking_post_model.dart
│       │   └── post_interaction_model.dart
│       ├── data_managers/
│       │   ├── user_profile_data_manager.dart
│       │   ├── friendship_data_manager.dart
│       │   └── shared_tracking_data_manager.dart
│       ├── functions/
│       │   ├── friendship_functions.dart
│       │   └── sharing_functions.dart
│       └── notifiers/
│           ├── friendship_notifier.dart
│           └── timeline_notifier.dart
│
└── presentation/
    └── screens/
        └── friends/
            ├── friends_list_screen.dart
            ├── friend_search_screen.dart
            ├── friend_profile_screen.dart
            ├── timeline_screen.dart
            ├── post_detail_screen.dart
            └── sharing_settings_screen.dart
```

## 🔐 Firestoreデータ構造

### ユーザープロフィール
```
users/{userId}/profile/{profileId}
- userId: string
- displayName: string
- photoURL: string?
- bio: string?
- goalText: string?
- privacySettings: { isPublic: bool }
- stats: { streakDays: int, totalFocusedHours: double }
- lastModified: timestamp
```

### フレンド関係
```
users/{userId}/friendships/{friendshipId}
- requesterId: string
- recipientId: string
- status: string (pending, accepted, rejected, blocked)
- requestedAt: timestamp
- acceptedAt: timestamp?
- lastModified: timestamp
```

### 共有トラッキング投稿
```
shared_tracking_posts/{postId}
- id: string
- userId: string
- sessionId: string
- sessionInfo: { ... } (SessionInfoのデータ)
- comment: string?
- sharedAt: timestamp
- privacy: string (public, friends_only)
- likeCount: int
- commentCount: int
- lastModified: timestamp
```

### いいね
```
shared_tracking_posts/{postId}/likes/{likeId}
- userId: string
- likedAt: timestamp
```

### コメント
```
shared_tracking_posts/{postId}/comments/{commentId}
- userId: string
- content: string
- commentedAt: timestamp
```

## 🚀 実装の優先順位

### Phase 1: 基本機能（MVP）
1. ユーザープロフィールモデル・データマネージャー
2. フレンド関係モデル・データマネージャー
3. フレンド検索機能
4. フレンド申請・承認機能
5. フレンド一覧画面

### Phase 2: トラッキング共有機能
1. 共有トラッキング投稿モデル・データマネージャー
2. トラッキング終了画面の拡張（共有機能）
3. タイムライン画面
4. 投稿詳細画面

### Phase 3: インタラクション機能
1. いいね機能
2. コメント機能
3. リアルタイム更新

### Phase 4: 最適化・拡張
1. 通知機能
2. パフォーマンス最適化
3. エラーハンドリング強化

## 📝 注意事項

1. **プライバシー**: トラッキングデータは機密情報のため、共有は明示的なユーザー同意が必要
2. **セキュリティ**: Firestoreセキュリティルールで適切なアクセス制御を実装
3. **パフォーマンス**: タイムライン取得時はページネーションを必ず実装
4. **データ整合性**: フレンド関係は双方向で管理（両方のユーザーのfriendshipsコレクションに保存）
5. **既存データ**: 既存ユーザーに対してはマイグレーション処理が必要

