import '../core/utils/validators.dart';
import '../models/app_user.dart';

class AuthService {
  const AuthService();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _validateCredentials(
      name: name,
      email: email,
      password: password,
      requireName: true,
    );

    return AppUser(
      id: _localUserId(email),
      name: name.trim(),
      email: email.trim(),
    );
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _validateCredentials(
      name: 'Local user',
      email: email,
      password: password,
      requireName: false,
    );

    return AppUser(
      id: _localUserId(email),
      name: 'Local user',
      email: email.trim(),
    );
  }

  void _validateCredentials({
    required String name,
    required String email,
    required String password,
    required bool requireName,
  }) {
    final nameError = requireName ? Validators.requiredText(name, 'Name') : null;
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);

    final firstError = nameError ?? emailError ?? passwordError;
    if (firstError != null) {
      throw AuthValidationException(firstError);
    }
  }

  String _localUserId(String email) {
    return 'local-${email.trim().toLowerCase().hashCode.abs()}';
  }
}

class AuthValidationException implements Exception {
  const AuthValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
