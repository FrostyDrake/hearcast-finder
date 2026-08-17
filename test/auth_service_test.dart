import 'package:flutter_test/flutter_test.dart';
import 'package:hearcast_finder/services/auth_service.dart';

void main() {
  const service = AuthService();

  test('register returns a local user for valid input', () async {
    final user = await service.register(
      name: 'Andrei',
      email: 'andrei@example.com',
      password: 'password123',
    );

    expect(user.name, 'Andrei');
    expect(user.email, 'andrei@example.com');
    expect(user.role.name, 'user');
  });

  test('register rejects weak passwords', () {
    expect(
      () => service.register(
        name: 'Andrei',
        email: 'andrei@example.com',
        password: 'short',
      ),
      throwsA(isA<AuthValidationException>()),
    );
  });
}
