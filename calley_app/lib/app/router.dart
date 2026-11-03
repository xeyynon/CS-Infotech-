import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/calls/calling_queue_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/language/language_screen.dart';
import '../features/onboarding/getting_started_screen.dart';
import '../features/settings/settings_screen.dart';

abstract final class Routes {
  static const language = '/language';
  static const register = '/register';
  static const otp = '/otp';
  static const login = '/login';
  static const gettingStarted = '/getting-started';
  static const dashboard = '/dashboard';
  static const queue = '/queue';
  static const settings = '/settings';

  static const authGroup = {language, register, otp, login};
}

/// Bumps whenever the session changes so GoRouter re-runs `redirect`.
class _RouterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionProvider, (_, _) => refresh.bump());
  ref.listen(onboardedProvider, (_, _) => refresh.bump());
  ref.onDispose(refresh.dispose);

  final user = ref.read(sessionProvider);
  final language = ref.read(languageProvider);
  final initial = user != null
      ? (ref.read(onboardedProvider) ? Routes.dashboard : Routes.gettingStarted)
      : (language == null ? Routes.language : Routes.login);

  return GoRouter(
    initialLocation: initial,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider) != null;
      final path = state.uri.path;
      final inAuth = Routes.authGroup.contains(path);
      if (loggedIn && inAuth) {
        return ref.read(onboardedProvider)
            ? Routes.dashboard
            : Routes.gettingStarted;
      }
      if (!loggedIn && !inAuth) {
        return ref.read(languageProvider) == null
            ? Routes.language
            : Routes.login;
      }
      return null;
    },
    routes: appRoutes(),
  );
});

/// The route table on its own, so tests can mount any screen under a
/// GoRouter without the session redirect.
List<RouteBase> appRoutes() => [
  GoRoute(path: Routes.language, builder: (_, _) => const LanguageScreen()),
  GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
  GoRoute(path: Routes.otp, builder: (_, _) => const OtpScreen()),
  GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
  GoRoute(
    path: Routes.gettingStarted,
    builder: (_, _) => const GettingStartedScreen(),
  ),
  GoRoute(path: Routes.dashboard, builder: (_, _) => const DashboardScreen()),
  GoRoute(path: Routes.queue, builder: (_, _) => const CallingQueueScreen()),
  GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
];
