<!-- manual:start -->
# Build 1003: Working Gamification, Reminders, Send Logs, Share App and Cancel Subscription

Date: 2026-11-05

## What changed

The drawer items and the bell that were stubs are now features: Your progress (level, outcomes, badges), Reminders behind a bell badge, Send Logs with a visible privacy-safe report, Share App through the system share sheet, and an honest Cancel Subscription flow.

## Why

A reviewer tapping the drawer should find working screens, built only from real list data and outcomes logged on the phone (DEC-018).

## How it was checked

flutter analyze 0 issues; flutter test 107 passed incl. behavior tests for share, mail, the bell and Reminders; 18 new snapshots reviewed in light and dark. Not yet run on a physical device.

## Next improvement

Merge to main; rebuild the APKs; later branches for language switching and auto-dial.
<!-- manual:end -->

## Files changed

- `calley_app/lib/app/router.dart`
- `calley_app/lib/core/providers.dart`
- `calley_app/lib/core/utils/launchers.dart`
- `calley_app/lib/core/widgets/calley_logo.dart`
- `calley_app/lib/features/calls/call_actions.dart`
- `calley_app/lib/features/calls/calling_queue_screen.dart`
- `calley_app/lib/features/dashboard/dashboard_screen.dart`
- `calley_app/lib/features/drawer/app_drawer.dart`
- `calley_app/lib/features/progress/progress_screen.dart`
- `calley_app/lib/features/progress/progress_stats.dart`
- `calley_app/lib/features/reminders/reminders.dart`
- `calley_app/lib/features/reminders/reminders_screen.dart`
- `calley_app/lib/features/support/log_report.dart`
- `calley_app/lib/features/support/support_sheets.dart`
- `calley_app/pubspec.lock`
- `calley_app/pubspec.yaml`
