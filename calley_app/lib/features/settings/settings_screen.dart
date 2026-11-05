import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/build_info.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/status_views.dart';
import '../drawer/app_drawer.dart';
import '../language/languages.dart';
import '../lists/calling_lists_sheet.dart';

/// Figma 07 — profile header, PROFILE SETTINGS, CALLING LISTS. Plus two
/// rows the design does not have: theme and data source.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _changePassword(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: const Text(
          'The test server has no endpoint for this. Passwords are managed on the Calley web panel.',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(sessionProvider);
    final language = languageFor(ref.watch(languageProvider));
    final themeMode = ref.watch(themeModeProvider);
    final source = ref.watch(dataSourceProvider);

    Widget row({
      required IconData icon,
      required String title,
      String? value,
      VoidCallback? onTap,
      Widget? trailing,
    }) => ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
      ),
      subtitle: value == null
          ? null
          : Text(value, style: TextStyle(fontSize: 12.5, color: c.textMuted)),
      trailing:
          trailing ??
          Icon(Icons.arrow_circle_right_outlined, color: c.textMuted),
      onTap: onTap,
      minTileHeight: Dims.tap,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          const SampleDataBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Dims.page, 12, Dims.page, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.navy,
                    borderRadius: BorderRadius.circular(Dims.cardRadius),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Avatar(
                        initial: user?.initial ?? '?',
                        size: 48,
                        inverted: true,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Guest',
                              style: context.display(
                                22,
                                weight: FontWeight.w700,
                                color: c.onNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.email ?? noData,
                              style: context.body(
                                13,
                                color: c.onNavy.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              user?.phone ?? noData,
                              style: context.mono(
                                13,
                                color: c.onNavy.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PARENT ACCOUNT  ·  NA',
                              style: context.eyebrow(
                                color: c.onNavy.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SUBSCRIPTION  ·  ${(user?.subscription ?? noData).toUpperCase()}',
                              style: context.eyebrow(
                                color: c.onNavy.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const NavyHeader('Profile Settings'),
                      row(
                        icon: Icons.language_rounded,
                        title: 'App Language',
                        value: language.name,
                        onTap: () => context.push(Routes.language),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      row(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        onTap: () => _changePassword(context),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.brightness_6_outlined,
                          size: 22,
                        ),
                        title: const Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        minTileHeight: Dims.tap,
                        // Below the title, not beside it: three segments do
                        // not fit next to the label on a 360 px phone.
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {themeMode},
                            showSelectedIcon: false,
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            onSelectionChanged: (s) => ref
                                .read(themeModeProvider.notifier)
                                .set(s.first),
                          ),
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      // B-46: one control, one label; tapping the row toggles.
                      SwitchListTile(
                        secondary: const Icon(Icons.cloud_outlined, size: 22),
                        title: const Text(
                          'Use sample data',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          source == DataSource.remote
                              ? 'Off: using the Calley test server'
                              : 'On: data bundled with the app',
                          style: TextStyle(fontSize: 12.5, color: c.textMuted),
                        ),
                        value: source == DataSource.sample,
                        onChanged: kForceMock
                            ? null
                            : (v) => ref
                                  .read(dataSourceProvider.notifier)
                                  .set(
                                    v ? DataSource.sample : DataSource.remote,
                                  ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const CallingListsSection(),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Calley $kAppVersion · build $kBuildNumber',
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
