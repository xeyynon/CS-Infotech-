import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../snapshots/snapshot_harness.dart';

void main() {
  setUpAll(loadSnapshotFonts);

  testWidgets('the dashboard waits behind the branded loader', (tester) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
      api: const HangingApi(),
    );
    expect(find.text('Loading your list…'), findsOneWidget);
    expect(find.byType(LottieBuilder), findsOneWidget);
    // Not the old grey skeleton blocks, and not an error.
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('the queue and progress screens use it too', (tester) async {
    await pumpApp(
      tester,
      location: '/queue',
      prefs: signedInPrefs(withList: true),
      api: const HangingApi(),
    );
    expect(find.text('Loading contacts…'), findsOneWidget);

    final router = await pumpApp(
      tester,
      location: '/progress',
      prefs: signedInPrefs(withList: true),
      api: const HangingApi(),
    );
    expect(router.state.uri.path, '/progress');
    expect(find.text('Working out your progress…'), findsOneWidget);
  });

  testWidgets('with animations removed the loader holds still', (tester) async {
    stillMotion(tester);
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(withList: true),
      api: const HangingApi(),
    );
    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.animate, isFalse);
  });

  testWidgets('the greeting card shows the plan as a chip', (tester) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: signedInPrefs(), // no list chosen: the greeting card shows
    );
    expect(find.text('Swati'), findsOneWidget);
    expect(find.text('Calley Personal'), findsOneWidget);
    expect(find.text('Sample data'), findsNothing);
  });

  testWidgets('the greeting card also says when data is sample data', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/dashboard',
      prefs: {...signedInPrefs(), 'pref.dataSource': 'sample'},
    );
    // One in the banner, one as the card's chip.
    expect(find.text('Sample data'), findsOneWidget);
    expect(find.textContaining('Sample data'), findsWidgets);
  });
}
