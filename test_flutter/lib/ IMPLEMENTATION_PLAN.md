# Focus Tracker 実装プラン

## 実装方針

- **段階的実装**: 細かく区切って段階的に進める
- **MVP優先**: Phase 1の基本機能を優先的に実装
- **将来機能は後回し**: Phase 2以降は将来実装として計画

## Phase 1: 基本機能（MVP）

### Phase 1.1: AI検出機能の実装

**目的**: カメラを使った多ラベル分類による物体検出機能を実装

**実装内容**:
- [ ] 多ラベル分類モデルの選定・統合
  - 既存モデルの調査（TensorFlow Lite、MediaPipeなど）
  - Flutterプラグインまたはネイティブ実装の検討
- [ ] カメラアクセス権限の実装
  - `camera`パッケージの統合
  - 権限要求ロジック（トラッキング開始時）
  - 権限拒否時のエラーハンドリング
- [ ] 検出タイミングの制御
  - 省電力モード: 5秒間隔での検出
  - 通常モード: リアルタイム検出
  - 検出タイミングの切り替え機能
- [ ] 信頼度フィルタリング
  - 信頼度0.7以上の検出結果のみ有効化
  - 信頼度が低い場合は無視

**ファイル構成**:
```
lib/
├── feature/
│   └── tracking/
│       ├── detection/
│       │   ├── detection_service.dart      # 検出サービスの抽象化
│       │   ├── camera_manager.dart          # カメラ管理
│       │   └── detection_processor.dart     # 検出結果の処理
│       └── tracking_functions.dart          # 既存ファイルを拡張
```

**依存関係**:
- `camera`パッケージ（カメラアクセス）
- AIモデルライブラリ（未決定）

---

### Phase 1.2: トラッキングコア機能

**目的**: 検出結果を記録・管理するコア機能を実装

**実装内容**:
- [ ] トラッキングセッション管理
  - セッション開始・終了
  - セッションIDの生成
  - セッション状態管理
- [ ] 検出結果の記録（時間単位で保存）
  - 検出カテゴリの記録
  - 開始時刻・終了時刻の記録
  - カテゴリごとの時間を時間単位で計算・保存
  - Map<String, double>形式でcategoryHoursに保存
- [ ] カテゴリマッピング
  - 本/ペン/ノート → 'study'
  - PC/キーボード/マウス → 'pc'
  - スマホ → 'smartphone'
  - 人 → 'personOnly'
  - 検出なし → 'nothingDetected'
- [ ] 同時検出時の優先順位処理
  - 優先順位: 勉強 > パソコン > スマホ
  - 優先順位に基づくカテゴリ決定
- [ ] 誤検出補正ロジック（バックグラウンド）
  - 継続検出の見落とし補正
  - 一定時間継続検出時のカテゴリ移行判定
  - 補正ロジックの実装（具体的な数値は後で調整）

**ファイル構成**:
```
lib/
├── feature/
│   └── tracking/
│       ├── tracking_session.dart           # セッション管理
│       ├── detection_corrector.dart        # 誤検出補正
│       └── tracking_functions.dart         # 既存ファイルを拡張
```

---

### Phase 1.3: トラッキングUI実装

**目的**: トラッキング関連のUI画面を実装

**実装内容**:
- [ ] トラッキング設定画面
  - 目標選択セクション（Study、Computer、Smartphoneごとに目標を選択）
  - 省電力モードの切り替え
  - カメラ映像オン/オフ設定
  - スタートボタン
- [ ] トラッキング中画面
  - 検出カテゴリの表示
  - カテゴリごとの計測時間表示（時間単位で表示、例: 1.5h）
  - 目標達成率バーの表示
  - 省電力モードの切り替えボタン
  - カメラ映像の表示（オプション、オレンジ色調）
  - 終了ボタン
