import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/data/services/shared_preferences_service.dart';

/// ログレベルを定義する列挙型
enum LogLevel {
  debug,   // デバッグ情報
  info,    // 通常情報
  warning, // 警告
  error,   // エラー
}

/// ログエントリ
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// JSONから生成
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      tag: json['tag'] as String?,
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'] as String)
          : null,
    );
  }
}

/// ロギング/監視の汎用的な基本関数
/// 
/// ログレベル管理とログ保存に関する基本的な操作を提供する関数群
/// カウントダウンなどの具体的なビジネスロジックは含まない
class LogMk {
  // ログ保存のキー
  static const String _logStorageKey = '_logmk_logs';
  
  // 最大保存ログ数（デフォルト: 1000件）
  static const int _maxLogEntries = 1000;
  
  // ログをコンソールに出力するかどうか
  static bool _consoleOutputEnabled = true;
  
  // 最小ログレベル（これ以下のレベルは出力しない）
  static LogLevel _minLogLevel = LogLevel.debug;
  
  // ログ保存処理のキュー（並列アクセスを防ぐ）
  static Future<void>? _saveQueue;

  /// コンソール出力を有効/無効にする
  /// 
  /// **パラメータ**:
  /// - `enabled`: 有効にする場合はtrue、無効にする場合はfalse
  static void setConsoleOutputEnabled(bool enabled) {
    _consoleOutputEnabled = enabled;
  }

  /// 最小ログレベルを設定
  /// 
  /// **パラメータ**:
  /// - `level`: 最小ログレベル（これ以下のレベルは出力しない）
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// ログを出力
  /// 
  /// **パラメータ**:
  /// - `level`: ログレベル
  /// - `message`: ログメッセージ
  /// - `tag`: タグ（オプション）
  /// - `error`: エラーオブジェクト（オプション）
  /// - `stackTrace`: スタックトレース（オプション）
  static Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    // 最小ログレベル以下の場合はスキップ
    if (_shouldSkipLog(level)) {
      return;
    }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // コンソールに出力
    if (_consoleOutputEnabled) {
      _outputToConsole(entry);
    }

