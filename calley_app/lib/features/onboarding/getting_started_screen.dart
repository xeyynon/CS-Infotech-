import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
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
    final now = ref.watch(clockProvider)();
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
                      eyebrow: greetingFor(now),
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
                                text: 'If you are here for the first time, make sure you have uploaded the list to call from the Calley web panel at ',
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
                    Align(
                      alignment: Alignment.centerLeft,
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
class _ChallengeThumbnail extends StatelessWidget {
  const _ChallengeThumbnail({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Watch the 2 minute challenge video',
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 200,
          width: double.infinity,
          color: c.cardAlt,
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tutorial · 2:00', style: context.eyebrow()),
                    const SizedBox(height: 8),
                    Text(
                      '2 minute\nchallenge',
                      style: context.display(
                        34,
                        weight: FontWeight.w800,
                        height: 0.98,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload a list, sync, dial. Watch how.',
                      style: context.body(13, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.text,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: c.bg, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
