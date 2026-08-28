import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/validators.dart';
import '../../providers/session_providers.dart';
import '../../services/auth_service.dart';

enum _AuthMode { signIn, register }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _mode = _AuthMode.signIn;
  var _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 24),
              Text(
                'HearCast Finder',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _mode == _AuthMode.signIn
                    ? 'Sign in to continue'
                    : 'Create your account',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SegmentedButton<_AuthMode>(
                segments: const [
                  ButtonSegment(
                    value: _AuthMode.signIn,
                    label: Text('Login'),
                    icon: Icon(Icons.login),
                  ),
                  ButtonSegment(
                    value: _AuthMode.register,
                    label: Text('Register'),
                    icon: Icon(Icons.person_add_alt),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    _message = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_mode == _AuthMode.register) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.requiredText(value, 'Name'),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _mode == _AuthMode.signIn
                            ? Icons.login
                            : Icons.person_add_alt,
                      ),
                label: Text(_mode == _AuthMode.signIn ? 'Login' : 'Register'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final authController = ref.read(authControllerProvider);

    try {
      if (_mode == _AuthMode.signIn) {
        await authController.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await authController.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      // AuthGate reacts to the resulting auth-state change on its own.
    } on AuthValidationException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = 'Could not continue: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
