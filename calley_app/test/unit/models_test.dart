import 'dart:convert';
import 'dart:io';

import 'package:calley_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    const raw = {
      '_id': '68626f9497757cb741f449b0',
      'username': 'Swati Sharma',
      'email': 'swati@cstech.in',
      'phone': '+91 9871125588',
      'subscription': 'Calley Personal',
    };

    test('parses a top-level user', () {
      final u = User.fromJson(raw);
      expect(u.id, '68626f9497757cb741f449b0');
      expect(u.username, 'Swati Sharma');
      expect(u.firstName, 'Swati');
      expect(u.initial, 'S');
      expect(u.subscription, 'Calley Personal');
    });

    test('parses a user wrapped under "user" as a login endpoint may send', () {
      final u = User.fromJson({'user': raw, 'token': 'x'});
      expect(u.email, 'swati@cstech.in');
      expect(u.phone, '+91 9871125588');
    });

    test('accepts alternative id and name keys', () {
      final u = User.fromJson({'id': '1', 'name': 'Asha', 'email': 'a@b.co'});
      expect(u.id, '1');
      expect(u.username, 'Asha');
    });

    test(
      'survives a toJson then fromJson round trip (the session store path)',
      () {
        final u = User.fromJson(raw);
        final again = User.fromJson(
          jsonDecode(jsonEncode(u.toJson())) as Map<String, dynamic>,
        );
        expect(again.id, u.id);
        expect(again.username, u.username);
        expect(again.email, u.email);
        expect(again.phone, u.phone);
        expect(again.subscription, u.subscription);
      },
    );

    test('initial of an empty name is a question mark, not a crash', () {
      expect(const User(id: '1', username: '  ', email: 'x@y.z').initial, '?');
    });
  });

  group('CallStatus.parse', () {
    test('maps the server words to the three statuses', () {
      expect(CallStatus.parse('called'), CallStatus.called);
      expect(CallStatus.parse('Done'), CallStatus.called);
      expect(CallStatus.parse('rescheduled'), CallStatus.rescheduled);
      expect(CallStatus.parse('scheduled'), CallStatus.rescheduled);
      expect(CallStatus.parse('pending'), CallStatus.pending);
    });

    test('unknown or missing is pending, never a throw', () {
      expect(CallStatus.parse(null), CallStatus.pending);
      expect(CallStatus.parse('weird'), CallStatus.pending);
    });

    test('labels match the dashboard words', () {
      expect(CallStatus.called.label, 'Done');
      expect(CallStatus.rescheduled.label, 'Scheduled');
      expect(CallStatus.pending.label, 'Pending');
    });
  });

  group('CallRecord', () {
    final raw = <String, dynamic>{
      'FirstName': 'Danielle',
      'LastName': 'Johnson',
      'Title': 'Mrs.',
      'Phone': 1000000000,
      'Other Phone 1': 1000000003,
      'Other Phone 2': 1000000006,
      'Email': 'donaldgarcia@mcclain.com',
      'Company': 'Henderson, Ramirez and Lewis',
      'Age': 73,
      'calledAt': '2025-06-22 19:41:31',
      'rescheduledAt': null,
      'createdAt': '2025-05-03 10:34:31',
      'status': 'called',
      'duration': 17,
      'feedback': 'Needs follow-up',
    };

    test('keeps the phone as text and collects the other phones in order', () {
      final r = CallRecord.fromJson(raw);
      expect(r.phone, '1000000000');
      expect(r.otherPhones, ['1000000003', '1000000006']);
    });

    test('reads the server date format and leaves nulls null', () {
      final r = CallRecord.fromJson(raw);
      expect(r.calledAt, DateTime(2025, 6, 22, 19, 41, 31));
      expect(r.rescheduledAt, isNull);
      expect(r.duration, 17);
    });

    test('names and keys', () {
      final r = CallRecord.fromJson(raw);
      expect(r.fullName, 'Mrs. Danielle Johnson');
      expect(r.displayName, 'Danielle Johnson');
      expect(r.key, contains('1000000000'));
      expect(r.key, isNot(CallRecord.fromJson({...raw, 'Phone': 1}).key));
    });

    test('a called record with a rescheduledAt counts as scheduled (B-09)', () {
      expect(CallRecord.fromJson(raw).isRescheduled, isFalse);
      expect(
        CallRecord.fromJson({...raw, 'rescheduledAt': '2025-06-23 19:41:31'})
            .isRescheduled,
        isTrue,
      );
    });

    test('a record with nothing but a status still parses', () {
      final r = CallRecord.fromJson({'status': 'pending'});
      expect(r.firstName, '');
      expect(r.phone, isNull);
      expect(r.status, CallStatus.pending);
    });
  });

  group('ListDetails', () {
    test('parses the bundled sample exactly as the app will', () {
      final text = File('assets/mock/list_details.json').readAsStringSync();
      final d = ListDetails.fromJson(jsonDecode(text) as Map<String, dynamic>);
      expect(d.pending, 27);
      expect(d.called, 23);
      expect(d.rescheduled, 11);
      expect(d.calls.length, 50);
      // Disjoint groups that add up to the records (rescheduled ⊂ called).
      expect(d.scheduledCount, 11);
      expect(d.doneCount, 12);
      expect(d.pendingCount, 27);
      expect(d.total, 50);
      expect(d.calls.every((r) => r.phone != null), isTrue);
    });

    test(
      'with no records the summary counts are used, without double counting',
      () {
        final d = ListDetails.fromJson(const {
          'pending': 27,
          'called': 23,
          'rescheduled': 11,
        });
        expect(d.pendingCount, 27);
        expect(d.doneCount, 12);
        expect(d.scheduledCount, 11);
        expect(d.total, 50);
      },
    );

    test('missing counts are zero and a missing calls array is empty', () {
      final d = ListDetails.fromJson(const {});
      expect(d.total, 0);
      expect(d.calls, isEmpty);
    });
  });

  group('CallingList', () {
    test('parses the bundled lists file', () {
      final text = File('assets/mock/lists.json').readAsStringSync();
      final j = jsonDecode(text) as Map<String, dynamic>;
      final lists = (j['lists'] as List)
          .map((e) => CallingList.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(lists.single.name, 'Test List');
      expect(lists.single.id, '68626fb697757cb741f449b9');
    });
  });
}
