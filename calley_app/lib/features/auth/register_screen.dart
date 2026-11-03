import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import 'auth_scaffold.dart';

/// Figma 02 — "Welcome! Please register to continue".
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _mobile = TextEditingController();
  bool _agreed = false;
  bool _agreeError = false;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _agreeError = !_agreed);
    if (!_form.currentState!.validate() || !_agreed) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(apiProvider)
          .register(
            username: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      ref.read(pendingEmailProvider.notifier).set(_email.text.trim());
      // Figma 03 says "we have sent an OTP to your email": request it now.
      try {
        await ref.read(apiProvider).sendOtp(email: _email.text.trim());
      } on ApiException {
        // The OTP screen can resend; registration itself succeeded.
      }
      if (mounted) context.push(Routes.otp);
    } on ApiException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // When the user switches to sample data after an error, carry on.
    ref.listen(dataSourceProvider, (prev, next) {
      if (prev == DataSource.remote &&
          next == DataSource.sample &&
          _error != null) {
        setState(() => _error = null);
        _submit();
      }
    });
    return AuthScaffold(
      title: 'Welcome!',
      subtitle: 'Please register to continue',
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _name,
                hint: 'Name',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: Validators.name,
                autofillHints: const [AutofillHints.name],
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _email,
                hint: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _password,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: c.input,
                      borderRadius: BorderRadius.circular(Dims.fieldRadius),
                    ),
                    child: Row(
                      children: [
                        const _IndiaFlag(),
                        const SizedBox(width: 8),
                        Text(
                          '+91',
                          style: context.mono(15, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      controller: _mobile,
                      hint: 'Mobile number',
                      mono: true,
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: Validators.mobile,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TermsRow(
                value: _agreed,
                error: _agreeError,
                onTerms: () =>
                    ref.read(launcherProvider).open(context, Links.terms),
                onChanged: (v) => setState(() {
                  _agreed = v;
                  if (v) _agreeError = false;
                }),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          ErrorView(error: _error!, onRetry: _submit),
        ],
        const SizedBox(height: 10),
        AuthSwitchLine(
          text: 'Already have an account?',
          action: 'Sign In',
          onTap: () => context.go(Routes.login),
        ),
        const SizedBox(height: 6),
        PrimaryButton(label: 'Sign Up', busy: _busy, onPressed: _submit),
      ],
    );
  }
}

/// Drawn tricolour instead of an emoji, so it renders the same on every
/// device and in tests.
class _IndiaFlag extends StatelessWidget {
  const _IndiaFlag();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'India',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: 22,
          height: 15,
          child: Column(
            children: [
              Expanded(child: Container(color: const Color(0xFFFF9933))),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF000080),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container(color: const Color(0xFF138808))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.value,
    required this.error,
    required this.onChanged,
    required this.onTerms,
  });

  final bool value;
  final bool error;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTerms;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                isError: error,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                    children: [
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: c.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onTerms,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              'Please accept the terms to continue',
              style: TextStyle(fontSize: 12, color: c.danger),
            ),
          ),
      ],
    );
  }
}
