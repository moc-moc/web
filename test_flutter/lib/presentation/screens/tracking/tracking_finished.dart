import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_flutter/core/theme.dart';
import 'package:test_flutter/presentation/widgets/buttons.dart';
import 'package:test_flutter/feature/Streak/streak_data_manager.dart';
import 'package:test_flutter/feature/Streak/streak_functions.dart';
import 'package:test_flutter/feature/Total/total_data_manager.dart';
import 'package:test_flutter/feature/Total/total_functions.dart';

/// Tracking Finished画面
/// トラッキング完了画面
///
/// トラッキング完了時に以下の処理を実行します:
/// - 連続継続日数の記録
/// - 総ログイン日数と総作業時間の記録
class TrackingFinishedScreen extends ConsumerStatefulWidget {
  const TrackingFinishedScreen({super.key});

  @override
  ConsumerState<TrackingFinishedScreen> createState() =>
      _TrackingFinishedScreenState();
}

class _TrackingFinishedScreenState
    extends ConsumerState<TrackingFinishedScreen> {
  bool _isProcessing = true;
  String _message = 'トラッキングデータを保存中...';
  int _workTimeMinutes = 0;
  bool _hasReceivedArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 引数を一度だけ受け取る
    if (!_hasReceivedArguments) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _workTimeMinutes = args['total'] as int? ?? 0;
        debugPrint('🔍 [TrackingFinished] 受け取った作業時間: $_workTimeMinutes分');
      }
      _hasReceivedArguments = true;

      // トラッキング完了処理を実行
      _processTrackingFinished();
    }
  }

  /// トラッキング完了処理
  ///
  /// 連続継続日数と累計データを記録します。
  Future<void> _processTrackingFinished() async {
    try {
      debugPrint('🔍 [TrackingFinished] トラッキング完了処理開始');
      debugPrint('🔍 [TrackingFinished] 作業時間: $_workTimeMinutes分');

      // 1. データ保存：連続継続日数を記録
      final streakManager = StreakDataManager();
      final streakResult = await streakManager.trackFinished();
      final streakSuccess = streakResult['success'] as bool;
      final streakMessage = streakResult['message'] as String;

      debugPrint(
        '🔍 [TrackingFinished] Streak結果: $streakSuccess - $streakMessage',
      );

      // 2. データ保存：累計データを記録（受け取った作業時間を使用）
      final totalManager = TotalDataManager();
      final totalResult = await totalManager.trackFinished(
        workTimeMinutes: _workTimeMinutes,
      );
      final totalSuccess = totalResult['success'] as bool;
      final totalMessage = totalResult['message'] as String;

      debugPrint(
        '🔍 [TrackingFinished] Total結果: $totalSuccess - $totalMessage',
      );

      // 3. Providerを更新：保存されたデータを取得してProviderに反映
      final updatedStreakData = await streakManager.getStreakDataOrDefault();
      ref.read(streakDataProvider.notifier).updateStreak(updatedStreakData);
      debugPrint(
        '✅ [TrackingFinished] StreakProvider更新完了: ${updatedStreakData.currentStreak}日連続',
      );

      final updatedTotalData = await totalManager.getTotalDataOrDefault();
      ref.read(totalDataProvider.notifier).updateTotal(updatedTotalData);
      debugPrint(
        '✅ [TrackingFinished] TotalProvider更新完了: ${updatedTotalData.totalLoginDays}日、${updatedTotalData.totalWorkTimeMinutes}分',
      );

      // 4. 結果をUI に反映
      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (streakSuccess && totalSuccess) {
            _message = '$streakMessage\n$totalMessage';
          } else {
            _message = 'トラッキング完了！\n$streakMessage\n$totalMessage';
          }
        });

        // スナックバーで通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_message),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint('✅ [TrackingFinished] トラッキング完了処理完了');
    } catch (e) {
      debugPrint('❌ [TrackingFinished] トラッキング完了処理エラー: $e');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _message = 'エラーが発生しました';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エラーが発生しました'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Tracking Finished'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackgray,
        automaticallyImplyLeading: false, // 戻るボタンを無効化
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'トラッキング完了',
              style: TextStyle(
                color: AppColors.blackgray,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.blackgray,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 40),
            // pushNamedAndRemoveUntilでhome画面へ遷移（全履歴削除）
            CustomBackToHomeButton(text: 'OK', color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
