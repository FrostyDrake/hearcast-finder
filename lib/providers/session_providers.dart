import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'firebase_providers.dart';

/// Raw Firebase sign-in state.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// The signed-in user's app profile (name/email/role), kept live so a role
/// change (e.g. an admin promotion) is reflected without a re-login.
final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (firebaseUser == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchUser(firebaseUser.uid);
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    authService: ref.watch(authServiceProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

/// Orchestrates AuthService (Firebase Auth) and UserRepository (the
/// Firestore profile) so screens never have to coordinate the two directly.
class AuthController {
  AuthController({
    required this.authService,
    required this.userRepository,
  });

  final AuthService authService;
  final UserRepository userRepository;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final firebaseUser = await authService.register(
      name: name,
      email: email,
      password: password,
    );
    await userRepository.ensureUserProfile(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? email.trim(),
      name: name,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final firebaseUser = await authService.signIn(email: email, password: password);
    await userRepository.ensureUserProfile(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? email.trim(),
      name: firebaseUser.displayName,
    );
  }

  Future<void> signOut() => authService.signOut();
}
