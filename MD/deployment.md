# deployment.md — build & submission checklist

No store deployment is required for the test (the brief mentions Play/App Store as part of the *job*). This is the submission pipeline.

## 1. Build

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug          # required deliverable
flutter build apk --release        # optional; uses debug signing unless you add a keystore — fine for a test
```
Outputs: `build/app/outputs/flutter-apk/app-debug.apk` (and `app-release.apk`).

Optional split for smaller files: `flutter build apk --split-per-abi` → ship the `arm64-v8a` one plus the universal debug APK.

## 2. Verify on a real device
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- Tap through the full flow once with Wi-Fi on, once with Wi-Fi off (error states must appear, not fake data).
- `tel:` launch opens the dialer; WhatsApp link opens WhatsApp or browser.

## 3. Repo
- Public or private GitHub repo `calley_app` (or `calley-flutter`).
- `.gitignore` from `flutter create` (no `build/`, no `.dart_tool/`).
- README per rules R-12, with a `screenshots/` folder (take them from the device, 1080×2400, 9 + queue).
- Create a **GitHub Release v1.0.0** and attach the APK(s) — more reliable than Drive links.
- Settings → Collaborators → add the reviewer (`info@cstech.in` per prior candidates — **confirm from your email**; if the repo is public this is still a nice signal).

## 4. Recording
- Android: `adb shell screenrecord /sdcard/demo.mp4` (max 3 min) or the built-in screen recorder.
- Cover: language → register → OTP → login → getting started → empty dashboard → select list → active dashboard → queue → dial → drawer → logout. Under 3 minutes.
- Upload as unlisted YouTube or attach to the GitHub release.

## 5. Email
Subject: `Flutter Machine Test – <Your Name>`
Body: repo link, release/APK link, recording link, 3-line summary of stack, one line on known issues (e.g. mock API cert), thanks.

## 6. iOS (only if you have a Mac)
`flutter build ios --no-codesign` and mention it in the README. Not a required deliverable.
