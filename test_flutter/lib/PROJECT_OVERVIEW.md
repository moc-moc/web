# プロジェクト概要

## アプリケーション名
**Focus Tracker**（仮称）- 作業時間自動計測・管理アプリ

## アプリの目的
ユーザーの作業時間を自動計測して記録・管理するアプリケーション。カメラとAIを使用して、勉強・パソコン作業・スマホ使用時間を自動判別し、目標設定・達成管理・詳細レポートを提供する。

---

## 主要機能

### 1. トラッキング機能（メイン機能）
スマホ・パソコン・iPadの内カメでユーザーと机上の物を検出し、何をしているか自動判別。

#### 検出カテゴリー
- **勉強（ノート・読書）**: 本、ペン、ノートを検出
- **パソコン**: パソコン、デスクトップ、キーボード、マウスを検出
- **スマホ**: スマホを検出
- **人のみ**: 人はいるが作業していない状態
- **検出なし**: 何も検出されない（離席中）

#### AI実装（段階的）
- **Phase 1（現在）**: ダミーデータで実装、AI統合は最後
- **Phase 2（将来）**: 多ラベル分類で物体検出
- **Phase 3（将来）**: 姿勢推定で手の動き判定
- **Phase 4（将来）**: 視線推定で集中度判定

#### トラッキング画面の表示内容
- リアルタイム検出状況の表示
- カテゴリーごとの計測時間（秒単位）
- カメラ映像のオン/オフ切り替え
- 目標達成率バー
- 省電力モード切り替え

#### トラッキング終了画面
- セッションごとの時間集計
- 目標達成状況（±何%）
- コメント入力
- フレンド共有設定（将来実装）

### 2. レポート・分析・グラフ機能
トラッキングデータを基に詳細な分析を提供。

#### 表示期間
- 1日（無課金でも閲覧可）
- 1週間（課金必要）
- 1ヶ月（課金必要）
- 1年（課金必要）

#### グラフの種類
**棒グラフ**
- 横軸：時間帯（1日の場合0-24時）
- 縦軸：時間
- 色分け：
  - 勉強（オレンジ：濃=集中、薄=非集中）
  - パソコン（青緑：濃=集中、薄=非集中）
  - スマホ（黄色）
  - 人のみ（明るい緑）
  - 検出なし（灰色）

**円グラフ**
- 各カテゴリーの割合表示
- 中心に合計時間表示
- 線で各要素の時間を表記

#### その他の表示項目
- 継続日数（連続トラッキング日数）
- 集中作業時間合計（勉強+パソコンの集中時間）

### 3. 目標設定・管理機能

#### 目標設定の要素
- **検出カテゴリー**: 勉強/パソコン/スマホ/作業時間（勉強+パソコン）
- **期間**: 1日/1週間/1ヶ月
- **目標時間**: 分単位で設定
- **比較タイプ**: 以上/以下
- **時間タイプ**: 集中時間のみ/総時間（将来実装）
- **開始時期**: 週初め・月初めスタート/設定日からスタート

#### 目標達成画面の表示
- 目標ごとの達成率（円グラフ）
- 残り日数表示（週間・月間目標の場合）
- 連続達成回数表示
- やる気の出る名言をランダム表示
- カウントダウン機能

#### カウントダウン機能
- イベント名と日程を設定
- 残り日数を表示
- カウントダウン終了時にイベント発生

### 4. ユーザー・プロフィール機能

#### プロフィール情報
- アイコン
- ユーザー名
- フォロー・フォロワー数（将来実装）
- 継続日数
- 集中総合計時間

#### 設定項目
**通知設定**
- 朝の通知（デフォルト8:30）
- 夜の通知（デフォルト22:00）
- 通知内容の個別オン/オフ：
  - カウントダウン
  - 目標達成/未達成
  - 目標新スタート
  - 日次/週次/月次レポート
  - 継続日数途切れ

