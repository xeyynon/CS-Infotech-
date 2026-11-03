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

/// Asks "How did the call go?" after the dialer was opened. Returns the
/// chosen disposition or null if dismissed.
Future<String?> showDispositionSheet(BuildContext context, CallRecord record) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final c = ctx.c;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How did the call go?',
                style: ctx.display(22, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                record.fullName,
                style: ctx.body(13.5, color: c.textSecondary),
              ),
              const SizedBox(height: 14),
              for (final d in kDispositions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, d),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: Text(d),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Kept on this device for this session. The test server has no endpoint to save it.',
                style: TextStyle(fontSize: 11.5, color: c.textMuted),
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
