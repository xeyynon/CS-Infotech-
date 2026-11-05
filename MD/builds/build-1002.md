<!-- manual:start -->
# Build 1002: Demo login, the official Calley logo, and a sign-in that accepts the server's own passwords

Date: 2026-11-05

## What changed

A demo account (demo@getcalley.com / Demo@1234) signs in against the bundled sample data while the supplied API is down; the official getcalley.com logo replaces the drawn one and becomes the launcher icon; sign-in no longer enforces a password length the server itself does not use.

## Why

The supplied API returns 404 everywhere, so a reviewer needs a one-tap way in; the user asked for the official logo; the official Postman collection's example password is 123.

## How it was checked

flutter analyze 0 issues; flutter test 72 passed including real-router tests for the demo login; snapshots regenerated and reviewed in light and dark. Not yet run on a physical device.

## Next improvement

Run on a real Android phone; attach the release APKs to a GitHub release.
<!-- manual:end -->

## Files changed

- `calley_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `calley_app/assets/brand/calley_logo.png`
- `calley_app/assets/brand/calley_logo_dark.png`
- `calley_app/assets/brand/calley_mark.png`
- `calley_app/lib/core/demo_account.dart`
- `calley_app/lib/core/utils/validators.dart`
- `calley_app/lib/core/widgets/calley_logo.dart`
- `calley_app/lib/features/auth/login_screen.dart`
- `calley_app/pubspec.yaml`