**表示設定**
- カテゴリー名のカスタマイズ（勉強/パソコン/スマホ）
- リセット時間設定（デフォルト24:00）

**アカウント設定**
- アイコン変更
- ユーザー名変更
- 自己紹介文

### 5. イベント表示機能
特定の達成時にイベント画面を表示。

#### イベントの種類
- **目標達成時**: 目標達成＋連続達成回数表示
- **目標設定時**: 新しい目標スタートの告知
- **目標期間終了時**: 達成率表示＋祝福/励まし
- **継続日数大台**: 3,5,7,10,20,30,50,75,100,150日...（以降50日ごと）、1年ごと
- **集中時間大台**: 1,3,5,10,20,30,40,50,75,100時間...（以降100時間ごと）
- **カウントダウン終了**: イベント達成の祝福

### 6. 初期画面・認証機能

#### ログイン方法
- メールアドレス
- Apple認証
- Google認証

#### 新規アカウント作成時の情報
- メールアドレス
- ユーザー名（重複不可）
- 性別
- 生まれた年
- アプリを入れた理由（勉強/資格/仕事/時間管理/趣味/その他）
- 初期目標設定（スキップ可）

### 7. 課金システム（将来実装）

#### 無料版の制限
- レポートは1日のみ閲覧可
- 目標設定は1つのみ
- カウントダウン機能使用不可

#### 有料プラン
- 1週間無料トライアル
- 週額350円
- 月額1,480円（初月980円キャンペーン）
- 年額14,800円
- 買い切り19,800円

#### 広告（無料版）
- バナー広告：トラッキング中に表示
- ネイティブ広告：記事・フレンド投稿に混在

---

## データ構造

### Firestoreコレクション構造

```
users/{userId}/
  ├── streak/                    # 継続日数（1ドキュメント）
  ├── total/                     # 総合計データ（1ドキュメント）
  ├── goals/                     # 目標（複数）
  ├── settings/                  # ユーザー設定（1ドキュメント）
  ├── app_settings/              # アプリ設定（1ドキュメント）
  ├── notification_settings/     # 通知設定（1ドキュメント）
  ├── countdown/                 # カウントダウン（1ドキュメント）
  ├── tracking_sessions/         # トラッキングセッション（複数）
  ├── daily_reports/             # 日別レポート（複数）
  ├── weekly_reports/            # 週別レポート（複数）
  ├── monthly_reports/           # 月別レポート（複数）
  ├── yearly_reports/            # 年別レポート（複数）
  └── milestone_events/          # 大台イベント記録（複数、必要なら）
```

### 主要データモデル

#### Goal（目標）
```dart
Goal {
  id: String,                      // 一意のID
  tag: String,                     // タグ（将来実装用）
  title: String,                   // 目標タイトル
  targetTime: int,                 // 目標時間（分）
  comparisonType: String,          // "above" or "below"
  detectionItem: String,           // "book"/"smartphone"/"pc"/"workTime"
  startDate: Timestamp,            // 開始日
  durationDays: int,               // 期間（日数）
  periodType: String,              // "daily"/"weekly"/"monthly"
  isFixedStart: bool,              // 週初め/月初めスタートか
  isFocusedOnly: bool,             // 集中時間のみ（将来実装、デフォルトfalse）
  consecutiveAchievements: int,    // 連続達成回数
  achievedTime: int?,              // 達成時間
  isDeleted: bool,                 // 削除フラグ
  lastModified: Timestamp,         // 最終更新日時
}
```

#### TrackingSession（トラッキングセッション）
```dart
TrackingSession {
  id: String,                      // セッションID
  userId: String,                  // ユーザーID
  startTime: DateTime,             // 開始時刻
  endTime: DateTime,               // 終了時刻
  totalDuration: int,              // 総時間（秒）
  
  // 各カテゴリーの時間（秒）
  studyTime: int,                  // 勉強（総）
  studyFocusedTime: int,           // 勉強（集中）※将来実装
  pcTime: int,                     // パソコン（総）
  pcFocusedTime: int,              // パソコン（集中）※将来実装
  smartphoneTime: int,             // スマホ
  personOnlyTime: int,             // 人のみ
  nothingDetectedTime: int,        // 検出なし
  
  comment: String?,                // コメント
  sharedToFriends: bool,           // フレンド共有フラグ（将来実装）
  goalAchievements: List?,         // 達成した目標情報
  
  lastModified: DateTime,          // 最終更新日時
}
```

