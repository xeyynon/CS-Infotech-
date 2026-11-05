<!-- manual:start -->
# Build 1007: Sign-in puts its button before the detour, the dashboard shows each figure once, and outcomes have icons

Date: 2026-11-05

## What changed

On Sign In and Sign Up the primary button now follows the fields and the switch-form link comes after it. The dashboard drops the ring legend that repeated the stat strip; the strip now shows each status share and uses the ring's order. Outcome choices carry an icon and colour beside the word, and an expanded contact leaves out rows with no data.

## Why

A second pass using HCI principles: task flow, one home per fact, recognition over recall, say only what is known.

## How it was checked

flutter analyze clean; 80 unit tests and 52 snapshot tests pass; light and dark snapshots of the changed screens checked by eye.

## Next improvement

Run through the calling loop on a physical phone.
<!-- manual:end -->

## Files changed

- `calley_app/lib/core/widgets/cards.dart`
- `calley_app/lib/features/auth/login_screen.dart`
- `calley_app/lib/features/auth/register_screen.dart`
- `calley_app/lib/features/calls/calling_queue_screen.dart`
- `calley_app/lib/features/calls/disposition_sheet.dart`
- `calley_app/lib/features/dashboard/dashboard_screen.dart`
