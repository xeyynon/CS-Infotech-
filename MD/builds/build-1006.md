<!-- manual:start -->
# Build 1006: Getting Started separates the upload note from the greeting and plays the tutorial in the app

Date: 2026-11-05

## What changed

The upload instructions are now a light card with a label, icon and the web-panel link, so they no longer look like a second navy greeting card. The tutorial card plays the video inside the app (Play here, Hide video) and has an Open in YouTube button for the YouTube app or browser.

## Why

The two cards looked alike, and the tutorial could only be opened outside the app.

## How it was checked

flutter analyze clean; 74 unit tests and 50 snapshot tests pass; light and dark snapshots checked by eye. The real in-app player was not run on a device (tests use a stand-in).

## Next improvement

Check playback, fullscreen and the offline case on a physical device.
<!-- manual:end -->

## Files changed

- `calley_app/lib/core/utils/launchers.dart`
- `calley_app/lib/core/widgets/tutorial_video.dart`
- `calley_app/lib/features/onboarding/getting_started_screen.dart`
- `calley_app/pubspec.lock`
- `calley_app/pubspec.yaml`
