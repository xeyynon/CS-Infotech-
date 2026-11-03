# tried_and_implemented.md — approaches confirmed working

Reuse these before building anything new. Format: what · where · notes.

## Research phase (2026-11-04)

### TI-01 · Reading a public Notion page headlessly
Playwright `browser_navigate` + `document.body.innerText` + collecting `iframe[src]` gives full text and embed URLs (the YouTube ID came from the iframe src).

### TI-02 · Reading a view-only Figma file
Anonymous load works; `browser_take_screenshot(scale: "device")` at the default zoom is legible for 9 phone frames. No login needed for layout/copy.

### TI-03 · Finding prior submissions
Searching the **YouTube video ID** (not the company name) surfaced two candidates' GitHub repos, which in turn gave the API base URL, endpoints and sample JSON that the Notion page omits. Generalises: search unique IDs/strings from an assignment.

### TI-04 · Pulling raw files from GitHub without cloning
`https://raw.githubusercontent.com/<owner>/<repo>/HEAD/<path>` + GitHub tree API `…/git/trees/HEAD?recursive=1` to list paths.

## Build phase (2026-11-04)

### TI-05 · Snapshot tests as the screenshot pipeline
`test/snapshots/snapshot_harness.dart`: sets `tester.view.physicalSize` to 1170×2532 @3x, loads every TTF in `assets/fonts` and `test/fonts` through `FontLoader` (family = file prefix), plus MaterialIcons from `$FLUTTER_ROOT/bin/cache/artifacts/material_fonts`, mounts the app under a plain `GoRouter(routes: appRoutes())` with `SharedPreferences.setMockInitialValues`, and `matchesGoldenFile('../../snapshots/<theme>/<name>.png')`. `settle()` pumps fixed frames because the skeleton shimmer never settles.

### TI-06 · Indic scripts in the test renderer
Download `NotoSans<Script>-400.ttf` via the hashes in google_fonts' source (`part_n.dart`), load under those family names, and list them in `ThemeData.fontFamilyFallback`. On a device the system fonts take over.

### TI-07 · Scoped certificate pin (`api_client.dart`)
`badCertificateCallback: (cert, host, port) => host == apiHost && pinned.contains(sha256(cert.der))`. Verified with a standalone Dart probe before wiring it in.

### TI-08 · Honest offline mode
`DataSource {remote, sample}` persisted; `ErrorView` offers "Use sample data" only for server-class errors; `SampleDataBanner` on every data screen while active, with "Try server". Auth screens listen for the switch and resubmit automatically.

### TI-09 · Build/InBul tooling in Node with no dependencies
`scripts/changelog.mjs`: numbers from `git tag`, reports in `MD/builds/`, `CHANGELOG.md` regenerated, `--tag` refuses a mismatched title or a double tag.
