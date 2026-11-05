import 'package:calley_app/app/router.dart';
import 'package:calley_app/app/theme.dart';
import 'package:calley_app/core/providers.dart';
import 'package:calley_app/core/storage/session_store.dart';
import 'package:calley_app/features/language/language_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../snapshots/snapshot_harness.dart';

/// These mount the REAL router, with its session redirect, which the
/// snapshot tests deliberately bypass.
Future<GoRouter> pumpRealRouter(
  WidgetTester tester,
  Map<String, Object> prefs,
) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = SessionStore(await SharedPreferences.getInstance());
  final container = ProviderContainer(
    overrides: [
      sessionStoreProvider.overrideWithValue(store),
      apiProvider.overrideWithValue(sampleApi),
    ],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  final router = container.read(routerProvider);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: buildTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );
  await settle(tester);
  return router;
}

void main() {
  testWidgets('B-01: a signed-in user can open App language from Settings', (
    tester,
  ) async {
    final router = await pumpRealRouter(tester, signedInPrefs());
    expect(router.state.uri.path, Routes.dashboard);

    router.push(Routes.settings);
    await settle(tester);
    await tester.tap(find.text('App Language'));
    await settle(tester);

    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('a signed-in user is still kept out of register/login', (
    tester,
  ) async {
    final router = await pumpRealRouter(tester, signedInPrefs());
    router.go(Routes.login);
    await settle(tester);
    expect(router.state.uri.path, Routes.dashboard);
  });

  testWidgets('the demo account signs in and switches to sample data', (
    tester,
  ) async {
    final router = await pumpRealRouter(tester, {'pref.language': 'en'});
    await tester.ensureVisible(find.text('Sign in with the demo account'));
    await tester.tap(find.text('Sign in with the demo account'));
    await settle(tester);
    expect(router.state.uri.path, Routes.gettingStarted);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(container.read(dataSourceProvider), DataSource.sample);
    expect(container.read(sessionProvider)?.email, 'demo@getcalley.com');
  });

  testWidgets('the demo email with a wrong password is refused', (
    tester,
  ) async {
    final router = await pumpRealRouter(tester, {'pref.language': 'en'});
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@getcalley.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'nope123');
    await tester.tap(find.text('Sign In'));
    await settle(tester);
    expect(router.state.uri.path, Routes.login);
    expect(
      find.textContaining('Wrong password for the demo account'),
      findsOneWidget,
    );
  });

  testWidgets('a signed-out user with a language lands on Login', (
    tester,
  ) async {
    final router = await pumpRealRouter(tester, {'pref.language': 'en'});
    expect(router.state.uri.path, Routes.login);
    router.go(Routes.settings);
    await settle(tester);
    expect(router.state.uri.path, Routes.login);
  });
}
