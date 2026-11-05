import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tutorial_video.dart';

/// Figma 05 — the first screen after sign-in: who you are, where to upload
/// numbers, the 2-minute tutorial, and "Start Calling Now".
class GettingStartedScreen extends ConsumerWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      initial: user?.initial ?? '?',
                    ),
                    const SizedBox(height: Dims.gap),
                    const _UploadNote(),
                    const SizedBox(height: Dims.gap),
                    const TutorialVideoCard(),
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

/// Where to upload numbers. A light card with its own icon and label, so it
/// reads as a note and not as a second hero beside the navy greeting card.
/// The wording is the Figma text (B-44); the link and the button both lead
/// to the web panel, so the button lives here instead of floating below.
class _UploadNote extends ConsumerWidget {
  const _UploadNote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: c.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BEFORE YOU START', style: context.eyebrow()),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        text: 'If you are here for the first time then ensure that you have uploaded the list to call from calley Web Panel hosted on ',
                        children: [
                          TextSpan(
                            text: 'app.getcalley.com',
                            style: context.mono(
                              13,
                              weight: FontWeight.w600,
                              color: c.primary,
                            ),
                          ),
                        ],
                      ),
                      style: context.body(13.5, color: c.text, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 42),
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(launcherProvider).open(context, Links.webPanel),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open the Calley web panel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
