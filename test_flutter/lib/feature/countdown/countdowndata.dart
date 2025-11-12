import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_flutter/data/repositories/firestore_repository.dart';

part 'countdowndata.freezed.dart';
part 'countdowndata.g.dart';

/// カウントダウンモデル
///
/// ユーザーが設定するタイトルと目標日時を管理します。
/// Freezedを使用してイミュータブルなモデルを実現しています。
///
/// **フィールド**:
/// - `id`: カウントダウンを一意に識別するID
/// - `title`: カウントダウンのタイトル（ユーザー設定）
/// - `targetDate`: 目標日時（ユーザー設定）
/// - `isDeleted`: 論理削除フラグ（削除済みかどうか）
/// - `lastModified`: 最終更新日時（同期管理用）
@freezed
abstract class Countdown with _$Countdown {
  /// Countdownモデルのコンストラクタ
  ///
  const factory Countdown({
    required String id,
    required String title,
    required DateTime targetDate,
    @Default(false) bool isDeleted,
    required DateTime lastModified,
  }) = _Countdown;

  /// JSONからCountdownモデルを生成
  ///
  /// SharedPreferencesからの読み込み時に使用されます。
  factory Countdown.fromJson(Map<String, dynamic> json) =>
      _$CountdownFromJson(json);
}

/// カウントダウン用データマネージャー
///
/// data_manager_shared_un.dartのFirestoreDataManagerを使用して
/// カウントダウンデータの管理を行います。
///
/// **提供機能**:
/// - 基本CRUD操作（追加、取得、更新、削除）
/// - ローカルストレージ（SharedPreferences）との同期
/// - リトライ機能（失敗時の自動再試行）
/// - クエリ機能（条件付き取得）
/// - 論理削除サポート
class CountdownDataManager {
  /// FirestoreDataManagerのインスタンス
  ///
  /// このインスタンスがすべてのデータ操作を担当します。
  late final FirestoreDataManager<Countdown> _manager;

  /// コンストラクタ
  ///
  /// FirestoreDataManager<Countdown>のインスタンスを作成し、
  /// 各種変換関数とコレクションパスを設定します。
  CountdownDataManager() {
    _manager = FirestoreDataManager<Countdown>(
      // コレクションパス: users/{userId}/countdowns
      collectionPathBuilder: (userId) => 'users/$userId/countdowns',

      // Firestoreデータ → Countdownモデル変換
      // Timestamp → DateTime変換を行う
      fromFirestore: (data) {
        return Countdown(
          id: data['id'] as String,
          title: data['title'] as String,
          targetDate: (data['targetDate'] as Timestamp).toDate(),
          isDeleted: data['isDeleted'] as bool? ?? false,
          lastModified: (data['lastModified'] as Timestamp).toDate(),
        );
      },

      // Countdownモデル → Firestoreデータ変換
      // DateTime → Timestamp変換を行う
      toFirestore: (countdown) {
        return {
          'id': countdown.id,
          'title': countdown.title,
          'targetDate': Timestamp.fromDate(countdown.targetDate),
          'isDeleted': countdown.isDeleted,
          'lastModified': Timestamp.fromDate(countdown.lastModified),
        };
      },

      // SharedPreferencesのストレージキー
      storageKey: 'countdowns',

      // JSON → Countdownモデル変換（Freezedの生成メソッドを使用）
      fromJson: (json) => Countdown.fromJson(json),

      // Countdownモデル → JSON変換（Freezedの生成メソッドを使用）
      toJson: (countdown) => countdown.toJson(),

      // IDフィールド名（デフォルト値）
      idField: 'id',

      // 最終更新フィールド名（デフォルト値）
      lastModifiedField: 'lastModified',
    );
  }

  // ===== 基本CRUD操作 =====

  /// カウントダウンを追加
  ///
  Future<bool> addCountdown(String userId, Countdown countdown) async {
    return await _manager.add(userId, countdown);
  }

  /// カウントダウンを追加（認証自動取得版）
  ///
  Future<bool> addCountdownWithAuth(Countdown countdown) async {
    return await _manager.addWithAuth(countdown);
  }

  /// 全カウントダウンを取得
  ///
  Future<List<Countdown>> getAllCountdowns(String userId) async {
    return await _manager.getAll(userId);
  }

  /// 全カウントダウンを取得（認証自動取得版）
  ///
  Future<List<Countdown>> getAllCountdownsWithAuth() async {
    return await _manager.getAllWithAuth();
  }

  /// カウントダウンを更新
  ///
  Future<bool> updateCountdown(String userId, Countdown countdown) async {
    return await _manager.update(userId, countdown);
  }

  /// カウントダウンを更新（認証自動取得版）
  ///
  Future<bool> updateCountdownWithAuth(Countdown countdown) async {
    return await _manager.updateWithAuth(countdown);
  }

  /// カウントダウンを削除（物理削除）
  ///
  Future<bool> deleteCountdown(String userId, String id) async {
    return await _manager.delete(userId, id);
  }

  /// カウントダウンを削除（認証自動取得版）
  ///
  Future<bool> deleteCountdownWithAuth(String id) async {
    return await _manager.deleteWithAuth(id);
  }

  // ===== ローカルストレージ操作 =====

  /// ローカルから全カウントダウンを取得
  ///
  Future<List<Countdown>> getLocalCountdowns() async {
    return await _manager.getLocalAll();
  }

  /// ローカルからカウントダウンを取得
  ///
  Future<Countdown?> getLocalCountdownById(String id) async {
    return await _manager.getLocalById(id);
  }

  /// ローカルにカウントダウンを保存
  ///
  Future<void> saveLocalCountdowns(List<Countdown> countdowns) async {
    await _manager.saveLocal(countdowns);
  }