- [ ] トラッキング終了画面
  - お祝いメッセージ表示（"Great Work!"）
  - 開始時刻〜終了時刻の表示（薄い灰色で表示）
  - サマリーカード（総時間、作業時間: study + pc）
  - カテゴリ別の内訳表示（study、pc、smartphone、personOnly、nothingDetected）
  - 目標更新情報（達成率、プラス/マイナス%）
  - フレンド共有のオン/オフ（デフォルト: ON）
  - コメント入力欄
  - OKボタン

**ファイル構成**:
```
lib/
└── presentation/
    └── screens/
        └── tracking/
            ├── tracking_setting.dart       # 既存ファイルを拡張
            ├── tracking.dart                # 既存ファイルを拡張
            └── tracking_finished.dart      # 既存ファイルを拡張
```

**既存ファイルの確認**:
- `lib/presentation/screens/tracking/tracking_setting.dart`
- `lib/presentation/screens/tracking/tracking.dart`
- `lib/presentation/screens/tracking/tracking_finished.dart`

---

### Phase 1.4: データモデル・データマネージャー実装

**目的**: トラッキングデータのモデルとデータマネージャーを実装

**実装内容**:
- [ ] TrackingSessionモデル
  - Freezedを使用したイミュータブルモデル
  - 検出結果のリストを含む
- [ ] DailyTrackingDataモデル（CategoryDataPoint形式）
  - 日ごとの集計データ
  - Map<String, double>形式でカテゴリごとの時間を保存（時間単位）
- [ ] WeeklyTrackingDataモデル（CategoryDataPoint形式）
  - 週ごとの集計データ（study、pc、smartphone、totalTimeのみ）
  - personOnly、nothingDetectedは保存しない
- [ ] MonthlyTrackingDataモデル（CategoryDataPoint形式）
  - 月ごとの集計データ（study、pc、smartphone、totalTimeのみ）
  - personOnly、nothingDetectedは保存しない
- [ ] TrackingDataManager実装
  - FirestoreHiveRepositoryを使用
  - CRUD操作の実装
  - データ集計ロジック（日次/週次/月次）
- [ ] データ保存ロジック
  - トラッキングごとのデータ: 1日保存
  - 日ごとのデータ: 1ヶ月保存
  - 週ごとのデータ: 3ヶ月保存
  - 月ごとのデータ: 永続保存

**ファイル構成**:
```
lib/
├── feature/
│   └── tracking/
│       ├── tracking_data.dart              # データモデル（Freezed）
│       └── tracking_data_manager.dart      # データマネージャー
```

**データ構造例**:
```dart
@freezed
class TrackingSession with _$TrackingSession {
  const factory TrackingSession({
    required String id,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required Map<String, double> categoryHours, // カテゴリー別の時間（時間単位）
    // カテゴリ: 'study', 'pc', 'smartphone', 'personOnly', 'nothingDetected'
    required bool isCompleted,
    required DateTime createdAt,
  }) = _TrackingSession;
}

// レポート用データポイント
class CategoryDataPoint {
  final String label;
  final Map<String, double> values; // カテゴリー別の値（時間単位）
}
```

---

### Phase 1.5: 目標機能の実装

**目的**: 目標設定・管理機能を実装

**実装内容**:
- [ ] Goalモデルの確認・拡張
  - 既存のGoalモデルを確認（targetTimeは分単位、DetectionItem enum使用）
  - DummyGoalモデルとの整合性確認（UI表示用は時間単位）
  - 作業時間（work time: pc + study）のサポート追加
  - category: 'work'のサポート追加
- [ ] 目標設定画面の実装
  - 目標タイトル入力
  - 検出項目タグ選択
  - 期間選択（1日、1週間、1ヶ月）
  - 開始時期設定
  - 時間設定
  - 以上/以下選択
  - 追加ボタン
- [ ] 目標達成判定ロジック
  - 日次/週次/月次の集計時に進捗計算
  - 目標達成の判定
  - 達成継続回数の更新
- [ ] 目標達成率計算
  - 円グラフ用の達成率計算
  - 残り日数の計算
