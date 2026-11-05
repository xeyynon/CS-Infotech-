<!-- manual:start -->
# Build 1001: Bug fixes and a calmer, centred layout with a faster calling loop

Date: 2026-11-05

## What changed

Fixes all 47 bugs confirmed by the 2026-11-05 audit (MD/bugs.md, MD/bugfixed.md) and applies the HCI pass: centred headings and charts, a calling queue built around Call next / outcome / undo with progress, error messages by cause, counts that add up, real getcalley.com links.

## Why

A verified audit found 47 defects (9 user-visible S2) and 48 UX problems; the reviewer will compare against Figma and try the calling flow.

## How it was checked

flutter analyze 0 issues; flutter test 69 passed: 37 unit and real-router tests (including a regression test for B-01) and 32 snapshots regenerated and reviewed. Not yet run on a physical device.

## Next improvement

Run on a real Android phone (launchers, OTP keyboard, TalkBack); attach the release APKs to a GitHub release.
<!-- manual:end -->

## Files changed

- `calley_app/ios/Runner/Info.plist`
- `calley_app/lib/app/router.dart`
- `calley_app/lib/app/theme.dart`
- `calley_app/lib/core/network/api_client.dart`
- `calley_app/lib/core/providers.dart`
- `calley_app/lib/core/utils/launchers.dart`
- `calley_app/lib/core/utils/validators.dart`
- `calley_app/lib/core/widgets/app_text_field.dart`
- `calley_app/lib/core/widgets/cards.dart`
- `calley_app/lib/core/widgets/otp_input.dart`
- `calley_app/lib/core/widgets/primary_button.dart`
- `calley_app/lib/core/widgets/status_views.dart`
- `calley_app/lib/features/auth/auth_scaffold.dart`
- `calley_app/lib/features/auth/login_screen.dart`
- `calley_app/lib/features/auth/otp_screen.dart`
- `calley_app/lib/features/auth/register_screen.dart`
- `calley_app/lib/features/calls/calling_queue_screen.dart`
- `calley_app/lib/features/calls/disposition_sheet.dart`
- `calley_app/lib/features/dashboard/dashboard_screen.dart`
- `calley_app/lib/features/drawer/app_drawer.dart`
- `calley_app/lib/features/language/language_screen.dart`
- `calley_app/lib/features/lists/calling_lists_sheet.dart`
- `calley_app/lib/features/onboarding/getting_started_screen.dart`
- `calley_app/lib/features/settings/settings_screen.dart`
- `calley_app/lib/models/models.dart`
