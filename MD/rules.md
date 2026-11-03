# rules.md — project rulebook

Constraints on how this app is built. Change a rule via a `decisions.md` entry, not silently.

## R-01 Figma is the spec
Match the 9 frames. When Figma and the video disagree, the video wins (it is the "task to be done"); note the discrepancy in `decisions.md`.

## R-02 API data over design data
Numbers (call counts, list names, user name/email) come from the API, never hard-coded from Figma (Figma shows 28/22/09 — the API returns 27/23/11).

## R-03 Copy fidelity, with one exception
Reproduce Figma copy verbatim, **except** the typo "Star Calling Now" → use "Start Calling Now". Record this as DEC-004. (Typos copied verbatim look like carelessness, not fidelity.)

## R-04 One state-management solution
Riverpod or Provider — not both, no Bloc on top. See DEC-002.

## R-05 Feature-first folders
`lib/features/<feature>/{data,domain,presentation}` is *too much* for this size. Use:
```
lib/
  app/        (router, theme, di)
  core/       (network client, storage, utils, widgets)
  features/
    language/ auth/ onboarding/ dashboard/ lists/ calls/ settings/
      ├── <feature>_screen.dart
      ├── <feature>_controller.dart  (state)
      └── widgets/
  models/     (shared DTOs: user, calling_list, list_details, call_record)
```

## R-06 No silent fakes
If a request fails, surface it (snackbar/empty state + retry). A local mock/fallback is allowed only behind an explicit flag (`--dart-define=USE_MOCK=true`) or a visible "offline sample data" banner. Never return `{'message':'User registered'}` on a 500.

## R-07 Never disable TLS verification in shipped code
`badCertificateCallback = (_, __, ___) => true` is a red flag to any reviewer. If the mock host's cert is broken (see pain P-01), handle it with: (a) ask HR, (b) a debug-only override gated by `kDebugMode` **and** a dart-define, documented in README.

## R-08 Session persistence
Store `userId`, `username`, `email`, selected language, selected `listId` in `shared_preferences`. App restart lands on Dashboard if logged in, else Language screen.

## R-09 Validation before network
Forms validate client-side first; buttons show a loading state; double-submit is prevented.

## R-10 Analyzer clean, formatted
`flutter analyze` → 0 issues; `dart format .` before every commit.

## R-11 Commit hygiene
Small commits, imperative messages, no "final final fix". The reviewer will read `git log`.

## R-12 README is part of the product
Setup, architecture diagram (text is fine), API table, screenshots grid, known issues, how to run with/without mock.

## R-13 Secrets
None expected. If HR sends an API key, read it from `--dart-define`, never commit it.

## R-14 Assets
Logo and illustrations: export from Figma (view-only allows export of selected frames via right-click → Copy/Paste as PNG in some cases; otherwise screenshot and crop). Attribute nothing — it's their brand.
