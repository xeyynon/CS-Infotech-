import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/status_views.dart';
import '../../models/models.dart';
import 'disposition_sheet.dart';

/// The calling queue: every record in the active list, filterable by status,
/// one tap to dial. Not in the Figma file; implied by "Start Calling Now".
class CallingQueueScreen extends ConsumerStatefulWidget {
  const CallingQueueScreen({super.key});

  @override
  ConsumerState<CallingQueueScreen> createState() => _CallingQueueScreenState();
}

class _CallingQueueScreenState extends ConsumerState<CallingQueueScreen> {
  CallStatus? _filter;
  bool _filterInitialised = false;
  String _query = '';
  String? _expandedKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_filterInitialised) {
      _filterInitialised = true;
      final extra = GoRouterState.of(context).extra;
      if (extra is CallStatus) _filter = extra;
    }
  }

  Color _colorFor(CallStatus s) => switch (s) {
    CallStatus.pending => context.c.pending,
    CallStatus.called => context.c.success,
    CallStatus.rescheduled => context.c.scheduled,
  };

  Future<void> _call(CallRecord r) async {
    if (r.phone == null) return;
    await ref.read(launcherProvider).dial(context, r.phone!);
    if (!mounted) return;
    // We cannot know when the call ended; offer the disposition straight away
    // and let the agent fill it in when they are back.
    final result = await showDispositionSheet(context, r);
    if (result != null) {
      ref.read(dispositionsProvider.notifier).set(r.key, result);
    }
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
    final details = ref.watch(listDetailsProvider(selected.id));
    final dispositions = ref.watch(dispositionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calling queue'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => ref.invalidate(listDetailsProvider(selected.id)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const SampleDataBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dims.page, 4, Dims.page, 10),
            child: Row(
              children: [
                Text(selected.name.toUpperCase(), style: context.eyebrow()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dims.page, 0, Dims.page, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              style: context.body(15),
              decoration: InputDecoration(
                hintText: 'Search name, company or number',
                prefixIcon: Icon(Icons.search_rounded, color: c.textMuted),
                isDense: true,
              ),
            ),
          ),
          details.when(
            loading: () => const SizedBox(height: 44),
            error: (_, _) => const SizedBox.shrink(),
            data: (d) => _FilterChips(
              details: d,
              current: _filter,
              colorFor: _colorFor,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: details.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(Dims.page),
                itemCount: 7,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, _) => const SkeletonBox(height: 60),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(Dims.page),
                child: ErrorView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(listDetailsProvider(selected.id)),
                ),
              ),
              data: (d) {
                final items = d.calls.where((r) {
                  if (_filter != null && r.status != _filter) return false;
                  if (_query.isEmpty) return true;
                  return r.displayName.toLowerCase().contains(_query) ||
                      (r.company ?? '').toLowerCase().contains(_query) ||
                      (r.phone ?? '').contains(_query);
                }).toList();
                if (items.isEmpty) {
                  return EmptyView(
                    icon: Icons.filter_list_off_rounded,
                    title: _query.isEmpty
                        ? 'Nothing ${_filter?.label.toLowerCase() ?? ''} in this list'
                        : 'No match for "$_query"',
                    body: _query.isEmpty
                        ? 'Try another status.'
                        : 'Check the spelling or clear the search.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(listDetailsProvider(selected.id).future),
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
                                disposition: dispositions[items[i].key],
                                color: _colorFor(items[i].status),
                                expanded: _expandedKey == items[i].key,
                                onToggle: () => setState(
                                  () => _expandedKey =
                                      _expandedKey == items[i].key
                                      ? null
                                      : items[i].key,
                                ),
                                onCall: () => _call(items[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.details,
    required this.current,
    required this.colorFor,
    required this.onChanged,
  });

  final ListDetails details;
  final CallStatus? current;
  final Color Function(CallStatus) colorFor;
  final ValueChanged<CallStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    int count(CallStatus? s) => s == null
        ? details.calls.length
        : details.calls.where((r) => r.status == s).length;
    Widget chip(CallStatus? s, String label) {
      final selected = s == current;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Semantics(
          button: true,
          selected: selected,
          label: '$label, ${count(s)}',
          child: Material(
            color: selected ? c.text : c.card,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onChanged(s),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (s != null) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colorFor(s),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      label,
                      style: context.body(
                        13,
                        weight: FontWeight.w600,
                        color: selected ? c.bg : c.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${count(s)}',
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
      );
    }

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dims.page),
        children: [
          chip(null, 'All'),
          chip(CallStatus.pending, 'Pending'),
          chip(CallStatus.called, 'Done'),
          chip(CallStatus.rescheduled, 'Scheduled'),
        ],
      ),
    );
  }
}

/// One contact in the queue: initials, name, company, status, a call
/// button. Tap the row for the rest of the record.
class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.disposition,
    required this.color,
    required this.expanded,
    required this.onToggle,
    required this.onCall,
  });

  final CallRecord record;
  final String? disposition;
  final Color color;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = record;
    final initials =
        '${r.firstName.isNotEmpty ? r.firstName[0] : ''}${r.lastName.isNotEmpty ? r.lastName[0] : ''}'
            .toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Avatar(initial: initials, size: 42, seed: r.displayName),
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
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          StatusPill(label: r.status.label, color: color),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              fmtPhone(r.phone),
                              overflow: TextOverflow.ellipsis,
                              style: context.mono(12.5, color: c.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Call ${r.displayName}',
                  child: Material(
                    color: c.success.withValues(alpha: 0.14),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: r.phone == null ? null : onCall,
                      child: SizedBox(
                        width: Dims.tap,
                        height: Dims.tap,
                        child: Icon(
                          Icons.call_rounded,
                          color: c.success,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    'Logged: $disposition (this session only)',
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
            padding: const EdgeInsets.fromLTRB(72, 0, 18, 14),
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
                if (r.status == CallStatus.rescheduled)
                  _fact(
                    context,
                    'Rescheduled',
                    fmtDate(r.rescheduledAt),
                    mono: true,
                  ),
                _fact(context, 'Duration', fmtDuration(r.duration), mono: true),
                _fact(context, 'Feedback', r.feedback),
                _fact(context, 'Agent', r.agentName),
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
