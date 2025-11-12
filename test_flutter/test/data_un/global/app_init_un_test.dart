import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/repositories/initialization_repository.dart';

void main() {
  group('AppInitUN', () {
    group('initialize', () {
      test('ログイン済みユーザーの情報を正しく取得できる', () async {
        // このテストは実際のFirebase認証が必要なため、
        // モックを使用するか統合テストとして実行する必要があります
        // 現在は基本的な構造のみをテスト
        
        // AppContextクラスのテスト
        final context = AppContext(
          userId: 'test_user_id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          token: 'test_token',
          initializedAt: DateTime.now(),
        );
        
        expect(context.userId, 'test_user_id');
        expect(context.email, 'test@example.com');
        expect(context.displayName, 'Test User');
        expect(context.photoURL, 'https://example.com/photo.jpg');
        expect(context.token, 'test_token');
        expect(context.isAuthenticated, true);
      });

      test('AppContextのisAuthenticatedプロパティが正しく動作する', () {
        // 有効なユーザーIDとトークンがある場合
        final authenticatedContext = AppContext(
          userId: 'test_user_id',
          token: 'valid_token',
          initializedAt: DateTime.now(),
        );
        expect(authenticatedContext.isAuthenticated, true);

        // ユーザーIDが空の場合
        final emptyUserIdContext = AppContext(
          userId: '',
          token: 'valid_token',
          initializedAt: DateTime.now(),
        );
        expect(emptyUserIdContext.isAuthenticated, false);

        // トークンがnullの場合
        final nullTokenContext = AppContext(
          userId: 'test_user_id',
          token: null,
          initializedAt: DateTime.now(),
        );
        expect(nullTokenContext.isAuthenticated, false);

        // トークンが空文字列の場合
        final emptyTokenContext = AppContext(
          userId: 'test_user_id',
          token: '',
          initializedAt: DateTime.now(),
        );
        expect(emptyTokenContext.isAuthenticated, false);
      });

      test('AppContextのcopyWithメソッドが正しく動作する', () {
        final originalContext = AppContext(
          userId: 'original_user_id',
          email: 'original@example.com',
          displayName: 'Original User',
          photoURL: 'https://example.com/original.jpg',
          token: 'original_token',
          initializedAt: DateTime(2024, 1, 1),
        );

        // 一部のフィールドのみを変更
        final updatedContext = originalContext.copyWith(
          email: 'updated@example.com',
          displayName: 'Updated User',
        );

        // 変更されたフィールド
        expect(updatedContext.email, 'updated@example.com');
        expect(updatedContext.displayName, 'Updated User');
        
        // 変更されていないフィールド
        expect(updatedContext.userId, 'original_user_id');
        expect(updatedContext.photoURL, 'https://example.com/original.jpg');
        expect(updatedContext.token, 'original_token');
        expect(updatedContext.initializedAt, DateTime(2024, 1, 1));
      });

      test('AppContextのtoStringメソッドが正しく動作する', () {
        final context = AppContext(
          userId: 'test_user_id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          token: 'test_token',
          initializedAt: DateTime(2024, 1, 1, 12, 0, 0),
        );

        final stringRepresentation = context.toString();
        
        expect(stringRepresentation, contains('userId: test_user_id'));
        expect(stringRepresentation, contains('email: test@example.com'));
        expect(stringRepresentation, contains('displayName: Test User'));
        expect(stringRepresentation, contains('photoURL: https://example.com/photo.jpg'));
        expect(stringRepresentation, contains('hasToken: true'));
        expect(stringRepresentation, contains('initializedAt: 2024-01-01 12:00:00.000'));
      });
    });

    group('AppContext', () {
      test('必須フィールドのみでAppContextを作成できる', () {
        final context = AppContext(
          userId: 'test_user_id',
          initializedAt: DateTime.now(),
        );

        expect(context.userId, 'test_user_id');
        expect(context.email, null);
        expect(context.displayName, null);
        expect(context.photoURL, null);
        expect(context.token, null);
        expect(context.isAuthenticated, false);
      });

      test('全てのフィールドでAppContextを作成できる', () {
        final now = DateTime.now();
        final context = AppContext(
          userId: 'test_user_id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          token: 'test_token',
          initializedAt: now,
        );

        expect(context.userId, 'test_user_id');
        expect(context.email, 'test@example.com');
        expect(context.displayName, 'Test User');
        expect(context.photoURL, 'https://example.com/photo.jpg');
        expect(context.token, 'test_token');
        expect(context.initializedAt, now);
        expect(context.isAuthenticated, true);
      });
    });
  });
}
