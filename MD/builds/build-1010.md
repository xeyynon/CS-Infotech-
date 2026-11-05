<!-- manual:start -->
# Build 1010: Em dashes are gone from the app's text

Date: 2026-11-05

## What changed

The sample-data banner now reads Sample data: the Calley server could not be reached, and a value that is missing shows a plain hyphen instead of a long dash. Comments in the code no longer use em dashes either.

## Why

A style choice: plain punctuation throughout, in the app, the code, the docs and the generated changelog.

## How it was checked

flutter analyze clean; 81 unit tests and 52 snapshot tests pass; the banner snapshots checked by eye.

## Next improvement

None.
<!-- manual:end -->

## Files changed

- `calley_app/lib/core/utils/formatters.dart`
- `calley_app/lib/core/utils/validators.dart`
- `calley_app/lib/core/widgets/status_views.dart`
- `calley_app/lib/features/auth/login_screen.dart`
- `calley_app/lib/features/auth/otp_screen.dart`
- `calley_app/lib/features/auth/register_screen.dart`
- `calley_app/lib/features/drawer/app_drawer.dart`
- `calley_app/lib/features/onboarding/getting_started_screen.dart`
- `calley_app/lib/features/settings/settings_screen.dart`
