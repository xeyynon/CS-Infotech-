# How the Calley frontend was designed and built

A reusable design-and-build guide, written from a real project: a Flutter clone of the Calley auto-dialer (ten screens plus five drawer features) built from a three-sentence brief, a Figma file, a silent video and a mock API that turned out to be dead. Every rule below is tied to something that happened: a commit, a bug id (`B-nn` in [bugs.md](bugs.md)), a decision (`DEC-nnn` in [decisions.md](decisions.md)), a failed attempt (`TF-nn` in [tried_and_failed.md](tried_and_failed.md)) or a build tag (`build-N`).

**Who this is for.** A person or an AI session starting a *different* mobile or web frontend who wants the same quality bar without repeating the same mistakes. Part A is stack-agnostic (principles, process, honesty, HCI). Part B is Flutter-specific (architecture, components, tests, traps). Part C is the checklist, the build order and the file map.

**How the quality happened.** Almost none of it came from a good first draft. It came from a loop: build → render it and *look* at it → get a user's reaction → name the class of mistake → write the rule down → search the whole project for the same mistake. Four numbered builds (1000–1004) and seven internal checkpoints in four days. The loop is the lesson; the components are the evidence.

**Last brought up to date:** 2026-11-05, `build-1004` plus the greeting-card and loader work on branch `feature/drawer-and-reminders`.

---

## 0. Start a new session with this

Paste this into the first message of the next project, then attach this file and your brief:

> Read `frontendcalley.md` fully. Treat Part A as rules and Part C as the checklist. For this project: (1) turn the brief into a written spec and compare it with any video/Figma frame by frame before coding; (2) set up design tokens for light and dark first; (3) build the state layer and an injectable API with a *sample-data* implementation before any screen; (4) render every screen to PNG in light and dark and review them by eye before calling anything done; (5) keep `bugs.md`, `bugfixed.md`, `decisions.md`, `tried_and_failed.md`; (6) run an adversarial audit (finders, then refuters) before release; (7) number builds from the git tag and show the number in the app. Ask me for the brief, the design file and the API docs first.

---

# Part A — Principles and process (any stack)

## A1. The 22 principles, in one page

1. **The design file is the spec; the API is the truth.** Copy and order come from the design; every number comes from the data. Figma said 28/22/09, the API said 27/23/11: the app shows the API (R-02).
2. **Turn a thin brief into a written spec first.** The Notion page was three sentences. The real requirements were in a silent video, the Figma frames and a Postman collection found through two other candidates' repositories (§A2).
3. **One home per fact.** If the plan appears on the greeting card, it is not also a line of text under it.
4. **Honest states.** Every network screen has loading, empty, error and "sample data" states, and each says something true. Never return a fake success (R-06).
5. **Say what is not built, in a sentence, where the user is looking.** "The test server stores no outcomes." Not a silent no-op, not a lie.
6. **Errors are worded by cause**, not by a generic "something went wrong": a 404 says the data is not on the server; a wrong password does not show a cloud icon.
7. **Status is a word with a dot, never a colour alone.**
8. **Numbers are monospaced and tabular**, so columns do not twitch and figures read as readings.
9. **One hero per screen.** One display heading or one big figure; everything else is smaller. One solid primary button.
10. **Centre the single focal block, left-align the things people scan.** Brand, title, one sentence, a chart: centred. Forms, lists, ledgers: left (§A5).
11. **No decoration that carries no information.** No accent stripes, no gradients, no card borders where a tone difference does the job. This was the fix for "it looks AI-generated" (§B4.1).
12. **Tokenise every colour; two themes with the same token names.** Components never change between themes. Never write a hex outside the theme file.
13. **Measure contrast.** Pale brand blue in dark mode with dark text failed visibly; the fix was a navy card that is the same in both themes.
14. **48 dp targets, with a gap between neighbours.** Forgot-password touched the show-password toggle (B-17).
15. **A control must work for a screen reader and a keyboard**, not only a finger. Three separate traps made our main button un-activatable by TalkBack (§B7).
16. **Make the next action the closest one.** The calling queue has a thumb-zone "Call next · Sherri"; the loop is dial → outcome → next, with no scrolling.
17. **Every change is undoable or confirmable.** Outcome logged: snackbar with Undo. Logout: says how many outcomes will be cleared.
18. **State the user chose lives above the screens; everything else stays local** (B3.3).
19. **Never disable security to make a demo work.** The mock host served a certificate for the wrong name; we pinned that one certificate for that one host instead of switching verification off (DEC-010).
20. **If the supplied backend is dead, ship a labelled demo mode, not a pretence.** A banner on every screen, a demo login, and a README section that says why (§A6).
21. **Look at the pixels.** Render every screen to a PNG in both themes and read them. Several bugs passed every test and were visible in one glance (bottom bar eating the screen, §B8).
22. **When two different fixes leave the same symptom, question the diagnosis.** Check the render tree before guessing (TF-08).

