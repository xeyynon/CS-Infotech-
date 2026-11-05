import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/primary_button.dart';

/// Figma 05 — the first screen after sign-in: who you are, where to upload
/// numbers, the 2-minute tutorial, and "Start Calling Now".
class GettingStartedScreen extends ConsumerWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(sessionProvider);
    final fromDrawer = context.canPop();
    return Scaffold(
      appBar: fromDrawer ? AppBar(title: const Text('Getting Started')) : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Dims.page, 12, Dims.page, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GreetingCard(
                      eyebrow: 'Hello', // B-35: Figma wording
                      name: user?.firstName ?? 'there',
                      subline: user?.subscription ?? 'Calley',
                    ),
                    const SizedBox(height: Dims.gap),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            color: c.navy,
                            child: Text.rich(
                              TextSpan(
                                text: 'If you are here for the first time then ensure that you have uploaded the list to call from calley Web Panel hosted on ', // B-44
                                children: [
                                  TextSpan(
                                    text: 'app.getcalley.com',
                                    style: context.mono(
                                      13,
                                      weight: FontWeight.w600,
                                      color: c.onNavy,
                                    ),
                                  ),
                                ],
                              ),
                              style: context.body(
                                13.5,
                                color: c.onNavy,
                                height: 1.5,
                              ),
                            ),
                          ),
                          _ChallengeThumbnail(
                            onTap: () => ref
                                .read(launcherProvider)
                                .open(context, Links.tutorialVideo),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => ref
                            .read(launcherProvider)
                            .open(context, Links.webPanel),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Open the Calley web panel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 16),
              child: Row(
                children: [
                  WhatsAppButton(
                    onPressed: () => ref
                        .read(launcherProvider)
                        .open(context, Links.whatsapp),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Start Calling Now',
                      onPressed: () async {
                        await ref.read(onboardedProvider.notifier).set(true);
                        if (context.mounted) context.go(Routes.dashboard);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "2 MINUTE CHALLENGE" video card. A poster drawn in the display face;
/// a tap opens Calley's own setup video on YouTube.
///
/// B-45: a centred Column that grows with the text instead of a fixed-height
/// Stack, so nothing runs under the play button at large text sizes. The
/// play disc is outlined, not solid, so the blue "Start Calling Now" stays
/// the one primary action on the screen.
class _ChallengeThumbnail extends StatelessWidget {
  const _ChallengeThumbnail({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Watch the 2 minute challenge video',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          color: c.cardAlt,
          child: Column(
            children: [
              Text('TUTORIAL · 2:00', style: context.eyebrow()),
              const SizedBox(height: 10),
              Text(
                '2 Minute Challenge',
                textAlign: TextAlign.center,
                style: context.display(28, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a list, sync, dial. Watch how.',
                textAlign: TextAlign.center,
                style: context.body(13.5, color: c.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 1.5),
                ),
                child: Icon(Icons.play_arrow_rounded, color: c.text, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
