<!-- manual:start -->
# Build 1005: The greeting card is redesigned and loading screens use the Calley animation

Date: 2026-11-05

## What changed

The greeting card is now deep navy in both themes with the person's initial, name, plan chip and a faint Calley mark, so it no longer washes out in dark mode. The dashboard, calling queue, progress and reminders screens wait behind the supplied Calley loading animation with a plain-words label instead of grey blocks.

## Why

The dark-theme card was pale blue with dark text and hard to read; the supplied loader gives waits the brand look.

## How it was checked

flutter analyze clean; 70 unit tests and 48 snapshot tests pass; light and dark snapshots of the card and both loaders checked by eye. Not run on a physical device.

## Next improvement

Run on a device and check the loader at large text sizes.
<!-- manual:end -->

## Files changed

- `calley_app/assets/loading/calley_loading_animation.json`
- `calley_app/lib/core/widgets/calley_loader.dart`
- `calley_app/lib/core/widgets/cards.dart`
- `calley_app/lib/features/calls/calling_queue_screen.dart`
- `calley_app/lib/features/dashboard/dashboard_screen.dart`
- `calley_app/lib/features/onboarding/getting_started_screen.dart`
- `calley_app/lib/features/progress/progress_screen.dart`
- `calley_app/lib/features/reminders/reminders_screen.dart`
- `calley_app/pubspec.lock`
- `calley_app/pubspec.yaml`
