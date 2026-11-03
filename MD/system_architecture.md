# system_architecture.md — planned app architecture

Status: **planned**, nothing built yet (2026-11-04). Update as code lands; code wins over this file.

## Layers

```
┌──────────────────────────────────────────────────────┐
│ Presentation   Screens + widgets (Material 3, Figma)  │
│                watch Riverpod providers                │
├──────────────────────────────────────────────────────┤
│ State          AsyncNotifier per feature:              │
│                sessionProvider, authController,        │
│                listsController, listDetailsController, │
│                languageProvider                        │
├──────────────────────────────────────────────────────┤
│ Data           CalleyApi (dio) ──► mock-api.calleyacd  │
│                MockCalleyApi (assets/mock/*.json)      │
│                SessionStore (shared_preferences)       │
├──────────────────────────────────────────────────────┤
│ Models         User, CallingList, ListDetails,         │
│                CallRecord  (plain Dart + fromJson)     │
└──────────────────────────────────────────────────────┘
```

## Folder layout

```
lib/
  main.dart                      – ProviderScope, runApp
  app/
    app.dart                     – MaterialApp.router, theme
    router.dart                  – go_router routes + redirect (session gate)
    theme.dart                   – colours, text styles, component themes
  core/
    network/api_client.dart      – dio instance, interceptors, ApiException
    network/calley_api.dart      – abstract CalleyApi + RemoteCalleyApi + MockCalleyApi
    storage/session_store.dart   – prefs wrapper
    widgets/                     – PrimaryButton, AppTextField, OtpInput, DonutChart, StatCard, CalleyLogo, AppBottomBar
    utils/validators.dart, launchers.dart
  models/
    user.dart, calling_list.dart, list_details.dart, call_record.dart
  features/
    language/   language_screen.dart, language_provider.dart
    auth/       register_screen.dart, otp_screen.dart, login_screen.dart, auth_controller.dart
    onboarding/ getting_started_screen.dart
    dashboard/  dashboard_screen.dart, dashboard_controller.dart, widgets/
    lists/      calling_lists_sheet.dart, lists_controller.dart
    calls/      calling_queue_screen.dart, disposition_dialog.dart
    settings/   settings_screen.dart
    drawer/     app_drawer.dart
assets/
  images/   (logo, illustration, 2-minute-challenge thumbnail)
  mock/     (register.json, login.json, lists.json, list_details.json)
test/
```

## Key components

### Router + session gate
`go_router` with `redirect`: if `session.isLoggedIn` and route is in the auth group → `/dashboard`; if not logged in and route is protected → `/language` (first run) or `/login`.

### CalleyApi
```dart
abstract class CalleyApi {
  Future<Map<String, dynamic>> register({required String username, required String email, required String password});
  Future<User> login({required String email, required String password});
  Future<void> sendOtp({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<List<CallingList>> getLists(String userId);
  Future<ListDetails> getListDetails(String listId);
}
```
`RemoteCalleyApi` is the default; `MockCalleyApi` is selected when `const bool.fromEnvironment('USE_MOCK')` is true. A `MockBanner` widget is shown in that case (rule R-06).

### Donut chart
`CustomPainter` drawing 3 arcs from `(called, pending, rescheduled)`; `AnimationController` sweeps 0→1 over 800 ms; colours: Done blue `#2F6BFF`, Pending yellow `#F5B400`, Schedule purple `#8E6BFF` (sample exact values from Figma).

### Bottom bar
Custom 5-slot bar: home, contacts, **center play (raised, filled blue pill)**, phone, calendar. Only "home" and "play" need to do anything; others can be no-ops with a toast.

## Error handling
`ApiException(statusCode, message)` thrown by the client → controllers expose `AsyncValue.error` → screens render an `ErrorView(retry:)`. Timeouts 10 s. No automatic fallback to mock in remote mode.

## Platform notes
- Android: `INTERNET` permission; `<queries>` for `tel:` and `https` intents (Android 11+) so `canLaunchUrl` works.
- iOS: `LSApplicationQueriesSchemes` for `tel`, `whatsapp`, `youtube`.
