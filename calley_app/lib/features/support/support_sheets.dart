import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/primary_button.dart';
import '../drawer/app_drawer.dart';
import 'log_report.dart';

// ---------------------------------------------------------------------------
// Send logs
// ---------------------------------------------------------------------------

Future<void> showSendLogsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _SendLogsSheet(),
  );
}

class _SendLogsSheet extends ConsumerWidget {
  const _SendLogsSheet();

  String _report(WidgetRef ref) {
    final selected = ref.read(selectedListProvider);
    final details = selected == null
        ? null
        : ref.read(listDetailsProvider(selected.id));
    final d = details?.value;
    final outcomes = selected == null
        ? const <String, int>{}
        : ref.read(dispositionsProvider.notifier).outcomeCounts(selected.id);
    return buildLogReport(
      appVersion: kAppVersion,
      platform: defaultTargetPlatform.name,
      now: ref.read(clockProvider)(),
      dataSource: ref.read(dataSourceProvider) == DataSource.sample
          ? 'sample data'
          : 'Calley test server',
      accountEmail: ref.read(sessionProvider)?.email,
      listName: selected?.name,
      listId: selected?.id,
      total: d?.calls.length ?? 0,
      pending: d?.pendingCount ?? 0,
      done: d?.doneCount ?? 0,
      scheduled: d?.scheduledCount ?? 0,
      outcomes: outcomes,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final report = _report(ref);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Send logs',
                textAlign: TextAlign.center,
                style: context.display(22, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This is exactly what will be sent to support. It has no '
              'contact names or phone numbers.',
              textAlign: TextAlign.center,
              style: context.body(13.5, color: c.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.cardAlt,
                borderRadius: BorderRadius.circular(Dims.fieldRadius),
              ),
              child: SelectableText(
                report,
                style: context.mono(12, color: c.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Email to support',
              icon: Icons.mail_outline_rounded,
              onPressed: () async {
                final launcher = ref.read(launcherProvider);
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                final sent = await launcher.email(
                  Links.supportEmail,
                  subject: 'Calley app log',
                  body: report,
                );
                if (sent) {
                  nav.pop();
                } else {
                  await Clipboard.setData(ClipboardData(text: report));
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No mail app on this phone. The log was copied, so '
                          'you can paste it into a message to '
                          '${Links.supportEmail}.',
                        ),
                      ),
                    );
                }
              },
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: report));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Log copied.')));
              },
              style: TextButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy instead'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancel subscription
// ---------------------------------------------------------------------------

Future<void> showCancelSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CancelSheet(),
  );
}

class _CancelSheet extends ConsumerWidget {
  const _CancelSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final plan = ref.watch(sessionProvider)?.subscription;
    final launcher = ref.read(launcherProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Cancel your subscription?',
                textAlign: TextAlign.center,
                style: context.display(22, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan == null || plan.isEmpty
                  ? 'Your plan is billed outside this app, so it cannot be '
                        'cancelled here.'
                  : 'Your plan, $plan, is billed outside this app, so it '
                        'cannot be cancelled here.',
              textAlign: TextAlign.center,
              style: context.body(14, color: c.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'If you subscribed through Google Play, cancel it there. '
              'Otherwise our support team can do it for you.',
              textAlign: TextAlign.center,
              style: context.body(14, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
            // The safe choice first and primary.
            PrimaryButton(
              label: 'Keep my plan',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => launcher.open(context, Links.playSubscriptions),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Manage on Google Play'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => launcher.open(context, Links.support),
              style: TextButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
              child: const Text('Contact support'),
            ),
          ],
        ),
      ),
    );
  }
}
