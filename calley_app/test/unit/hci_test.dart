import 'package:flutter_test/flutter_test.dart';

import '../snapshots/snapshot_harness.dart';

void main() {
  setUpAll(loadSnapshotFonts);

  testWidgets('Sign In follows the fields; the Sign Up detour comes after it', (
    tester,
  ) async {
    await pumpApp(tester, location: '/login', prefs: {'pref.language': 'en'});
    final button = tester.getTopLeft(find.text('Sign In').last).dy;
    final detour = tester.getTopLeft(find.text('Sign Up')).dy;
    final lastField = tester.getBottomLeft(find.text('Forgot Password?')).dy;
    expect(button, greaterThan(lastField));
    expect(detour, greaterThan(button));
  });

  testWidgets('Sign Up button comes before the Sign In detour', (tester) async {
    await pumpApp(
      tester,
      location: '/register',
      prefs: {'pref.language': 'en'},
    );
    final button = tester.getTopLeft(find.text('Sign Up').first).dy;
    final detour = tester.getTopLeft(find.text('Sign In')).dy;
    expect(detour, greaterThan(button));
  });

  testWidgets('the dashboard shows each figure once, with its share', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
    );
    // One "Done" (the ledger); the ring's old legend copy is gone.
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('54%'), findsOneWidget); // 27 of 50
    expect(find.text('24%'), findsOneWidget); // 12 of 50
    expect(find.text('22%'), findsOneWidget); // 11 of 50
  });
}
