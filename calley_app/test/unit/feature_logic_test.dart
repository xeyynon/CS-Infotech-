import 'dart:convert';
import 'dart:io';

import 'package:calley_app/features/progress/progress_stats.dart';
import 'package:calley_app/features/reminders/reminders.dart';
import 'package:calley_app/features/support/log_report.dart';
import 'package:calley_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

CallRecord rec(
  String first, {
  String status = 'pending',
  String? phone = '9000000001',
  String? rescheduledAt,
}) => CallRecord.fromJson({
  'FirstName': first,
  'LastName': 'X',
  'Phone': phone,
  'status': status,
  'rescheduledAt': rescheduledAt,
});

ListDetails details(List<CallRecord> calls) =>
    ListDetails(pending: 0, called: 0, rescheduled: 0, calls: calls);

void main() {
  group('computeProgress', () {
    test('an untouched list is Rookie, nothing earned', () {
      final s = computeProgress(
        details([rec('A'), rec('B'), rec('C'), rec('D')]),
        (_) => null,
      );
      expect(s.total, 4);
      expect(s.reached, 0);
      expect(s.open, 4);
      expect(s.level.name, 'Rookie');
      expect(s.nextLevel!.name, 'Dialer');
      expect(s.toNextLevel, 1); // 25% of 4
      expect(s.earnedBadges, 0);
    });

    test('server-called and rescheduled contacts count as reached', () {
      final s = computeProgress(
        details([
          rec('A', status: 'called'),
          rec('B', rescheduledAt: '2026-01-01 10:00:00'),
          rec('C'),
          rec('D'),
        ]),
        (_) => null,
      );
      expect(s.reached, 2);
      expect(s.level.name, 'Closer');
      expect(s.badges.firstWhere((b) => b.id == 'half').earned, isTrue);
    });

    test('an outcome logged here counts a pending contact as reached', () {
      final a = rec('A');
      final s = computeProgress(
        details([a, rec('B')]),
        (r) => r.firstName == 'A' ? 'Neutral' : null,
      );
      expect(s.logged, 1);
      expect(s.reached, 1);
      expect(s.byOutcome, {'Neutral': 1});
      expect(s.badges.firstWhere((b) => b.id == 'first').earned, isTrue);
    });

    test('a contact without a number is not "left to call"', () {
      final s = computeProgress(
        details([rec('A', status: 'called'), rec('B', phone: null)]),
        (_) => null,
      );
      expect(s.open, 0);
      expect(s.badges.firstWhere((b) => b.id == 'sweep').earned, isTrue);
    });

    test('everyone reached is Champion with nothing to go', () {
      final s = computeProgress(
        details([rec('A', status: 'called'), rec('B', status: 'called')]),
        (_) => null,
      );
      expect(s.level.name, 'Champion');
      expect(s.nextLevel, isNull);
      expect(s.toNextLevel, 0);
      expect(s.levelFraction, 1);
    });

    test('positive vibes needs three good outcomes', () {
      final calls = List.generate(4, (i) => rec('N$i'));
      final s = computeProgress(
        details(calls),
        (r) => ['N0', 'N1'].contains(r.firstName)
            ? 'Very positive'
            : r.firstName == 'N2'
            ? 'Satisfied'
            : null,
      );
      expect(s.badges.firstWhere((b) => b.id == 'positive').earned, isTrue);
    });

    test('an empty list does not divide by zero', () {
      final s = computeProgress(details(const []), (_) => null);
      expect(s.fraction, 0);
      expect(s.levelFraction, 0);
      expect(s.earnedBadges, 0);
    });

    test('the bundled sample list', () {
      final text = File('assets/mock/list_details.json').readAsStringSync();
      final d = ListDetails.fromJson(jsonDecode(text) as Map<String, dynamic>);
      final s = computeProgress(d, (_) => null);
      expect(s.total, 50);
      expect(s.reached, 23); // 23 called, the 11 scheduled are among them
      expect(s.open, 27);
      expect(s.level.name, 'Dialer'); // 46%: past 25%, short of 50%
      expect(s.nextLevel!.name, 'Closer');
      expect(s.toNextLevel, 2); // reach 25 of 50 for Closer
    });
  });

  group('buildReminders', () {
    final now = DateTime(2026, 11, 4, 10, 30);

    test('buckets and orders overdue, today, upcoming', () {
      final r = buildReminders([
        rec('Later', rescheduledAt: '2026-11-09 09:00:00'),
        rec('Today', rescheduledAt: '2026-11-04 16:00:00'),
        rec('Old', rescheduledAt: '2026-10-01 09:00:00'),
        rec('Older', rescheduledAt: '2026-09-01 09:00:00'),
        rec('NoDate'),
      ], now);
      expect(r.map((e) => e.record.firstName), [
        'Older',
        'Old',
        'Today',
        'Later',
      ]);
      expect(r.map((e) => e.bucket), [
        ReminderBucket.overdue,
        ReminderBucket.overdue,
        ReminderBucket.today,
        ReminderBucket.upcoming,
      ]);
    });

    test('earlier today still counts as today, not overdue', () {
      final r = buildReminders([
        rec('Morning', rescheduledAt: '2026-11-04 08:00:00'),
      ], now);
      expect(r.single.bucket, ReminderBucket.today);
    });

    test('handled records drop out', () {
      final r = buildReminders(
        [rec('A', rescheduledAt: '2026-11-04 16:00:00')],
        now,
        isHandled: (_) => true,
      );
      expect(r, isEmpty);
    });

    test('dueCount ignores upcoming', () {
      final r = buildReminders([
        rec('A', rescheduledAt: '2026-10-01 09:00:00'),
        rec('B', rescheduledAt: '2026-11-04 23:00:00'),
        rec('C', rescheduledAt: '2026-12-01 09:00:00'),
      ], now);
      expect(dueCount(r), 2);
    });

    test('the bundled sample has 11 reminders, all overdue in 2026', () {
      final text = File('assets/mock/list_details.json').readAsStringSync();
      final d = ListDetails.fromJson(jsonDecode(text) as Map<String, dynamic>);
      final r = buildReminders(d.calls, now);
      expect(r.length, 11);
      expect(r.every((e) => e.bucket == ReminderBucket.overdue), isTrue);
    });
  });

  group('buildLogReport', () {
    String report({Map<String, int> outcomes = const {}, String? listId}) =>
        buildLogReport(
          appVersion: '1.0.0',
          platform: 'android',
          now: DateTime(2026, 11, 4, 9, 5),
          dataSource: 'sample data',
          accountEmail: 'demo@getcalley.com',
          listName: 'Test List',
          listId: listId,
          total: 50,
          pending: 27,
          done: 12,
          scheduled: 11,
          outcomes: outcomes,
        );

    test('lists the facts a support person needs', () {
      final t = report(
        listId: 'abc123',
        outcomes: {'Neutral': 2, 'Negative': 1},
      );
      expect(t, contains('Time: 2026-11-04 09:05'));
      expect(t, contains('App version: 1.0.0'));
      expect(t, contains('Data source: sample data'));
      expect(t, contains('Account: demo@getcalley.com'));
      expect(t, contains('Test List (abc123)'));
      expect(t, contains('Contacts: 50 (pending 27, done 12, scheduled 11)'));
      expect(t, contains('Outcomes logged on this phone: 3'));
      expect(t, contains('  Neutral: 2'));
    });

    test('says so when no list is selected', () {
      expect(report(), contains('Calling list: none selected'));
      expect(report(), isNot(contains('Contacts:')));
    });

    test('contains no contact names or numbers from the sample list', () {
      final text = File('assets/mock/list_details.json').readAsStringSync();
      final d = ListDetails.fromJson(jsonDecode(text) as Map<String, dynamic>);
      final t = report(listId: 'abc123', outcomes: {'Neutral': 50});
      for (final r in d.calls.take(10)) {
        expect(t, isNot(contains(r.phone!)));
        expect(t, isNot(contains(r.firstName)));
      }
    });
  });
}
