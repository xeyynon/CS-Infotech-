import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_views.dart';
import '../../models/models.dart';
import 'disposition_sheet.dart';

/// Status filter for the queue. "Open" = still to call in this session:
/// pending on the server and no outcome logged here yet.
enum QueueFilter { open, all, done, scheduled }

extension on QueueFilter {
  String get label => switch (this) {
    QueueFilter.open => 'To call',
    QueueFilter.all => 'All',
    QueueFilter.done => 'Done',
    QueueFilter.scheduled => 'Scheduled',
  };
}

/// The calling queue: every record in the active list, one tap to dial,
/// then one tap to log the outcome. Not in the Figma file; it is where
/// "Start Calling Now" leads.
///
/// HCI choices, for an agent working through 50 numbers:
/// - The default view is "To call", so finished contacts drop out of the way
///   as outcomes are logged (the list visibly gets shorter: progress).
/// - A "Call next" button sits in the thumb zone and always targets the next
///   open contact, so the loop is dial → outcome → next, with no scrolling.
/// - Progress ("12 of 50 logged") is always on screen.
/// - Logging is undoable from the snackbar; outcomes can be changed later.
class CallingQueueScreen extends ConsumerStatefulWidget {
  const CallingQueueScreen({super.key});

  @override
  ConsumerState<CallingQueueScreen> createState() => _CallingQueueScreenState();
}

