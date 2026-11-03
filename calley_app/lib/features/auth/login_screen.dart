import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import 'auth_scaffold.dart';

/// Figma 04 — "Welcome. Please sign-in to continue".
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(
    text: ref.read(pendingEmailProvider) ?? '',
  );
  final _password = TextEditingController();
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(apiProvider)
          .login(email: _email.text.trim(), password: _password.text);
      await ref.read(sessionProvider.notifier).signIn(user);
      // The router redirects to Getting Started once the session exists.
    } on ApiException catch (e) {
      setState(() => _error = e);
      if (e.kind == ApiErrorKind.unauthorized ||
          e.kind == ApiErrorKind.badRequest) {
        _password.clear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot password?'),
        content: const Text(
          'Password reset is handled on the Calley web panel (app.getcalley.com). '
          'This test build does not include a reset flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dataSourceProvider, (prev, next) {
      if (prev == DataSource.remote &&
          next == DataSource.sample &&
          _error != null) {
        setState(() => _error = null);
        _submit();
      }
    });
    return AuthScaffold(
      title: 'Welcome',
      subtitle: 'Please sign-in to continue',
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _email,
                hint: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                autofocus: _email.text.isEmpty,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _password,
                textInputAction: TextInputAction.done,
                validator: Validators.password,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.c.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          ErrorView(error: _error!, onRetry: _submit),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 6),
        AuthSwitchLine(
          text: "Don't have an account?",
          action: 'Sign Up',
          onTap: () => context.go(Routes.register),
        ),
        const SizedBox(height: 6),
        PrimaryButton(label: 'Sign In', busy: _busy, onPressed: _submit),
      ],
    );
  }
}
