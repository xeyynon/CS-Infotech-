<!-- manual:start -->
# Build 1000: The Calley app: nine screens, the mock API client, and sample data when the server is down

Date: 2026-11-03

## What changed

A Flutter build of the Calley onboarding and dashboard from the Figma file: language, register, OTP, login, getting started, dashboard (empty and active), calling lists, settings, drawer, and a calling queue with a dialer and disposition sheet. Talks to the mock API with a pinned certificate; when the server cannot be reached it says so and offers labelled sample data.

## Why

Machine test for the Flutter Mobile App Developer role at C S Tech Infosolutions. The mock API host answers 404 on every path, so the app must stay usable and honest without it.

## How it was checked

flutter analyze: 0 issues. 32 snapshot tests (every screen, light and dark) pass and their PNGs were reviewed by eye. The certificate pin and the 404s were confirmed with a standalone Dart probe. Not yet run on a physical device.

## Next improvement

Run on a real Android phone: tel: and WhatsApp launchers, the OTP keyboard, the pinned-cert path. Attach the APK to a release.
<!-- manual:end -->

## Files changed

- `.gitattributes`
- `.gitignore`
- `calley_app/.gitignore`
- `calley_app/.metadata`
- `calley_app/README.md`
- `calley_app/analysis_options.yaml`
- `calley_app/android/.gitignore`
- `calley_app/android/app/build.gradle.kts`
- `calley_app/android/app/src/debug/AndroidManifest.xml`
- `calley_app/android/app/src/main/AndroidManifest.xml`
- `calley_app/android/app/src/main/kotlin/in/cstech/calley_app/MainActivity.kt`
- `calley_app/android/app/src/main/res/drawable-v21/launch_background.xml`
- `calley_app/android/app/src/main/res/drawable/launch_background.xml`
- `calley_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/values-night/styles.xml`
- `calley_app/android/app/src/main/res/values/styles.xml`
- `calley_app/android/app/src/profile/AndroidManifest.xml`
- `calley_app/android/build.gradle.kts`
- `calley_app/android/gradle.properties`
- `calley_app/android/gradle/wrapper/gradle-wrapper.properties`
- `calley_app/android/settings.gradle.kts`
- `calley_app/assets/fonts/BricolageGrotesque-500.ttf`
- `calley_app/assets/fonts/BricolageGrotesque-600.ttf`
- `calley_app/assets/fonts/BricolageGrotesque-700.ttf`
- `calley_app/assets/fonts/BricolageGrotesque-800.ttf`
- `calley_app/assets/fonts/IBMPlexMono-400.ttf`
- `calley_app/assets/fonts/IBMPlexMono-500.ttf`
- `calley_app/assets/fonts/IBMPlexMono-600.ttf`
- `calley_app/assets/fonts/Inter-400.ttf`
- `calley_app/assets/fonts/Inter-500.ttf`
- `calley_app/assets/fonts/Inter-600.ttf`
- `calley_app/assets/fonts/Inter-700.ttf`
- `calley_app/assets/fonts/Inter-800.ttf`
- `calley_app/assets/mock/list_details.json`
- `calley_app/assets/mock/lists.json`
- `calley_app/assets/mock/user.json`
- `calley_app/ios/.gitignore`
- `calley_app/ios/Flutter/AppFrameworkInfo.plist`
- `calley_app/ios/Flutter/Debug.xcconfig`
- `calley_app/ios/Flutter/Release.xcconfig`
- `calley_app/ios/Runner.xcodeproj/project.pbxproj`
- `calley_app/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `calley_app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `calley_app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `calley_app/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `calley_app/ios/Runner.xcworkspace/contents.xcworkspacedata`
- `calley_app/ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `calley_app/ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `calley_app/ios/Runner/AppDelegate.swift`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`
- `calley_app/ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `calley_app/ios/Runner/Base.lproj/Main.storyboard`
- `calley_app/ios/Runner/Info.plist`
- `calley_app/ios/Runner/Runner-Bridging-Header.h`
- `calley_app/ios/Runner/SceneDelegate.swift`
- `calley_app/ios/RunnerTests/RunnerTests.swift`
- `calley_app/lib/app/app.dart`
- `calley_app/lib/app/router.dart`
- `calley_app/lib/app/theme.dart`
- `calley_app/lib/core/network/api_client.dart`
- `calley_app/lib/core/network/calley_api.dart`
- `calley_app/lib/core/providers.dart`
- `calley_app/lib/core/storage/session_store.dart`
- `calley_app/lib/core/utils/formatters.dart`
- `calley_app/lib/core/utils/launchers.dart`
- `calley_app/lib/core/utils/validators.dart`
- `calley_app/lib/core/widgets/app_text_field.dart`
- `calley_app/lib/core/widgets/bottom_bar.dart`
- `calley_app/lib/core/widgets/calley_logo.dart`
- `calley_app/lib/core/widgets/cards.dart`
- `calley_app/lib/core/widgets/donut_chart.dart`
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
- `calley_app/lib/features/language/languages.dart`
- `calley_app/lib/features/lists/calling_lists_sheet.dart`
- `calley_app/lib/features/onboarding/getting_started_screen.dart`
- `calley_app/lib/features/settings/settings_screen.dart`
- `calley_app/lib/main.dart`
- `calley_app/lib/models/models.dart`
- `calley_app/pubspec.lock`
- `calley_app/pubspec.yaml`
