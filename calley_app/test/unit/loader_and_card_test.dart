import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../snapshots/snapshot_harness.dart';

void main() {
  setUpAll(loadSnapshotFonts);
  tutorialTests();

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

void tutorialTests() {
  testWidgets(
    'Play here shows the player inside the card, Hide video undoes it',
    (tester) async {
      final opened = <Uri>[];
      await pumpApp(
        tester,
        location: '/getting-started',
        prefs: signedInPrefs(onboarded: false),
        launcher: okLauncher(onLaunch: opened.add),
      );
      expect(find.text('Video player'), findsNothing);
      await tester.tap(find.text('Play here'));
      await settle(tester);
      expect(find.text('Video player'), findsOneWidget);
      expect(opened, isEmpty, reason: 'playing here must not leave the app');
      expect(find.text('Start Calling Now'), findsOneWidget);

      await tester.tap(find.text('Hide video'));
      await settle(tester);
      expect(find.text('Video player'), findsNothing);
    },
  );

  testWidgets('tapping the poster also plays here', (tester) async {
    await pumpApp(
      tester,
      location: '/getting-started',
      prefs: signedInPrefs(onboarded: false),
    );
    await tester.tap(find.text('2 Minute Challenge'));
    await settle(tester);
    expect(find.text('Video player'), findsOneWidget);
  });

  testWidgets('Open in YouTube hands the video to the platform', (
    tester,
  ) async {
    final opened = <Uri>[];
    await pumpApp(
      tester,
      location: '/getting-started',
      prefs: signedInPrefs(onboarded: false),
      launcher: okLauncher(onLaunch: opened.add),
    );
    await tester.tap(find.text('Open in YouTube'));
    await settle(tester);
    expect(
      opened.single.toString(),
      'https://www.youtube.com/watch?v=hzwSizmvMD0',
    );
    expect(find.text('Video player'), findsNothing);
  });

  testWidgets('the upload note keeps the Figma wording and opens the panel', (
    tester,
  ) async {
    final opened = <Uri>[];
    await pumpApp(
      tester,
      location: '/getting-started',
      prefs: signedInPrefs(onboarded: false),
      launcher: okLauncher(onLaunch: opened.add),
    );
    expect(find.text('BEFORE YOU START'), findsOneWidget);
    expect(find.textContaining('uploaded the list to call'), findsOneWidget);
    await tester.tap(find.text('Open the Calley web panel'));
    await settle(tester);
    expect(opened.single.host, 'app.getcalley.com');
  });
}
