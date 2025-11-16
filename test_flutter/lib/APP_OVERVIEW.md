# Focus Tracker アプリ概要

## アプリコンセプト

Focus Trackerは、カメラを使ったAI検出技術を活用して、ユーザーの学習・作業時間を自動的にトラッキングするアプリです。机の上に置かれた物体（本、ペン、ノート、PC、スマホなど）を検出し、ユーザーが何をしているかを自動判別します。集中度の判定、目標設定、レポート機能により、ユーザーの生産性向上をサポートします。

## 主な機能

### 1. トラッキング機能（メイン機能）

#### 検出技術
- **多ラベル分類**: 本、PC、スマホ、キーボード、マウス、ペン、人を検出
- **将来実装**: 姿勢推定、視線推定による集中度判定
- **検出タイミング**: 
  - 省電力モードON: 5秒間隔
  - 省電力モードOFF: リアルタイム検出
- **信頼度**: 0.7以上で有効、低い場合は無視
- **誤検出補正**: バックグラウンドで自動補正（継続検出の見落とし補正など）

#### 検出カテゴリ
- **勉強**: 本、ペン、ノートの検出
- **パソコン**: PC、デスクトップ、キーボード、マウスの検出
- **スマホ**: スマホの検出
- **人**: 人のみ検出された時間
- **検出なし**: 何も検出されない時間

#### 同時検出時の優先順位
1. 勉強
2. パソコン
3. スマホ

#### トラッキング設定画面の機能
- 目標選択（Study、Computer、Smartphoneごとに目標を選択）
- 省電力モードの切り替え
- カメラ映像のオン/オフ設定
- スタートボタン

#### トラッキング中画面の機能
- カメラ映像のオン/オフ（デフォルト: オフ）
- 検出カテゴリの表示
- カテゴリごとの計測時間表示（時間単位で表示）
- 目標達成率バーの表示
- 省電力モードの切り替えボタン
- 終了ボタン

#### トラッキング終了画面
- お祝いメッセージ表示
- 開始時刻〜終了時刻の表示
- サマリーカード（総時間、作業時間）
- カテゴリ別の内訳表示（study、pc、smartphone、personOnly、nothingDetected）
- 目標更新情報（達成率、プラス/マイナス%）
- フレンド共有のオン/オフ（デフォルト: ON）
- コメント機能
- OKボタン

### 2. レポート・分析・グラフ機能

#### 期間選択
- 1日、1週間、1ヶ月、1年の4つのタブ

#### 棒グラフ
- カテゴリごとの色分け（勉強: 緑、PC: 青、スマホ: オレンジ、人: グレー、検出なし: 無効グレー）
- 集中時間は濃く、非集中時間は薄く表示（将来実装）
- 過去データの閲覧（左右スワイプまたは前後ボタン）
- 1日: 0時〜24時の時間軸、1時間単位
- 1週間: 月曜〜日曜の7日分
- 1ヶ月: 1日〜30日の日次データ
- 1年: 1月〜12月の月次データ

#### 円グラフ
- カテゴリごとの割合表示
- 集中/非集中の色分け（将来実装）
- 中心に合計時間を表示
- 各要素の時間を線で表示

#### 統計情報
- **継続日数**: 連続トラッキング日数（StreakDataから取得）
- **集中作業時間合計**: PCと勉強の集中時間の合計（将来実装）
- **総合計時間**: 全カテゴリの合計時間（TotalDataから取得、分単位で保存、時間単位で表示）

### 3. 目標機能

#### 目標設定
- **カテゴリ**: 勉強（study）、パソコン（pc）、スマホ（smartphone）、作業時間（work: PC+勉強）の4パターン
- **期間**: 1日（daily）、1週間（weekly）、1ヶ月（monthly）
- **条件**: 以上（above）/以下（below）
- **時間タイプ**: 集中時間のみ（isFocusedOnly: true）/総合計時間（isFocusedOnly: false）（将来実装）
- **目標時間**: 分単位で保存（targetTime）、UIでは時間単位で表示
- **開始時期**: 週初め/月初スタート、または設定日から（startDate、durationDays）

#### 目標達成率
- 円グラフで達成率を表示
- 複数目標がある場合は目標ごとに表示
- 残り日数の表示（週間/月間目標）
- 連続達成日数の表示

#### カウントダウン
- イベント名（title）の設定
- 目標日時（targetDate）の設定
- 説明（description）・絵文字（emoji）の設定（オプション）
- 残り日数・時間・分・秒の表示
- 論理削除対応（isDeleted）

#### やる気の出る名言
- ランダム表示

### 4. ユーザー・プロフィール機能

#### プロフィール表示
- アイコン、ユーザー名
- フォロー数、フォロワー数
- 継続日数、集中総合計時間

#### 設定機能
- **通知設定**: 
  - フレンド関連（トラッキング、イベント共有、申請）
  - 目標関連（カウントダウン、達成/未達成、新スタート）
  - トラッキング関連（1日/週間/月間の集中時間と総合計時間）
  - 継続日数途切れ通知
  - 通知時間の設定（朝: 8:30、夜: 22:00、デフォルト）
