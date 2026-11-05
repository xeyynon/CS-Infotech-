import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/otp_input.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import 'auth_scaffold.dart';

/// Figma 03 — "Whatsapp OTP Verification".
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendWait = 30;
  String _code = '';
  bool _busy = false;
  Object? _error;
  String? _notice;
  int _secondsLeft = _resendWait;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendWait);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  PendingSignup? get _pending => ref.read(pendingSignupProvider);
  String get _email => _pending?.email ?? '';

  /// What the last failure was trying to do, so Retry repeats THAT (B-21).
  VoidCallback? _retry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // B-08: show what the server said when it sent the code (in sample mode
    // that is "any 6 digits verify").
    _notice ??= _pending?.otpNotice;
  }

  Future<void> _resend() async {
    if (_busy) return; // B-25
    setState(() {
      _error = null;
      _notice = null;
    });
    final api = ref.read(apiProvider);
    try {
      final msg = await api.sendOtp(email: _email);
      if (!mounted) return; // B-22
      setState(() => _notice = msg ?? 'A new code has been sent.');
      _startTimer();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _retry = _resend;
      });
    }
  }

  Future<void> _verify([String? code]) async {
    if (_busy) return; // B-25: onCompleted and the button can both fire.
    final v = code ?? _code;
    final invalid = Validators.otp(v);
    if (invalid != null) {
      setState(() {
        _error = ApiException(invalid, kind: ApiErrorKind.badRequest);
        _retry = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(apiProvider);
    try {
      await api.verifyOtp(email: _email, otp: v);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verified. Please sign in.')),
      );
      context.go(Routes.login);
    } on ApiException catch (e) {
      // B-19: keep the digits so one wrong digit can be corrected.
      if (!mounted) return;
      setState(() {
        _error = e;
        _retry = () => _verify();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final email = _email;
    final mobile = _pending?.mobile ?? '';
    return AuthScaffold(
      title: 'Whatsapp OTP\nVerification',
      subtitle: 'Please ensure that the email id mentioned is valid as we have sent an OTP to your email.',
      // Where the code went, right under the sentence that talks about it.
      detail: email.isEmpty
          ? null
          : Text(
              email,
              textAlign: TextAlign.center,
              style: context.body(14, weight: FontWeight.w600),
            ),
      children: [
        OtpInput(
          enabled: !_busy,
          onChanged: (v) => setState(() => _code = v),
          onCompleted: _verify,
        ),
        // B-20: the number from Register, as Figma 03 shows it, with a way
        // back to correct it (user control and freedom).
        if (mobile.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '+91 ${fmtPhone(mobile)}',
                style: context.mono(14, color: c.textSecondary),
              ),
              TextButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.register),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, Dims.tap),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Wrong details?'),
              ),
            ],
          ),
        ],
        if (_notice != null) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(
              _notice!,
              textAlign: TextAlign.center,
              style: context.body(13, color: c.textSecondary),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          ErrorView(
            error: _error!,
            onRetry: _retry,
            compact: (_error as ApiException).kind == ApiErrorKind.badRequest,
          ),
        ],
        const SizedBox(height: 14),
        // B-07: wraps onto two lines at large text instead of overflowing.
        AuthSwitchLine(
          text: "Didn't receive OTP code?",
          action: _secondsLeft == 0
              ? 'Resend OTP'
              : 'Resend in ${_secondsLeft}s',
          onTap: _secondsLeft == 0 && !_busy ? _resend : null,
        ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Verify',
          busy: _busy,
          onPressed: _code.length == 6 ? () => _verify() : null,
        ),
      ],
    );
  }
}
