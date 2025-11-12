/// エラーの種類を定義する列挙型
enum ErrorType {
  network, // ネットワークエラー
  validation, // バリデーションエラー
  sync, // 同期エラー
  storage, // ストレージエラー
  authentication, // 認証エラー
  permission, // 権限エラー
  unknown, // 不明なエラー
}

/// データマネージャーのカスタムエラー型
///
/// FirestoreDataManagerで発生するエラーを表す
class DataManagerError implements Exception {
  /// エラーの種類
  final ErrorType type;

  /// エラーメッセージ
  final String message;

  /// 元のエラーオブジェクト（オプション）
  final Object? originalError;

  /// スタックトレース（オプション）
  final StackTrace? stackTrace;

  /// エラーコード（オプション）
  final String? code;

  /// 追加情報（オプション）
  final Map<String, dynamic>? metadata;

  DataManagerError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
    this.code,
    this.metadata,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('DataManagerError(${type.name}): $message');

    if (code != null) {
      buffer.writeln('コード: $code');
    }

    if (originalError != null) {
      buffer.writeln('元のエラー: $originalError');
    }

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('メタデータ: $metadata');
    }

    if (stackTrace != null) {
      buffer.writeln('スタックトレース: $stackTrace');
    }

    return buffer.toString();
  }

  /// エラーハンドリングの汎用的な基本関数
  ///
  /// エラー型定義とエラー処理に関する基本的な操作を提供する関数群
  /// カウントダウンなどの具体的なビジネスロジックは含まない
  static DataManagerError handleError(
    Object error, {
    ErrorType? defaultType,
    String? defaultMessage,
    StackTrace? stackTrace,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    // 既にDataManagerErrorの場合はそのまま返す
    if (error is DataManagerError) {
      return error;
    }

    // エラーメッセージを取得
    final message = defaultMessage ?? error.toString();

    // エラータイプを判定
    ErrorType type = defaultType ?? _inferErrorType(error);

    return DataManagerError(
      type: type,
      message: message,
      originalError: error,
      stackTrace: stackTrace,
      code: code,
      metadata: metadata,
    );
  }

  /// エラーから型を推論
  static ErrorType _inferErrorType(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return ErrorType.network;
    }

    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return ErrorType.validation;
    }

    if (errorString.contains('sync') ||
        errorString.contains('synchronization')) {
      return ErrorType.sync;
    }

    if (errorString.contains('storage') ||
        errorString.contains('sharedpreferences') ||
        errorString.contains('permission denied')) {
      return ErrorType.storage;
    }

    if (errorString.contains('authentication') ||
        errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('login')) {
      return ErrorType.authentication;
    }

    if (errorString.contains('permission') ||
        errorString.contains('forbidden')) {
      return ErrorType.permission;
    }

    return ErrorType.unknown;
  }

  /// 再試行可能なエラーかどうかを判定
  ///
  /// **パラメータ**:
  /// - `error`: エラーオブジェクト
  ///
  /// **戻り値**: 再試行可能な場合はtrue、そうでない場合はfalse
  static bool isRetryableError(Object error) {
    // DataManagerErrorの場合
    if (error is DataManagerError) {
      switch (error.type) {
        case ErrorType.network:
          // ネットワークエラーは再試行可能
          return true;
        case ErrorType.sync:
          // 同期エラーは再試行可能
          return true;
        case ErrorType.storage:
          // ストレージエラーは状況によるが、一時的なものは再試行可能
          return true;
        case ErrorType.authentication:
          // 認証エラーは再試行可能（トークンリフレッシュなど）
          return true;
        case ErrorType.validation:
          // バリデーションエラーは再試行不可
          return false;
        case ErrorType.permission:
          // 権限エラーは再試行不可
          return false;
        case ErrorType.unknown:
          // 不明なエラーは再試行可能として扱う
          return true;
      }
    }

    // エラーメッセージから判定
    final errorString = error.toString().toLowerCase();

    // 再試行可能なエラーパターン
    final retryablePatterns = [
      'network',
      'connection',
      'timeout',
      'temporary',
      'retry',
      'unavailable',
      'socket',
    ];

    // 再試行不可なエラーパターン
    final nonRetryablePatterns = [
      'validation',
      'invalid',
      'permission denied',
      'forbidden',
      'not found',
      'malformed',
    ];

    // 再試行不可パターンを先にチェック
    for (final pattern in nonRetryablePatterns) {
      if (errorString.contains(pattern)) {
        return false;
      }
    }

    // 再試行可能パターンをチェック
    for (final pattern in retryablePatterns) {
      if (errorString.contains(pattern)) {
        return true;
      }
    }

    // デフォルトは再試行可能
    return true;
  }

  /// エラーからネットワークエラーかどうかを判定
  ///
  /// **パラメータ**:
  /// - `error`: エラーオブジェクト
  ///
  /// **戻り値**: ネットワークエラーの場合はtrue、そうでない場合はfalse
  static bool isNetworkError(Object error) {
    if (error is DataManagerError) {
      return error.type == ErrorType.network;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket');
  }

  /// エラーから認証エラーかどうかを判定
  ///
  /// **パラメータ**:
  /// - `error`: エラーオブジェクト
  ///
  /// **戻り値**: 認証エラーの場合はtrue、そうでない場合はfalse
  static bool isAuthenticationError(Object error) {
    if (error is DataManagerError) {
      return error.type == ErrorType.authentication;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('authentication') ||
        errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('login');
  }

  /// エラーからバリデーションエラーかどうかを判定
  ///
  /// **パラメータ**:
  /// - `error`: エラーオブジェクト
  ///
  /// **戻り値**: バリデーションエラーの場合はtrue、そうでない場合はfalse
  static bool isValidationError(Object error) {
    if (error is DataManagerError) {
      return error.type == ErrorType.validation;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required');
  }

  /// ネットワークエラーを作成
  ///
  /// **パラメータ**:
  /// - `message`: エラーメッセージ
  /// - `originalError`: 元のエラーオブジェクト（オプション）
  /// - `stackTrace`: スタックトレース（オプション）
  ///
  /// **戻り値**: DataManagerError
  static DataManagerError networkError(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return DataManagerError(
      type: ErrorType.network,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// バリデーションエラーを作成
  ///
  /// **パラメータ**:
  /// - `message`: エラーメッセージ
  /// - `originalError`: 元のエラーオブジェクト（オプション）
  ///
  /// **戻り値**: DataManagerError
  static DataManagerError validationError(
    String message, {
    Object? originalError,
  }) {
    return DataManagerError(
      type: ErrorType.validation,
      message: message,
      originalError: originalError,
    );
  }

  /// 同期エラーを作成
  ///
  /// **パラメータ**:
  /// - `message`: エラーメッセージ
  /// - `originalError`: 元のエラーオブジェクト（オプション）
  /// - `stackTrace`: スタックトレース（オプション）
  ///
  /// **戻り値**: DataManagerError
  static DataManagerError syncError(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return DataManagerError(
      type: ErrorType.sync,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// ストレージエラーを作成
  ///
  /// **パラメータ**:
  /// - `message`: エラーメッセージ
  /// - `originalError`: 元のエラーオブジェクト（オプション）
  ///
  /// **戻り値**: DataManagerError
  static DataManagerError storageError(
    String message, {
    Object? originalError,
  }) {
    return DataManagerError(
      type: ErrorType.storage,
      message: message,
      originalError: originalError,
    );
  }

  /// 認証エラーを作成
  ///
  /// **パラメータ**:
  /// - `message`: エラーメッセージ
  /// - `originalError`: 元のエラーオブジェクト（オプション）
  ///
  /// **戻り値**: DataManagerError
  static DataManagerError authenticationError(
    String message, {
    Object? originalError,
  }) {
    return DataManagerError(
      type: ErrorType.authentication,
      message: message,
      originalError: originalError,
    );
  }
}
