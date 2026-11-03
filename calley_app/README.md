# Calley — automatic call dialer (Flutter)

A Flutter build of the Calley mobile app's first ten screens, made for the C S Tech Infosolutions Flutter machine test. Nine screens follow the Figma file; the tenth, the calling queue, is what "Start Calling Now" leads to.

<p>
  <img src="snapshots/light/01-language.png" width="160" alt="Language">
  <img src="snapshots/light/02-register.png" width="160" alt="Register">
  <img src="snapshots/light/05-getting-started.png" width="160" alt="Getting started">
  <img src="snapshots/light/08-dashboard-active.png" width="160" alt="Dashboard">
  <img src="snapshots/light/10-calling-queue.png" width="160" alt="Calling queue">
</p>
<p>
  <img src="snapshots/dark/08-dashboard-active.png" width="160" alt="Dashboard, dark">
  <img src="snapshots/dark/10-calling-queue.png" width="160" alt="Queue, dark">
  <img src="snapshots/light/11-server-unreachable.png" width="160" alt="Server unreachable">
  <img src="snapshots/light/10c-disposition-sheet.png" width="160" alt="Disposition">
  <img src="snapshots/light/09-drawer.png" width="160" alt="Drawer">
</p>

Every screen, light and dark, is in [`snapshots/`](snapshots/). They are rendered by `flutter test test/snapshots` at 390×844 @3x with the app's bundled fonts, so they are the real widget tree, not mock-ups.

## Run

```
flutter pub get
flutter run                                   # a device or emulator
flutter build apk --debug                     # build/app/outputs/flutter-apk/app-debug.apk
flutter run --dart-define=USE_MOCK=true       # force sample data (no server at all)
```

Requires Flutter 3.35+ (built with 3.47 / Dart 3.13). Android `minSdk` is Flutter's default (21).

## What it does

| Screen | Figma | Behaviour |
|---|---|---|
| Choose language | 01 | Nine languages with native greetings; remembered; reachable again from Settings |
| Register | 02 | Name, email, password, +91 mobile, T&C; validates before sending; `POST /auth/register` then `POST /auth/send-otp` |
| OTP | 03 | Six boxes that paste, auto-advance and backspace; resend with a 30 s timer; `POST /auth/verify-otp` |
| Login | 04 | `POST /auth/login`; session persisted; wrong password clears the field |
| Getting started | 05 | Greeting, the web-panel note, the tutorial card (opens YouTube), WhatsApp, Start Calling Now |
| Dashboard, no list | 06 | "Load number to call" or "Choose a calling list"; `GET /list?userId=` |
| Calling lists | 07 | Bottom sheet and Settings section with Refresh; selection persisted |
| Dashboard, active list | 08 | `GET /list/{id}`: ring chart, Pending/Done/Scheduled ledger, counts as the server sends them |
| Drawer | 09 | All items; Logout clears the session and returns to Login |
| Calling queue | — | Search and status filters, one tap opens the dialer, then a disposition sheet (kept for the session: the API has no write endpoint) |

Pull to refresh on every data screen. Light and dark themes (Settings → Appearance).

## When the server is down

The mock host was checked on 2026-11-04: it presents a certificate for its hosting provider's name (`*.plesk.page`) and every `/api/*` path answers an empty 404. So:

- TLS is **not** disabled. The connection is accepted only for that one host and only if the certificate's SHA-256 fingerprint matches the one on record (`lib/core/network/api_client.dart`). Any other certificate is rejected as usual. When the host renews its certificate the pin must be updated.
- A failed request shows what happened, with **Retry** and **Use sample data**. Sample data is the JSON in `assets/mock/` (the same shapes as the API) and a banner stays on screen while it is active. Nothing returns a fake success.

## Architecture

```
lib/
  app/        router (go_router, session gate), theme (tokens, three bundled fonts)
  core/       network (dio client + pinned cert, CalleyApi: remote and sample)
              storage (shared_preferences), providers (Riverpod), widgets, utils
  models/     User, CallingList, ListDetails, CallRecord — fromJson only, nothing invented
  features/   language, auth, onboarding, dashboard, lists, calls, settings, drawer
assets/       fonts (Inter, Bricolage Grotesque, IBM Plex Mono — OFL), mock JSON
test/         snapshot harness and tests
```

- **State:** Riverpod 3. Preferences the user set (language, theme, selected list, data source, session) live above every screen and survive navigation; transient state stays local.
- **Networking:** `dio`, 10 s timeouts, plain-language errors, no automatic retry (the Retry button is explicit).
- **Design:** warm paper background; Bricolage Grotesque for headings and the one hero number per screen, IBM Plex Mono (tabular) for every figure, Inter for body. Status is always a word with a dot, never colour alone. 48 px hit targets. Reduced motion respected.

## Checks

```
flutter analyze                                 # 0 issues
flutter test                                    # 32 snapshot tests: every screen builds, light and dark
flutter test test/snapshots --update-goldens    # regenerate snapshots/ after a deliberate UI change
```

## Known limits

- Counts in the sample `list_details.json` (27 + 23 + 11 = 61) do not match its 50 records; the app shows both as sent and says so under the ledger.
- The Figma has "Star Calling Now"; the app says "Start Calling Now".
- The 2-minute-challenge thumbnail and the "load number" illustration are drawn, not the Figma images (which could not be exported from a view-only file).
- No iOS build was made (no Mac); the iOS project is generated and `url_launcher` schemes are not yet declared in `Info.plist`.