## A2. From a vague brief to a spec

What we did, in order, and what each step found:

| Step | How | What it found |
|---|---|---|
| Read the brief page | Headless browser, `innerText` plus every iframe `src` | 3 sentences; a YouTube embed; a Figma link; "on-site role" |
| Find the video's ID, search it | Web search on the *video ID*, not the company | Two earlier candidates' public repos → the API base URL, the six endpoints, the deliverable list |
| Read the design | Anonymous Figma load, device-scale screenshot | 9 frames, the demo user ("Swati"), copy including typos ("Star Calling Now") |
| Test the API | A small Dart probe with a pinned certificate | Host up, wrong certificate name, **every `/api/*` path 404** |
| Find the official API docs | The user supplied the Postman link | The collection confirmed the shapes (login returns `{user}`; `GET /list` returns one object) |
| **Watch the video** | `yt-dlp` + a bundled `ffmpeg` in a throwaway venv → one frame per second as contact sheets | It is a click-through of the Figma prototype: the real list of screen-to-screen taps = the functional requirements (`video_requirements.md`) |

Rules: write the requirements down as a table (`step → where in the app → met?`); search for unique strings from the brief, not only names; install helper tools in a throwaway virtual environment, never system-wide.

## A3. Process: the loop

```
brief → spec (A2) → tokens + state layer + sample API → screens → render PNGs → review by eye
   ↑                                                                                  ↓
   └── write the rule down ← name the class of bug ← user reaction ← fix ← audit ←────┘
```

