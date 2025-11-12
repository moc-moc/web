import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/services/error_handler.dart';

void main() {
  group('DataManagerError Tests', () {
    test('handleError - エラーを適切に処理', () {
      final error = Exception('テストエラー');
      final managedError = DataManagerError.handleError(error);
      
      expect(managedError, isA<DataManagerError>());
      expect(managedError.originalError, error);
    });

    test('isRetryableError - ネットワークエラーは再試行可能', () {
      final networkError = DataManagerError.networkError('接続エラー');
      expect(DataManagerError.isRetryableError(networkError), true);
    });

    test('isRetryableError - バリデーションエラーは再試行不可', () {
      final validationError = DataManagerError.validationError('無効なデータ');
      expect(DataManagerError.isRetryableError(validationError), false);
    });

    test('isNetworkError - ネットワークエラーを判定', () {
      final networkError = DataManagerError.networkError('接続エラー');
      expect(DataManagerError.isNetworkError(networkError), true);
      
      final validationError = DataManagerError.validationError('無効なデータ');
      expect(DataManagerError.isNetworkError(validationError), false);
    });

    test('isAuthenticationError - 認証エラーを判定', () {
      final authError = DataManagerError.authenticationError('未認証');
      expect(DataManagerError.isAuthenticationError(authError), true);
    });

    test('toString - エラー情報を文字列化', () {
      final error = DataManagerError(
        type: ErrorType.network,
        message: 'テストエラー',
        code: 'ERR001',
      );
      
      final str = error.toString();
      expect(str.contains('network'), true);
      expect(str.contains('テストエラー'), true);
      expect(str.contains('ERR001'), true);
    });
  });
}

