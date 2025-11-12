import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // SharedPreferencesのモックを初期化
    SharedPreferences.setMockInitialValues({});
  });

  group('LogMk Tests', () {
    test('logDebug - デバッグログを出力', () async {
      await LogMk.logDebug('テストメッセージ', tag: 'Test');
      
      final logs = await LogMk.getLogs();
      expect(logs.isNotEmpty, true);
      expect(logs.first.level, LogLevel.debug);
      expect(logs.first.message, 'テストメッセージ');
      expect(logs.first.tag, 'Test');
    });

    test('logInfo - 情報ログを出力', () async {
      await LogMk.logInfo('情報メッセージ', tag: 'Info');
      
      final logs = await LogMk.getLogs();
      expect(logs.any((log) => log.level == LogLevel.info), true);
    });

    test('logWarning - 警告ログを出力', () async {
      await LogMk.logWarning('警告メッセージ', tag: 'Warning');
      
      final logs = await LogMk.getLogs();
      expect(logs.any((log) => log.level == LogLevel.warning), true);
    });

    test('logError - エラーログを出力', () async {
      await LogMk.logError('エラーメッセージ', tag: 'Error', error: Exception('test'));
      
      final logs = await LogMk.getLogs();
      expect(logs.any((log) => log.level == LogLevel.error), true);
    });

    test('getLogsByLevel - 指定レベルのログを取得', () async {
      await LogMk.logDebug('デバッグ');
      await LogMk.logInfo('情報');
      await LogMk.logError('エラー');
      
      final errorLogs = await LogMk.getLogsByLevel(LogLevel.error);
      expect(errorLogs.length, 1);
      expect(errorLogs.first.message, 'エラー');
    });

    test('clearLogs - ログをクリア', () async {
      await LogMk.logInfo('テスト');
      await LogMk.clearLogs();
      
      final logs = await LogMk.getLogs();
      expect(logs.isEmpty, true);
    });

    test('setMinLogLevel - 最小ログレベルを設定', () async {
      LogMk.setMinLogLevel(LogLevel.warning);
      
      await LogMk.logDebug('デバッグ（出力されない）');
      await LogMk.logInfo('情報（出力されない）');
      await LogMk.logWarning('警告');
      
      final logs = await LogMk.getLogs();
      expect(logs.length, 1);
      expect(logs.first.level, LogLevel.warning);
      
      // リセット
      LogMk.setMinLogLevel(LogLevel.debug);
    });
  });
}