- **表示名カスタマイズ**: 勉強、パソコン、スマホなどの表示名変更
- **リセット時間設定**: 1日のリセット時刻（デフォルト: 24時）
- **アカウント設定**: 
  - アイコン変更
  - ユーザー名変更
  - 目標（フレンドが見れる文章）の設定
  - メールアドレス連携
  - 自己紹介文

### 5. イベント表示機能

#### イベントタイプ
- **目標設定時**: 目標内容、期間、開始メッセージ
- **目標達成時**: 目標内容、達成継続回数、祝福メッセージ
- **目標期間終了時**: 達成率、達成/未達成メッセージ
- **継続日数更新時**: 継続日数、祝福、次の大台告知
- **集中総合計時間の大台**: 集中総合計時間、祝福、次の大台告知
- **カウントダウン設定時**: イベント名、残り時間、メッセージ
- **カウントダウン終了時**: イベント名、終了メッセージ、次のイベント設定提案

#### イベント共有
- フレンド共有のオン/オフ（デフォルト: ON）
- SNS共有（LINE、Instagram、リンクコピー）

### 6. 初期画面・アカウント設定

#### 認証方法
- メールアドレス認証
- Apple認証（Sign in with Apple）
- Google認証

#### 新規アカウント作成
- メールアドレス（必須）
- ユーザー名（必須、重複不可）
- 性別（必須）
- 生まれた年（必須）
- なぜこのアプリを入れたか（勉強、資格勉強、仕事、時間管理、趣味、その他）
- 目標設定（スキップ可）

### 7. 課金システム（将来実装）

#### サブスクリプション
- 1週間無料期間
- 1週間: 350円
- 1ヶ月: 1480円（期間限定: 最初の1ヶ月980円）
- 1年: 14800円
- 買い切り: 19800円

#### 課金制限
- **無課金**: 1日のレポートのみ閲覧可能、目標1つのみ、カウントダウン機能不可
- **有課金**: 1週間/1ヶ月/1年のレポート閲覧、複数目標設定、カウントダウン機能

#### 招待システム（将来実装）
- LINEで3〜5人に送ったら1週間無料

### 8. 広告システム（将来実装）

#### 広告タイプ
- **バナー広告**: トラッキング中に常時表示
- **ネイティブ広告**: 
  - モチベーション記事にPR広告を混ぜる
  - フレンドの投稿の途中にPR広告を混ぜる

### 9. フレンド機能（将来実装）

#### フレンド追加
- ユーザー名で検索
- プロフィール表示（アイコン、ユーザー名、目標文章、自己紹介文、フォロー数、フォロワー数、継続日数、集中総合計時間）

#### タイムライン
- フレンドのトラッキング投稿
- イベント共有の投稿
- いいね・コメント機能

### 10. 記事機能（将来実装）

#### 記事カテゴリ
- 勉強、集中、自主学習、資格勉強、モチベーション関連の記事
- AI作成、定期作成、ユーザー作成

#### 検索機能
- 検索バーで記事を検索
- トピックカテゴリ（モチベーション、勉強、仕事、豆知識、論文）でフィルタ

## 技術スタック

### フロントエンド
- **フレームワーク**: Flutter (SDK ^3.9.2)
- **状態管理**: Riverpod (hooks_riverpod, riverpod_annotation)
- **UI**: Material Design、Google Fonts
- **グラフ**: fl_chart
- **ナビゲーション**: go_router

### バックエンド・データベース
- **認証**: Firebase Auth
- **データベース**: Cloud Firestore
- **ローカルストレージ**: Hive、SharedPreferences
- **セキュアストレージ**: flutter_secure_storage

### AI・機械学習（将来実装）
- **多ラベル分類**: 既存モデルを活用（ライブラリ未決定）
- **姿勢推定**: 将来実装
- **視線推定**: 将来実装

### その他
- **通知**: flutter_local_notifications（ネイティブアプリのみ）
- **課金**: 未決定（RevenueCat、In-App Purchaseなど）
- **広告**: 未決定（Google AdMob、Facebook Audience Networkなど）

## データ構造

### トラッキングデータ

#### トラッキングセッションデータ（保存期間: 1日）
```dart
class TrackingSession {
  String id;
  String userId;
  DateTime startTime;
  DateTime endTime;
  Map<String, double> categoryHours; // カテゴリー別の時間（時間単位）
  // カテゴリ: 'study', 'pc', 'smartphone', 'personOnly', 'nothingDetected'
  bool isCompleted;
  DateTime createdAt;
}
```

#### 日ごとのデータ（保存期間: 1ヶ月）
- トラッキングセッションデータを1日単位で集計
- `CategoryDataPoint`形式で保存
- `values`: Map<String, double> - カテゴリー別の時間（時間単位）

#### 週ごとのデータ（保存期間: 3ヶ月）
- 日ごとのデータを1週間単位で集計
- `CategoryDataPoint`形式で保存
- study、pc、smartphone、totalTimeのみ保存
- personOnly、nothingDetectedは保存しない