#### DailyReport（日別レポート）
```dart
DailyReport {
  id: String,                      // 日付（例: "2025-11-11"）
  userId: String,                  // ユーザーID
  date: DateTime,                  // 日付
  
  // 集計時間（秒）
  totalStudyTime: int,             // 勉強（総）
  totalStudyFocusedTime: int,      // 勉強（集中）※将来実装
  totalPcTime: int,                // パソコン（総）
  totalPcFocusedTime: int,         // パソコン（集中）※将来実装
  totalSmartphoneTime: int,        // スマホ
  totalPersonOnlyTime: int,        // 人のみ
  totalNothingTime: int,           // 検出なし
  
  sessionIds: List<String>,        // この日のセッションID一覧
  goalAchievements: Map?,          // goalId -> 達成したか
  
  lastModified: DateTime,          // 最終更新日時
}
```

#### WeeklyReport（週別レポート）
```dart
WeeklyReport {
  id: String,                      // 週ID（例: "2025-W45"）
  userId: String,                  // ユーザーID
  weekStartDate: DateTime,         // 週の開始日
  weekEndDate: DateTime,           // 週の終了日
  
  // 集計時間（秒）
  totalStudyTime: int,             // 勉強（総）
  totalStudyFocusedTime: int,      // 勉強（集中）※将来実装
  totalPcTime: int,                // パソコン（総）
  totalPcFocusedTime: int,         // パソコン（集中）※将来実装
  totalSmartphoneTime: int,        // スマホ
  totalPersonOnlyTime: int,        // 人のみ
  totalNothingTime: int,           // 検出なし
  
  dailyReportIds: List<String>,    // この週の日別レポートID一覧
  
  lastModified: DateTime,          // 最終更新日時
}
```

#### MonthlyReport（月別レポート）
```dart
MonthlyReport {
  id: String,                      // 月ID（例: "2025-11"）
  userId: String,                  // ユーザーID
  year: int,                       // 年
  month: int,                      // 月
  
  // 集計時間（秒）
  totalStudyTime: int,             // 勉強（総）
  totalStudyFocusedTime: int,      // 勉強（集中）※将来実装
  totalPcTime: int,                // パソコン（総）
  totalPcFocusedTime: int,         // パソコン（集中）※将来実装
  totalSmartphoneTime: int,        // スマホ
  totalPersonOnlyTime: int,        // 人のみ
  totalNothingTime: int,           // 検出なし
  
  dailyReportIds: List<String>,    // この月の日別レポートID一覧
  
  lastModified: DateTime,          // 最終更新日時
}
```

#### YearlyReport（年別レポート）
```dart
YearlyReport {
  id: String,                      // 年ID（例: "2025"）
  userId: String,                  // ユーザーID
  year: int,                       // 年
  
  // 集計時間（秒）
  totalStudyTime: int,             // 勉強（総）
  totalStudyFocusedTime: int,      // 勉強（集中）※将来実装
  totalPcTime: int,                // パソコン（総）
  totalPcFocusedTime: int,         // パソコン（集中）※将来実装
  totalSmartphoneTime: int,        // スマホ
  totalPersonOnlyTime: int,        // 人のみ
  totalNothingTime: int,           // 検出なし
  
  monthlyReportIds: List<String>,  // この年の月別レポートID一覧
  
  lastModified: DateTime,          // 最終更新日時
}
```