- **Registers, not memory.** `bugs.md` (what is wrong, verified), `bugfixed.md` (what happened to each, how it was checked), `decisions.md` (why, `DEC-nnn`), `tried_and_failed.md` / `tried_and_implemented.md` (so nobody repeats or forgets), `pain.md` (risks), `tasks.md`.
- **Audit before release (how we found 47 bugs).** 8 bug-finding "lenses" (state, routing, network, layout, forms, models, accessibility, tooling) and 4 HCI lenses read the code and the screenshots in parallel, then 3 fresh-eyes finders were told what was already found. 67 distinct claims. **Each claim went to three independent verifiers instructed to refute it** (framework semantics, reproduction, impact); it stood only if two could not. **47 stood, 20 were refuted** and are listed in `bugs.md` so they are not raised again. Findings must cite a file, a line and quoted evidence; "consider adding…" is not a finding.
- **Verify the suspicious first.** Before regenerating snapshots, run them *against the old images* and list which changed; only the expected ones may. A refactor that changed nothing visible should change no PNG.
- **Version control that explains itself.** Two kinds of change: a **build** (a user would notice: tag `build-N`, a report, a changelog entry) and an **InBul** (docs, tests, tooling: tag `InBulNN`). Tags are the truth, titles never carry the number, builds are batched. Details: [version_control.md](version_control.md).
- **The build number lives in the app.** One number in three places that must agree: the git tag, the `+N` in `pubspec.yaml` (Android versionCode / iOS build) and a generated `build_info.dart` shown in the drawer and in the support log. A unit test fails if they disagree. (Flutter's `--split-per-abi` adds 1000/2000/4000 to the code; the in-app label stays plain.)
- **Commit only when asked; push only when asked.** Commit messages from a file, never an inline here-string on Windows.

## A4. Honest data (the part most worth copying)

| Situation | What the screen does |
|---|---|
| Waiting | Skeleton for a small block; the branded loader for a whole section (§B4.5) |
| Failed | A card in plain words by cause, **Retry**, and (only for server-class failures) **Use sample data** |
| Nothing there | An empty state that says what would fill it ("Calls you move to a later time will show up here") |
| Sample data active | A banner on **every** data screen, **Try server** to switch back, and a chip on the greeting card |
| Not possible (no endpoint) | One honest sentence: "Your plan is billed outside this app, so it cannot be cancelled here", then the real next steps (Google Play, support) |
| Derived values | Computed only from real records and the phone's own session; labelled so ("kept on this phone for this session") |

Anti-patterns we removed from the two earlier candidates' submissions: a global `badCertificateCallback => true`; every request silently returning `{message: 'User registered'}` on failure; a fallback that makes a dead server look healthy.

Server numbers can lie to each other. The sample list reported `pending 27, called 23, rescheduled 11` for **50** records: the 11 rescheduled are *also* among the 23 called. The app computes three disjoint groups from the records (27 + 12 + 11 = 50) and says so in one line (DEC-017). If two figures on one screen disagree, find out why before drawing either.

## A5. HCI rules we applied (and where)

| Principle | What we did |
|---|---|
| **Fitts's law** (big, near targets) | 48 dp minimum everywhere (B-17); the main action in the thumb zone: pill button at the bottom of every screen, **Call next** in the queue; ≥8 dp between adjacent targets |
| **Hick's law** (fewer choices) | One primary button per screen; the five outcomes in one column; filters default to "To call" so finished contacts leave the view |
| **Gestalt** (proximity, similarity, alignment) | Related facts in one card; status dots the same colour everywhere (Done is blue in ring, legend, ledger, chips; green is only the call button, B-39) |
| **Visual hierarchy** | Display font for the title, one hero figure, mono for readings, muted text for hints; 3 text sizes per card |
| **Recognition over recall** | The demo credentials are printed on the login screen with a one-tap button; the exact Send Logs report is shown before sending |
| **User control and freedom** | Undo on every logged outcome; "Wrong details?" on OTP; Keep my plan is the first, default button on Cancel; back always works |
| **Error prevention** | Validate before sending; busy state refuses a second tap; the dialer opens first and the outcome sheet only follows if it opened (B-27) |
| **Feedback / visibility of status** | "0 of 50 logged" with a bar; a count badge on the bell; skeletons and the loader during waits; a banner when data is sample |
| **Consistency** | One `dial → log outcome` path shared by the queue, reminders and the phone tab; the same pill button, sheet and card everywhere |
| **Aesthetic and minimal** | No borders, no stripes, no gradients, no shadows except the 3 px "pressed edge" under the primary button |

**The centring rule** (the product owner asked for content in the centre "for the betterment of the user"). One axis per screen. **Centre:** the brand mark, the title, the single instruction sentence, a chart with its legend underneath, empty states, sheet headings, the tutorial poster, the loader. **Left-align:** form fields (people scan labels down a left edge), list rows, the stat ledger, tables, long text. **Cap the column** at 440 dp so a tablet or landscape phone keeps a reading width in the middle instead of stretching. Do not centre a block whose lines have different lengths and are meant to be compared.

## A6. When the backend you were given does not work

1. Prove it with evidence you can show (status codes, certificate subject, a link the reviewer can open), on two different days.
2. Build to the *documented* contract exactly (request bodies, response shapes), so the app works unchanged if the server returns.
3. Call the real API first. On failure say why and **offer** sample data; never switch silently.
4. Sample data = the documentation's own example responses, so every screen shows what the real API would return.
5. A demo account that goes straight to sample mode, shown on the login screen, so a reviewer gets in with one tap.
6. A README section near the top: *Why the app uses demo data*, written for the reader (the hiring team), with the evidence and the one setting (`API_BASE_URL`) that changes the address.
7. If the certificate is wrong for the host, **pin it narrowly** (host + fingerprint), document the renewal, never turn verification off.

---

# Part B — Flutter specifics

## B1. Stack and the reasons

| Choice | Why | What it cost / rejected |
|---|---|---|
| Flutter 3.47, Dart 3.13, Material 3 | Brief asked for Flutter | — |
| `flutter_riverpod` 3 | Compile-safe, testable, `AsyncValue` fits "fetch → loading/error/data" (80% of the app) | Bloc (ceremony for ~10 screens), GetX (reviewers dislike), setState only (no shared session) |
| `go_router` 18 with a session `redirect` | One place decides "signed in / out" | A custom navigator |
| `dio` | Interceptors, typed errors, a certificate callback | `http` (fine, no interceptors) |
| `shared_preferences` | A handful of preferences | A database (nothing to query) |
| `url_launcher`, `share_plus` | Dialer, WhatsApp, web, share sheet, mail | — |
| `lottie` | The company's supplied loading animation | A hand-drawn spinner |
| **Bundled fonts** (Inter, Bricolage Grotesque, IBM Plex Mono, all OFL) | Offline, deterministic, tests load the same files | `google_fonts` failed to compile on Flutter 3.47, fetches at runtime and registers one weight (DEC-009, TF-05) |
| No code generation | Fewer moving parts to break | Freezed/json_serializable: models are plain `fromJson` |
| No chart package | Three arcs are trivial to paint | Dependency for nothing |

## B2. Architecture

```
lib/
  main.dart                 ProviderScope(retry: none), loads prefs, runApp
  app/        app.dart · router.dart (routes + redirect + appRoutes()) · theme.dart (tokens, fonts, ThemeData)
  core/
    network/  api_client.dart (dio, pinned cert, ApiException) · calley_api.dart (interface + Remote + Sample)
    storage/  session_store.dart (typed prefs)
    providers.dart          theme, language, data source, session, selected list, dispositions, reminders, clock
    utils/    validators · formatters · launchers (Launcher: open/dial/share/email, injectable)
    widgets/  the shared kit (§B4)
    build_info.dart         generated: kBuildNumber
  models/     User, CallingList, ListDetails, CallRecord  (fromJson only; nothing invented)
  features/   language auth onboarding dashboard lists calls settings drawer progress reminders support
assets/       brand/ (logo, mark) · loading/ (Lottie) · mock/ (sample JSON) · fonts/
test/         unit/ (logic + router + behavior) · snapshots/ (harness + screenshot tests)
snapshots/    light/ and dark/ PNGs, committed, one per screen state
```

### B2.1 Layers
Screens → Riverpod providers → `CalleyApi` (interface) → `RemoteCalleyApi` (dio) or `SampleCalleyApi` (bundled JSON). Models are dumb. Pure logic (progress, reminders, log report) sits in plain functions with no Flutter imports so it is tested in microseconds.

### B2.2 The API as an interface
`CalleyApi` has the six endpoints. `apiProvider` returns remote or sample from `dataSourceProvider`. A screen never knows which. `ApiException(message, statusCode, kind)` is the only thing screens catch: kinds are `network, timeout, server, notFound, unauthorized, badRequest`, so `ErrorView` can word each correctly.

### B2.3 The state placement rule
| Kind of state | Lives in |
|---|---|
| A preference the user set on purpose (theme, language, selected list, data source, session, onboarded) | A provider above every screen, persisted |
| Per-list session data (logged outcomes) | A provider keyed `listId/recordKey` (B-28), cleared on logout and on a data-source switch (DEC-015) |
| Transient (search text, expanded row, which filter chip) | The screen's own `State` |
| Derived (reminders, progress, counts) | A pure function over the two above; never stored |

### B2.4 Router and session
`routerProvider` holds a `GoRouter` whose `redirect` reads the session: signed-in users are kept out of **register/otp/login only** (`signedOutOnly`); `/language` stays reachable from Settings (B-01 was exactly this: it was in the auth group, so Settings → App Language opened a second Dashboard). `refreshListenable` bumps when the session changes. Export `appRoutes()` separately so tests can mount any screen *without* the redirect, and write separate tests *with* it.

### B2.5 Make the world injectable
Three tiny providers made everything testable: `clockProvider` (greetings, reminders), `launcherProvider` (dialer, share, mail, browser; tests stub it and record what was opened), `sessionStoreProvider` (overridden in `main`). Add one the first time a test cannot reach something.

## B3. Design system

### B3.1 Why it first looked generated, and what changed (DEC-013)
| First pass | Why it read as a template | Redesign |
|---|---|---|
| Blue-grey page, white bordered cards, 1 px borders everywhere | Every default dashboard looks like this | Warm paper page, flat white cards, **no borders**; the tone difference is the edge |
| Stat cards with a coloured left stripe | The most common AI-dashboard tell | One **ledger** strip: dot + word, then the figure in mono |
| Centred card floating on a page for auth | Same | Brand, big title, one sentence on the page; fields full width |
| Inter for everything | No voice | **Bricolage Grotesque** for headings and hero figures, **IBM Plex Mono** for every figure, Inter for body |
| Rectangular buttons | — | Pill with a hard 3 px lower edge that presses flat on tap |
| Plain list of stacked boxes | — | Contacts-style rows with name-seeded avatar colours |
| Generic hero | — | Navy greeting card with avatar, name, chips and the official mark as a watermark |

### B3.2 Tokens (copy these as a starting point)
Defined once as a `ThemeExtension<CalleyColors>`; both themes define the **same names**; `context.c.primary` everywhere; a widget never branches on brightness.

| Token | Light | Dark | Job |
|---|---|---|---|
| `bg` | `#F6F5F1` | `#0E0F12` | page (warm paper / near-black) |
| `card` | `#FFFFFF` | `#17191E` | surfaces |
| `cardAlt` / `input` | `#F1F0EB` / `#EFEEE9` | `#1E2127` / `#1B1E24` | nested surface, field fill |
| `border` | `#E6E4DD` | `#2A2E36` | hairlines only (dividers, outlined buttons) |
| `text` / `textSecondary` / `textMuted` | `#15161A` / `#4D505A` / `#656975` | `#F2F2F0` / `#B5B8C0` / `#8D919C` | all ≥ 4.5:1 on their surfaces |
| `primary` / `primaryDeep` | `#1F5EFF` / `#1546C9` | `#6B93FF` / `#3A66E0` | the one action; the pressed edge |
| `navy` / `onNavy` | `#0E1B3D` / white | `#182650` / `#F2F4F8` | section headers and the greeting card (same strong contrast in both themes) |
| `pending` / `done` / `scheduled` | `#F0B429` / `#1F5EFF` / `#8B5CF6` | `#F5C04A` / `#6B93FF` / `#A78BFA` | call status |
| `success` / `danger` | `#167A47` / `#C0302F` | `#3DCB7E` / `#F26B6B` | the call button / errors (text-safe darker values in light) |

Shape: page padding 20, gap 12, card radius 20, field radius 14, button height 52, minimum target 48.

Fonts, with one job each: **Bricolage Grotesque** (500–800): titles, hero figure, sheet headings. **IBM Plex Mono** (400–600) with tabular figures: every number, phone, date, the small uppercase tracked "eyebrow" labels. **Inter** (400–800): body, buttons, labels. Access them as `context.display(size)`, `context.mono(size)`, `context.body(size)`, `context.eyebrow()` so a literal `TextStyle` never creeps in (a bare `TextStyle` drops the font family: TF-10).

### B3.3 Rules that keep it consistent
1. A colour is a token. Grep for `Color(0x` outside `theme.dart` and the logo painter.
2. Status = coloured dot + a word (`StatusPill`, ledger, chips, donut legend).
3. One primary button per screen, always at the bottom. Secondary actions are outlined or text.
4. Cards have no border; nested surfaces use `cardAlt`.
5. Sheets and dialogs use the same radius and the same centred heading.
6. Icons are Material rounded/outlined; filled only for the selected state (bottom bar).
7. Copy: sentence case for new text; keep the design file's wording where it exists (fix only real typos, and write the fix down: "Star Calling Now" → "Start", DEC-004).

## B4. The component kit (`lib/core/widgets/`)

| Component | Job | Notes |
|---|---|---|
| `AppCard` | Flat surface, optional tap | `radius`, `color`, no border |
| `StatLedger` | The status figures as one strip: dot + label, then mono figure; each column tappable | Replaces three stripe cards |
| `GreetingCard` | Hero: avatar initial, eyebrow, name (display), subline, **chips**, faint official mark | Navy in both themes; reads as one sentence to a screen reader (`MergeSemantics`) |
| `NavyHeader` | Section header strip | Uppercase mono |
| `Avatar` | Initial in a circle; `seed` derives a stable hue from a name | Six fixed hues |
| `StatusPill` | Dot + word | Never colour alone |
| `PrimaryButton` | The pill CTA with the pressed edge | `busy` shows a spinner and refuses taps; real `Semantics(onTap)`; focusable with a focus ring (B-05) |
| `WhatsAppButton` | Round help button beside the CTA | |
| `AppTextField` / `PasswordField` | Filled fields, trailing icon, optional mono | `textCapitalization`, autofill hints, autocorrect off for email |
| `OtpInput` | Six boxes **drawn over one real, hidden field** | Paste, SMS autofill and soft-keyboard backspace work natively (B-03/B-16); the field carries the label |
| `DonutChart` | Rounded-end ring with gaps, total in the middle | Sweeps in once; still with reduced motion |
| `CalleyBottomBar` | Five slots, a raised play button | Fixed 56 dp row (TF-08) |
| `CalleyLogo` | The official logo (transparent PNG; a dark-theme copy) | The `showText: false` form is the mark alone |
| `CalleyLoader` / `CalleyLoaderBlock` | The supplied Lottie, with a label, for a whole-section wait | Still frame with reduced motion; live region; plain spinner if the file cannot load |
| `SkeletonBox` | A grey block the shape of what is coming, for small inline waits | Shimmer off with reduced motion |
| `ErrorView` | Cause-worded card, Retry, optional Use sample data | Live region; no cloud icon for a wrong password |
| `EmptyView` | Icon, title, one line, optional action | |
| `SampleDataBanner` | Amber strip on every data screen while sample data is active | `Try server` |
| Sheets | calling lists, outcome, send logs, cancel subscription | Centred heading, 48 dp options, drag handle |

### B4.5 The three kinds of wait
| Wait | Component |
|---|---|
| A button is working | the button's own spinner; it refuses a second tap |
| A small block is coming (a count, a list row) | `SkeletonBox` in its shape |
| A whole screen or section is coming (the list, the queue, progress) | `CalleyLoader` with a label in the user's words ("Loading your list…") |

One loader per wait, sized to the wait. The first loader needed a fix: the supplied animation embedded the logo on a **white** background, a white box in dark mode; we made that background transparent and saved the result in the app's assets (originals untouched).

## B5. Screens and flows (what exists, for orientation)
Language → Register → OTP → Login → Getting Started → Dashboard (empty / active) → Calling lists sheet → Settings → Drawer → Calling queue → Outcome sheet. Added after the audit: **Your progress** (level from the share of the list reached, outcomes by type, five badges), **Reminders** (scheduled calls grouped Overdue / Today / Upcoming behind a bell badge), **Send logs** (exact privacy-safe report, email or copy), **Share app**, **Cancel subscription** (honest). Plus a **demo account** card on Login.

**The calling loop** (the part designed for the real user, an agent working through 50 numbers): queue opens on *To call* → a *Call next · Sherri* button in the thumb zone → the dialer opens → only if it opened, the outcome sheet → the contact leaves *To call*, a bar says *12 of 50 logged*, a snackbar offers *Undo* → repeat. Outcomes can be changed later from the expanded row.

## B6. Forms
- Validate before the network; `autovalidateMode: onUserInteraction`; the Done key and the button share one `_submit` that begins with `if (_busy) return;` (B-25).
- After every `await`: check `mounted`, and take what you need from `ref` **before** the await (B-22). A sign-in that completes after the screen is gone must still land.
- Sign-in only requires a non-empty password (the server's own example password is `123`); the length rule is for sign-up.
- Mobile: 10 digits starting 6–9 (B-15) and a formatter that strips `+91`/`0` from pasted or autofilled numbers (B-24).
- A wrong OTP keeps the digits (B-19). **Retry repeats what failed** (resend or verify, B-21).
- Terms checkbox and its words are one merged control; the link is a separate 48 dp target (B-26).

## B7. Accessibility: the traps we actually fell into
| Trap | Symptom | Fix |
|---|---|---|
| `Semantics(button, label)` with `ExcludeSemantics(child: GestureDetector)` | The button is announced but has **no tap action**: TalkBack double-tap does nothing (B-02, B-05) | `Semantics(onTap: …, excludeSemantics: true)` |
| A raw `GestureDetector` | Not focusable: Tab never reaches it, Enter does nothing | `FocusableActionDetector` with `ActivateIntent`, and a visible focus ring |
| `Opacity(opacity: 0, child: TextField)` | The field vanishes from the semantics tree | `alwaysIncludeSemantics: true` |
| Six separate OTP text fields | Six unlabelled fields | One real field labelled "One-time code, 6 digits" |
| Errors that just appear | Not announced | `Semantics(liveRegion: true)` on `ErrorView`, notices and field errors |
| Titles as plain text | Not headings | `Semantics(header: true)` |
| `Semantics(label: 'A, B')` around a row that also shows "A" and "B" | Read twice | `excludeSemantics: true` plus the row's own `onTap` |
| An unlabelled `Switch` | No name, row does not toggle | `SwitchListTile` |
| Fixed-height rows and `Row`s of text | Overflow at 1.3× text | `Wrap`, `Expanded`, `constraints: minHeight` |
| Muted text at ~3.2:1 | Fails AA | Darken to ≥ 4.5:1 and record the ratio beside the token |

Also: reduced-motion honoured by the donut, the skeleton shimmer and the loader; every list row says whether it is expanded; a disabled call button says "No number for …".

## B8. Testing: how we made screens reviewable without a phone

**Snapshot harness** (`test/snapshots/snapshot_harness.dart`): fixes the surface to 390×844 at 3× (so PNGs are 1170×2532); loads every TTF in `assets/fonts` and the MaterialIcons font from the SDK through `FontLoader` so text and icons render instead of boxes; mounts the app under `GoRouter(routes: appRoutes())` with mock preferences; takes golden images to `snapshots/{light,dark}/NAME.png`.

Traps in widget tests, each of which cost an hour:
| Trap | Fix |
|---|---|
| `rootBundle.loadString` never finishes under the fake clock | Inject the loader (`loadText`); tests read the JSON from disk |
| `Image.asset` blank in goldens | `precacheImage` inside `tester.runAsync` before the screenshot (done in `settle()`) |
| Lottie composition never loads | Preload `AssetLottie(path).load()` under `runAsync` so it is in the cache |
| `launchUrl` never completes | `launcherProvider` stubbed to succeed, and recording what it was asked to open |
| `pumpAndSettle` hangs on a looping shimmer | `settle()` pumps a fixed number of frames |
| A bottom sheet "does not open" | It was awaiting the (hung) platform call, not a bug in the sheet |
| Riverpod 3 retries a failed provider with back-off, so skeletons show for seconds | `ProviderScope(retry: (_, _) => null)` |
| `Override` type missing | `import 'package:flutter_riverpod/misc.dart' show Override;` |
| The loader animates, so goldens differ every run | `stillMotion(tester)`: `accessibilityFeaturesTestValue = FakeAccessibilityFeatures(disableAnimations: true)` |

**What to test, in this order:** (1) pure functions (parsers, validators, formatters, progress, reminders, the log report); (2) the **real router** with its redirect (the snapshot tests bypass it, which is how B-01 hid); (3) behavior through the injected launcher/clock (share, mail, the bell count, a logged call leaving Reminders); (4) a drift test (pubspec `+N` = `kBuildNumber`); (5) snapshots for every screen state in both themes.

**Review snapshots by eye, every time.** Things only a glance found: the bottom bar taking the whole screen; the illustration badges missing; "Scheduled" cut at the card edge; a pale card with dark text in dark mode; a logo on a white box.

## B9. Flutter bug classes with the fix each time
| Class | Instance | Fix |
|---|---|---|
| Unbounded layout | A bare `Center` in an `Expanded` of the bottom bar took every pixel; the body got zero height (TF-08) | Give it a fixed-height `SizedBox`; **measure with `tester.getRect`** before guessing |
| Unbounded layout | `IntrinsicHeight` needed for a stretch bar in a scroll view | Wrap the `Row` |
| Positioned in a box that is not full width | Illustration badges never rendered (B-37) | A fixed-size `SizedBox` around the `Stack`, offsets from its edges |
| Context/ref after an async gap | Sign-in lost when the screen was left mid-request (B-22) | Read `ref` first; check `mounted` |
| Skeleton-on-refresh | Retry showed nothing happening (B-30) | `skipLoadingOnRefresh: false`, or check `isLoading` before `hasError` |
| Unhandled errors from `RefreshIndicator` | Server down → async error on every pull (B-38) | Invalidate, then `await … future` inside `try/catch` |
| Two views of one number | 61 total beside 50 contacts (DEC-017) | Compute disjoint groups from the records |
| Redirect applied to `push` | App Language opened a second Dashboard (B-01) | Redirect only the routes that must bounce |
| Fixed per-mode colour | Same blue for Done in one place, green in another (B-39) | One token per meaning |
| A debug-only assert on a derived count | Crashed when a logged contact left the list | Remove the assert; test the case |
| A `TextStyle` literal in a theme | Dropped the font family (TF-10) | Derive from the theme |
| Plugin throws without a platform | `launchUrl` in tests and on unsupported platforms | Wrap in `try/catch`, return `false` |

## B10. Tried and dropped
`google_fonts` (compile error, runtime fetch); a global TLS bypass (never); a Host-header trick for the mis-certified API host; three bordered stat cards with stripes; centred floating auth card; the brand-blue greeting card (pale and low-contrast in dark mode); a fixed-height tutorial poster that clipped at large text; six separate OTP fields; a snackbar saying "not part of this test build"; a floating "Call next" button that overlapped the last row (moved into the bottom bar slot); counting the server's overlapping totals.

## B11. Known gaps (be honest in the README)
Not run on a physical device (launchers, TalkBack, a real soft keyboard); real language switching (the picker stores the choice; the text is English); an iOS build (project generated, URL schemes declared, never built); auto-dial mode; Change/Forgot Password (no endpoint); the supplied mock API (dead).

---

# Part C — Checklist, order, file map

## C1. If you were starting again: the build order

**Day 1: the things expensive to retrofit**
1. Brief → spec table; watch the video frame by frame; find the API docs (A2).
2. Tokens as a theme extension, light and dark, same names; bundle the fonts; contrast-check every text/surface pair.
3. The API as an interface with a **sample implementation** from the docs' own examples; `ApiException` with kinds.
4. Providers for preferences, session, data source; the router with a redirect; `clock`/`launcher` providers.
5. The snapshot harness and one screen rendered in both themes. *Do this before the second screen.*

**Day 2: screens**
6. Shared kit (card, pill button, fields, status pill, empty/error/skeleton/loader, banner).
7. Screens in the design file's order; each rendered and read by eye in both themes before the next.
8. Forms with the busy guard, `mounted` checks and server-honest validation.

**Day 3: the real user's loop**
9. The flow the user repeats (here: call → outcome → next) with progress, undo and the closest action.
10. Honest stubs → real features (progress, reminders, share, support) built only from real data.

**Day 4: audit and release**
11. Accessibility pass using the trap table (B7).
12. The adversarial audit (A3); fix; write `bugs.md` / `bugfixed.md`.
13. README: why demo data, demo login, run, checks, known limits; screenshots grid.
14. Number the build from the tag and show it in the app; release APKs split per ABI (≈ 17–21 MB each).

## C2. Pre-release checklist
- [ ] Every screen rendered in light **and** dark and read by eye; no overflow at 390×844 and 360×640; text at 1.3×
- [ ] Every network screen has loading, empty, error, sample-data states
- [ ] No hex outside `theme.dart`; no `TextStyle(` without the theme
- [ ] Every tap target ≥ 48 dp; neighbours spaced
- [ ] Main buttons activatable by keyboard and by `Semantics` tap; errors are live regions; titles are headers
- [ ] Contrast ≥ 4.5:1 for text, recorded
- [ ] No contact data leaves the phone through "Send logs"; no secrets committed
- [ ] The README says why anything is demo/sample, and what is not built
- [ ] `flutter analyze` 0; all tests green; snapshots regenerated **and diffed against the old ones first**
- [ ] The build number in the app = the tag = `pubspec +N`

## C3. File map (this repository)
```
MD/                        README.md (index) · calley_MASTER.md · prd · intent · rules · decisions · tasks
                           bugs.md · bugfixed.md · tried_and_failed · tried_and_implemented · pain
                           api_reference · ui_screens · flow · video_requirements · plan_drawer_features
                           version_control · frontendcalley.md (this file) · builds/ (one report per build)
calley_app/                the Flutter app (see B2)
calley_loading_assets/     the supplied loader (originals; the app uses a transparent-background copy)
scripts/changelog.mjs      build/InBul bookkeeping; stamps the build number into pubspec and build_info.dart
CHANGELOG.md               generated; never edited by hand
```

## C4. Vocabulary
**Build** a user-visible numbered release (`build-N`). **InBul** an internal change (`InBulNN`). **Sample data** the bundled copy of the documentation's example responses. **Disjoint groups** pending / done / scheduled counted so they add up to the list. **Eyebrow** the small uppercase tracked label above a value. **Ledger** the single strip of status figures. **Still frame** what animated widgets show under "remove animations".
