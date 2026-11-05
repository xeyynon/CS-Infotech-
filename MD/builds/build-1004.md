<!-- manual:start -->
# Build 1004: The app now carries its build number: 1.0.0 (build 1004)

Date: 2026-11-05

## What changed

The project's build number is the +N in pubspec.yaml (Android versionCode, iOS build number) and is shown in the drawer's Version row, the Settings footer and the Send Logs report, so an APK or installed app can be matched to its git tag and commit.

## Why

Every APK reported 1.0.0+1 whatever it contained; a support log or screenshot could not say which build it came from.

## How it was checked

flutter analyze 0 issues; flutter test passes incl. a drift test between pubspec and build_info.dart; drawer, Settings and Send Logs snapshots reviewed.

## Next improvement

Merge the branch; attach the release APKs to a GitHub release.
<!-- manual:end -->

## Files changed

- `calley_app/lib/core/build_info.dart`
- `calley_app/lib/features/drawer/app_drawer.dart`
- `calley_app/lib/features/settings/settings_screen.dart`
- `calley_app/lib/features/support/support_sheets.dart`
