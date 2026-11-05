// Harness for rendering real screens at phone resolution in `flutter test`.
//
// Why here and not on a device: the machine has no emulator. Flutter's test
// renderer draws the exact same widget tree with Skia, so these PNGs are a
// faithful record of the UI; only platform text shaping differs.
import 'dart:io';

import 'package:calley_app/app/router.dart';
import 'package:calley_app/app/theme.dart';
import 'package:calley_app/core/network/calley_api.dart';
import 'package:calley_app/core/providers.dart';
import 'package:calley_app/core/storage/session_store.dart';
import 'package:calley_app/core/utils/launchers.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads `assets/mock/[name].json` from disk. Synchronous I/O completes under
/// the test binding's fake clock; rootBundle's real I/O would not.
Future<String> loadMockFromDisk(String name) async =>
    File('assets/mock/$name.json').readAsStringSync();

/// The sample API as the tests use it: no latency, disk-backed.
const CalleyApi sampleApi = SampleCalleyApi(
  latency: Duration.zero,
  loadText: loadMockFromDisk,
);

/// Phone surface: 390×844 logical at 3x (an iPhone 14 / Pixel-class panel).
const Size kPhoneLogical = Size(390, 844);
const double kDpr = 3;

/// Family name the theme is told to use after [loadSnapshotFonts].
String snapshotFontFamily = 'Roboto';

/// Loads real fonts so text and icons render instead of test-font boxes.
/// Inter (static weights, downloaded into test/fonts) when present, else
/// Roboto from the Flutter SDK cache. Material icons always come from the SDK.
Future<void> loadSnapshotFonts() async {
  // <Family>-<weight>.ttf → one FontLoader per family. The app's own fonts
  // come from assets/fonts; the Indic script fallbacks (test only, a device
  // has them from the system) from test/fonts.
  final byFamily = <String, List<File>>{};
  for (final dir in [Directory('assets/fonts'), Directory('test/fonts')]) {
    if (!dir.existsSync()) continue;
    for (final f in dir.listSync().whereType<File>()) {
      final name = f.uri.pathSegments.last;
      if (!name.toLowerCase().endsWith('.ttf')) continue;
      final family = name.split('-').first;
      byFamily.putIfAbsent(family, () => []).add(f);
    }
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final cache = flutterRoot == null
      ? null
      : Directory('$flutterRoot/bin/cache/artifacts/material_fonts');

  Future<void> loadFamily(String family, Iterable<File> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(await f.readAsBytes())));
    }
    await loader.load();
  }

  for (final e in byFamily.entries) {
    await loadFamily(e.key, e.value);
  }
  if (byFamily.containsKey('Inter')) {
    snapshotFontFamily = 'Inter';
  } else if (cache != null && cache.existsSync()) {
    await loadFamily(
      'Roboto',
      cache.listSync().whereType<File>().where(
        (f) =>
            RegExp(r'roboto-(regular|medium|bold)\.ttf$')
                .hasMatch(f.path.toLowerCase()),
      ),
    );
    snapshotFontFamily = 'Roboto';
  }
  if (cache != null) {
    final icons = File('${cache.path}/MaterialIcons-Regular.otf');
    if (icons.existsSync()) await loadFamily('MaterialIcons', [icons]);
  }
}

/// Mounts the app at [location] with the given stored preferences and API.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  required String location,
  Map<String, Object> prefs = const {},
  CalleyApi api = sampleApi,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = kPhoneLogical * kDpr;
  tester.view.devicePixelRatio = kDpr;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final store = SessionStore(await SharedPreferences.getInstance());
  final router = GoRouter(initialLocation: location, routes: appRoutes());

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        apiProvider.overrideWithValue(api),
        // A fixed morning, so the greeting in the snapshots never changes.
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 10, 30)),
        // No platform in a widget test: pretend every launch succeeded.
        launcherProvider.overrideWithValue(
          Launcher((uri, {mode = LaunchMode.platformDefault}) async => true),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: themeMode,
        routerConfig: router,
      ),
    ),
  );
  await settle(tester);
  return router;
}

/// Some widgets animate forever (skeleton shimmer), so pumpAndSettle would
/// never return. Advance time in fixed steps instead.
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await decodeImages(tester);
}

/// Asset images decode on real I/O, which the fake test clock never waits
/// for; without this the Calley logo would be blank in every snapshot.
Future<void> decodeImages(WidgetTester tester) async {
  final images = find.byType(Image).evaluate().toList();
  if (images.isEmpty) return;
  await tester.runAsync(() async {
    for (final e in images) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

Future<void> snap(WidgetTester tester, String name, {bool dark = false}) async {
  final dir = dark ? 'dark' : 'light';
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('../../snapshots/$dir/$name.png'),
  );
}

/// Stored state for "signed in as Swati".
Map<String, Object> signedInPrefs({
  bool withList = false,
  bool onboarded = true,
  String? theme,
}) => {
  'pref.language': 'en',
  'session.user': '{"_id":"68626f9497757cb741f449b0","username":"Swati Sharma","email":"swati@cstech.in","phone":"+91 9871125588","subscription":"Calley Personal"}',
  'session.onboarded': onboarded,
  if (withList) 'pref.selectedListId': '68626fb697757cb741f449b9',
  if (withList) 'pref.selectedListName': 'Test List',
  'pref.themeMode': ?theme,
};
