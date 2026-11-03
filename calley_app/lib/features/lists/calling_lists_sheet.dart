import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/status_views.dart';
import '../../models/models.dart';

/// Figma 07's "CALLING LISTS" block: Select Calling List + Refresh, then the
/// lists from `GET /list?userId=`. Used inside the bottom sheet and Settings.
class CallingListsSection extends ConsumerWidget {
  const CallingListsSection({super.key, this.onSelected});

  final ValueChanged<CallingList>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final lists = ref.watch(listsProvider);
    final selected = ref.watch(selectedListProvider);
    final busy = lists.isLoading;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NavyHeader('Calling Lists'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select calling list',
                    style: context.display(17, weight: FontWeight.w700),
                  ),
                ),
                Semantics(
                  button: true,
                  label: busy ? 'Refreshing' : 'Refresh lists',
                  child: Material(
                    color: c.cardAlt,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: busy ? null : () => ref.invalidate(listsProvider),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            busy
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: c.text,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: c.text,
                                  ),
                            const SizedBox(width: 6),
                            Text(
                              'Refresh',
                              style: context.body(13, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: lists.when(
              loading: () => const Column(
                children: [
                  SkeletonBox(height: 54, radius: 14),
                  SizedBox(height: 8),
                  SkeletonBox(height: 54, radius: 14),
                ],
              ),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(listsProvider),
              ),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                      child: Text(
                        'No calling lists yet. Upload one on the web panel, then tap Refresh.',
                        style: context.body(13.5, color: c.textSecondary),
                      ),
                    )
                  : Column(
                      children: [
                        for (final l in items)
                          _ListRow(
                            list: l,
                            selected: l.id == selected?.id,
                            onTap: () async {
                              await ref.read(selectedListProvider.notifier).set(
                                (id: l.id, name: l.name),
                              );
                              onSelected?.call(l);
                            },
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

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.list,
    required this.selected,
    required this.onTap,
  });

  final CallingList list;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '${list.name}${selected ? ', selected' : ''}',
        child: Material(
          color: selected ? c.primarySoft : c.cardAlt,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: context.body(15, weight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: selected ? c.primary : c.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showCallingListsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: SingleChildScrollView(
        child: CallingListsSection(onSelected: (_) => Navigator.of(ctx).pop()),
      ),
    ),
  );
}
