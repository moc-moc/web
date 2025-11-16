import 'package:flutter/foundation.dart';

/// リスト管理Notifierの共通メソッドを提供するヘルパークラス
/// 
/// 各featureのリスト管理Notifierで共通のパターンを提供します。
/// 各Notifierクラスでこのヘルパークラスのメソッドを呼び出すことで、
/// 共通のメソッドを簡単に実装できます。
/// 
/// **使用方法**:
/// ```dart
/// @Riverpod(keepAlive: true)
/// class CountdownsList extends _$CountdownsList {
///   @override
///   List<Countdown> build() => [];
///   
///   void addCountdown(Countdown countdown) {
///     BaseListNotifierHelper.addItem(this, countdown);
///   }
/// }
/// ```
class BaseListNotifierHelper {
  /// リストにアイテムを追加
  /// 
  /// **パラメータ**:
  /// - `notifier`: Notifierインスタンス（stateプロパティを持つ）
  /// - `item`: 追加するアイテム
  static void addItem<T>(dynamic notifier, T item) {
    final currentList = notifier.state as List<T>;
    notifier.state = [...currentList, item];
  }

  /// リスト全体を更新
  /// 
  /// **パラメータ**:
  /// - `notifier`: Notifierインスタンス（stateプロパティを持つ）
  /// - `newList`: 新しいリスト
  static void updateList<T>(dynamic notifier, List<T> newList) {
    final currentList = notifier.state as List<T>;
    debugPrint('🔍 [BaseListNotifierHelper.updateList] 更新前: ${currentList.length}件 → 更新後: ${newList.length}件');
    notifier.state = newList;
  }

  /// IDでアイテムを削除
  /// 
  /// **パラメータ**:
  /// - `notifier`: Notifierインスタンス（stateプロパティを持つ）
  /// - `id`: 削除するアイテムのID
  /// - `getId`: アイテムからIDを取得する関数
  static void removeById<T>(dynamic notifier, String id, String Function(T) getId) {
    final currentList = notifier.state as List<T>;
    notifier.state = currentList.where((item) => getId(item) != id).toList();
  }

  /// リストをクリア
  /// 
  /// **パラメータ**:
  /// - `notifier`: Notifierインスタンス（stateプロパティを持つ）
  static void clear<T>(dynamic notifier) {
    notifier.state = <T>[];
  }
}

