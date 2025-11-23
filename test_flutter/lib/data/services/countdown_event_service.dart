import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/route.dart';
import 'package:test_flutter/feature/countdown/countdown_functions.dart';

/// イベント表示待ちのカウントダウンIDを保持するセット
/// イベント表示中は削除されないようにするため
final Set<String> _pendingEventCountdownIds = <String>{};

/// カウントダウン終了イベントサービス
/// 
/// アプリ起動時にカウントダウン終了をチェックし、
/// 必要に応じてイベント画面を表示する処理を提供します。
class CountdownEventService {
  /// イベント表示待ちのカウントダウンIDを追加
  static void addPendingEventCountdownId(String countdownId) {
    _pendingEventCountdownIds.add(countdownId);
  }

  /// イベント表示待ちのカウントダウンIDを削除（イベント表示完了後）
  static void removePendingEventCountdownId(String countdownId) {
    _pendingEventCountdownIds.remove(countdownId);
  }

  /// イベント表示待ちのカウントダウンIDかどうかをチェック
  static bool isPendingEventCountdown(String countdownId) {
    return _pendingEventCountdownIds.contains(countdownId);
  }
  /// カウントダウン終了をチェックし、必要に応じてイベント画面を表示
  /// 
  /// **パラメータ**:
  /// - `ref`: RiverpodのWidgetRef
  /// - `navigator`: NavigatorState（イベント画面を表示するために使用）
  /// - `mounted`: ウィジェットがマウントされているかどうか
  /// 
  /// **戻り値**: イベント画面が表示された場合true、そうでない場合false
  static Future<bool> checkAndShowEndedCountdown({
    required WidgetRef ref,
    required NavigatorState? navigator,
    required bool mounted,
  }) async {
    if (!mounted || navigator == null) {
      return false;
    }

    try {
      // カウントダウンリストを取得
      final countdowns = ref.read(countdownsListProvider);
      final now = DateTime.now();

      // 残り期間が0以下のカウントダウンを検出（targetDateが現在時刻より前または等しい）
      final endedCountdowns = countdowns.where((countdown) {
        return countdown.targetDate.isBefore(now) || 
               countdown.targetDate.isAtSameMomentAs(now);
      }).toList();

      // 終了したカウントダウンがある場合、最初の1つを表示
      if (endedCountdowns.isNotEmpty) {
        final endedCountdown = endedCountdowns.first;
        
        // イベント表示待ちとしてマーク（削除されないようにするため）
        addPendingEventCountdownId(endedCountdown.id);
        
        // イベント画面を表示（画面が閉じられるまで待つ）
        await navigator.pushNamed(
          AppRoutes.countdownEndedEvent,
          arguments: {
            'eventName': endedCountdown.title,
            'countdownId': endedCountdown.id,
          },
        );
        
        // イベント画面が閉じられたら、待機リストから削除
        removePendingEventCountdownId(endedCountdown.id);
        
        return true;
      }
    } catch (e) {
      debugPrint('❌ [CountdownEventService] カウントダウン終了チェックエラー: $e');
    }

    return false;
  }

  /// アプリ起動時にカウントダウン終了をチェックする処理をスケジュール
  /// 
  /// データ読み込み完了を待ってからチェック処理を実行します。
  /// 
  /// **パラメータ**:
  /// - `ref`: RiverpodのWidgetRef
  /// - `navigator`: NavigatorState
  /// - `mounted`: ウィジェットがマウントされているかどうか
  static void scheduleCountdownCheck({
    required WidgetRef ref,
    required NavigatorState? navigator,
    required bool mounted,
  }) {
    // フレーム描画完了を待ってからチェック処理を実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkAndShowEndedCountdown(
          ref: ref,
          navigator: navigator,
          mounted: mounted,
        );
      }
    });
  }
}

