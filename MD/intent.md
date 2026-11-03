# intent.md — why this project exists

## The problem

C S Tech needs to see, before an on-site offer, whether a candidate can turn a Figma file plus a REST API into a working, deployable Flutter app without hand-holding. Their brief is deliberately thin (three sentences, a silent video, a Figma link) — part of the test is reading between the lines.

## Who evaluates it

A Flutter lead at a small product company (Calley is their one product: an auto-dialer for sales teams, free + ₹/€/$ "Pro" IAP, ~1.3k views on the test video → many candidates have taken it). They will judge quickly. They have seen dozens of clones. Expect them to:

1. install the APK and tap through in under 5 minutes,
2. open the repo and look at folder structure, state management, API layer, and whether the README is honest,
3. compare screens against Figma side by side,
4. check whether API calls are real (network tab / logs) or faked.

## Design principles for this submission

1. **Fidelity first.** The Figma is the spec. Match spacing, colours, copy (including quirks like "Star Calling Now" — see rules R-03), and the bottom bar.
2. **Honest networking.** Every endpoint is really called. If the mock server is down, the app says so; any fallback is labelled, not silent (prior candidates silently faked success — don't).
3. **Small, readable architecture.** Feature folders, one state solution, thin widgets, models with `fromJson`. No over-engineering (no clean-arch 5-layer ceremony for 9 screens).
4. **Ship the whole loop.** Repo + README + APK + recording. A beautiful app with no APK loses to an OK app with everything attached.
5. **Stand out in one place.** Options: smooth donut animation, i18n actually working for 2–3 languages, offline cache with "last synced" label, or widget tests. Pick one, do it well.

## Non-goals

Not building a production dialer. Not deploying to stores. Not reverse-engineering the real Calley app beyond what Figma shows.
