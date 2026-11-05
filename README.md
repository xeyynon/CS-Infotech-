<div align="center">

# Calley: Automatic Call Dialer

**A Flutter build of the Calley mobile app: onboarding, dashboard, calling queue and the drawer features.**
Made for the Flutter Mobile App Developer machine test at C S Tech Infosolutions Pvt. Ltd.

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Android-verified_on_device-3DDC84?logo=android&logoColor=white)
![Tests](https://img.shields.io/badge/tests-81_unit_+_52_snapshot-1F5EFF)
![Build](https://img.shields.io/badge/build-1010-0E1B3D)

<img src="docs/screens/device/02-dashboard.png" width="170" alt="Dashboard on a Galaxy S23 Ultra">
<img src="docs/screens/device/04-calling-queue.png" width="170" alt="Calling queue">
<img src="docs/screens/device/05-log-outcome.png" width="170" alt="Log the outcome of a call">
<img src="docs/screens/device/07-your-progress.png" width="170" alt="Your progress">

<sub>Real screenshots from a Samsung Galaxy S23 Ultra running the release build.</sub>

</div>

---

## Contents

1. [At a glance](#at-a-glance)
2. [Try it in two minutes](#try-it-in-two-minutes)
3. [What it does](#what-it-does)
4. [User workflows](#user-workflows)
5. [Screens](#screens)
6. [Why the app uses demo data](#why-the-app-uses-demo-data)
7. [Architecture](#architecture)
8. [Design system](#design-system)
9. [Security and privacy](#security-and-privacy)
10. [Quality](#quality)
11. [Engineering workflow](#engineering-workflow)
12. [Build history](#build-history)
13. [Known limits and what is next](#known-limits-and-what-is-next)
14. [Repository map](#repository-map)

---

## At a glance

| | |
|---|---|
| **What** | The Calley auto-dialer's first screens from the supplied Figma file, wired to the Calley REST API, plus the calling queue that "Start Calling Now" leads to and five working drawer features |
| **Screens** | 10 from the brief, plus Your progress, Reminders, Send logs, Cancel subscription, the start-up screen and the loading states |
| **Stack** | Flutter 3.47 · Dart 3.13 · Riverpod 3 · go_router 18 · dio 5 · Lottie · bundled fonts. No code generation |
| **Platform** | Android (min SDK 24). Release build installed and used on a Samsung Galaxy S23 Ultra, Android 17. The iOS project is generated but has not been built (no Mac) |
| **Version** | `1.0.0 (build 1010)`, shown in the app's drawer and in Send logs, and tied to the git tag `build-1010` |
| **API status** | The supplied mock API returns 404 on every endpoint, so the app falls back to clearly labelled **sample data**. See [why](#why-the-app-uses-demo-data) |
| **Demo login** | `demo@getcalley.com` / `Demo@1234` (one tap on the login screen) |
| **Demo video** | [`docs/demo/calley_demo.mp4`](docs/demo/calley_demo.mp4): 1 min 8 s, recorded on the phone, from the login screen, with the idle waits cut |
| **Quality** | `flutter analyze` clean · 81 unit and behaviour tests · 52 snapshot tests · 47 audited bugs fixed |

## Try it in two minutes

**On a phone.** Install a release APK (the arm64 build is about 21 MB; it fits nearly every phone from the last several years), open the app and tap **Sign in with the demo account** on the login screen. A prebuilt APK for each build is attached on the repository's [Releases](../../releases) page.

**From source.**

```bash
cd calley_app
flutter pub get
flutter run                          # a device or emulator
flutter build apk --release --split-per-abi   # one APK per CPU type
flutter run --dart-define=USE_MOCK=true       # force sample data (no server at all)
flutter run --dart-define=API_BASE_URL=https://new-host/api   # point at another server
```

Needs Flutter 3.35 or newer (built with 3.47).

**The 90-second tour:**
sign in with the demo account → *Getting Started* (play the tutorial inside the app) → **Start Calling Now** → pick *Test List* → the dashboard ring and ledger → the 🔔 bell for scheduled calls → **Start Calling Now** → **Call next** (your phone's own dialer opens with the number filled in) → come back and log how the call went → try **Undo** → open the drawer: *Gamification*, *Send Logs*, *Cancel Subscription*.

## What it does

| Area | Behaviour |
|---|---|
| **Onboarding** | Nine-language picker → register (name, email, password, +91 mobile, terms) → six-box OTP that pastes, auto-advances and resends after 30 s → login. Session survives restarts |
| **Getting Started** | Greeting card, the "upload your list on the web panel" note, and the *2 Minute Challenge* tutorial card: **Play here** plays Calley's setup video inside the app, **Open in YouTube** hands it to YouTube |
| **Dashboard** | Active list, a ring chart that sweeps in once, and one Pending / Done / Scheduled strip with each status's share of the list. Tap a figure to open the queue already filtered |
| **Calling lists** | Bottom sheet with Refresh; choice remembered; also in Settings |
| **Calling queue** | Search, status filters (default *To call*), expandable contacts, and a thumb-reach **Call next · Name** button. One tap opens the dialer, then asks *How did the call go?* |
| **Log outcome** | Five outcomes, each with an icon and colour beside its word. A snackbar offers **Undo** for six seconds. A bar shows *n of 50 logged* |
| **Your progress** | A level from the share of the list reached, a bar to the next level, outcomes logged by type, five badges. Counted from real records only |
| **Reminders** | Scheduled calls grouped *Overdue / Today / Upcoming*, with a count badge on the bell. One tap dials; a logged call leaves the list |
| **Send logs** | Shows the exact report before anything is sent: version, platform, data source, list counts, outcome totals. **No names or phone numbers.** Then *Email to support* or *Copy* |
| **Share app, Cancel subscription** | The system share sheet; an honest explanation that plans are billed outside the app, with *Keep my plan* first |
| **Appearance** | Light and dark themes; reduced motion respected; 48 dp touch targets |
| **Start-up** | The Calley loading animation instead of a blank white screen, an adaptive app icon, native launch screens in light and dark |

## User workflows

### 1. From install to the first call

```mermaid
flowchart LR
    A[Open app] --> B[Choose language]
    B --> C[Register]
    C --> D[OTP verification]
    D --> E[Login]
    C -->|already registered| E
    E -->|sign in or demo account| F[Getting Started]
    F -->|Start Calling Now| G[Dashboard]
    G -->|no list yet| H[Pick a calling list]
    H --> I[Dashboard with ring and ledger]
    I -->|Start Calling Now| J[Calling queue]
    J -->|Call next| K[Phone dialer opens]
    K --> L[Log how the call went]
    L --> J
```

### 2. The calling loop (the part an agent repeats fifty times)

```mermaid
sequenceDiagram
    actor Agent
    participant Queue as Calling queue
    participant Dialer as Phone dialer
    participant Store as Outcomes on this phone
    Agent->>Queue: Tap Call next
    Queue->>Dialer: Open with the number filled in
    Note over Queue,Dialer: Dial pad only - the app never places a call itself
    Dialer-->>Queue: Agent comes back
    Queue->>Agent: How did the call go - five outcomes
    Agent->>Store: Pick one
    Store-->>Queue: Contact leaves To call and progress updates
    Queue->>Agent: Undo is offered for 6 seconds
    Agent->>Store: Undo if they changed their mind
```

The queue asks about the call only if the dialer actually opened, so a failed launch never produces a question about a call that did not happen.

### 3. Honest data: what a screen does when the server fails

```mermaid
flowchart TD
    S[A screen needs data] --> R{Data source}
    R -->|Server| Q[Call the real API]
    R -->|Sample| M[Read the bundled examples]
    Q -->|success| OK[Show the data]
    Q -->|failure| E[Say why in plain words]
    E --> E1[Retry]
    E --> E2[Use sample data]
    E1 --> Q
    E2 --> M
    M --> B[Show the data with a banner on every screen]
    B --> T[Try server switches back]
    T --> Q
    D[Demo login] --> M
```

Nothing is faked silently: a failure is shown as a failure, and sample data is always labelled.

## Screens

Every screen, in light and dark, lives in [`calley_app/snapshots/`](calley_app/snapshots/). They are rendered by `flutter test` from the real widget tree at 390 × 844 @3x with the app's own fonts, so they are the app, not mock-ups.

**Onboarding**

<p>
  <img src="calley_app/snapshots/light/01-language.png" width="150" alt="Language">
  <img src="calley_app/snapshots/light/02-register.png" width="150" alt="Register">
  <img src="calley_app/snapshots/light/03-otp.png" width="150" alt="OTP">
  <img src="calley_app/snapshots/light/04-login.png" width="150" alt="Login">
  <img src="calley_app/snapshots/light/05-getting-started.png" width="150" alt="Getting started">
  <img src="calley_app/snapshots/light/05b-getting-started-video.png" width="150" alt="Tutorial playing in the app">
</p>

**Dashboard and lists**

<p>
  <img src="calley_app/snapshots/light/06b-dashboard-empty.png" width="150" alt="Dashboard before a list is chosen">
  <img src="calley_app/snapshots/light/07-calling-lists-sheet.png" width="150" alt="Calling lists">
  <img src="calley_app/snapshots/light/08-dashboard-active.png" width="150" alt="Dashboard with an active list">
  <img src="calley_app/snapshots/light/07b-settings.png" width="150" alt="Settings">
  <img src="calley_app/snapshots/light/09-drawer.png" width="150" alt="Drawer">
</p>

**Calling**

<p>
  <img src="calley_app/snapshots/light/10-calling-queue.png" width="150" alt="Calling queue">
  <img src="calley_app/snapshots/light/10b-calling-queue-expanded.png" width="150" alt="A contact expanded">
  <img src="calley_app/snapshots/light/10c-disposition-sheet.png" width="150" alt="Log the outcome">
  <img src="calley_app/snapshots/light/14-reminders.png" width="150" alt="Reminders">
  <img src="calley_app/snapshots/light/13b-progress-active.png" width="150" alt="Your progress">
</p>

**Drawer features and honest states**

<p>
  <img src="calley_app/snapshots/light/15-send-logs.png" width="150" alt="Send logs">
  <img src="calley_app/snapshots/light/16-cancel-subscription.png" width="150" alt="Cancel subscription">
  <img src="calley_app/snapshots/light/11-server-unreachable.png" width="150" alt="Server unreachable">
  <img src="calley_app/snapshots/light/12-sample-data-mode.png" width="150" alt="Sample data banner">
  <img src="calley_app/snapshots/light/17-dashboard-loading.png" width="150" alt="Loading animation">
  <img src="calley_app/snapshots/light/18-startup-splash.png" width="150" alt="Start-up">
</p>

**Dark theme**

<p>
  <img src="calley_app/snapshots/dark/05-getting-started.png" width="150" alt="Getting started, dark">
  <img src="calley_app/snapshots/dark/08-dashboard-active.png" width="150" alt="Dashboard, dark">
  <img src="calley_app/snapshots/dark/10-calling-queue.png" width="150" alt="Queue, dark">
  <img src="calley_app/snapshots/dark/10c-disposition-sheet.png" width="150" alt="Outcome sheet, dark">
  <img src="calley_app/snapshots/dark/14-reminders.png" width="150" alt="Reminders, dark">
  <img src="calley_app/snapshots/dark/09-drawer.png" width="150" alt="Drawer, dark">
</p>

**On the phone** (Samsung Galaxy S23 Ultra, dark mode, release build 1009)

<p>
  <img src="docs/screens/device/01-getting-started.png" width="120" alt="Getting started">
  <img src="docs/screens/device/02-dashboard.png" width="120" alt="Dashboard">
  <img src="docs/screens/device/03-reminders.png" width="120" alt="Reminders">
  <img src="docs/screens/device/04-calling-queue.png" width="120" alt="Queue">
  <img src="docs/screens/device/05-log-outcome.png" width="120" alt="Log outcome">
  <img src="docs/screens/device/06-undo-and-progress.png" width="120" alt="Undo">
  <img src="docs/screens/device/07-your-progress.png" width="120" alt="Your progress">
  <img src="docs/screens/device/08-drawer.png" width="120" alt="Drawer">
</p>

## Why the app uses demo data

**The API supplied for this test is not reachable, so the app ships with a demo mode.** Everything else is built against the real API.

- The test points to the Postman collection [Mock API V2](https://documenter.getpostman.com/view/38199901/2sB34Zpiy9), at `https://mock-api.calleyacd.com/api`. A copy is kept in [`MD/assets/postman-mock-api-v2.json`](MD/assets/postman-mock-api-v2.json).
- When checked on 2026-11-04 and again on 2026-11-05, **every documented endpoint returned HTTP 404** with an empty body: register, login, send-otp, verify-otp, list and list details.
- The server's TLS certificate is issued to the hosting provider's name (`cool-meninsky.74-208-123-142.plesk.page`), not to `mock-api.calleyacd.com`, so browsers and Postman refuse the connection.
- The root URL shows the hosting provider's default page. Together this suggests the domain is still parked on the hosting server but the API app is not deployed there.
- You can check this yourself: <https://mock-api.calleyacd.com/api/list?userId=68626f9497757cb741f449b0>.

**What the app does about it:**

1. **It calls the real API first.** Requests, bodies and response parsing follow the Postman collection exactly, including login's `{"user": {...}}` wrapper and `GET /list` returning a single object. TLS is not switched off: the app trusts only that one server's certificate.
2. **When a call fails, it says why**, with **Retry** and **Use sample data**. It never shows a fake success.
3. **Sample data is the collection's own examples.** The "Test List" and its 50 contacts in `calley_app/assets/mock/` are copied from the Postman example responses, so every list screen shows what the real API would return. The signed-in user is Swati, the person in the Figma screens.
4. **A banner stays on every screen while sample data is on.** It cannot be mistaken for live data, and **Try server** switches back.
5. **The demo login** goes straight to sample mode, so the whole flow can be tested in one tap.

**If the API comes back or moves:** nothing needs rebuilding for the same host. A new address is one build setting (`--dart-define=API_BASE_URL=...`). If the new server presents a different certificate, its SHA-256 fingerprint is added in [`api_client.dart`](calley_app/lib/core/network/api_client.dart).

The API's own numbers overlap (the 11 rescheduled calls are also among the 23 called, so its totals add to 61 for 50 contacts). The app shows three groups that do not overlap and add up to the list, and says so under the ledger.

## Architecture

```mermaid
flowchart TB
    UI[Screens - auth, onboarding, dashboard, calls, drawer features]
    W[Shared widgets and the design system]
    P[Riverpod providers - session, selected list, data source, outcomes, reminders, clock, launcher]
    API[CalleyApi interface]
    R[RemoteCalleyApi - dio, 10 second timeouts, pinned certificate]
    S[SampleCalleyApi - bundled JSON from the Postman examples]
    ST[Saved preferences - language, theme, session, selected list]
    L[Launcher - dialer, browser, share, mail]
    UI --> P
    UI --> W
    P --> API
    API --> R
    API --> S
    P --> ST
    P --> L
```

| Layer | Notes |
|---|---|
| **Screens** | One folder per feature. Forms have a busy guard, `mounted` checks after every `await`, and plain-language errors by cause |
| **State** | Riverpod 3. Choices the user made (language, theme, selected list, data source, session) live above every screen. Outcomes are keyed `listId/recordKey` and cleared on logout. Reminders and progress are *derived* by pure functions, never stored |
| **API** | `CalleyApi` has the six endpoints. A screen never knows whether it is talking to the server or to sample data. Errors become an `ApiException` with a kind (network, timeout, server, not found, unauthorized, bad request) so each is worded correctly |
| **Testability** | The clock, the launcher (dialer, share, mail, browser), the in-app video player and the data source are providers, so tests swap in stand-ins and record what was asked of the phone |
| **Models** | `fromJson` only. Nothing is invented: a missing field shows "-" or is left out |

**Stack**

| Choice | Why |
|---|---|
| `flutter_riverpod` 3 | Compile-safe, testable; `AsyncValue` matches "fetch, then loading / error / data" |
| `go_router` 18 | One `redirect` decides signed-in vs signed-out; `appRoutes()` is exported so tests can mount any screen with or without the redirect |
| `dio` 5 | Typed errors, timeouts and a certificate callback |
| Bundled fonts (Inter, Bricolage Grotesque, IBM Plex Mono, OFL) | Offline and identical in tests; `google_fonts` failed to compile on this Flutter and fetches at runtime |
| `lottie`, `youtube_player_iframe`, `share_plus`, `url_launcher` | The supplied loading animation, the in-app tutorial, the share sheet, the dialer and browser |
| No code generation | Fewer moving parts to break |

Decisions and the reasons for them are numbered in [`MD/decisions.md`](MD/decisions.md) (DEC-001 to DEC-018).

## Design system

Colours are tokens in a `ThemeExtension` with **the same names in light and dark**, so a widget never branches on brightness.

| Token | Light | Dark |
|---|---|---|
| `bg` (warm paper / near-black) | `#F6F5F1` | `#0E0F12` |
| `primary` | `#1F5EFF` | `#6B93FF` |
| `navy` (hero cards, same strong contrast in both) | `#0E1B3D` | `#182650` |
| status: pending / done / scheduled | `#F0B429` / `#1F5EFF` / `#8B5CF6` | `#F5C04A` / `#6B93FF` / `#A78BFA` |

- **Type with a job each:** Bricolage Grotesque for titles and the one hero figure per screen, IBM Plex Mono (tabular) for every number, Inter for body text.
- **One primary action per screen**, a pill with a hard 3 px edge that presses flat, always at the bottom within thumb reach.
- **Status is a dot and a word**, never colour alone. Cards have no borders and no accent stripes; the tone difference is the edge.
- **Centred where there is one focal point** (brand, title, chart, empty states); left-aligned where people scan (forms, lists).
- **HCI choices:** the primary button follows the fields it submits; each figure appears once; every change can be undone or is confirmed first; the queue's next action is the closest control.
- **Accessibility:** 48 dp targets with gaps, real `Semantics` actions (not just labels), keyboard focus rings, live regions for errors, reduced-motion respected, text contrast of at least 4.5:1.

The full design guide, written to be reused on other projects, is [`MD/frontendcalley.md`](MD/frontendcalley.md).

## Security and privacy

- **TLS is never disabled.** The only certificate the app accepts beyond the system's trust store is the one test host's, pinned by SHA-256 fingerprint and scoped to that host.
- **Send logs contains no personal data.** No contact names, phone numbers or email addresses of contacts. The person sees the exact text before sending.
- **Outcomes stay on the phone** for the session, and are cleared on logout, because the supplied API has no endpoint to write them. The app says so where the outcome is chosen.
- **No secrets in the repository.** Keys and signing files are git-ignored.
- **Dialing needs the person.** The app opens the dial pad with the number filled in; it never requests the call permission or places a call by itself.

## Quality

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| Unit and behaviour tests | **81** passing: models, validators, formatters, API error mapping, the real router with its redirect, progress, reminders, log report, drawer features, the start-up screen, button order, snackbar timing, build-number drift |
| Snapshot tests | **52** passing: 26 screens in light and dark. They double as "every screen builds" tests |
| Bug audit | A multi-agent review of the whole app: **67 claims, each tried by three independent verifiers who were asked to refute it. 47 stood and were fixed; 20 were refuted** and are recorded so they are not raised again ([`MD/bugs.md`](MD/bugs.md), [`MD/bugfixed.md`](MD/bugfixed.md)) |
| **On a real phone** | Release build installed and used on a Samsung Galaxy S23 Ultra (Android 17): sign-in, the in-app tutorial video, the real dialer, logging an outcome, Undo, the drawer features. **It found a bug the tests could not**: the Undo message never timed out and followed the agent onto other screens. Fixed, with a test that fails without the fix |

What has *not* been verified on a device: the WhatsApp help button, and the OTP flow against a real server (the supplied server has no working endpoint).

```bash
cd calley_app
flutter analyze
flutter test test/unit                           # logic and behaviour
flutter test test/snapshots                      # compares every screen with snapshots/
flutter test test/snapshots --update-goldens     # after a deliberate UI change
```

## Engineering workflow

Every change is either a **build** (a person using the app would notice it) or an **InBul** (internal: tests, docs, tooling). The git tag is the source of truth for the number, and the build number is shown in the app, so an installed APK, a release and a tag always agree.

```mermaid
flowchart LR
    C[Change made] --> Q{Would a user notice}
    Q -->|Yes| B[Build N - commit, report in MD builds, changelog entry]
    Q -->|No| I[InBul NN - commit with tests, docs or tooling]
    B --> N[changelog script stamps N into pubspec and build_info]
    N --> T[Tag build-N]
    I --> T2[Tag InBulNN]
    T --> V[Drift test checks pubspec equals build_info equals tag]
    T --> PUSH[Push branch and tags]
    T2 --> PUSH
```

- **Branches:** work happens on feature branches and is merged to `main` through pull requests.
- **Commits** carry only the author's name; titles say what the product now does and never carry the build number.
- **Release builds** use `flutter build apk --release --split-per-abi`; the Android version code is the build number plus the CPU offset.
- **Method:** the loop that produced the UI is *build → render every screen to a PNG in both themes → look at it → name the class of mistake → write the rule down → search the project for the same mistake*. It is described in [`MD/frontendcalley.md`](MD/frontendcalley.md).

## Build history

| Build | What changed |
|---|---|
| 1000 | The Calley app: nine screens, the mock API client, and sample data when the server is down |
| 1001 | Bug fixes and a calmer, centred layout with a faster calling loop |
| 1002 | Demo login, the official Calley logo, and a sign-in that accepts the server's own passwords |
| 1003 | Working Gamification, Reminders, Send Logs, Share App and Cancel Subscription |
| 1004 | The app carries its build number: 1.0.0 (build 1004) |
| 1005 | Greeting card redesigned; loading screens use the Calley animation |
| 1006 | Getting Started separates the upload note from the greeting and plays the tutorial in the app |
| 1007 | Sign-in puts its button before the detour, the dashboard shows each figure once, outcomes have icons |
| 1008 | The app opens on the Calley loading animation and has a bigger icon |
| 1009 | The Undo message no longer stays on screen, and the tutorial shows its real length |
| 1010 | Em dashes are gone from the app's text |

Full detail per build is in [`MD/builds/`](MD/builds/) and the generated [`CHANGELOG.md`](CHANGELOG.md).

## Known limits and what is next

**Limits, stated plainly**

- The supplied server is down, so the app runs on sample data (see above). It will use the real server unchanged if it returns.
- The language picker remembers the choice, but the app text is English.
- *Forgot password* and *Change password* have no server endpoint to call, so they say so.
- Outcomes are kept on the phone for the session; the API has no endpoint to save them.
- The Figma has the typo "Star Calling Now"; the app says "Start Calling Now".
- The tutorial card is titled *2 Minute Challenge* as in the design, but the video it plays is the 5-minute Calley setup guide, and the card says so.
- iOS: the project is set up (URL schemes, launch screen, icons) but has not been built or run.
- The app icon is scaled from a small source image; a high-resolution mark would make it sharper.

**Next**

- Real language switching (English and Hindi first).
- Auto-dial mode.
- An iOS build on a Mac.

## Repository map

```
calley_app/            the Flutter app
  lib/                 app/ (router, theme)  core/ (network, providers, widgets, utils)
                       models/  features/ (auth, onboarding, dashboard, lists, calls, drawer, progress, reminders, support)
  assets/              brand/ (official logo and mark)  loading/ (Lottie)  mock/ (sample data)  fonts/
  test/                unit/ (logic and behaviour)  snapshots/ (harness and screenshot tests)
  snapshots/           light/ and dark/ PNGs of every screen state
docs/                  demo/ (screen recording)  screens/device/ (phone screenshots)
MD/                    research, requirements, decisions, bug register, design guide, version control, build reports
scripts/changelog.mjs  build / InBul bookkeeping
calley_loading_assets/ the supplied loading animation (originals)
CHANGELOG.md           generated from the tags; not edited by hand
```

Where to start in `MD/`: [`README.md`](MD/README.md) is the index. [`video_requirements.md`](MD/video_requirements.md) checks the task video step by step against the app, [`api_reference.md`](MD/api_reference.md) documents the endpoints, [`decisions.md`](MD/decisions.md) explains why, and [`tasks.md`](MD/tasks.md) shows what is done and what is left.

---

<sub>The Calley name, logo and loading animation belong to C S Tech Infosolutions Pvt. Ltd. and are used here for the assessment. Fonts are bundled under the SIL Open Font License. The tutorial video is Calley's own, played from YouTube.</sub>