class _CallingQueueScreenState extends ConsumerState<CallingQueueScreen> {
  QueueFilter _filter = QueueFilter.open;
  bool _filterInitialised = false;
  final _search = TextEditingController();
  String _query = '';
  String? _expandedKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_filterInitialised) {
      _filterInitialised = true;
      final extra = GoRouterState.of(context).extra;
      _filter = switch (extra) {
        CallStatus.called => QueueFilter.done,
        CallStatus.rescheduled => QueueFilter.scheduled,
        CallStatus.pending => QueueFilter.open,
        QueueFilter f => f,
        _ => QueueFilter.open,
      };
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _colorFor(CallRecord r, bool logged) {
    final c = context.c;
    if (logged) return c.done;
    if (r.isRescheduled) return c.scheduled;
    return r.status == CallStatus.called ? c.done : c.pending;
  }

  String _labelFor(CallRecord r, bool logged) {
    if (logged) return 'Logged';
    if (r.isRescheduled) return 'Scheduled';
    return r.status.label;
  }

  bool _isOpen(String listId, CallRecord r) =>
      r.status == CallStatus.pending &&
      !r.isRescheduled &&
      ref.read(dispositionsProvider.notifier).get(listId, r.key) == null;

  bool _matches(
    String listId,
    CallRecord r, {
    QueueFilter? filter,
    bool withQuery = true,
  }) {
    final logged =
        ref.read(dispositionsProvider.notifier).get(listId, r.key) != null;
    final passFilter = switch (filter ?? _filter) {
      QueueFilter.all => true,
      QueueFilter.open => _isOpen(listId, r),
      QueueFilter.done =>
        logged || (r.status == CallStatus.called && !r.isRescheduled),
      QueueFilter.scheduled => r.isRescheduled,
    };
    if (!passFilter) return false;
    if (!withQuery || _query.isEmpty) return true;
    // B-31: compare digits with digits, so "10000 00002" finds 1000000002.
    final qDigits = _query.replaceAll(RegExp(r'\D'), '');
    final phoneDigits = (r.phone ?? '').replaceAll(RegExp(r'\D'), '');
    return r.displayName.toLowerCase().contains(_query) ||
        (r.company ?? '').toLowerCase().contains(_query) ||
        (qDigits.isNotEmpty && phoneDigits.contains(qDigits));
  }

  Future<void> _logOutcome(String listId, CallRecord r) async {
    final notifier = ref.read(dispositionsProvider.notifier);
    final previous = notifier.get(listId, r.key);
    final result = await showDispositionSheet(context, r, current: previous);
    if (result == null || !mounted) return;
    notifier.set(listId, r.key, result);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${r.displayName}: $result'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => previous == null
                ? notifier.remove(listId, r.key)
                : notifier.set(listId, r.key, previous),
          ),
        ),
      );
  }

  Future<void> _call(String listId, CallRecord r) async {
    if (r.phone == null) return;
    // B-27: only ask how the call went if the dialer actually opened.
    final placed = await ref.read(launcherProvider).dial(context, r.phone!);
    if (!placed || !mounted) return;
    await _logOutcome(listId, r);
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final selected = ref.watch(selectedListProvider);
    if (selected == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calling queue')),
        body: const EmptyView(
          icon: Icons.list_alt_rounded,
          title: 'No calling list selected',
          body: 'Pick a list on the Dashboard first.',
        ),
      );
    }
    final listId = selected.id;
    final details = ref.watch(listDetailsProvider(listId));
    ref.watch(dispositionsProvider); // rebuild when an outcome is logged
    final dispositions = ref.read(dispositionsProvider.notifier);

    final items = details.hasValue
        ? details.value!.calls.where((r) => _matches(listId, r)).toList()
        : const <CallRecord>[];
    final next = details.hasValue
        ? details.value!.calls
              .where((r) => r.phone != null && _isOpen(listId, r))
              .firstOrNull
        : null;
    final logged = dispositions.countFor(listId);
    final totalRecords = details.hasValue ? details.value!.calls.length : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calling queue'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => ref.invalidate(listDetailsProvider(listId)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      // The next action in the thumb zone, in the same place and style as
      // every other screen's main button; it names who it will call.
      bottomNavigationBar: next == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Dims.page, 8, Dims.page, 12),
                child: PrimaryButton(
                  label: 'Call next · ${next.firstName}',
                  icon: Icons.call_rounded,
                  onPressed: () => _call(listId, next),
                ),
              ),
            ),
      body: Column(
        children: [
          const SampleDataBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dims.page, 4, Dims.page, 10),
            child: Row(
              children: [
                // B-29: a long list name ellipsises instead of overflowing.
                Expanded(
                  child: Text(
                    selected.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.eyebrow(),
                  ),
                ),
                if (totalRecords > 0)
                  Text(
                    '$logged of $totalRecords logged',
                    style: context.mono(12.5, color: c.textSecondary),
                  ),
              ],
            ),
          ),
          if (totalRecords > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(Dims.page, 0, Dims.page, 10),
              child: Semantics(
                label: '$logged of $totalRecords calls logged',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: logged / totalRecords,
                    minHeight: 4,
                    backgroundColor: c.skeleton,
                    color: c.done,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dims.page, 0, Dims.page, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              style: context.body(15),
              decoration: InputDecoration(
                hintText: 'Search name, company or number',
                prefixIcon: Icon(Icons.search_rounded, color: c.textMuted),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _clearSearch,
                      ),
                isDense: true,
              ),
            ),
          ),
          if (details.hasValue)
            _FilterChips(
              listId: listId,
              details: details.value!,
              current: _filter,
              matchesFilter: (f, r) =>
                  _matches(listId, r, filter: f, withQuery: false),
              onChanged: (f) => setState(() => _filter = f),
            )
          else
            const SizedBox(height: 56),
          Expanded(
            // B-30: show the loading state on Retry too, not only first load.
            child: details.isLoading
                ? ListView.separated(
                    padding: const EdgeInsets.all(Dims.page),
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, _) => const SkeletonBox(height: 60),
                  )
                : details.hasError
                ? Padding(
                    padding: const EdgeInsets.all(Dims.page),
                    child: ErrorView(
                      error: details.error!,
                      onRetry: () =>
                          ref.invalidate(listDetailsProvider(listId)),
                    ),
                  )
                : items.isEmpty
                ? _emptyFor(details.value!)
                : RefreshIndicator(
                    // B-38: a failed refresh shows on screen; it must not
                    // also escape as an unhandled error.
                    onRefresh: () async {
                      ref.invalidate(listDetailsProvider(listId));
                      try {
                        await ref.read(listDetailsProvider(listId).future);
                      } catch (_) {}
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Dims.page,
                        4,
                        Dims.page,
                        24,
                      ),
                      children: [
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0; i < items.length; i++) ...[
                                if (i > 0)
                                  const Divider(indent: 72, endIndent: 18),
                                _RecordRow(
                                  record: items[i],
                                  disposition: dispositions.get(
                                    listId,
                                    items[i].key,
                                  ),
                                  statusLabel: _labelFor(
                                    items[i],
                                    dispositions.get(listId, items[i].key) !=
                                        null,
                                  ),
                                  color: _colorFor(
                                    items[i],
                                    dispositions.get(listId, items[i].key) !=
                                        null,
                                  ),
                                  expanded: _expandedKey == items[i].key,
                                  onToggle: () => setState(
                                    () => _expandedKey =
                                        _expandedKey == items[i].key
                                        ? null
                                        : items[i].key,
                                  ),
                                  onCall: () => _call(listId, items[i]),
                                  onLog: () => _logOutcome(listId, items[i]),
                                ),
                              ],
                            ],
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

  Widget _emptyFor(ListDetails d) {
    if (_query.isNotEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No match for "$_query"',
        body: 'Check the spelling, or clear the search.',
        action: OutlinedButton(
          onPressed: _clearSearch,
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
          child: const Text('Clear search'),
        ),
      );
    }
    return switch (_filter) {
      QueueFilter.open => EmptyView(
        icon: Icons.task_alt_rounded,
        title: 'Everyone in this list has been called',
        body: 'Outcomes are logged for this session.',
        action: OutlinedButton(
          onPressed: () => setState(() => _filter = QueueFilter.all),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, Dims.tap)),
          child: const Text('Show all contacts'),
        ),
      ),
      _ => EmptyView(
        icon: Icons.filter_list_off_rounded,
        title: 'Nothing ${_filter.label.toLowerCase()} in this list',
        body: 'Try another status.',
      ),
    };
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.listId,
    required this.details,
    required this.current,
    required this.matchesFilter,
    required this.onChanged,
  });

  final String listId;
  final ListDetails details;
  final QueueFilter current;
  final bool Function(QueueFilter, CallRecord) matchesFilter;
  final ValueChanged<QueueFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    int count(QueueFilter f) =>
        details.calls.where((r) => matchesFilter(f, r)).length;
    Color? dot(QueueFilter f) => switch (f) {
      QueueFilter.open => c.pending,
      QueueFilter.done => c.done,
      QueueFilter.scheduled => c.scheduled,
      QueueFilter.all => null,
    };
    Widget chip(QueueFilter f) {
      final selected = f == current;
      final d = dot(f);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Semantics(
          button: true,
          selected: selected,
          label: '${f.label}, ${count(f)}',
          excludeSemantics: true,
          onTap: () => onChanged(f),
          child: Material(
            color: selected ? c.text : c.card,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onChanged(f),
              borderRadius: BorderRadius.circular(999),
              child: ConstrainedBox(
                // B-17: chips are full 48 dp touch targets.
                constraints: const BoxConstraints(minHeight: Dims.tap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (d != null) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: d,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                      ],
                      Text(
                        f.label,
                        style: context.body(
                          13,
                          weight: FontWeight.w600,
                          color: selected ? c.bg : c.text,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${count(f)}',
                        style: context.mono(
                          12.5,
                          color: selected
                              ? c.bg.withValues(alpha: 0.75)
                              : c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(Dims.page, 2, Dims.page, 6),
        children: [for (final f in QueueFilter.values) chip(f)],
      ),
    );
  }
}

/// One contact in the queue: initials, name, company, status, a call
/// button. Tap the row for the rest of the record and to log an outcome.
class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.disposition,
    required this.statusLabel,
    required this.color,
    required this.expanded,
    required this.onToggle,
    required this.onCall,
    required this.onLog,
  });

  final CallRecord record;
  final String? disposition;
  final String statusLabel;
  final Color color;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCall;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = record;
    final canCall = r.phone != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              // B-32: the row says whether it is expanded and what a tap does.
              child: Semantics(
                expanded: expanded,
                button: true,
                onTapHint: expanded ? 'hide details' : 'show details',
                child: InkWell(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Row(
                      children: [
                        Avatar(
                          initial: r.initials,
                          size: 42,
                          seed: r.displayName,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.body(
                                  15,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.company ?? noData,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.body(
                                  12.5,
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  StatusPill(label: statusLabel, color: color),
                                  Text(
                                    fmtPhone(r.phone),
                                    style: context.mono(
                                      12.5,
                                      color: c.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Semantics(
                button: true,
                enabled: canCall,
                label: canCall
                    ? 'Call ${r.displayName}'
                    : 'No number for ${r.displayName}',
                excludeSemantics: true,
                onTap: canCall ? onCall : null,
                child: Material(
                  color: canCall
                      ? c.success.withValues(alpha: 0.14)
                      : c.skeleton,
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
            ),
          ],
        ),
        if (disposition != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 10),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 18, color: c.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Outcome: $disposition · kept on this phone for this session',
                    style: context.body(12, color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fact(context, 'Email', r.email),
                _fact(context, 'Address', r.address),
                _fact(context, 'Notes', r.notes),
                if (r.otherPhones.isNotEmpty)
                  _fact(
                    context,
                    'Other',
                    r.otherPhones.map(fmtPhone).join(', '),
                    mono: true,
                  ),
                _fact(context, 'Called', fmtDate(r.calledAt), mono: true),
                // B-33: shown whenever there is a reschedule time.
                if (r.rescheduledAt != null)
                  _fact(
                    context,
                    'Rescheduled',
                    fmtDate(r.rescheduledAt),
                    mono: true,
                  ),
                _fact(context, 'Duration', fmtDuration(r.duration), mono: true),
                _fact(context, 'Feedback', r.feedback),
                _fact(context, 'Agent', r.agentName),
                // Outcomes can be logged or changed without dialling again.
                TextButton.icon(
                  onPressed: onLog,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, Dims.tap),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: Text(
                    disposition == null ? 'Log outcome' : 'Change outcome',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fact(
    BuildContext context,
    String label,
    String? value, {
    bool mono = false,
  }) {
    final c = context.c;
    final text = value == null || value.isEmpty ? noData : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: context.body(12.5, color: c.textMuted)),
          ),
          Expanded(
            child: Text(
              text,
              style: mono
                  ? context.mono(12.5, color: c.textSecondary)
                  : context.body(12.5, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}