#### StreakData（継続日数）
```dart
StreakData {
  id: String,                      // 固定値 "user_streak"
  currentStreak: int,              // 現在の連続日数
  longestStreak: int,              // 最長連続記録
  lastTrackedDate: DateTime,       // 最後にトラッキングした日
  lastModified: DateTime,          // 最終更新日時
}
```

#### TotalData（総合計データ）
```dart
TotalData {
  id: String,                      // 固定値 "user_total"
  totalLoginDays: int,             // 総ログイン日数
  totalWorkTimeSeconds: int,       // 総作業時間（秒）
  lastTrackedDate: DateTime,       // 最後にトラッキングした日
  lastModified: DateTime,          // 最終更新日時
}
```

#### UserSettings（ユーザー設定）
```dart
UserSettings {
  userId: String,                  // ユーザーID
  username: String,                // ユーザー名
  iconUrl: String?,                // アイコンURL
  bio: String?,                    // 自己紹介
  lastModified: DateTime,          // 最終更新日時
}
```

#### AppSettings（アプリ設定）
```dart
AppSettings {
  userId: String,                  // ユーザーID
  studyDisplayName: String,        // 勉強の表示名（デフォルト「勉強」）
  pcDisplayName: String,           // パソコンの表示名（デフォルト「パソコン」）
  smartphoneDisplayName: String,   // スマホの表示名（デフォルト「スマホ」）
  dailyResetTime: TimeOfDay,       // リセット時間（デフォルト24:00）
  lastModified: DateTime,          // 最終更新日時
}
```

#### NotificationSettings（通知設定）
```dart
NotificationSettings {
  userId: String,                  // ユーザーID
  isEnabled: bool,                 // 通知全体のオン/オフ
  morningTime: TimeOfDay,          // 朝の通知時間（デフォルト8:30）
  eveningTime: TimeOfDay,          // 夜の通知時間（デフォルト22:00）
  isMorningEnabled: bool,          // 朝の通知オン/オフ
  isEveningEnabled: bool,          // 夜の通知オン/オフ
  
  // 各通知のオン/オフ
  goalCountdown: bool,             // カウントダウン
  goalAchievement: bool,           // 目標達成/未達成
  goalNewStart: bool,              // 目標新スタート
  dailyReport: bool,               // 日次レポート
  weeklyReport: bool,              // 週次レポート
  monthlyReport: bool,             // 月次レポート
  streakBroken: bool,              // 継続日数途切れ
  
  lastModified: DateTime,          // 最終更新日時
}
```

### ローカルストレージ戦略

#### ストレージの使い分け
1. **Firestore**: 全データのクラウド保存（flutter_secure_storage以外）
2. **Hive（検討中）**: ローカルキャッシュ、オフライン対応
3. **SharedPreferences**: 軽量設定データ
4. **flutter_secure_storage**: 認証トークン、API Key

#### データ同期方針
- オンライン時：Firestoreに即座に保存
- オフライン時：ローカルに保存、送信キューに追加
- オンライン復帰時：送信キューから順次アップロード
- 差分取得：全データではなく未取得部分のみ取得

---

## 実装方針

### 技術スタック
- **フレームワーク**: Flutter
- **状態管理**: Riverpod（Provider）
- **データモデル**: Freezed（イミュータブル）
- **データベース**: Firebase Firestore
- **ローカルDB**: Hive（検討中）、SharedPreferences
- **認証**: Firebase Authentication
- **プラットフォーム**: Web（Chrome）→ iOS → Android

### 開発フロー
1. **段階的実装**: 細かいステップに区切って進める
2. **リファクタリング優先**: 重複コード発見時は即座に抽象化
3. **ダミーデータでテスト**: AI統合は最後に実施
4. **動作確認重視**: 各ステップで動作確認してから次へ

### アーキテクチャ
4層のレイヤードアーキテクチャに従う（詳細は`rules`ファイル参照）

