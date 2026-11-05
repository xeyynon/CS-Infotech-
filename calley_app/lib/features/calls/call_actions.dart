import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/utils/launchers.dart';
import '../../models/models.dart';
import 'disposition_sheet.dart';

/// The two things an agent does with a contact, in one place so the queue,
/// the reminders and the dashboard's phone tab behave identically.

/// Asks how the call went and stores the answer, with Undo. Also used to
/// change an outcome that was logged earlier.
Future<void> logOutcome(
  BuildContext context,
  WidgetRef ref,
  String listId,
  CallRecord r,
) async {
  final notifier = ref.read(dispositionsProvider.notifier);
  final previous = notifier.get(listId, r.key);
  final result = await showDispositionSheet(context, r, current: previous);
  if (result == null || !context.mounted) return;
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

/// Opens the dialer and, only if it opened, asks for the outcome (B-27).
Future<void> callAndLog(
  BuildContext context,
  WidgetRef ref,
  String listId,
  CallRecord r,
) async {
  if (r.phone == null) return;
  final placed = await ref.read(launcherProvider).dial(context, r.phone!);
  if (!placed || !context.mounted) return;
  await logOutcome(context, ref, listId, r);
}
