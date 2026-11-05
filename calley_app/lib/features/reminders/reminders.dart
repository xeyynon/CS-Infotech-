import '../../models/models.dart';

/// Scheduled calls ("call me back on Tuesday") grouped by how urgent they
/// are. Built from the records' own `rescheduledAt`; nothing is made up.

enum ReminderBucket { overdue, today, upcoming }

class Reminder {
  const Reminder(this.record, this.at, this.bucket);

  final CallRecord record;
  final DateTime at;
  final ReminderBucket bucket;
}

extension ReminderBucketX on ReminderBucket {
  String get label => switch (this) {
    ReminderBucket.overdue => 'Overdue',
    ReminderBucket.today => 'Today',
    ReminderBucket.upcoming => 'Upcoming',
  };
}

/// Records with a reschedule time that still need calling, sorted overdue
/// first (oldest first), then today, then upcoming, each by time.
///
/// [isHandled] says whether an outcome was already logged for the record on
/// this phone; such records are done and drop out.
List<Reminder> buildReminders(
  List<CallRecord> calls,
  DateTime now, {
  bool Function(CallRecord)? isHandled,
}) {
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfTomorrow = startOfToday.add(const Duration(days: 1));
  final out = <Reminder>[];
  for (final r in calls) {
    final at = r.rescheduledAt;
    if (at == null) continue;
    if (isHandled?.call(r) ?? false) continue;
    final bucket = at.isBefore(startOfToday)
        ? ReminderBucket.overdue
        : at.isBefore(startOfTomorrow)
        ? ReminderBucket.today
        : ReminderBucket.upcoming;
    out.add(Reminder(r, at, bucket));
  }
  out.sort((a, b) {
    final byBucket = a.bucket.index.compareTo(b.bucket.index);
    return byBucket != 0 ? byBucket : a.at.compareTo(b.at);
  });
  return out;
}

/// What the bell badge counts: calls that should be made today or earlier.
int dueCount(List<Reminder> reminders) =>
    reminders.where((r) => r.bucket != ReminderBucket.upcoming).length;
