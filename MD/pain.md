# pain.md — what can break the submission and how badly

Severity: **S1** sinks the submission · **S2** costs real marks · **S3** annoyance.

## P-01 · S1 · Mock API host has a broken/expired TLS certificate or is down
Observed 2026-11-04: `curl` exit 60 on `mock-api.calleyacd.com`. Two prior candidates mention cert mismatches and shipped offline fallbacks.
**Risk:** reviewer installs APK → every screen errors.
**Mitigation:** (1) test from browser/Postman and ask HR early; (2) ship `USE_MOCK` dart-define + labelled fallback (DEC-007); (3) if the cert is merely untrusted (not expired), consider pinning the server cert in debug only — never `badCertificateCallback => true` in release (R-07); (4) say so plainly in README.

## P-02 · S1 · Missing a deliverable
No APK, no recording, or no repo access = likely auto-reject regardless of code quality.
**Mitigation:** deployment.md checklist; do §4 of tasks.md before polishing anything.

## P-03 · S2 · Screens don't match Figma
Wrong colours, missing bottom bar, wrong copy, missing drawer items.
**Mitigation:** build with Figma open side-by-side; use ui_screens.md as a checklist; screenshot comparison before submission.

## P-04 · S2 · Faked networking
Reviewer sees instant "success" with Wi-Fi off and concludes the API layer is fake (the pattern in prior repos).
**Mitigation:** R-06. Show real loading + real errors.

## P-05 · S2 · Unknown response shapes
`login`/`register`/OTP bodies are inferred. If `login` returns the user at top level and the app expects `data['user']`, login breaks.
**Mitigation:** parse defensively (`j['user'] ?? j`), log raw responses in debug, test against the live mock before submission.

## P-06 · S2 · `tel:` / WhatsApp / YouTube launchers silently fail
Android 11+ package visibility: `canLaunchUrl` returns false without `<queries>` entries.
**Mitigation:** add `<queries>` for `tel`, `https`, `whatsapp` in `AndroidManifest.xml`; use `launchUrl(mode: externalApplication)`; test on a physical device.

## P-07 · S3 · Counts don't reconcile
API: 27+23+11 = 61 vs 50 records; Figma: 28/22/09. Reviewer may ask why.
**Mitigation:** render API values verbatim; one README line explaining the data as received.

## P-08 · S3 · Figma font/colour guesses
Without inspect access, hex values are eyeballed.
**Mitigation:** sign into Figma (free) to read inspect values; or sample from a 2× screenshot.

## P-09 · S3 · Over-engineering
Clean-arch folders, codegen, DI containers for 10 screens → reviewer reads it as cargo-cult.
**Mitigation:** R-05 folder layout; keep it to what the app needs.

## P-10 · S3 · Deadline unknown
Not on the page.
**Mitigation:** check email today; if unspecified, aim for 3–4 days from receipt and say when you'll deliver.
