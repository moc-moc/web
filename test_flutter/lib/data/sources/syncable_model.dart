/// 同期可能なモデルのインターフェース
///
/// FirestoreとSharedPreferencesで同期されるモデルが実装すべきインターフェース。
/// このインターフェースを実装することで、データマネージャーでの同期処理が可能になります。
abstract class SyncableModel {
  /// モデルの一意識別子
  String get id;

  /// 最終更新日時
  DateTime get lastModified;

  /// 論理削除フラグ
  bool get isDeleted;
}