    // ローカルに保存
    await _saveLogEntry(entry);
  }

  /// デバッグログを出力
  /// 
  /// **パラメータ**:
  /// - `message`: ログメッセージ
  /// - `tag`: タグ（オプション）
  static Future<void> logDebug(String message, {String? tag}) async {
    await log(LogLevel.debug, message, tag: tag);
  }

  /// 情報ログを出力
  /// 
  /// **パラメータ**:
  /// - `message`: ログメッセージ
  /// - `tag`: タグ（オプション）
  static Future<void> logInfo(String message, {String? tag}) async {
    await log(LogLevel.info, message, tag: tag);
  }

  /// 警告ログを出力
  /// 
  /// **パラメータ**:
  /// - `message`: ログメッセージ
  /// - `tag`: タグ（オプション）
  static Future<void> logWarning(String message, {String? tag}) async {
    await log(LogLevel.warning, message, tag: tag);
  }

  /// エラーログを出力
  /// 
  /// **パラメータ**:
  /// - `message`: ログメッセージ
  /// - `tag`: タグ（オプション）
  /// - `error`: エラーオブジェクト（オプション）
  /// - `stackTrace`: スタックトレース（オプション）
  static Future<void> logError(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// ログをローカルに保存
  /// 
  /// **パラメータ**:
  /// - `entries`: ログエントリのリスト
  /// 
  /// 注意: getLogs()を呼ばずに直接SharedPreferencesから読み込むことで、
  /// 再帰的なSharedPreferencesアクセスを防ぐ
  static Future<void> saveLogsToLocal(List<LogEntry> entries) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      
      // getLogs()を呼ばずに直接SharedPreferencesから読み込む
      final jsonString = prefs.getString(_logStorageKey);
      List<LogEntry> existingLogs = [];
      
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final jsonList = json.decode(jsonString) as List<dynamic>;
          existingLogs = jsonList
              .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          // JSONのパースエラーは無視して空のリストを使用
          existingLogs = [];
        }
      }
      
      // 既存のログと新しいログを結合
      final allLogs = [...existingLogs, ...entries];
      
      // 最大数まで制限
      final logsToSave = allLogs.length > _maxLogEntries
          ? allLogs.sublist(allLogs.length - _maxLogEntries)
          : allLogs;
      
      // JSONに変換して保存
      final jsonList = logsToSave.map((e) => e.toJson()).toList();
      final newJsonString = json.encode(jsonList);
      
      await prefs.setString(_logStorageKey, newJsonString);
      
      debugPrint('✅ ログ保存完了: ${entries.length}件（合計: ${logsToSave.length}件）');
    } catch (e) {
      debugPrint('❌ ログ保存エラー: $e');
    }
  }

  /// 保存されたログを取得
  /// 
  /// **戻り値**: ログエントリのリスト
  static Future<List<LogEntry>> getLogs() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final jsonString = prefs.getString(_logStorageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ ログ取得エラー: $e');
      return [];
    }
  }

  /// 指定されたレベルのログを取得
  /// 
  /// **パラメータ**:
  /// - `level`: ログレベル
  /// 
  /// **戻り値**: 該当するログエントリのリスト
  static Future<List<LogEntry>> getLogsByLevel(LogLevel level) async {
    final allLogs = await getLogs();
    return allLogs.where((log) => log.level == level).toList();
  }

  /// 指定されたタグのログを取得
  /// 
  /// **パラメータ**:
  /// - `tag`: タグ
  /// 
  /// **戻り値**: 該当するログエントリのリスト
  static Future<List<LogEntry>> getLogsByTag(String tag) async {
    final allLogs = await getLogs();
    return allLogs.where((log) => log.tag == tag).toList();
  }

  /// ログをクリア
  /// 
  /// **パラメータ**:
  /// - `level`: 指定されたレベルのみをクリアする場合（オプション）
  /// 
  /// 注意: getLogs()を呼ばずに直接SharedPreferencesから読み込むことで、
  /// 再帰的なSharedPreferencesアクセスを防ぐ
  static Future<void> clearLogs({LogLevel? level}) async {
    try {
      if (level != null) {
        // 指定されたレベルのみをクリア
        final prefs = await SharedPreferences.getInstance();
        
        // getLogs()を呼ばずに直接SharedPreferencesから読み込む
        final jsonString = prefs.getString(_logStorageKey);
        List<LogEntry> allLogs = [];
        
        if (jsonString != null && jsonString.isNotEmpty) {
          try {
            final jsonList = json.decode(jsonString) as List<dynamic>;
            allLogs = jsonList
                .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
            // JSONのパースエラーは無視して空のリストを使用
            allLogs = [];
          }
        }
        
        final filteredLogs = allLogs.where((log) => log.level != level).toList();
        final jsonList = filteredLogs.map((e) => e.toJson()).toList();
        final newJsonString = json.encode(jsonList);
        await prefs.setString(_logStorageKey, newJsonString);
        
        debugPrint('✅ ログクリア完了: ${level.name}レベル');
      } else {
        // 全てのログをクリア
        final prefs = await SharedPreferencesService.getInstance();
        await prefs.remove(_logStorageKey);
        debugPrint('✅ 全ログクリア完了');
      }
    } catch (e) {
      debugPrint('❌ ログクリアエラー: $e');
    }
  }

  /// ログの件数を取得
  /// 
  /// **戻り値**: ログの件数
  static Future<int> getLogCount() async {
    final logs = await getLogs();
    return logs.length;
  }

  // ===== プライベートヘルパー関数 =====

  /// ログをスキップするかどうかを判定
  static bool _shouldSkipLog(LogLevel level) {
    // ログレベルの優先順位: debug < info < warning < error
    final levelValues = {
      LogLevel.debug: 0,
      LogLevel.info: 1,
      LogLevel.warning: 2,
      LogLevel.error: 3,
    };
    
    return levelValues[level]! < levelValues[_minLogLevel]!;
  }

  /// コンソールに出力
  static void _outputToConsole(LogEntry entry) {
    final prefix = _getLogPrefix(entry.level);
    final tagStr = entry.tag != null ? '[${entry.tag}] ' : '';
    final message = '$prefix$tagStr${entry.message}';
    
    if (entry.level == LogLevel.error) {
      debugPrint(message);
      if (entry.error != null) {
        debugPrint('エラー: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        debugPrint('スタックトレース: ${entry.stackTrace}');
      }
    } else {
      debugPrint(message);
    }
  }

  /// ログプレフィックスを取得
  static String _getLogPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 [DEBUG] ';
      case LogLevel.info:
        return 'ℹ️ [INFO] ';
      case LogLevel.warning:
        return '⚠️ [WARN] ';
      case LogLevel.error:
        return '❌ [ERROR] ';
    }
  }

  /// ログエントリを保存（内部使用）
  /// 
  /// SharedPreferencesへの並列アクセスを防ぐため、キューイングして順次実行
  static Future<void> _saveLogEntry(LogEntry entry) async {
    // 前の保存処理が完了するまで待つ
    if (_saveQueue != null) {
      try {
        await _saveQueue;
      } catch (e) {
        // 前の処理でエラーが発生しても続行
      }
    }
    
    // 新しい保存処理をキューに追加
    _saveQueue = _saveLogEntryInternal(entry);
    
    try {
      await _saveQueue;
    } catch (e) {
      // エラーは既に内部で処理されている
    } finally {
      // 処理が完了したらキューをクリア
      _saveQueue = null;
    }
  }
  
  /// ログエントリを保存（内部実装）
  /// 
  /// getLogs()を呼ばずに直接SharedPreferencesから読み込むことで、
  /// 再帰的なSharedPreferencesアクセスを防ぐ
  static Future<void> _saveLogEntryInternal(LogEntry entry) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      
      // getLogs()を呼ばずに直接SharedPreferencesから読み込む
      final jsonString = prefs.getString(_logStorageKey);
      List<LogEntry> existingLogs = [];
      
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final jsonList = json.decode(jsonString) as List<dynamic>;
          existingLogs = jsonList
              .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          // JSONのパースエラーは無視して空のリストを使用
          existingLogs = [];
        }
      }
      
      // 新しいエントリを追加
      final allLogs = [entry, ...existingLogs];
      
      // 最大数まで制限
      final logsToSave = allLogs.length > _maxLogEntries
          ? allLogs.sublist(0, _maxLogEntries)
          : allLogs;
      
      // JSONに変換して保存
      final jsonList = logsToSave.map((e) => e.toJson()).toList();
      final newJsonString = json.encode(jsonList);
      
      await prefs.setString(_logStorageKey, newJsonString);
    } catch (e) {
      // ログ保存のエラーはコンソールに出力しない（無限ループ防止）
      // ただし、デバッグモードでは出力する
      if (_consoleOutputEnabled) {
      debugPrint('ログ保存エラー: $e');
      }
    }
  }
}


