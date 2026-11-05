// Renders every screen (light and dark) to snapshots/ and, in doing so,
// checks that each one builds without throwing.
//
//   flutter test test/snapshots --update-goldens
import 'package:calley_app/core/network/api_client.dart';
import 'package:calley_app/core/providers.dart';
import 'package:calley_app/core/network/calley_api.dart';
import 'package:calley_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot_harness.dart';

/// A server that is down: every call fails like the real host did on
/// 2026-11-04 (TLS reaches it; the API answers 404).
class _DeadApi implements CalleyApi {
  const _DeadApi();
  Never _fail() => throw const ApiException(
    'Not found on the server.',
    statusCode: 404,
    kind: ApiErrorKind.notFound,
  );
  @override
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async => _fail();
  @override
  Future<User> login({required String email, required String password}) async =>
      _fail();
  @override
  Future<String?> sendOtp({required String email}) async => _fail();
  @override
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async => _fail();
  @override
  Future<List<CallingList>> getLists(String userId) async => _fail();
  @override
  Future<ListDetails> getListDetails(String listId) async => _fail();
}

/// Lists exist but no details yet — exercises the "choose a list" card.
class _ListsOnlyApi extends SampleCalleyApi {
  const _ListsOnlyApi()
    : super(latency: Duration.zero, loadText: loadMockFromDisk);
}

void main() {
  setUpAll(loadSnapshotFonts);

  for (final dark in [false, true]) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    final suffix = dark ? ' (dark)' : '';

    testWidgets('01 language$suffix', (tester) async {
      await pumpApp(tester, location: '/language', themeMode: mode);
      await snap(tester, '01-language', dark: dark);
    });

    testWidgets('02 register$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/register',
        themeMode: mode,
        prefs: {'pref.language': 'en'},
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Swati Sharma');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'swati@cstech.in',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9871125588');
      await settle(tester, frames: 2);
      await snap(tester, '02-register', dark: dark);
    });

    testWidgets('03 otp$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/otp',
        themeMode: mode,
        prefs: {'pref.language': 'en'},
      );
      // One real field behind the six boxes (B-03/B-16).
      await tester.enterText(find.byType(TextField).first, '482');
      await settle(tester, frames: 2);
      await snap(tester, '03-otp', dark: dark);
    });

    testWidgets('04 login$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/login',
        themeMode: mode,
        prefs: {'pref.language': 'en'},
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'swati@cstech.in',
      );
      await settle(tester, frames: 2);
      await snap(tester, '04-login', dark: dark);
    });

    testWidgets('05 getting started$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/getting-started',
        themeMode: mode,
        prefs: signedInPrefs(onboarded: false),
      );
      await snap(tester, '05-getting-started', dark: dark);
    });

    testWidgets('06 dashboard, lists available, none chosen$suffix', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(),
        api: const _ListsOnlyApi(),
      );
      await snap(tester, '06-dashboard-choose-list', dark: dark);
    });

    testWidgets('06b dashboard, no lists on the account$suffix', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(),
        api: const _EmptyAccountApi(),
      );
      await snap(tester, '06b-dashboard-empty', dark: dark);
    });

    testWidgets('07 calling lists sheet$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(),
      );
      await tester.tap(find.text('Choose a calling list'));
      await settle(tester, frames: 4);
      await snap(tester, '07-calling-lists-sheet', dark: dark);
    });

    testWidgets('07b settings$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/settings',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await snap(tester, '07b-settings', dark: dark);
    });

    testWidgets('08 dashboard with active list$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await settle(tester); // let the donut finish sweeping
      await snap(tester, '08-dashboard-active', dark: dark);
    });

    testWidgets('09 drawer$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await settle(tester, frames: 4);
      await snap(tester, '09-drawer', dark: dark);
    });

    testWidgets('10 calling queue$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/queue',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await snap(tester, '10-calling-queue', dark: dark);
    });

    testWidgets('10b calling queue, record expanded$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/queue',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await tester.tap(find.textContaining('Sherri').first);
      await settle(tester, frames: 3);
      await snap(tester, '10b-calling-queue-expanded', dark: dark);
    });

    testWidgets('10c disposition sheet$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/queue',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await tester.tap(find.byIcon(Icons.call_rounded).first);
      await settle(tester, frames: 4);
      await snap(tester, '10c-disposition-sheet', dark: dark);
    });

    testWidgets('11 server down$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
        api: const _DeadApi(),
      );
      await snap(tester, '11-server-unreachable', dark: dark);
    });

    testWidgets('13 progress, nothing logged yet$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/progress',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await snap(tester, '13-progress', dark: dark);
    });

    testWidgets('13b progress, part-way through$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/progress',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
        overrides: [
          dispositionsProvider.overrideWith(
            () => SeededDispositions(
              seedOutcomes([
                'Very positive',
                'Satisfied',
                'Satisfied',
                'Neutral',
                'Neutral',
                'Negative',
                'Needs follow-up',
              ]),
            ),
          ),
        ],
      );
      await snap(tester, '13b-progress-active', dark: dark);
    });

    testWidgets('14 reminders$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/reminders',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await snap(tester, '14-reminders', dark: dark);
    });

    testWidgets('14b reminders, nothing scheduled$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/reminders',
        themeMode: mode,
        prefs: signedInPrefs(), // no list chosen
      );
      await snap(tester, '14b-reminders-no-list', dark: dark);
    });

    testWidgets('15 send logs sheet$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
        overrides: [
          dispositionsProvider.overrideWith(
            () => SeededDispositions(
              seedOutcomes(['Satisfied', 'Neutral', 'Neutral']),
            ),
          ),
        ],
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await settle(tester, frames: 4);
      await tester.tap(find.text('Send Logs'));
      await settle(tester, frames: 4);
      await snap(tester, '15-send-logs', dark: dark);
    });

    testWidgets('16 cancel subscription sheet$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await settle(tester, frames: 4);
      await tester.tap(find.text('Cancel Subscription'));
      await settle(tester, frames: 4);
      await snap(tester, '16-cancel-subscription', dark: dark);
    });

    testWidgets('17 dashboard waiting for the list$suffix', (tester) async {
      stillMotion(tester);
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
        api: const HangingApi(),
      );
      await snap(tester, '17-dashboard-loading', dark: dark);
    });

    testWidgets('17b queue waiting for the list$suffix', (tester) async {
      stillMotion(tester);
      await pumpApp(
        tester,
        location: '/queue',
        themeMode: mode,
        prefs: signedInPrefs(withList: true),
        api: const HangingApi(),
      );
      await snap(tester, '17b-queue-loading', dark: dark);
    });

    testWidgets('12 sample data banner$suffix', (tester) async {
      await pumpApp(
        tester,
        location: '/dashboard',
        themeMode: mode,
        prefs: {...signedInPrefs(withList: true), 'pref.dataSource': 'sample'},
      );
      await settle(tester);
      await snap(tester, '12-sample-data-mode', dark: dark);
    });
  }
}

class _EmptyAccountApi extends SampleCalleyApi {
  const _EmptyAccountApi()
    : super(latency: Duration.zero, loadText: loadMockFromDisk);
  @override
  Future<List<CallingList>> getLists(String userId) async => const [];
}