1. **Core層**: アプリ全体の設定（theme, route）
2. **Data層**: 
   - sources/: 外部データソースとの直接やり取り
   - repositories/: 汎用的なデータ操作パターン
   - services/: 横断的機能（エラーハンドリング、リトライ、同期）
   - models/: 共通データモデル
3. **Feature層**: 機能単位のビジネスロジック
4. **Presentation層**: UI（widgets/, screens/）

### 依存関係ルール
- presentation → feature → data/repositories → data/sources → core
- 下位レイヤーは上位レイヤーに依存しない
- 同一レイヤー内の依存は最小限に

### コーディング規約
- **DRY原則**: 同じコードを2回以上書かない
- **抽象化優先**: ジェネリクス、抽象クラス、Mixin、Extension活用
- **ファイルサイズ**: 目標150-200行、最大300行、超えたら分割
- **ドキュメントコメント**: 公開APIには`///`でコメント

---

## 実装の優先順位

### Phase 0: リファクタリング（最優先）
既存の重複コードを抽象化。BaseDataManager作成。

### Phase 1: データモデル拡張（優先度A）
- Goal拡張
- TotalData修正（秒単位に統一）
- TrackingSession作成
- DailyReport作成
- WeeklyReport作成
- MonthlyReport作成
- YearlyReport作成
- Countdown確認

### Phase 2: DataManager作成（優先度A）
- TrackingSessionDataManager
- DailyReportDataManager
- WeeklyReportDataManager
- MonthlyReportDataManager
- YearlyReportDataManager

### Phase 3: ダミーデータテスト（優先度A）
- Firestore接続テスト
- ローカル同期テスト

### Phase 4: 計算ロジック（優先度B）
- トラッキングデータ集計
- 目標達成判定
- 継続日数管理
- 大台イベント検出

### Phase 5: 設定データ（優先度B）
- UserSettings, AppSettings, NotificationSettings

### Phase 6: UI実装（優先度C）
- レポート画面
- 目標画面
- トラッキング画面
- 設定画面

### Phase 7: AI統合（優先度D）
※最後に実装

### Phase 8: デザイン調整（優先度E）

### Phase 9: プラットフォーム対応（優先度E）

---

## 将来実装機能（今は作らない）

### タグ機能
カテゴリーごとに複数のタグを設定し、タグ別の時間計測

### 集中判定（AI）
- 多ラベル分類
- 姿勢推定
- 視線推定
これらを組み合わせて集中しているか判定

### フレンド機能
- ユーザー検索・フォロー
- タイムライン表示
- トラッキング結果共有
- いいね・コメント機能

### 記事・探す機能
- モチベーション記事
- PR広告混在のフィード

### 課金システム
- サブスクリプション
- 広告表示

---

## 大台イベントの閾値

### 継続日数
3, 5, 7, 10, 20, 30, 50, 75, 100, 150日
以降：50日ごと（200, 250, 300...）
特別：1年ごと（365, 730, 1095...）

### 集中総合計時間
1, 3, 5, 10, 20, 30, 40, 50, 75, 100時間
以降：100時間ごと（200, 300, 400...）

---

## 同時検出の優先順位
AIで複数カテゴリーを同時検出した場合、以下の優先順位で判定：
1. スマホ（最優先）
2. パソコン
3. 勉強（本・ペン）
4. 人のみ
5. 検出なし

---

## 継続日数のリセット条件
リセット時間（デフォルト24:00、カスタマイズ可）を跨いでトラッキングしなかった場合、継続日数がリセットされる。

---

## 注意事項

### 必ず守ること
- `rules`ファイルを常に参照
- 段階的に実装（一気にコーディングしない）
- 重複コードは即座に抽象化

### 現在の実装状況
- データ層の基礎は完成（Firestore/Hive Repository）
- 一部のUI（ボタン、画面構造）は作成済み
- トラッキングロジックは未実装
- データモデルは一部のみ（Goal, Streak, Total, Countdown）
- AI統合は未実装

---

このプロジェクトは長期的な実装を想定しており、段階的に機能を追加していきます。

