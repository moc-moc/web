import 'dart:async';
import 'dart:io';
import 'package:test_flutter/data/services/log_service.dart';

/// ネットワーク状態
enum NetworkStatus {
  online,   // オンライン
  offline,  // オフライン
  unknown,  // 不明
}

/// ネットワーク監視の汎用的な基本関数
/// 
/// ネットワーク状態の監視に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class NetworkMk {
  // ネットワーク状態のストリームコントローラー
  static StreamController<NetworkStatus>? _networkStatusController;
  
  // 定期チェックのタイマー
  static Timer? _periodicCheckTimer;
  
  // 現在のネットワーク状態
  static NetworkStatus _currentStatus = NetworkStatus.unknown;

  /// ネットワーク状態の変更を監視
  /// 
  /// **処理フロー**:
  /// 1. 定期的にネットワーク接続をチェック
  /// 2. 状態が変わったらStreamに流す
  /// 
  /// **パラメータ**:
  /// - `checkInterval`: チェック間隔（デフォルト: 5秒）
  /// 
  /// **戻り値**: ネットワーク状態のStream
  static Stream<NetworkStatus> watchNetworkStatus({
    Duration checkInterval = const Duration(seconds: 5),
  }) {
    if (_networkStatusController == null || _networkStatusController!.isClosed) {
      _networkStatusController = StreamController<NetworkStatus>.broadcast(
        onListen: () {
          LogMk.logDebug('ネットワーク監視開始', tag: 'NetworkMk.watchNetworkStatus');
          _startPeriodicCheck(checkInterval);
        },
        onCancel: () {
          LogMk.logDebug('ネットワーク監視停止', tag: 'NetworkMk.watchNetworkStatus');
          _stopPeriodicCheck();
        },
      );
      
      // 初回チェック
      _checkNetworkStatus();
    }
    
    return _networkStatusController!.stream;
  }

  /// ネットワーク利用可能性を確認
  /// 
  /// **処理フロー**:
  /// 1. google.comへの接続を試行
  /// 2. 成功したらオンライン、失敗したらオフライン
  /// 
  /// **戻り値**: ネットワークが利用可能な場合はtrue
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      final isAvailable = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isAvailable) {
        await LogMk.logDebug('ネットワーク: オンライン', tag: 'NetworkMk.isNetworkAvailable');
      } else {
        await LogMk.logDebug('ネットワーク: オフライン', tag: 'NetworkMk.isNetworkAvailable');
      }
      
      return isAvailable;
    } on SocketException {
      await LogMk.logDebug('ネットワーク: オフライン (SocketException)', tag: 'NetworkMk.isNetworkAvailable');
      return false;
    } on TimeoutException {
      await LogMk.logDebug('ネットワーク: オフライン (Timeout)', tag: 'NetworkMk.isNetworkAvailable');
      return false;
    } catch (e) {
      await LogMk.logWarning('ネットワークチェックエラー: $e', tag: 'NetworkMk.isNetworkAvailable');
      return false;
    }
  }

  /// 現在のネットワーク状態を取得
  /// 
  /// **戻り値**: 現在のネットワーク状態
  static NetworkStatus getCurrentStatus() {
    return _currentStatus;
  }

  /// ネットワーク状態をリセット
  /// 
  /// ストリームをクローズして監視を停止する
  static void resetNetworkMonitoring() {
    _stopPeriodicCheck();
    _networkStatusController?.close();
    _networkStatusController = null;
    _currentStatus = NetworkStatus.unknown;
    LogMk.logDebug('ネットワーク監視リセット', tag: 'NetworkMk.resetNetworkMonitoring');
  }

  // ===== プライベートヘルパー関数 =====

  /// 定期的なネットワークチェックを開始
  static void _startPeriodicCheck(Duration interval) {
    _periodicCheckTimer?.cancel();
    
    _periodicCheckTimer = Timer.periodic(interval, (timer) {
      _checkNetworkStatus();
    });
  }

  /// 定期的なネットワークチェックを停止
  static void _stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  /// ネットワーク状態をチェック
  static Future<void> _checkNetworkStatus() async {
    try {
      final isAvailable = await isNetworkAvailable();
      final newStatus = isAvailable ? NetworkStatus.online : NetworkStatus.offline;
      
      // 状態が変わった場合のみStreamに流す
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _networkStatusController?.add(newStatus);
        
        await LogMk.logInfo(
          'ネットワーク状態変更: ${newStatus.name}',
          tag: 'NetworkMk._checkNetworkStatus',
        );
      }
    } catch (e) {
      await LogMk.logError(
        'ネットワーク状態チェックエラー',
        tag: 'NetworkMk._checkNetworkStatus',
        error: e,
      );
    }
  }
}

