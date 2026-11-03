# tasks.md — living task tracker

Legend: `[ ]` todo · `[~]` in progress · `[x]` done · `[-]` dropped. Dates are when the box was ticked.

## 0. Before coding

- [x] Read Notion page, Figma, find mock API (2026-11-04, external_research.md)
- [ ] **Watch the 2:20 video end-to-end** and note anything not in Figma. (Still the user's job: headless capture failed, TF-01/02.)
- [ ] Re-read the HR email: deadline, exact submission address, whether a Postman collection was attached.
- [x] Test the mock API (2026-11-04): host up, cert for `*.plesk.page`, every `/api/*` path answers an empty 404. See api_reference.md, pain.md P-01.
- [x] Confirm DEC-002 Riverpod (3.4) and DEC-003 dio.

## 1. Project setup

- [x] `flutter create calley_app --org in.cstech`
- [x] Deps: flutter_riverpod, dio, shared_preferences, url_launcher, go_router, crypto. (google_fonts was added, then dropped for bundled fonts — DEC-009.)
- [x] Theme: tokens as a `ThemeExtension`, light + dark with the same names; three bundled fonts
- [x] Router with session gate (go_router 18)
- [x] `ApiClient` with scoped certificate pin (DEC-010); `USE_MOCK` dart-define; sample-data mode with banner (DEC-007)

## 2. Screens (Figma order)

- [x] 01 Language — [x] 02 Register — [x] 03 OTP — [x] 04 Login — [x] 05 Getting Started
- [x] 06 Dashboard empty + bottom bar — [x] 07 Settings + Calling Lists sheet — [x] 08 Dashboard active
- [x] 09 Drawer (+ logout) — [x] 10 Calling queue (filters, search, `tel:`, disposition sheet) — DEC-006

## 3. Quality

- [x] Error / empty / loading states on every network screen; no silent fallback (R-06)
- [x] `flutter analyze` clean; `dart format`
- [x] 32 snapshot tests (every screen × light/dark) double as "it renders" tests
- [ ] Unit tests for models `fromJson` and validators (small; worth adding)
- [ ] **Test on a physical Android device** — `tel:`, WhatsApp, YouTube launchers; the pinned-cert path; real keyboard on the OTP boxes

## 4. Submission

- [x] README in `calley_app/` with screenshots, API notes, architecture, limits
- [~] `flutter build apk --debug` (first build running 2026-11-04)
- [x] Git history per MD/version_control.md; pushed to github.com/xeyynon/CS-Infotech-
- [ ] Attach the APK to a GitHub Release (v1.0.0 / build-1000)
- [ ] Screen recording ≤ 3 min on a real device
- [ ] Share repo with `info@cstech.in` (verify the address from the HR email) and send the email

## 5. Nice-to-have (only after §4)

- [ ] EN + HI translations (DEC-008)
- [ ] iOS: `LSApplicationQueriesSchemes` in Info.plist; build on a Mac
- [ ] Unit test for the certificate-pin predicate

## Design pass (2026-11-04, after "this looks AI generated")

- [x] Replace stripe stat cards with a ledger strip; flat paper surfaces; no card borders
- [x] Bricolage Grotesque headings, IBM Plex Mono figures, Inter body — bundled
- [x] Left-aligned auth screens; filled fields; tactile pill CTA; raised play button
- [x] Contacts-style queue rows with name-seeded avatars
- [x] Time-of-day greeting hero card
