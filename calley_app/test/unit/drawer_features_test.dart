import 'package:calley_app/core/providers.dart';
import 'package:calley_app/features/calls/disposition_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../snapshots/snapshot_harness.dart';

Future<void> openDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await settle(tester, frames: 4);
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await settle(tester, frames: 4);
}

void main() {
  setUpAll(loadSnapshotFonts);

  testWidgets('Gamification opens the progress screen', (tester) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
    );
    await openDrawerItem(tester, 'Gamification');
    expect(find.text('Your progress'), findsOneWidget);
    expect(find.text('Dialer'), findsOneWidget); // 23 of 50 reached
    expect(find.textContaining('BADGES'), findsOneWidget);
  });

  testWidgets('progress survives an outcome for a contact no longer listed', (
    tester,
  ) async {
    // A logged outcome whose record has since left the list must not break
    // the screen (it used to trip a debug assertion).
    await pumpApp(
      tester,
      location: '/progress',
      prefs: signedInPrefs(withList: true),
      overrides: [
        dispositionsProvider.overrideWith(
          () => SeededDispositions({
            '68626fb697757cb741f449b9/gone|gone|Nobody|Left': 'Neutral',
          }),
        ),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Your progress'), findsOneWidget);
  });

  testWidgets('Share App opens the share sheet with the download link', (
    tester,
  ) async {
    String? shared;
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
      launcher: okLauncher(onShare: (text, _) => shared = text),
    );
    await openDrawerItem(tester, 'Share App');
    expect(shared, contains('https://www.getcalley.com/download'));
  });

  testWidgets('Send Logs emails the shown report to support', (tester) async {
    Uri? opened;
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
      launcher: okLauncher(onLaunch: (u) => opened = u),
    );
    await openDrawerItem(tester, 'Send Logs');
    expect(find.textContaining('Calley app log'), findsOneWidget);
    expect(find.textContaining('no contact names'), findsOneWidget);
    await tester.tap(find.text('Email to support'));
    await settle(tester, frames: 3);
    expect(opened?.scheme, 'mailto');
    expect(opened?.path, 'support@getcalley.com');
    final body = opened!.queryParameters['body']!;
    expect(body, contains('Calling list: Test List'));
    // Nothing from the contact list leaks into the mail.
    expect(body, isNot(contains('Danielle')));
    expect(body, isNot(contains('1000000000')));
  });

  testWidgets('Cancel Subscription offers Keep first and real next steps', (
    tester,
  ) async {
    Uri? opened;
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
      launcher: okLauncher(onLaunch: (u) => opened = u),
    );
    await openDrawerItem(tester, 'Cancel Subscription');
    expect(find.text('Cancel your subscription?'), findsOneWidget);
    expect(find.textContaining('Calley Personal'), findsOneWidget);
    await tester.tap(find.text('Manage on Google Play'));
    await settle(tester, frames: 3);
    expect(opened?.host, 'play.google.com');
    await tester.tap(find.text('Keep my plan'));
    await settle(tester, frames: 4);
    expect(find.text('Cancel your subscription?'), findsNothing);
  });

  testWidgets('the bell shows how many calls are due and opens Reminders', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
    );
    // All 11 scheduled calls in the sample are overdue on the test clock.
    expect(find.byTooltip('Reminders, 11 due'), findsOneWidget);
    expect(find.text('11'), findsWidgets);
    await tester.tap(find.byTooltip('Reminders, 11 due'));
    await settle(tester, frames: 4);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.textContaining('OVERDUE · 11'), findsOneWidget);
  });

  testWidgets('logging an outcome removes a call from Reminders', (
    tester,
  ) async {
    final router = await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
    );
    router.push('/reminders');
    await settle(tester);
    expect(find.textContaining('OVERDUE · 11'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.call_rounded).first);
    await settle(tester, frames: 4);
    expect(find.text('How did the call go?'), findsOneWidget);
    await tester.tap(find.text(kDispositions.first));
    await settle(tester, frames: 4);

    expect(find.textContaining('OVERDUE · 10'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(container.read(dispositionsProvider), hasLength(1));
  });
}
