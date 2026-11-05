import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/demo_account.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import 'auth_scaffold.dart';

/// Figma 04: "Welcome. Please sign-in to continue".
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(
    text: ref.read(pendingSignupProvider)?.email ?? '',
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
    if (_busy) return; // B-25
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    // B-22: capture before awaiting, so a successful sign-in still lands if
    // the screen is gone by the time the server answers.
    final session = ref.read(sessionProvider.notifier);
    final pending = ref.read(pendingSignupProvider.notifier);
    final email = _email.text.trim();
    // The demo account never touches the server: it signs in against the
    // bundled sample data, and the sample banner stays visible.
    if (DemoAccount.isDemoEmail(email)) {
      if (_password.text != DemoAccount.password) {
        setState(() {
          _busy = false;
          _error = const ApiException(
            'Wrong password for the demo account. It is ${DemoAccount.password}.',
            kind: ApiErrorKind.unauthorized,
          );
        });
        return;
      }
      await ref.read(dataSourceProvider.notifier).set(DataSource.sample);
    }
    final api = ref.read(apiProvider);
    try {
      final user = await api.login(email: email, password: _password.text);
      pending.set(null); // B-14
      await session.signIn(user);
      // The router redirects to Getting Started once the session exists.
    } on ApiException catch (e) {
      if (!mounted) return;
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
                validator: Validators.loginPassword,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
              ),
              // Spaced away from the show-password toggle so the two
              // targets do not touch (Fitts: adjacent targets need a gap).
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, Dims.tap),
                    foregroundColor: context.c.textSecondary,
                  ),
                  child: const Text('Forgot Password?'),
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
        // The button follows the fields it submits; the way to the other
        // form comes after it (the next step of the task, then the detour).
        PrimaryButton(label: 'Sign In', busy: _busy, onPressed: _submit),
        const SizedBox(height: 6),
        AuthSwitchLine(
          text: "Don't have an account?",
          action: 'Sign Up',
          onTap: () => context.go(Routes.register),
        ),
        const SizedBox(height: 14),
        _DemoCard(onUse: _useDemo),
      ],
    );
  }

  void _useDemo() {
    _email.text = DemoAccount.email;
    _password.text = DemoAccount.password;
    _submit();
  }
}

/// Shows the demo credentials in plain sight (recognition over recall) and
/// signs in with them in one tap.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.onUse});

  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: BoxDecoration(
        color: c.cardAlt,
        borderRadius: BorderRadius.circular(Dims.cardRadius),
      ),
      child: Column(
        children: [
          Text('TRY THE DEMO', style: context.eyebrow()),
          const SizedBox(height: 10),
          SelectableText(
            DemoAccount.email,
            textAlign: TextAlign.center,
            style: context.mono(14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          SelectableText(
            DemoAccount.password,
            textAlign: TextAlign.center,
            style: context.mono(14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Uses sample data bundled with the app.',
            textAlign: TextAlign.center,
            style: context.body(12.5, color: c.textSecondary),
          ),
          TextButton.icon(
            onPressed: onUse,
            style: TextButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign in with the demo account'),
          ),
        ],
      ),
    );
  }
}
