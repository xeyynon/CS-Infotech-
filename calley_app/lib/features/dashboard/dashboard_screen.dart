import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/bottom_bar.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/donut_chart.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import '../../models/models.dart';
import '../drawer/app_drawer.dart';
import '../lists/calling_lists_sheet.dart';

/// Figma 06 (no list selected) and 08 (a list selected) on one screen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _onBottomTap(
    BuildContext context,
    WidgetRef ref,
    BottomTab tab,
  ) async {
    final selected = ref.read(selectedListProvider);
    switch (tab) {
      case BottomTab.home:
        return;
      case BottomTab.contacts:
      case BottomTab.play:
      case BottomTab.calendar:
        if (selected == null) {
          await showCallingListsSheet(context);
          return;
        }
        if (context.mounted) {
          context.push(
            Routes.queue,
            extra: tab == BottomTab.calendar ? CallStatus.rescheduled : null,
          );
        }
      case BottomTab.phone:
        if (selected == null) {
          await showCallingListsSheet(context);
          return;
        }
        final details = ref.read(listDetailsProvider(selected.id));
        final next = details.hasValue
            ? details.value!.calls
                  .where((r) => r.status == CallStatus.pending)
                  .firstOrNull
            : null;
        if (next?.phone != null) {
          if (context.mounted) {
            ref.read(launcherProvider).dial(context, next!.phone!);
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No pending call to dial.')),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedListProvider);
    final user = ref.watch(sessionProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              ref.invalidate(listsProvider);
              if (selected != null) {
                ref.invalidate(listDetailsProvider(selected.id));
              }
            },
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No notifications yet.')),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const SampleDataBanner(),
          Expanded(
            child: selected == null
                ? _EmptyDashboard(user: user)
                : _ActiveDashboard(user: user, list: selected),
          ),
        ],
      ),
      bottomNavigationBar: CalleyBottomBar(
        current: BottomTab.home,
        onTap: (t) => _onBottomTap(context, ref, t),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Figma 06: no list chosen yet
// ---------------------------------------------------------------------------

class _EmptyDashboard extends ConsumerWidget {
  const _EmptyDashboard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final lists = ref.watch(listsProvider);
    final hasLists = lists.hasValue && lists.value!.isNotEmpty;
    final now = ref.watch(clockProvider)();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(listsProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 8),
              children: [
                GreetingCard(
                  eyebrow: greetingFor(now),
                  name: user?.firstName ?? 'there',
                  subline: 'Welcome to Calley · ${user?.subscription ?? ''}',
                ),
                const SizedBox(height: Dims.gap),
                if (lists.hasError && !lists.isLoading)
                  ErrorView(
                    error: lists.error!,
                    onRetry: () => ref.invalidate(listsProvider),
                  )
                else if (hasLists)
                  _PickListCard(count: lists.value!.length)
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        const NavyHeader('Load number to call'),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                          child: Text.rich(
                            TextSpan(
                              text: 'Visit ',
                              children: [
                                TextSpan(
                                  text: 'app.getcalley.com',
                                  style: context.body(
                                    14.5,
                                    weight: FontWeight.w600,
                                    color: c.primary,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' to upload numbers that you wish to call using Calley Mobile App.',
                                ),
                              ],
                            ),
                            style: context.body(14.5, height: 1.5),
                          ),
                        ),
                        const _UploadIllustration(),
                        if (lists.isLoading)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 18),
                            child: SkeletonBox(height: 14, width: 160),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => ref.invalidate(listsProvider),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: const Text('Check for lists again'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 12),
          child: Row(
            children: [
              WhatsAppButton(
                onPressed: () =>
                    ref.read(launcherProvider).open(context, Links.whatsapp),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Start Calling Now',
                  onPressed: hasLists
                      ? () => showCallingListsSheet(context)
                      : () => ref
                            .read(launcherProvider)
                            .open(context, Links.webPanel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickListCard extends StatelessWidget {
  const _PickListCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: () => showCallingListsSheet(context),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.list_alt_rounded, color: c.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a calling list',
                  style: context.display(17, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count ${count == 1 ? 'list' : 'lists'} ready on your account',
                  style: context.body(13, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}

/// Stand-in for the Figma illustration (person at a desk with a phone), drawn
/// from icons so it follows the theme.
class _UploadIllustration extends StatelessWidget {
  const _UploadIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget badge(IconData icon, Color color) => Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: c.bg,
        shape: BoxShape.circle,
        border: Border.all(color: c.card, width: 3),
      ),
      child: Icon(icon, size: 18, color: color),
    );
    return ExcludeSemantics(
      child: SizedBox(
        height: 126,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: c.cardAlt,
                shape: BoxShape.circle,
              ),
            ),
            Icon(Icons.phone_iphone_rounded, size: 60, color: c.primary),
            Positioned(
              top: 4,
              right: 118,
              child: badge(Icons.cloud_upload_outlined, c.scheduled),
            ),
            Positioned(
              bottom: 4,
              left: 118,
              child: badge(Icons.headset_mic_outlined, c.pending),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Figma 08: a list is active
// ---------------------------------------------------------------------------

class _ActiveDashboard extends ConsumerWidget {
  const _ActiveDashboard({required this.user, required this.list});

  final User? user;
  final SelectedList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final details = ref.watch(listDetailsProvider(list.id));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(listDetailsProvider(list.id).future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 8),
              children: [
                AppCard(
                  onTap: () => showCallingListsSheet(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active list', style: context.eyebrow()),
                            const SizedBox(height: 6),
                            Text(
                              list.name,
                              style: context.display(
                                22,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      details.when(
                        loading: () => const SkeletonBox(height: 34, width: 64),
                        error: (_, _) => Text(
                          noData,
                          style: context.mono(28, color: c.textMuted),
                        ),
                        data: (d) => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${d.calls.length}',
                              style: context.mono(
                                30,
                                weight: FontWeight.w600,
                                color: c.primary,
                              ),
                            ),
                            Text('calls', style: context.eyebrow()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.unfold_more_rounded, color: c.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: Dims.gap),
                details.when(
                  loading: () => const _StatsSkeleton(),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () => ref.invalidate(listDetailsProvider(list.id)),
                  ),
                  data: (d) => _Stats(
                    details: d,
                    onStatTap: (s) => context.push(Routes.queue, extra: s),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 12),
          child: PrimaryButton(
            label: 'Start Calling Now',
            icon: Icons.play_arrow_rounded,
            onPressed: details.hasValue
                ? () => context.push(Routes.queue)
                : null,
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.details, required this.onStatTap});

  final ListDetails details;
  final ValueChanged<CallStatus?> onStatTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final segments = [
      DonutSegment(label: 'Done', value: details.called, color: c.done),
      DonutSegment(label: 'Pending', value: details.pending, color: c.pending),
      DonutSegment(
        label: 'Scheduled',
        value: details.rescheduled,
        color: c.scheduled,
      ),
    ];
    final total = details.total;
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Row(
            children: [
              total == 0
                  ? const SizedBox(
                      width: 150,
                      child: EmptyView(
                        icon: Icons.donut_large_rounded,
                        title: 'No calls yet',
                      ),
                    )
                  : DonutChart(
                      segments: segments,
                      size: 150,
                      centerLabel: 'TOTAL',
                    ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: context.eyebrow()),
                    const SizedBox(height: 10),
                    for (final s in segments) ...[
                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.label,
                              style: context.body(13.5, color: c.textSecondary),
                            ),
                          ),
                          Text(
                            fmtShare(s.value, total),
                            style: context.mono(13.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dims.gap),
        StatLedger(
          entries: [
            LedgerEntry(
              label: 'Pending',
              value: details.pending,
              color: c.pending,
              onTap: () => onStatTap(CallStatus.pending),
            ),
            LedgerEntry(
              label: 'Done',
              value: details.called,
              color: c.success,
              onTap: () => onStatTap(CallStatus.called),
            ),
            LedgerEntry(
              label: 'Scheduled',
              value: details.rescheduled,
              color: c.scheduled,
              onTap: () => onStatTap(CallStatus.rescheduled),
            ),
          ],
        ),
        if (details.calls.length != total) ...[
          const SizedBox(height: 10),
          Text(
            'Counts as reported by the server; the list holds ${details.calls.length} records.',
            style: context.body(12, color: c.textMuted),
          ),
        ],
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Row(
            children: const [
              SkeletonBox(height: 150, width: 150, radius: 75),
              SizedBox(width: 18),
              Expanded(child: SkeletonBox(height: 90)),
            ],
          ),
        ),
        const SizedBox(height: Dims.gap),
        const SkeletonBox(height: 86, radius: Dims.cardRadius),
      ],
    );
  }
}
