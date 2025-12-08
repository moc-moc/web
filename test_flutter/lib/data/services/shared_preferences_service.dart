import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesのシングルトンサービス
/// 
/// SharedPreferencesへの並列アクセスを防ぐため、インスタンスをキャッシュし、
/// 複数回の`getInstance()`呼び出しを避けます。
class SharedPreferencesService {
  static SharedPreferences? _instance;
  static Future<SharedPreferences>? _initFuture;
  
  /// SharedPreferencesインスタンスを取得（キャッシュ付き）
  /// 
  /// 既にインスタンスが存在する場合はそれを返し、
  /// 初期化中の場合はその完了を待ちます。
  /// これにより、複数の`getInstance()`呼び出しによる並列アクセスを防ぎます。
  static Future<SharedPreferences> getInstance() async {
    // 既にインスタンスがある場合はそれを返す
    if (_instance != null) {
      return _instance!;
    }
    
    // 初期化中の場合は、その完了を待つ
    if (_initFuture != null) {
      return await _initFuture!;
    }
    
    // 初期化を開始
    _initFuture = SharedPreferences.getInstance();
    _instance = await _initFuture!;
    _initFuture = null;
    
    return _instance!;
  }
  
  /// インスタンスをクリア（テスト用）
  static void clearInstance() {
    _instance = null;
    _initFuture = null;
  }
}

