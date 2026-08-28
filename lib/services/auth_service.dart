import 'package:firebase_auth/firebase_auth.dart';

import '../core/utils/validators.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final validationError = validateCredentials(
      name: name,
      email: email,
      password: password,
    );
    if (validationError != null) {
      throw AuthValidationException(validationError);
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthValidationException('Could not create the account.');
      }
      await user.updateDisplayName(name.trim());
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthValidationException(_messageForFirebaseError(error));
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final validationError = validateCredentials(email: email, password: password);
    if (validationError != null) {
      throw AuthValidationException(validationError);
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthValidationException('Could not sign in.');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthValidationException(_messageForFirebaseError(error));
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  /// Pure client-side validation, checked before any Firebase call is made.
  /// [name] is only required when registering a new account.
  static String? validateCredentials({
    required String email,
    required String password,
    String? name,
  }) {
    final nameError = name != null ? Validators.requiredText(name, 'Name') : null;
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);

    return nameError ?? emailError ?? passwordError;
  }

  String _messageForFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}

class AuthValidationException implements Exception {
  const AuthValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
