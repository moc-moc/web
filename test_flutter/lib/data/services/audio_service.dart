import 'package:audioplayers/audioplayers.dart';
import 'package:test_flutter/data/services/log_service.dart';

/// 音声アラートサービス
/// 
/// アラート音を再生するためのサービスです。
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// アラート音を再生（ループ再生）
  /// 
  /// アラートが表示されている間、音声をループ再生します。
  Future<void> playAlertSoundLoop() async {
    try {
      // 音声ファイル名（実際のファイル名に合わせる）
      const soundFileName = 'sounds/80921__justinbw__buttonchime02up.wav';
      
      try {
        // ループ再生モードに設定
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource(soundFileName));
        _isPlaying = true;
        LogMk.logDebug('アラート音をループ再生しました: $soundFileName', tag: 'AudioService.playAlertSoundLoop');
      } catch (e) {
        // 音声ファイルの再生に失敗した場合
        LogMk.logWarning(
          '音声ファイルの再生に失敗しました: $e',
          tag: 'AudioService.playAlertSoundLoop',
        );
        // フォールバックとしてビープ音を試行
        await _playBeepSound();
      }
    } catch (e) {
      LogMk.logError(
        'アラート音の再生エラー: $e',
        tag: 'AudioService.playAlertSoundLoop',
        error: e,
      );
      _isPlaying = false;
    }
  }

  /// アラート音を再生（1回のみ）
  /// 
  /// システムのデフォルトアラート音を使用します。
  /// 注意: このメソッドは後方互換性のため残していますが、通常は`playAlertSoundLoop()`を使用してください。
  @Deprecated('Use playAlertSoundLoop() instead')
  Future<void> playAlertSound() async {
    if (_isPlaying) {
      LogMk.logDebug('既に音声を再生中のため、スキップします', tag: 'AudioService.playAlertSound');
      return;
    }

    try {
      _isPlaying = true;
      
      // 音声ファイル名（実際のファイル名に合わせる）
      const soundFileName = 'sounds/80921__justinbw__buttonchime02up.wav';
      
      try {
        // 1回のみ再生モードに設定
        await _player.setReleaseMode(ReleaseMode.release);
        await _player.play(AssetSource(soundFileName));
        LogMk.logDebug('アラート音を再生しました: $soundFileName', tag: 'AudioService.playAlertSound');
      } catch (e) {
        // 音声ファイルの再生に失敗した場合
        LogMk.logWarning(
          '音声ファイルの再生に失敗しました: $e',
          tag: 'AudioService.playAlertSound',
        );
        // フォールバックとしてビープ音を試行
        await _playBeepSound();
      }
    } catch (e) {
      LogMk.logError(
        'アラート音の再生エラー: $e',
        tag: 'AudioService.playAlertSound',
        error: e,
      );
    } finally {
      _isPlaying = false;
    }
  }

  /// ビープ音を生成（Web環境用・フォールバック用）
  Future<void> _playBeepSound() async {
    // Web環境では、HTML5 Audio APIを使用してビープ音を生成
    // モバイル環境でもalert.mp3が存在しない場合のフォールバックとして使用
    try {
      // 実際の実装では、Web Audio APIを使用してビープ音を生成
      // ここでは簡易的な実装として、システムのデフォルト音を使用
      // 注意: プラットフォームによっては音が鳴らない場合があります
      LogMk.logDebug(
        'ビープ音を再生します',
        tag: 'AudioService._playBeepSound',
      );
      
      // 簡易的な実装: 音声ファイルが存在しない場合は、ログのみ出力
      // 実際のアプリでは、assets/sounds/alert.mp3を追加することを推奨します
      // または、プラットフォーム固有のシステム音を使用してください
    } catch (e) {
      LogMk.logError(
        'ビープ音の再生エラー: $e',
        tag: 'AudioService._playBeepSound',
        error: e,
      );
    }
  }

  /// 音声を停止
  /// 
  /// ループ再生を停止し、再生モードをリセットします。
  Future<void> stop() async {
    try {
      await _player.stop();
      // ループモードをリセット（次回の再生時に正しく設定される）
      await _player.setReleaseMode(ReleaseMode.release);
      _isPlaying = false;
      LogMk.logDebug('音声を停止しました', tag: 'AudioService.stop');
    } catch (e) {
      LogMk.logError(
        '音声停止エラー: $e',
        tag: 'AudioService.stop',
      );
    }
  }

  /// リソースを解放
  void dispose() {
    _player.dispose();
  }
}

