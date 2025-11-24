# Firebaseセットアップ手順

Flutterアプリでメール／パスワード認証とFirestoreを使うまでの流れをまとめました。Firebase経験がなくても進められるように、作業順でチェックできる形にしています。

## 1. Firebaseプロジェクトを作成
1. https://console.firebase.google.com にアクセスし、「プロジェクトを追加」から新規作成します。
2. プロジェクト名を入力し、Google アナリティクスは必要に応じて有効／無効を選びます。
3. 作成完了後、左メニュー「Build > Authentication」で「始める」を押し、**メール／パスワード**を有効化します。
4. 同じく「Firestore Database」で本番用データベースを作成し、ロケーションを決定します（テストモードで作成し、後で `firestore.rules` をデプロイしてもOK）。

## 2. 各プラットフォームのアプリ登録
Firebaseコンソール上部の歯車 →「プロジェクトの設定」→「全般」タブから、順番に各プラットフォームを登録します。

### Android
1. 「アプリを追加」→ Android を選択。
2. `android/app/src/main/AndroidManifest.xml` の `package` 名を入力（例: `com.example.test_flutter`）。SHA-1/256は後から追加できます。
3. 生成された `google-services.json` を `android/app/` に配置。
4. `android/build.gradle.kts` と `android/app/build.gradle.kts` の Google Services プラグイン設定を確認（既に済の場合はスキップ）。

### iOS / macOS
1. 「アプリを追加」→ iOS を選択し、`ios/Runner.xcodeproj` の bundle identifier（例: `com.example.testFlutter`）を入力。
2. `GoogleService-Info.plist` を `ios/Runner/` に置き、同じファイルを `macos/Runner/` にもコピー。
3. Xcode の Runner ターゲットで `GoogleService-Info.plist` がバンドルされていることを確認。

### Web / Windows
1. 「アプリを追加」→ Web を選択し、任意のニックネームとホスティング設定を入力。
2. 表示された `firebaseConfig` の値（apiKey や authDomain 等）を後述の `lib/firebase_options.dart` に反映します。
3. Windows ビルドも Firebase を使う場合、Web と同じ API キーを使って `flutterfire configure` で Windows ターゲットを有効化します。

## 3. Flutter へのSDK設定
1. ルートで `dart pub global activate flutterfire_cli` を実行（初回のみ）。
2. 下記コマンドでプラットフォームを一括設定します（必要に応じて `--project` でID指定）。
   ```bash
   cd /Users/ki/Documents/GitHub/web/test_flutter
   flutterfire configure --platforms=android,ios,macos,web,windows
   ```
3. コマンド完了後、`lib/firebase_options.dart` が生成されるので Git に追加します（本リポジトリでは雛形をコミット済み。必要なら `flutterfire configure` で上書き）。
4. 依存パッケージが不足している場合は `flutter pub add firebase_core firebase_auth cloud_firestore` を実行します。

## 4. アプリ起動時の初期化
1. `lib/main.dart` の `main()` で `WidgetsFlutterBinding.ensureInitialized()` → `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` を呼び出します。
2. すべての `runApp` が `ProviderScope`/`UncontrolledProviderScope` 内で実行されていることを確認します。
3. Web で Firebase App Check を使う場合は、`firebase_app_check` を追加し、`FirebaseAppCheck.instance.activate()` を呼び出します（任意）。

## 5. FirestoreとAuthのルールデプロイ
1. 既存の `firestore.rules` や `firebase.json` を編集したら、Firebase CLI でデプロイします。
   ```bash
   firebase deploy --only firestore:rules
   ```
2. 認証メールを必須にする場合、Firestore ルールや UI で `emailVerified` を参照し、未確認ユーザーの書き込みを制限します。

## 6. 動作確認チェックリスト
- [ ] `flutter run -d ios` / `-d android` でアプリ起動→Firebase初期化ログが出る。
- [ ] サインアップ→メールリンク送信／クリック→サインイン再試行で `emailVerified = true`。
- [ ] Firestore の `users/{uid}` にニックネームと目標値が保存される。
- [ ] サインアウト後は `AuthController` が未ログイン状態になり、保護画面へリダイレクトされる。
- [ ] Web 版でも `Firebase.initializeApp` が `DefaultFirebaseOptions.currentPlatform` を使って動作する。

必要に応じてこの手順書を追記し、チーム全員が同じ流れで環境構築できるようにしてください。


以下は、現状（Google認証は稼働中）を前提に、メール認証＋Firestoreを正しく動かすために必要な作業だけを順番にまとめたものです。

1. **メール/パスワード認証の有効化（Firebase Console）**  
   - コンソールの「Authentication > Sign-in method」で **Email/Password** を「有効」にします。  
   - まだなら同画面で「メールアドレスの確認」を必須に設定。

2. **Firestore ルールの更新**  
   - 先ほどの `email_verified` チェックを含むルールに差し替え（`firestore.rules` を編集）。  
   - 例:
     ```rules
     function isVerifiedUser(userId) {
       return request.auth != null &&
              request.auth.uid == userId &&
              request.auth.token.email_verified == true;
     }
     ...
     allow read, write: if isVerifiedUser(userId);
     ```
   - 変更後 `firebase deploy --only firestore:rules` で反映。

3. **Flutter 側の Firebase 設定確認**  
   - `lib/firebase_options.dart` に最新の API キー/ID が入っているか確認。Google認証が動くなら基本OKですが、メール認証用にも共通なので念のため再確認。  
   - `main.dart` の `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` が呼ばれているかチェック（既に実装済みならスキップ）。

4. **メールサインアップ導線の検証**  
   - `SignupLoginScreen` でメール＋パスワード登録を実行し、メール送信→確認リンク→再サインインの流れを手動で確かめる。  
   - Firestore の `users/{uid}` に初期プロフィールが書かれ、メール未認証時はルールでブロックされることを確認。

5. **Web/iOS/Android での動作確認**  
   - 主要プラットフォーム（最低 Web＋ターゲットOS）で `flutter run` → サインアップ/認証/Firestore書き込み→サインアウト を通し、挙動とエラー表示をチェック。

既に Google 認証が成功しているため、新規プロジェクト作成や Google Service ファイルの配置といった初期セットアップ手順は省略可能です。上記 1〜5 を完了すれば、メール認証ユーザーにも安全な Firestore アクセス制御が適用されます。