# 画面実装ガイドライン

このファイルは、新しい画面を実装する際の必須チェックリストです。

## 📋 新しい画面を作成する際の必須ステップ

### ステップ1: 画面ファイルを作成
- [ ] `lib/presentation/screens/[カテゴリ]/[画面名].dart`を作成
- [ ] デザインシステムのコンポーネントを使用
- [ ] ダミーデータを使用

### ステップ2: ルーティングに登録（必須！）
- [ ] `lib/core/route.dart`の`AppRoutes`クラスにルート定数を追加
- [ ] `RouteGenerator._routeMap`にマッピングを追加
- [ ] 画面のインポート文を追加

```dart
// AppRoutesに追加
static const String myNewScreen = '/my-new-screen';

// インポート追加
import 'package:test_flutter/presentation/screens/xxx/my_new_screen.dart';

// _routeMapに追加
AppRoutes.myNewScreen: () => const MyNewScreen(),
```

### ステップ3: 関連画面から遷移できるようにする
- [ ] 関連する画面にナビゲーションボタン/リンクを追加
- [ ] **関連画面が不明な場合**: 設定画面のテストセクションに追加

```dart
// 設定画面に追加する場合（settings_screen.dart）
SettingsTile(
  icon: Icons.preview,
  iconBackgroundColor: AppColors.purple,
  title: '🧪 [画面名]（テスト用）',
  onTap: () {
    Navigator.pushNamed(context, AppRoutes.myNewScreen);
  },
),
```

### ステップ4: 動作確認
- [ ] アプリをrunして画面が表示されることを確認
- [ ] 画面遷移が正しく動作することを確認
- [ ] デザインシステムが適用されていることを確認

### ステップ5: Lintチェックとフォーマット
- [ ] `dart format [ファイルパス]`を実行
- [ ] lintエラーがないことを確認

## 🔄 画面遷移パターン

### パターン1: 通常のpush（戻れる）
```dart
Navigator.pushNamed(context, AppRoutes.targetScreen);
```

### パターン2: 置き換え（戻れない）
```dart
Navigator.pushReplacementNamed(context, AppRoutes.targetScreen);
```

### パターン3: すべてクリアしてホームへ
```dart
Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
```

### パターン4: 戻る
```dart
Navigator.pop(context);
```

## 📁 設定画面のテストセクション

関連画面が不明な場合や、イベント画面などのプレビューが必要な場合は、
設定画面（`settings_screen.dart`）の`_buildSettingsList`メソッドの
「テスト用セクション」に項目を追加してください。

### 現在のテスト項目
- 🧪 認証フロー（サインアップ/ログイン画面）

### 今後追加予定
- イベントプレビュー（Phase 9で実装予定）
- その他、テストが必要な画面

## ⚠️ 注意事項

1. **必ずルーティングに登録する**: 画面を作成したらすぐにroute.dartに登録
2. **動作確認を怠らない**: 実装後は必ず実際にrunして確認
3. **関連画面からアクセス可能にする**: ユーザーが自然にたどり着けるように
4. **テスト項目は絵文字で識別**: 🧪 をつけて本番機能と区別

## 🎯 このガイドラインの目的

- すべての画面が実際に表示可能な状態を維持
- 実装した機能をすぐに確認できる
- 画面遷移フローが明確
- デバッグとテストが容易