  /// ローカルデータをクリア
  Future<void> clearLocalCountdowns() async {
    await _manager.clearLocal();
  }

  /// ローカルのカウントダウン数を取得
  ///
  Future<int> getLocalCountdownsCount() async {
    return await _manager.getLocalCount();
  }

  // ===== 同期機能 =====

  /// FirestoreとSharedPreferencesを同期
  ///
  Future<List<Countdown>> syncCountdowns(String userId) async {
    return await _manager.sync(userId);
  }

  /// FirestoreとSharedPreferencesを同期（認証自動取得版）
  ///
  Future<List<Countdown>> syncCountdownsWithAuth() async {
    return await _manager.syncWithAuth();
  }

  /// 強制同期（全データ取得）
  ///
  Future<List<Countdown>> forceSync(String userId) async {
    return await _manager.forceSync(userId);
  }

  /// ローカルの変更をFirestoreにプッシュ
  ///
  Future<int> pushLocalChanges(String userId) async {
    return await _manager.pushLocalChanges(userId);
  }

  /// 最終同期時刻を取得
  ///
  Future<DateTime?> getLastSyncTime() async {
    return await _manager.getLastSyncTime();
  }

  /// 同期状態をリセット
  Future<void> resetSyncState() async {
    await _manager.resetSyncState();
  }

  // ===== リトライ機能 =====

  /// リトライ機能付きでカウントダウンを追加
  ///
  Future<bool> addCountdownWithRetry(String userId, Countdown countdown) async {
    return await _manager.addWithRetry(userId, countdown);
  }

  /// リトライ機能付きでカウントダウンを更新
  ///
  Future<bool> updateCountdownWithRetry(
    String userId,
    Countdown countdown,
  ) async {
    return await _manager.updateWithRetry(userId, countdown);
  }

  /// リトライ機能付きでカウントダウンを削除
  ///
  Future<bool> deleteCountdownWithRetry(String userId, String id) async {
    return await _manager.deleteWithRetry(userId, id);
  }

  /// キュー処理（失敗した操作を再試行）
  ///
  Future<int> processQueue(String userId) async {
    return await _manager.processQueue(userId);
  }

  /// キュー統計を取得
  ///
  Future<Map<String, int>> getQueueStats() async {
    return await _manager.getQueueStats();
  }

  /// キューを全クリア
  Future<void> clearQueue() async {
    await _manager.clearQueue();
  }

  /// 失敗した操作を再試行
  ///
  Future<int> retryFailedOperations(String userId) async {
    return await _manager.retryFailedOperations(userId);
  }

  // ===== クエリ機能 =====

  /// アクティブなカウントダウンのみを取得（isDeleted=false）
  ///
  Future<List<Countdown>> getActiveCountdowns(String userId) async {
    return await _manager.getAllWithQuery(
      userId,
      whereConditions: {'isDeleted': false},
    );
  }

  /// アクティブなカウントダウンのみを取得（認証自動取得版）
  ///
  Future<List<Countdown>> getActiveCountdownsWithAuth() async {
    final countdowns = await _manager.getAllWithAuth();
    return countdowns.where((countdown) => !countdown.isDeleted).toList();
  }

  /// 条件付きでカウントダウンを取得
  ///
  Future<List<Countdown>> getCountdownsWithQuery(
    String userId, {
    Map<String, dynamic>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    return await _manager.getAllWithQuery(
      userId,
      whereConditions: whereConditions,
      orderBy: orderBy,
      descending: descending,
      limit: limit,
    );
  }

  /// ソート付きでカウントダウンを取得
  ///
  Future<List<Countdown>> getCountdownsWithSort(
    String userId,
    String orderBy, {
    bool descending = false,
    int? limit,
  }) async {
    return await _manager.getAllWithSort(
      userId,
      orderBy,
      descending: descending,
      limit: limit,
    );
  }

  // ===== カスタム機能（カウントダウン特有） =====

  /// カウントダウンを論理削除
  ///
  /// isDeletedフラグをtrueに設定します。
  ///
  Future<bool> softDeleteCountdown(String userId, String id) async {
    return await _manager.updatePartial(userId, id, {'isDeleted': true});
  }

  /// カウントダウンを論理削除（認証自動取得版）
  ///
  /// isDeletedフラグをtrueに設定します。
  ///
  Future<bool> softDeleteCountdownWithAuth(String id) async {
    return await _manager.updatePartialWithAuth(id, {'isDeleted': true});
  }

  /// 論理削除されたカウントダウンを取得
  ///
  Future<List<Countdown>> getDeletedCountdowns(String userId) async {
    return await _manager.getAllWithQuery(
      userId,
      whereConditions: {'isDeleted': true},
    );
  }

  /// カウントダウンを復元（isDeletedをfalseに戻す）
  ///
  Future<bool> restoreCountdown(String userId, String id) async {
    return await _manager.updatePartial(userId, id, {'isDeleted': false});
  }

  // ===== 高度な機能 =====

  /// リアルタイム監視を開始
  ///
  Stream<List<Countdown>> watchAllCountdowns(String userId) {
    return _manager.watchAll(userId);
  }

  /// 指定IDのカウントダウンをリアルタイム監視
  ///
  Stream<Countdown?> watchCountdownById(String userId, String id) {
    return _manager.watchById(userId, id);
  }

  /// リアルタイム同期を開始
  ///
  Future<void> startRealtimeSync(String userId) async {
    await _manager.startRealtimeSync(userId);
  }

  /// リアルタイム同期を停止
  Future<void> stopRealtimeSync() async {
    await _manager.stopRealtimeSync();
  }
}