- [ ] カウントダウン機能の実装
  - Countdownモデルの確認（title、targetDate、isDeleted、lastModified）
  - DummyCountdownモデルとの整合性確認（eventName、description、emoji）
  - カウントダウン設定画面
  - 残り日数・時間・分・秒の計算・表示
- [ ] やる気の出る名言の実装
  - 名言データの準備
  - ランダム表示機能

**ファイル構成**:
```
lib/
├── feature/
│   ├── goals/
│   │   ├── goal_data_manager.dart          # 既存ファイルを拡張
│   │   └── goal_functions.dart             # 既存ファイルを拡張
│   └── countdown/
│       ├── countdowndata.dart              # 既存ファイルを確認
│       └── countdown_functions.dart        # 既存ファイルを拡張
└── presentation/
    └── screens/
        └── goal/
            ├── goal.dart                   # 既存ファイルを確認・拡張
            └── setgoal.dart                # 目標設定画面（新規または拡張）
```

---

### Phase 1.6: レポート基本機能（1日のみ）

**目的**: 1日のレポート機能を実装

**実装内容**:
- [ ] 1日の棒グラフ実装
  - 0時〜24時の時間軸
  - カテゴリごとの色分け（勉強: 緑、PC: 青、スマホ: オレンジ、人: グレー、検出なし: 無効グレー）
  - 1時間単位の表示
  - CategoryDataPoint形式のデータを使用
- [ ] 1日の円グラフ実装
  - カテゴリごとの割合表示
  - 中心に合計時間を表示
  - 各要素の時間を線で表示
- [ ] 継続日数表示
  - StreakDataからcurrentStreakを取得
  - 表示
- [ ] 総合計時間表示
  - TotalDataからtotalWorkTimeMinutesを取得（分単位）
  - 時間単位に変換して表示
  - または全カテゴリの合計時間を計算して表示
- [ ] 過去データ閲覧機能
  - 左右スワイプまたは前後ボタンで過去の1日データを閲覧

**ファイル構成**:
```
lib/
└── presentation/
    └── screens/
        └── report/
            └── report.dart                # 既存ファイルを拡張
```

**既存ファイルの確認**:
- `lib/presentation/screens/report/report.dart`（既に1日/週間/月間/年間のタブが実装されている）

---

### Phase 1.7: ユーザー認証・プロフィール

**目的**: ユーザー認証とプロフィール機能を実装

**実装内容**:
- [ ] メールアドレス認証実装
  - Firebase Authを使用
  - サインアップ・ログイン機能
- [ ] Apple認証実装
  - Sign in with Apple
  - iOS/Web対応
- [ ] Google認証実装
  - Google Sign-In
  - 既存の実装を確認・拡張
- [ ] 新規アカウント作成フロー
  - メールアドレス入力
  - ユーザー名入力（重複チェック）
  - 性別選択（必須）
  - 生まれた年入力（必須）
  - アプリを入れた理由選択（勉強、資格勉強、仕事、時間管理、趣味、その他）
  - 目標設定（スキップ可）
- [ ] プロフィール画面実装
  - アイコン表示
  - ユーザー名表示
  - フォロー数・フォロワー数表示（将来実装のためプレースホルダー）
  - 継続日数・集中総合計時間表示
- [ ] アカウント設定画面実装
  - アイコン変更
  - ユーザー名変更
  - 目標文章設定
  - メール連携
  - 自己紹介文

**ファイル構成**:
```
lib/
├── data/
│   └── sources/
│       └── auth_source.dart               # 既存ファイルを拡張
├── feature/
│   └── user/
│       ├── user_data.dart                 # ユーザーデータモデル
│       └── user_functions.dart            # ユーザー関連関数
└── presentation/
    └── screens/
        ├── auth/
        │   ├── signup_login_screen.dart   # 既存ファイルを拡張
        │   ├── initial_setup_screen.dart # 既存ファイルを拡張
        │   └── initial_goal_screen.dart  # 既存ファイルを拡張
        └── setting/
            └── account_settings.dart      # 既存ファイルを拡張
```

---

### Phase 1.8: 設定機能実装

**目的**: アプリ設定機能を実装

