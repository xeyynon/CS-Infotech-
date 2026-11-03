import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
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
  final _otpKey = GlobalKey<OtpInputState>();
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

  String get _email => ref.read(pendingEmailProvider) ?? '';

  Future<void> _resend() async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final msg = await ref.read(apiProvider).sendOtp(email: _email);
      setState(() => _notice = msg ?? 'A new code has been sent.');
      _startTimer();
    } on ApiException catch (e) {
      setState(() => _error = e);
    }
  }

  Future<void> _verify([String? code]) async {
    final v = code ?? _code;
    final invalid = Validators.otp(v);
    if (invalid != null) {
      setState(
        () => _error = ApiException(invalid, kind: ApiErrorKind.badRequest),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).verifyOtp(email: _email, otp: v);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verified. Please sign in.')),
      );
      context.go(Routes.login);
    } on ApiException catch (e) {
      setState(() => _error = e);
      if (e.kind == ApiErrorKind.badRequest) _otpKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final email = _email;
    return AuthScaffold(
      title: 'Whatsapp OTP\nVerification',
      subtitle: 'Please ensure that the email id mentioned is valid as we have sent an OTP to your email.',
      children: [
        OtpInput(
          key: _otpKey,
          enabled: !_busy,
          onChanged: (v) => setState(() => _code = v),
          onCompleted: _verify,
        ),
        const SizedBox(height: 14),
        if (email.isNotEmpty)
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        if (_notice != null) ...[
          const SizedBox(height: 10),
          Text(
            _notice!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: c.success),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          ErrorView(
            error: _error!,
            onRetry: () => _verify(),
            compact: (_error as ApiException).kind == ApiErrorKind.badRequest,
          ),
        ],
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive OTP code? ",
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            ),
            TextButton(
              onPressed: _secondsLeft == 0 ? _resend : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, Dims.tap),
              ),
              child: Text(
                _secondsLeft == 0 ? 'Resend OTP' : 'Resend in ${_secondsLeft}s',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
