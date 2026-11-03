# tried_and_failed.md — approaches that didn't work

So nobody repeats them. Format: what · why it failed · what to do instead.

## Research phase (2026-11-04)

### TF-01 · Pulling the task video's transcript
Auto-caption track exists but the timedtext endpoint returns an empty 200 body; `fmt=json3` likewise. The video is silent.
→ Watch it manually.

### TF-02 · Grabbing video frames headlessly
Seeking the embedded YouTube player via `video.currentTime` + `play()` throws `NotAllowedError` (autoplay policy) and the frame doesn't repaint.
→ Not worth automating; a 2:20 manual watch is faster.

### TF-03 · `curl` against the mock API without cert bypass
Exit 60 (TLS). Didn't retry with `-k` on purpose (R-07).
→ Inspect the cert in a browser; test in Postman; ask HR.

### TF-04 · Figma "zoom to 100%" shortcut via Playwright
`Shift+0` didn't take (canvas not focused). The 41 % device-scale screenshot was legible enough.
→ If exact values are needed, log in and use Inspect.

## Build phase (2026-11-04)

### TF-05 · google_fonts for the app font
`GoogleFonts.interTextTheme()` would not compile against Flutter 3.47 (TextTheme type mismatch), and `ThemeData(fontFamily: GoogleFonts.inter().fontFamily)` registers only the regular weight. → Bundled TTFs (DEC-009).

### TF-06 · Host-header trick for the mis-certified API host
Connecting to the Plesk hostname (valid cert) with `Host: mock-api.calleyacd.com` → 404. Apache routes by SNI. → Scoped pin (DEC-010). The API is 404 either way.

### TF-07 · `rootBundle` in widget tests
`SampleCalleyApi` read assets through `rootBundle`; under the test binding's fake clock the I/O never completed, so the dashboard rendered nothing and the queue stayed on skeletons. → Injectable `loadText`; tests read the JSON from disk synchronously.

### TF-08 · `Center` inside the bottom bar
A bare `Center` in an `Expanded` took every pixel the Scaffold offered; the bar became 844 px tall and the body got zero height, in every dashboard snapshot. → `SizedBox(height: 56)` around it. Lesson: measure the render tree (`tester.getRect`) before guessing.

### TF-09 · `launchUrl` in widget tests
Never completes (no platform), so anything awaited after it never ran — the disposition sheet "didn't open". → `launcherProvider` stubbed in tests (DEC-012).

### TF-10 · A `TextStyle` literal in `ButtonStyle.textStyle`
Drops the font family; on the test font it rendered as a solid block, on a device it would silently fall back to Roboto. → Always derive from the theme or name the family.