**実装内容**:
- [ ] 通知設定画面
  - 通知内容のオン/オフ
    - フレンド関連（トラッキング、イベント共有、申請）
    - 目標関連（カウントダウン、達成/未達成、新スタート）
    - トラッキング関連（1日/週間/月間の集中時間と総合計時間）
    - 継続日数途切れ通知
  - 通知時間の設定（朝: 8:30、夜: 22:00、デフォルト）
- [ ] 表示名カスタマイズ画面
  - 勉強、パソコン、スマホなどの表示名変更
- [ ] リセット時間設定画面
  - 1日のリセット時刻設定（デフォルト: 24時）
- [ ] アカウント設定画面
  - アイコン変更
  - ユーザー名変更
  - 目標文章設定
  - メール連携
  - 自己紹介文

**ファイル構成**:
```
lib/
├── feature/
│   └── setting/
│       ├── settings_data_manager.dart     # 既存ファイルを拡張
│       └── settings_functions.dart       # 既存ファイルを拡張
└── presentation/
    └── screens/
        └── setting/
            ├── settings_screen.dart       # 既存ファイルを確認
            ├── notification_settings.dart # 既存ファイルを拡張
            ├── display_settings.dart     # 既存ファイルを拡張
            ├── time_settings.dart        # 既存ファイルを拡張
            └── account_settings.dart      # 既存ファイルを拡張
```

---

### Phase 1.9: ホーム画面実装

**目的**: ホーム画面を実装

**実装内容**:
- [ ] 継続日数表示
  - 左上に表示
- [ ] 総合計集中時間表示
  - 右上に表示
- [ ] 今日の目標表示
  - アイコン、名前、1日あたりの作業時間、集中かどうか（将来実装）
- [ ] 設定ボタン
  - 灰色のボタン
- [ ] スタートボタン
  - 青色のボタン

**ファイル構成**:
```
lib/
└── presentation/
    └── screens/
        └── home/
            └── home_screen.dart           # 既存ファイルを拡張
```

**既存ファイルの確認**:
- `lib/presentation/screens/home/home_screen.dart`（既に実装されている）

---

### Phase 1.10: イベントシステム基本実装

**目的**: イベント発生・表示機能を実装

**実装内容**:
- [ ] イベントモデル
  - イベントタイプ（目標設定、目標達成、継続日数更新など）
  - イベントデータ
- [ ] イベント発生判定ロジック
  - 目標達成時の判定
  - カウントダウン終了時の判定
  - 継続日数更新時の判定
  - 集中総合計時間の大台到達時の判定
- [ ] イベント表示画面の基本実装
  - 目標設定時イベント
  - 目標達成時イベント
  - カウントダウン設定時イベント
  - カウントダウン終了時イベント

**ファイル構成**:
```
lib/
├── feature/
│   └── event/
│       ├── event_data.dart                # イベントデータモデル
│       └── event_functions.dart           # イベント判定ロジック
└── presentation/
    └── screens/
        └── event/
            ├── event_screen_base.dart     # 既存ファイルを確認
            ├── goal_set_event.dart       # 既存ファイルを確認
            ├── goal_achieved_event.dart  # 既存ファイルを確認
            ├── countdown_set_event.dart  # 既存ファイルを確認
            └── countdown_ended_event.dart # 既存ファイルを確認
```

---

### Phase 1.11: データ同期機能

**目的**: Firestoreとのデータ同期機能を実装

**実装内容**:
- [ ] Firestoreとの同期実装
  - FirestoreHiveRepositoryを使用
  - トラッキングデータの同期
  - 目標データの同期
  - カウントダウンデータの同期
- [ ] ローカルキャッシュ（Hive）実装
  - トラッキングデータのキャッシュ
  - オフライン時のデータ取得
- [ ] オフライン対応
  - オフライン時のデータ保存
  - オンライン復帰時の自動同期
- [ ] データ競合解決ロジック
  - lastModifiedに基づく競合解決
  - データマージロジック

