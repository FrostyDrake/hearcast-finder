import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/session_providers.dart';
import '../shell/app_shell.dart';
import 'login_screen.dart';

/// Routes between the login flow and the signed-in app shell based on live
/// Firebase Auth state. Nothing behind this widget is reachable while
/// signed out.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentAppUserProvider);

    return session.when(
      data: (user) => user == null ? const LoginScreen() : const AppShell(),
      loading: () => const _AuthGateMessage(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _AuthGateMessage(
        child: Text(
          'Could not load your account.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AuthGateMessage extends StatelessWidget {
  const _AuthGateMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
