import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/calley_loader.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/status_views.dart';
import 'progress_stats.dart';

/// Drawer → Gamification. How far through the list the agent is, what the
/// calls led to, and the badges earned. Everything comes from the list data
/// and the outcomes logged on this phone; nothing is invented.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedListProvider);
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: Column(
        children: [
          const SampleDataBanner(),
          Expanded(
            child: selected == null
                ? EmptyView(
                    icon: Icons.emoji_events_outlined,
                    title: 'Pick a calling list first',
                    body: 'Your progress is counted against a list.',
                    action: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, Dims.tap),
                      ),
                      child: const Text('Back to the dashboard'),
                    ),
                  )
                : _Body(listId: selected.id, listName: selected.name, c: c),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.listId, required this.listName, required this.c});

  final String listId;
  final String listName;
  final CalleyColors c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(listDetailsProvider(listId));
    final dispositions = ref.watch(dispositionsProvider);

    if (details.isLoading) {
      return const Center(
        child: CalleyLoader(label: 'Working out your progress…'),
      );
    }
    if (details.hasError) {
      return Padding(
        padding: const EdgeInsets.all(Dims.page),
        child: ErrorView(
          error: details.error!,
          onRetry: () => ref.invalidate(listDetailsProvider(listId)),
        ),
      );
    }

    final stats = computeProgress(
      details.value!,
      (r) => dispositions[DispositionsNotifier.keyFor(listId, r.key)],
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 28),
      children: [
        _LevelCard(stats: stats, listName: listName),
        const SizedBox(height: Dims.gap),
        _OutcomesCard(stats: stats),
        const SizedBox(height: Dims.gap),
        _BadgesCard(stats: stats),
        const SizedBox(height: 16),
        Text(
          'Counted from this list and the outcomes you logged on this phone. '
          'The test server does not store outcomes.',
          textAlign: TextAlign.center,
          style: context.body(12, color: c.textMuted),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.stats, required this.listName});

  final ProgressStats stats;
  final String listName;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final next = stats.nextLevel;
    final pct = (stats.fraction * 100).round();
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        children: [
          Text('LEVEL', style: context.eyebrow()),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              stats.level.name,
              style: context.display(40, weight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${stats.reached} of ${stats.total} contacts reached · $pct%',
            style: context.mono(13.5, color: c.textSecondary),
          ),
          const SizedBox(height: 18),
          Semantics(
            label: next == null
                ? 'Top level reached'
                : '${(stats.levelFraction * 100).round()} percent of the way to ${next.name}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: stats.levelFraction,
                minHeight: 8,
                backgroundColor: c.skeleton,
                color: c.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            next == null
                ? 'Top level. Everyone in $listName has been reached.'
                : '${stats.toNextLevel} more ${stats.toNextLevel == 1 ? 'contact' : 'contacts'} to reach ${next.name}',
            textAlign: TextAlign.center,
            style: context.body(13.5, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OutcomesCard extends StatelessWidget {
  const _OutcomesCard({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final entries = stats.byOutcome.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final most = entries.isEmpty ? 1 : entries.first.value;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OUTCOMES LOGGED ON THIS PHONE', style: context.eyebrow()),
          const SizedBox(height: 12),
          if (entries.isEmpty) ...[
            Text(
              'None yet. Call someone from the queue and say how it went.',
              style: context.body(14, color: c.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(Routes.queue),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, Dims.tap),
              ),
              child: const Text('Open the calling queue'),
            ),
          ] else
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 118,
                      child: Text(e.key, style: context.body(13.5)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: e.value / most,
                          minHeight: 8,
                          backgroundColor: c.skeleton,
                          color: c.done,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: context.mono(14, weight: FontWeight.w600),
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

class _BadgesCard extends StatelessWidget {
  const _BadgesCard({required this.stats});

  final ProgressStats stats;

  static const _icons = {
    'first': Icons.flag_rounded,
    'five': Icons.filter_5_rounded,
    'half': Icons.timelapse_rounded,
    'positive': Icons.sentiment_satisfied_alt_rounded,
    'sweep': Icons.cleaning_services_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BADGES · ${stats.earnedBadges} OF ${stats.badges.length}',
            style: context.eyebrow(),
          ),
          const SizedBox(height: 8),
          for (final b in stats.badges)
            // One line per badge; earned or locked is a word, not just colour.
            Semantics(
              label: '${b.title}, ${b.earned ? 'earned' : 'locked'}. ${b.hint}',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: b.earned ? c.primary : c.cardAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icons[b.id] ?? Icons.star_rounded,
                        size: 21,
                        color: b.earned ? c.onPrimary : c.textMuted,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: context.body(
                              14.5,
                              weight: FontWeight.w600,
                              color: b.earned ? c.text : c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.hint,
                            style: context.body(12.5, color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      b.earned ? 'Earned' : 'Locked',
                      style: context.eyebrow(
                        color: b.earned ? c.success : c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
