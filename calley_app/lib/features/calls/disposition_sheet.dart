import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/models.dart';

/// The five outcomes seen in the API data. Returned as typed by the server
/// so a future write endpoint can take the value as is.
const List<String> kDispositions = [
  'Very positive',
  'Satisfied',
  'Needs follow-up',
  'Neutral',
  'Negative',
];

/// Asks "How did the call go?". Returns the chosen outcome, or null if the
/// sheet was dismissed. [current] marks an outcome already logged, so the
/// sheet doubles as "change outcome".
///
/// HCI: centred heading (one focal point right after a call), five
/// full-width 48 dp options in a single column (one decision, no hunting),
/// and a plain statement of where the answer is kept.
Future<String?> showDispositionSheet(
  BuildContext context,
  CallRecord record, {
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final c = ctx.c;
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
                  current == null ? 'How did the call go?' : 'Change outcome',
                  textAlign: TextAlign.center,
                  style: ctx.display(22, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.fullName,
                textAlign: TextAlign.center,
                style: ctx.body(13.5, color: c.textSecondary),
              ),
              const SizedBox(height: 16),
              for (final d in kDispositions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, d),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size.fromHeight(Dims.tap),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      backgroundColor: d == current ? c.primarySoft : null,
                      side: BorderSide(
                        color: d == current ? c.primary : c.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(d)),
                        if (d == current)
                          Icon(Icons.check_rounded, size: 20, color: c.primary),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Kept on this phone for this session: the test server has no endpoint to save it.',
                textAlign: TextAlign.center,
                style: ctx.body(12, color: c.textMuted),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
