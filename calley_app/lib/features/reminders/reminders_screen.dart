import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/status_views.dart';
import '../calls/call_actions.dart';
import 'reminders.dart';

/// The bell. Calls that were moved to a later time, with the ones that are
/// due now or late first. One tap dials, then asks how it went; once an
/// outcome is logged the call leaves the list.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final selected = ref.watch(selectedListProvider);
    final reminders = ref.watch(remindersProvider);
    final details = selected == null
        ? null
        : ref.watch(listDetailsProvider(selected.id));

    Widget body;
    if (selected == null) {
      body = EmptyView(
        icon: Icons.notifications_off_outlined,
        title: 'Pick a calling list first',
        body: 'Reminders come from the calls scheduled in a list.',
        action: OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
          child: const Text('Back to the dashboard'),
        ),
      );
    } else if (details!.isLoading) {
      body = ListView(
        padding: const EdgeInsets.all(Dims.page),
        children: const [
          SkeletonBox(height: 72, radius: Dims.cardRadius),
          SizedBox(height: Dims.gap),
          SkeletonBox(height: 72, radius: Dims.cardRadius),
        ],
      );
    } else if (details.hasError) {
      body = Padding(
        padding: const EdgeInsets.all(Dims.page),
        child: ErrorView(
          error: details.error!,
          onRetry: () => ref.invalidate(listDetailsProvider(selected.id)),
        ),
      );
    } else if (reminders.isEmpty) {
      body = const EmptyView(
        icon: Icons.alarm_on_rounded,
        title: 'Nothing scheduled',
        body: 'Calls you move to a later time will show up here.',
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(Dims.page, 4, Dims.page, 28),
        children: [
          for (final bucket in ReminderBucket.values)
            ..._section(
              context,
              ref,
              selected.id,
              bucket,
              reminders.where((r) => r.bucket == bucket).toList(),
              c,
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Column(
        children: [
          const SampleDataBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    WidgetRef ref,
    String listId,
    ReminderBucket bucket,
    List<Reminder> items,
    CalleyColors c,
  ) {
    if (items.isEmpty) return const [];
    final color = switch (bucket) {
      ReminderBucket.overdue => c.danger,
      ReminderBucket.today => c.pending,
      ReminderBucket.upcoming => c.scheduled,
    };
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${bucket.label.toUpperCase()} · ${items.length}',
              style: context.eyebrow(),
            ),
          ],
        ),
      ),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(indent: 72, endIndent: 18),
              _ReminderRow(
                reminder: items[i],
                onCall: () => callAndLog(context, ref, listId, items[i].record),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder, required this.onCall});

  final Reminder reminder;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = reminder.record;
    final canCall = r.phone != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Avatar(initial: r.initials, size: 42, seed: r.displayName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.body(15, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  r.company ?? noData,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.body(12.5, color: c.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  fmtDate(reminder.at),
                  style: context.mono(12.5, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            enabled: canCall,
            label: canCall
                ? 'Call ${r.displayName}'
                : 'No number for ${r.displayName}',
            excludeSemantics: true,
            onTap: canCall ? onCall : null,
            child: Material(
              color: canCall ? c.success.withValues(alpha: 0.14) : c.skeleton,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: canCall ? onCall : null,
                child: SizedBox(
                  width: Dims.tap,
                  height: Dims.tap,
                  child: Icon(
                    Icons.call_rounded,
                    color: canCall ? c.success : c.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
