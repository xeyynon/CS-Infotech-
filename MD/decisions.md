# decisions.md — decision log

Format: ID · date · decision · why · consequences. Append-only; supersede with a new entry.

---

## DEC-001 · 2026-11-04 · Keep research and planning in `MD/` as markdown
**Decision:** All project knowledge lives in `E:\Projects\CS\MD\*.md`, indexed by `MD/README.md`.
**Why:** Same layout as the previous project; works with any editor and with Claude Code recall.
**Consequence:** Update `tasks.md` and `decisions.md` as work proceeds; `calley_MASTER.md` is the tie-breaker.

## DEC-002 · 2026-11-04 · State management: **Riverpod** (proposed — confirm before coding)
**Decision:** `flutter_riverpod` with `AsyncNotifier`s per feature.
**Why:** Compile-safe, testable, no `BuildContext` plumbing, and idiomatic for "fetch → loading/error/data" screens, which is 80 % of this app. Provider is acceptable if the candidate is more fluent in it — both prior public submissions used Provider, so Riverpod is a mild differentiator.
**Alternatives rejected:** Bloc (too much ceremony for 9 screens), GetX (reviewers often dislike it), setState only (no shared session state).

## DEC-003 · 2026-11-04 · HTTP client: **dio**
**Decision:** `dio` with a single `ApiClient` (base URL, JSON headers, 10 s timeouts, log interceptor in debug).
**Why:** Interceptors + typed errors make the "no silent fakes" rule (R-06) easy. `http` is fine too; dio chosen for logging.

## DEC-004 · 2026-11-04 · Fix the "Star Calling Now" typo
**Decision:** Render "Start Calling Now".
**Why:** See R-03. Mention in README that Figma says "Star".

## DEC-005 · 2026-11-04 · Donut chart: custom `CustomPainter`, animated
**Decision:** No chart package.
**Why:** 3 arcs is trivial; avoids a dependency; shows Flutter fundamentals; both prior submissions did the same so it's the expected baseline.

## DEC-006 · 2026-11-04 · Calling queue screen is in scope
**Decision:** Add a 10th screen (not in Figma) listing `calls[]` with filter tabs and a `tel:` launcher.
**Why:** "Start Calling Now" must do *something*; the API gives 50 records; the brief's product is a dialer. Both prior candidates added it.

## DEC-007 · 2026-11-04 · Mock fallback is opt-in, labelled
**Decision:** Ship `assets/mock/*.json` (from `MD/assets/sample-list-details.json`) behind `--dart-define=USE_MOCK=true` and a visible banner.
**Why:** The mock host may be down during the review (pain P-01). The reviewer must still be able to tap through, but must never be misled that the network works.

## DEC-009 · 2026-11-04 · Fonts are bundled assets, not google_fonts
**Decision:** Inter (body), Bricolage Grotesque (display), IBM Plex Mono (figures) ship in `assets/fonts/` (OFL).
**Why:** google_fonts 9 failed to compile against Flutter 3.47 (`TextTheme` type mismatch), fetches at runtime (the app must work offline and in tests), and only loads one weight per family unless each style is built through its API. Bundling is deterministic and lets the snapshot tests load the exact same files.
**Consequence:** +2.3 MB of assets. Adding a weight means adding a file and a pubspec line.

## DEC-010 · 2026-11-04 · The mock host's certificate is pinned, not bypassed
**Decision:** `badCertificateCallback` accepts a certificate only for `mock-api.calleyacd.com` **and** only if its SHA-256 fingerprint is on the list in `api_client.dart`.
**Why:** The host serves a valid Let's Encrypt certificate for `cool-meninsky.74-208-123-142.plesk.page`, so hostname validation fails. Both prior candidates disabled TLS validation globally (R-07 forbids it). A pin is narrower than normal validation, not wider.
**Consequence:** When the host renews (~every 60–90 days; current cert expires 2027-01-19) the fingerprint must be added. The host returns 404 for every API path anyway as of 2026-11-04.

## DEC-011 · 2026-11-04 · No automatic retry on failed providers
**Decision:** `ProviderScope(retry: (_, _) => null)`.
**Why:** Riverpod 3 retries a failed provider with exponential backoff; the screen shows skeletons for up to ~12 s before the error appears. An explicit Retry button and the "Use sample data" offer are faster and honest.

## DEC-012 · 2026-11-04 · Snapshots come from `flutter test`, and launchers/clock are providers
**Decision:** `test/snapshots/` renders every screen at 390×844 @3x to `snapshots/{light,dark}/`. `launcherProvider` and `clockProvider` exist so tests can stub the platform and fix the time.
**Why:** No emulator on this machine; the test renderer draws the real widget tree. `launchUrl` never completes in a widget test, which hid the disposition sheet until the launcher was made injectable.
**Consequence:** Regenerate with `--update-goldens` after any deliberate UI change and commit the PNGs (InBul).

## DEC-013 · 2026-11-04 · Design direction: "an instrument, not a template"
**Decision:** Warm paper background; flat cards without borders; one display heading and one hero figure per screen; every number in tabular mono; status as dot + word; the primary CTA is a pill with a hard 3 px edge; the queue is contact rows, not stacked boxes; no accent stripes.
**Why:** The first pass (bordered white cards, stripe stat cards, centred auth cards, Inter everywhere) read as generic. The user's own TARANG/Dukaan Dost rules say the same: no stripes, one hero, mono figures, colour never alone.
**Consequence:** Figma is followed for content and order, not for the stripe cards or centred layouts. Noted in the README.

## DEC-014 · 2026-11-04 · Version control follows the build/InBul scheme
**Decision:** Tags are the truth (`build-N`, `InBulNN`); `scripts/changelog.mjs` writes `MD/builds/build-N.md` and `CHANGELOG.md`; push only when asked, with `--tags`. See MD/version_control.md.
**Why:** Same scheme as the user's other projects; keeps the public build list short and the internal work recorded.

## DEC-015 · 2026-11-05 · Switching data source keeps the session (B-13)
**Decision:** Turning sample data on or off does not sign the user out; it clears this session's logged outcomes, and lists/details refetch from the new source.
**Why:** "Use sample data" is offered in the middle of a task when the server fails; signing the person out there would punish the recovery path. Outcomes are cleared because they belong to the other data set.

## DEC-016 · 2026-11-05 · Links point at the real Calley pages
**Decision:** Terms, Privacy, About, Download from getcalley.com; Help/WhatsApp uses +91 99711 25511 as published on csquaretech.com. The company is C S Tech Infosolutions (csquaretech.com, info@csquaretech.com).
**Why:** The user supplied both sites on 2026-11-05. Placeholder links look unfinished to a reviewer from the company itself.

## DEC-017 · 2026-11-05 · Counts are shown as disjoint groups
**Decision:** Ring and ledger show Pending / Done / Scheduled computed from the records so they add up to the list (27 + 12 + 11 = 50). The server's own "called 23" includes the 11 rescheduled; a footnote says so.
**Why:** Two different totals on one screen (50 contacts vs 61) was the most confusing thing on the dashboard (audit UX #27/#32/#38).

## DEC-008 · 2026-11-04 · i18n: ship real translations for EN + HI only (nice-to-have)
**Decision:** `flutter_localizations` + ARB for English and Hindi; other 7 languages fall back to English.
**Why:** Demonstrates the language screen does something; full 9-language translation is wasted effort for a test. **Defer until core flow is done.**