#### 月ごとのデータ（永続保存）
- 日ごとのデータを1ヶ月単位で集計
- `CategoryDataPoint`形式で保存
- study、pc、smartphone、totalTimeの合計のみ保存

### 目標データ
```dart
@freezed
class Goal {
  String id;
  String userId;
  String tag;
  String title;
  int targetTime; // 分単位
  ComparisonType comparisonType; // 'above' | 'below'
  DetectionItem detectionItem; // 'book' | 'smartphone' | 'pc'
  DateTime startDate;
  int durationDays;
  int consecutiveAchievements;
  int? achievedTime; // 分単位
  bool isDeleted;
  DateTime lastModified;
}

// ダミーデータ用（UI表示用）
class DummyGoal {
  String id;
  String title;
  String category; // 'study', 'pc', 'smartphone', 'work'
  double targetHours; // 時間単位
  double currentHours; // 時間単位
  String period; // 'daily', 'weekly', 'monthly'
  int remainingDays;
  int consecutiveAchievements;
  bool isFocusedOnly;
  String comparisonType; // 'above' | 'below'
}
```

### カウントダウンデータ
```dart
@freezed
class Countdown {
  String id;
  String title; // イベント名
  DateTime targetDate;
  bool isDeleted;
  DateTime lastModified;
}

// ダミーデータ用（UI表示用）
class DummyCountdown {
  String id;
  String eventName;
  DateTime targetDate;
  String? description;
  String? emoji;
}
```

### 継続日数データ
```dart
@freezed
class StreakData {
  String id; // 固定値 'user_streak'
  int currentStreak;
  int longestStreak; // 最長記録のみ保存
  DateTime lastTrackedDate;
  DateTime lastModified;
}
```

### 総合計時間データ
```dart
@freezed
class TotalData {
  String id; // 固定値 'user_total'
  int totalLoginDays; // 総ログイン日数
  int totalWorkTimeMinutes; // 総作業時間（分単位）
  DateTime lastTrackedDate;
  DateTime lastModified;
}

// ダミーデータ用（UI表示用）
class DummyUser {
  String name;
  String userId;
  String? avatarUrl;
  int streakDays;
  double totalFocusedHours; // 時間単位
  int totalLoginDays;
  String bio;
}
```

### イベントデータ
```dart
enum EventType {
  goalAchieved,      // 目標達成
  goalSet,           // 目標設定完了
  goalPeriodEnded,   // 目標期間終了
  streakMilestone,    // 連続日数大台
  totalHoursMilestone, // 総時間大台
  countdownEnded,     // カウントダウン終了
  countdownSet,       // カウントダウン設定完了
}

class DummyEvent {
  String id;
  EventType type;
  String title;
  String message;
  DateTime timestamp;
  Map<String, dynamic>? data;
}
```

## アーキテクチャ

### ディレクトリ構造
```
lib/
├── core/                    # アプリ全体の設定
│   ├── theme.dart
│   ├── route.dart
│   └── route_generator.dart
│
├── data/
│   ├── sources/            # 最低レイヤー（外部データソース）
│   ├── repositories/        # 中間レイヤー（汎用的なデータ操作）
│   ├── services/           # 横断的機能
│   └── models/             # 共通モデル
│
├── feature/                # 機能単位のビジネスロジック
│   ├── tracking/
│   ├── goals/
│   ├── countdown/
│   ├── streak/
│   ├── total/
│   └── setting/
│
└── presentation/
    ├── widgets/            # 汎用ウィジェット
    └── screens/           # 画面単位
```

### レイヤー間の依存関係
- **presentation → feature → data/repositories → data/sources → core**
- 下位レイヤーは上位レイヤーに依存しない

## プライバシー・セキュリティ

### カメラ処理
- **完全ローカル処理**: カメラ映像はデバイス上で処理され、サーバーに送信されない
- **検出結果のみ保存**: 検出されたカテゴリと時間のみを保存
- **カメラ映像**: ユーザーがオプトインした場合のみ表示

### データ保護
- 認証情報はFirebase Authで管理
- 機密データはSecureStorageに保存
- HTTPS通信のみ使用

## プラットフォーム対応

### 対応プラットフォーム
- **iOS**: ネイティブアプリ
- **Android**: ネイティブアプリ
- **Web**: Webアプリ（カメラAPI対応、無理な場合はPCアプリに転換）

### プラットフォーム固有機能
- **通知**: ネイティブアプリのみ（FCM不使用）
- **課金**: iOS/Android/Web対応
- **広告**: 各プラットフォームの基本的方法を採用

## 実装フェーズ

### Phase 1: 基本機能（MVP）
- トラッキング基本機能（多ラベル分類のみ）
- 目標設定・管理
- レポート基本機能（1日のみ）
- ユーザー認証・プロフィール
- カウントダウン機能

### Phase 2: 拡張機能
- 姿勢推定・視線推定による集中度判定
- レポート拡張（週間/月間/年間）
- イベント表示機能
- 通知機能

### Phase 3: ソーシャル機能
- フレンド機能
- タイムライン
- 記事機能

### Phase 4: 収益化
- 課金システム
- 広告システム
- 招待システム

