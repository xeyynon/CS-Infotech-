import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/build_info.dart';
import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cards.dart';
import '../support/support_sheets.dart';

/// Shown in the drawer's App Info and the Settings footer.
const String kAppVersion = '1.0.0';

/// Version plus the project build number, e.g. `1.0.0 (build 1004)`.
const String kAppVersionLabel = '$kAppVersion (build $kBuildNumber)';

/// Figma 09: the side navigation.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    const text =
        'Calley turns your phone into an auto dialer for sales calls. '
        '${Links.download}';
    final messenger = ScaffoldMessenger.of(context);
    final shared = await ref
        .read(launcherProvider)
        .share(text, subject: 'Calley: automatic call dialer');
    if (shared) return;
    // No share sheet on this device: copy the message instead.
    await Clipboard.setData(const ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Sharing is not available here. The message was copied.',
          ),
        ),
      );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: Text(
          ref.read(dispositionsProvider).isEmpty
              ? 'You will need to sign in again to see your calling lists.'
              : 'You will need to sign in again. The '
                    '${ref.read(dispositionsProvider).length} call outcome'
                    '${ref.read(dispositionsProvider).length == 1 ? '' : 's'} '
                    'logged on this phone will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(sessionProvider.notifier).signOut();
      // The router redirects to Login when the session is gone.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(sessionProvider);
    final plan = (user?.subscription ?? '').replaceFirst('Calley ', '');

    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      minTileHeight: Dims.tap,
      dense: true,
    );

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              color: c.primary,
              child: Row(
                children: [
                  Avatar(
                    initial: user?.initial ?? '?',
                    size: 46,
                    inverted: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: user?.firstName ?? 'Guest',
                            style: TextStyle(
                              color: c.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            children: [
                              if (plan.isNotEmpty)
                                TextSpan(
                                  text: '  ·  $plan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: c.onPrimary.withValues(alpha: 0.85),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '-',
                          style: TextStyle(
                            color: c.onPrimary.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            item(Icons.rocket_launch_outlined, 'Getting Started', () {
              Navigator.pop(context);
              context.push(Routes.gettingStarted);
            }),
            item(Icons.sync_rounded, 'Sync Data', () {
              Navigator.pop(context);
              ref.invalidate(listsProvider);
              final sel = ref.read(selectedListProvider);
              if (sel != null) ref.invalidate(listDetailsProvider(sel.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ref.read(dataSourceProvider) == DataSource.sample
                        ? 'Reloading sample data…' // B-41
                        : 'Refreshing from the server…',
                  ),
                ),
              );
            }),
            item(Icons.emoji_events_outlined, 'Gamification', () {
              Navigator.pop(context);
              context.push(Routes.progress);
            }),
            item(Icons.description_outlined, 'Send Logs', () {
              Navigator.pop(context);
              showSendLogsSheet(context);
            }),
            item(Icons.settings_outlined, 'Settings', () {
              Navigator.pop(context);
              context.push(Routes.settings);
            }),
            item(Icons.help_outline_rounded, 'Help?', () {
              Navigator.pop(context);
              ref.read(launcherProvider).open(context, Links.whatsapp);
            }),
            item(Icons.person_off_outlined, 'Cancel Subscription', () {
              Navigator.pop(context);
              showCancelSubscriptionSheet(context);
            }),
            const Divider(height: 20, indent: 18, endIndent: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: Text(
                'App Info',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
            item(Icons.info_outline_rounded, 'About Us', () {
              Navigator.pop(context);
              ref.read(launcherProvider).open(context, Links.about);
            }),
            item(Icons.privacy_tip_outlined, 'Privacy Policy', () {
              Navigator.pop(context);
              ref.read(launcherProvider).open(context, Links.privacy);
            }),
            ListTile(
              leading: const Icon(Icons.verified_outlined, size: 22),
              title: const Text(
                'Version',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                '$kAppVersion · build $kBuildNumber',
                style: TextStyle(color: c.textMuted, fontSize: 13),
              ),
              minTileHeight: Dims.tap,
              dense: true,
            ),
            item(Icons.share_outlined, 'Share App', () {
              Navigator.pop(context);
              _share(context, ref);
            }),
            item(Icons.logout_rounded, 'Logout', () => _logout(context, ref)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
