import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/services/auth_service.dart';

void main() {
  group('AuthService.validateCredentials', () {
    test('accepts a valid registration', () {
      final error = AuthService.validateCredentials(
        name: 'Andrei',
        email: 'andrei@example.com',
        password: 'password123',
      );

      expect(error, isNull);
    });

    test('accepts a valid sign-in (no name required)', () {
      final error = AuthService.validateCredentials(
        email: 'andrei@example.com',
        password: 'password123',
      );

      expect(error, isNull);
    });

    test('rejects weak passwords', () {
      final error = AuthService.validateCredentials(
        name: 'Andrei',
        email: 'andrei@example.com',
        password: 'short',
      );

      expect(error, isNotNull);
    });

    test('rejects an invalid email', () {
      final error = AuthService.validateCredentials(
        name: 'Andrei',
        email: 'not-an-email',
        password: 'password123',
      );

      expect(error, isNotNull);
    });

    test('requires a name only when registering', () {
      final error = AuthService.validateCredentials(
        name: '',
        email: 'andrei@example.com',
        password: 'password123',
      );

      expect(error, isNotNull);
    });
  });
}
