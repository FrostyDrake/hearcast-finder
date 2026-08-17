import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

enum _AuthMode {
  signIn,
  register,
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = const AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _mode = _AuthMode.signIn;
  var _isSubmitting = false;
  AppUser? _currentUser;
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
    if (_currentUser != null) {
      return _SignedInProfile(
        user: _currentUser!,
        onSignOut: () {
          setState(() {
            _currentUser = null;
            _message = 'Signed out locally.';
          });
        },
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _mode == _AuthMode.signIn ? 'Sign in' : 'Create account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Local-only auth UI while Firebase configuration is being prepared.',
          ),
          const SizedBox(height: 16),
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
            Text(_message!),
          ],
        ],
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

    try {
      final user = _mode == _AuthMode.signIn
          ? await _authService.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await _authService.register(
              name: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            );

      if (!mounted) {
        return;
      }
      setState(() => _currentUser = user);
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

class _SignedInProfile extends StatelessWidget {
  const _SignedInProfile({
    required this.user,
    required this.onSignOut,
  });

  final AppUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(user.name),
            subtitle: Text('${user.email}\nRole: ${user.role.name}'),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}