**ファイル構成**:
```
lib/
├── data/
│   ├── repositories/
│   │   └── firestore_hive_repository.dart # 既存ファイルを確認
│   └── services/
│       └── sync_service.dart              # 既存ファイルを確認
```

---

### Phase 1.12: エラーハンドリング・テスト

**目的**: エラーハンドリングと基本的な動作テストを実装

**実装内容**:
- [ ] カメラ権限エラー処理
  - 権限拒否時のメッセージ表示
  - 設定画面への誘導
- [ ] モデル読み込みエラー処理
  - モデル読み込み失敗時のフォールバック
- [ ] 検出エラー処理
  - 検出失敗時のリトライロジック
- [ ] ネットワークエラー処理
  - オフライン時の処理
  - ネットワーク復帰時の自動同期
- [ ] データ保存エラー処理
  - 保存失敗時のリトライロジック
- [ ] 基本的な動作テスト
  - トラッキング開始・終了のテスト
  - データ保存のテスト
  - 目標達成判定のテスト

**ファイル構成**:
```
lib/
├── data/
│   └── services/
│       └── error_handler.dart             # 既存ファイルを確認
```

---

## Phase 2: 拡張機能（将来実装）

### Phase 2.1: 集中度判定機能

**実装内容**:
- 姿勢推定モデルの統合
- 視線推定モデルの統合
- 集中度判定ロジック
- 集中時間と総時間の区別
- 集中度に応じたUI表示（濃淡）

---

### Phase 2.2: レポート拡張機能

**実装内容**:
- 週間レポート実装
- 月間レポート実装
- 年間レポート実装
- 集中時間と総時間の区別表示
- 過去データ閲覧機能の拡張

---

### Phase 2.3: 通知機能実装

**実装内容**:
- flutter_local_notificationsの統合
- 通知スケジューリング機能
- 通知設定に基づく通知送信
- 通知内容のカスタマイズ

---

## Phase 3: ソーシャル機能（将来実装）

### Phase 3.1: フレンド機能

**実装内容**:
- フレンド追加機能
- フレンド検索機能
- フォロー/フォロワー管理
- タイムライン実装
- いいね・コメント機能

---

### Phase 3.2: 記事機能

**実装内容**:
- 記事モデル
- 記事一覧画面
- 記事検索機能
- 記事カテゴリフィルタ
- 記事詳細画面

---

## Phase 4: 収益化（将来実装）

### Phase 4.1: 課金システム

**実装内容**:
- サブスクリプション実装（RevenueCatまたはIn-App Purchase）
- 課金状態の管理
- 課金制限の実装
- 招待システム実装

---

### Phase 4.2: 広告システム

**実装内容**:
- バナー広告実装
- ネイティブ広告実装
- 広告SDKの統合（Google AdMobなど）

---

## 実装順序の推奨

1. **Phase 1.4**: データモデル・データマネージャー実装（他の機能の基盤）
2. **Phase 1.1**: AI検出機能の実装（コア機能）
3. **Phase 1.2**: トラッキングコア機能（コア機能）
4. **Phase 1.3**: トラッキングUI実装（ユーザー体験）
5. **Phase 1.7**: ユーザー認証・プロフィール（必須機能）
6. **Phase 1.5**: 目標機能の実装（主要機能）
7. **Phase 1.6**: レポート基本機能（主要機能）
8. **Phase 1.9**: ホーム画面実装（統合）
9. **Phase 1.8**: 設定機能実装（補完機能）
10. **Phase 1.10**: イベントシステム基本実装（補完機能）
11. **Phase 1.11**: データ同期機能（必須機能）
12. **Phase 1.12**: エラーハンドリング・テスト（品質保証）

---

## 注意事項

- **段階的実装**: 各Phaseを細かく区切って実装
- **既存ファイルの確認**: 既存の実装を確認してから拡張
- **抽象化の優先**: 重複コードを避け、抽象化を積極的に行う
- **エラーハンドリング**: 各機能で適切なエラーハンドリングを実装
- **テスト**: 各機能実装後に動作確認を実施

