import 'dart:async';

import 'package:calley_app/app/app.dart';
import 'package:calley_app/app/bootstrap.dart';
import 'package:calley_app/core/widgets/calley_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../snapshots/snapshot_harness.dart';

void main() {
  setUpAll(loadSnapshotFonts);

  Future<SharedPreferences> prefs() {
    SharedPreferences.setMockInitialValues({'pref.language': 'en'});
    return SharedPreferences.getInstance();
  }

  testWidgets('the loading animation is the first frame, then the app', (
    tester,
  ) async {
    await tester.runAsync(() => AssetLottie(CalleyLoader.asset).load());
    final gate = Completer<SharedPreferences>();
    await tester.pumpWidget(
      Bootstrap(load: () => gate.future, minimumShow: Duration.zero),
    );
    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.byType(CalleyApp), findsNothing);

    gate.complete(await tester.runAsync(prefs));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.byType(CalleyApp), findsOneWidget);
    expect(find.byType(LottieBuilder), findsNothing);
  });

  testWidgets('the splash stays for its minimum time even if prefs are quick', (
    tester,
  ) async {
    await tester.runAsync(() => AssetLottie(CalleyLoader.asset).load());
    // Read once on real I/O, so the test's own load returns at once and the
    // only thing left to wait for is the minimum time.
    final ready = (await tester.runAsync(prefs))!;
    await tester.pumpWidget(
      Bootstrap(
        load: () => Future.value(ready),
        minimumShow: const Duration(seconds: 5),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CalleyApp), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(CalleyApp), findsOneWidget);
  });

  testWidgets('unreadable preferences say so instead of spinning forever', (
    tester,
  ) async {
    await tester.runAsync(() => AssetLottie(CalleyLoader.asset).load());
    await tester.pumpWidget(
      Bootstrap(load: () => Future<SharedPreferences>.error(StateError('x'))),
    );
    await tester.pump();
    expect(find.textContaining('could not start'), findsOneWidget);
    expect(find.byType(LottieBuilder), findsNothing);
  });
}
