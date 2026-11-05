import 'package:flutter/gestures.dart';
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
import '../calls/call_actions.dart';
import '../reminders/reminders.dart';
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
        void say(String m) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(m)));
        if (details.isLoading) {
          return say('Still loading the list. Try again in a moment.');
        }
        if (details.hasError) {
          return say('Could not load the list, so there is nobody to dial.');
        }
        // B-34: the next contact still to call (pending AND not already
        // logged this session), not always the first pending one.
        final dispositions = ref.read(dispositionsProvider.notifier);
        final next = details.value!.calls
            .where(
              (r) =>
                  r.phone != null &&
                  r.status == CallStatus.pending &&
                  !r.isRescheduled &&
                  dispositions.get(selected.id, r.key) == null,
            )
            .firstOrNull;
        if (next == null) return say('Everyone in this list has been called.');
        if (!context.mounted) return;
        await callAndLog(context, ref, selected.id, next);
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
          // Calls due today or late, as a count on the bell.
          Builder(
            builder: (context) {
              final due = dueCount(ref.watch(remindersProvider));
              return IconButton(
                tooltip: due == 0 ? 'Reminders' : 'Reminders, $due due',
                icon: Badge(
                  isLabelVisible: due > 0,
                  label: Text('$due'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                onPressed: () => context.push(Routes.reminders),
              );
            },
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
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(listsProvider);
              try {
                await ref.read(listsProvider.future);
              } catch (_) {} // B-38: the error is shown on screen
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 8),
              children: [
                GreetingCard(
                  eyebrow: 'Hello',
                  name: user?.firstName ?? 'there',
                  subline: 'Welcome to Calley!',
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
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Visit ',
                              children: [
                                // Styled as a link, so it works as one.
                                TextSpan(
                                  text: 'app.getcalley.com',
                                  style: context
                                      .body(
                                        14.5,
                                        weight: FontWeight.w600,
                                        color: c.primary,
                                      )
                                      .copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => ref
                                        .read(launcherProvider)
                                        .open(context, Links.webPanel),
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
                            child: Center(
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
                // B-36: never send someone to the browser because the lists
                // have not arrived yet or failed to load.
                child: PrimaryButton(
                  label: lists.hasError ? 'Try again' : 'Start Calling Now',
                  busy: lists.isLoading,
                  onPressed: lists.hasError
                      ? () => ref.invalidate(listsProvider)
                      : hasLists
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
    // B-37: a fixed box, so the badges sit on the circle's edge.
    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          width: 150,
          height: 126,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
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
                top: 6,
                right: 6,
                child: badge(Icons.cloud_upload_outlined, c.scheduled),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: badge(Icons.headset_mic_outlined, c.pending),
              ),
            ],
          ),
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
            onRefresh: () async {
              ref.invalidate(listDetailsProvider(list.id));
              try {
                await ref.read(listDetailsProvider(list.id).future);
              } catch (_) {} // B-38
            },
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
                        skipLoadingOnRefresh: false,
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
                            Text('contacts', style: context.eyebrow()),
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
                  skipLoadingOnRefresh: false, // B-30: Retry shows progress
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
                ? () => context.push(Routes.queue, extra: CallStatus.pending)
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
    // Three groups that do not overlap, so the ring adds up to the list
    // (the server's own counts count rescheduled calls twice).
    final segments = [
      DonutSegment(label: 'Done', value: details.doneCount, color: c.done),
      DonutSegment(
        label: 'Pending',
        value: details.pendingCount,
        color: c.pending,
      ),
      DonutSegment(
        label: 'Scheduled',
        value: details.scheduledCount,
        color: c.scheduled,
      ),
    ];
    final total = details.total;
    return Column(
      children: [
        // Centred: the ring is the one focal point of this screen, with its
        // legend directly underneath so the eye does not travel sideways.
        AppCard(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: LayoutBuilder(
            builder: (context, box) {
              final size = (box.maxWidth * 0.55).clamp(140.0, 190.0);
              return SizedBox(
                width: double.infinity, // fill the card; centre within it
                child: Column(
                  children: [
                    if (total == 0)
                      const EmptyView(
                        icon: Icons.donut_large_rounded,
                        title: 'No calls in this list yet',
                        body: 'Upload numbers on the web panel, then Refresh.',
                      )
                    else
                      DonutChart(
                        segments: segments,
                        size: size,
                        centerLabel: 'CONTACTS',
                      ),
                    const SizedBox(height: 18),
                    // B-40: wraps instead of cutting words at large text sizes.
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        for (final s in segments)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                s.label,
                                style: context.body(
                                  13.5,
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                fmtShare(s.value, total),
                                style: context.mono(13.5),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Dims.gap),
        StatLedger(
          entries: [
            LedgerEntry(
              label: 'Pending',
              value: details.pendingCount,
              color: c.pending,
              onTap: () => onStatTap(CallStatus.pending),
            ),
            // B-39: Done is the same blue everywhere it appears.
            LedgerEntry(
              label: 'Done',
              value: details.doneCount,
              color: c.done,
              onTap: () => onStatTap(CallStatus.called),
            ),
            LedgerEntry(
              label: 'Scheduled',
              value: details.scheduledCount,
              color: c.scheduled,
              onTap: () => onStatTap(CallStatus.rescheduled),
            ),
          ],
        ),
        if (details.scheduledCount > 0 && details.calls.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Scheduled calls were made and moved to a later time; the server '
            'also counts them as called (${details.called} called in all).',
            textAlign: TextAlign.center,
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
        const AppCard(
          child: Column(
            children: [
              SkeletonBox(height: 170, width: 170, radius: 85),
              SizedBox(height: 18),
              SkeletonBox(height: 14, width: 220),
            ],
          ),
        ),
        const SizedBox(height: Dims.gap),
        const SkeletonBox(height: 86, radius: Dims.cardRadius),
      ],
    );
  }
}
