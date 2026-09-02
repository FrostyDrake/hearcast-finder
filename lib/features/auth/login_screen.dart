import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/hc_palette.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/hc_layout.dart';
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
  var _obscurePassword = true;
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRegister = _mode == _AuthMode.register;
    final message = _message;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Keeps the form a comfortable reading width on a tablet or a
            // large phone in landscape instead of stretching edge to edge.
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(HcSpace.xl),
                children: [
                  const SizedBox(height: HcSpace.xxl),
                  const _Wordmark(),
                  const SizedBox(height: HcSpace.xxl),
                  Semantics(
                    header: true,
                    child: Text(
                      isRegister ? 'Create your account' : 'Sign in to continue',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: HcSpace.sm),
                  Text(
                    isRegister
                        ? 'One account lets you save places and send in what '
                            'your phone finds.'
                        : 'Your places, scans and submissions are tied to your '
                            'account.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: HcSpace.xl),
                  SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment(
                        value: _AuthMode.signIn,
                        label: Text('Login'),
                        icon: Icon(Icons.login_rounded),
                      ),
                      ButtonSegment(
                        value: _AuthMode.register,
                        label: Text('Register'),
                        icon: Icon(Icons.person_add_alt_rounded),
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
                  const SizedBox(height: HcSpace.xl),
                  if (isRegister) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.requiredText(value, 'Name'),
                    ),
                    const SizedBox(height: HcSpace.lg),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: HcSpace.lg),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      helperText: 'At least 8 characters',
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: HcSpace.xl),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isRegister
                                ? Icons.person_add_alt_rounded
                                : Icons.login_rounded,
                          ),
                    label: Text(isRegister ? 'Register' : 'Login'),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: HcSpace.lg),
                    HcNotice(message: message, tone: HcNoticeTone.error),
                  ],
                ],
              ),
            ),
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

/// The brand mark. Deliberately not the string "HearCast Finder" as a plain
/// heading duplicate - the app bar owns that name once the user is inside.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);

    return Row(
      children: [
        ExcludeSemantics(
          child: Container(
            width: scaler.scale(48),
            height: scaler.scale(48),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(HcRadius.card),
              ),
            ),
            child: Icon(
              Icons.hearing_rounded,
              size: scaler.scale(26),
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: HcSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HearCast Finder',
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'The map of where the sound is',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
