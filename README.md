# Calley — Flutter machine test

Submission for the **Flutter Mobile App Developer** machine test at C S Tech Infosolutions Pvt. Ltd.: a Flutter build of the Calley (automatic call dialer) onboarding and dashboard, from the supplied Figma file, against the Calley mock REST API.

| | |
|---|---|
| App source | [`calley_app/`](calley_app/) — see its [README](calley_app/README.md) for setup, architecture and screenshots |
| Screenshots | [`calley_app/snapshots/`](calley_app/snapshots/) (light and dark, every screen) |
| Project docs | [`MD/`](MD/) — research, requirements, decisions, risks; start at [`MD/README.md`](MD/README.md) |
| Change history | [`CHANGELOG.md`](CHANGELOG.md) (generated) and `git tag` — see [`MD/version_control.md`](MD/version_control.md) |

## Run it

```
cd calley_app
flutter pub get
flutter run                       # device or emulator
flutter build apk --debug         # build/app/outputs/flutter-apk/app-debug.apk
```

## A note on the test server

The mock API host (`mock-api.calleyacd.com`) was checked on 2026-11-04: it answers TLS with a certificate for its hosting provider's name and every `/api/*` path returns an empty 404. The app calls it first and, when it cannot be reached, says so and **offers** bundled sample data with a persistent banner. Nothing is faked silently. Details in [`MD/api_reference.md`](MD/api_reference.md) and [`MD/pain.md`](MD/pain.md).
