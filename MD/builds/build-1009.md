<!-- manual:start -->
# Build 1009: The Undo message no longer stays on screen, and the tutorial shows its real length

Date: 2026-11-05

## What changed

After logging a call outcome, the Undo message now disappears after six seconds instead of staying up and following you to other screens. Undo is as bright as the message. The tutorial card says 5:13, the length of the video it plays.

## Why

Found by using the app on a real phone: with an action, a snackbar was never dismissed, and the tutorial label said 2:00 for a 5:13 video.

## How it was checked

A test fails without the fix and passes with it; flutter analyze clean; 81 unit tests and 52 snapshot tests pass; release build installed and used on a Samsung Galaxy S23 Ultra.

## Next improvement

Re-record the demo from this build.
<!-- manual:end -->

## Files changed

- `calley_app/lib/app/theme.dart`
- `calley_app/lib/core/widgets/tutorial_video.dart`
- `calley_app/lib/features/calls/call_actions.dart`
