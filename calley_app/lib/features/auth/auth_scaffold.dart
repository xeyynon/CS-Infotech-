import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/calley_logo.dart';
import '../../core/widgets/status_views.dart';

/// The frame shared by Register, OTP and Login (Figma 02–04).
///
/// HCI: the brand, the heading and the one sentence of instruction are
/// centred, as in the Figma, so the eye lands on one axis and reads top to
/// bottom; the form fields themselves stay full-width and left-aligned
/// (people scan form labels down a left edge). The column is capped at
/// 440 px so on a tablet or a phone in landscape it stays a comfortable
/// reading width in the middle of the screen instead of stretching.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.detail,
  });

  final String title;
  final String subtitle;

  /// An extra line under the subtitle (the OTP screen shows where the code went).
  final Widget? detail;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // B-08: in sample mode the sign-up screens say so too.
            const SampleDataBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Dims.page,
                  24,
                  Dims.page,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: CalleyLogo(size: 40)),
                          const SizedBox(height: 36),
                          // B-18: announced as a heading.
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: context.display(
                                32,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: context.body(14.5, color: c.textSecondary),
                          ),
                          if (detail != null) ...[
                            const SizedBox(height: 6),
                            Center(child: detail!),
                          ],
                          const SizedBox(height: 28),
                          ...children,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Already have an account? Sign In" style line. A Wrap, not a Row, so it
/// breaks onto two centred lines instead of overflowing at large text (B-07).
class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: context.body(13.5, color: c.textSecondary)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, Dims.tap),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
