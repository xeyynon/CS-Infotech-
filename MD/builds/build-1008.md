<!-- manual:start -->
# Build 1008: The app opens on the Calley loading animation and has a bigger icon

Date: 2026-11-05

## What changed

Instead of a blank white start-up, the app shows the page colour with the Calley mark, then the Calley loading animation while it reads its saved settings. The app icon now fills most of its square, and Android gets an adaptive icon.

## Why

Flutter's default start-up is a blank white screen, and the old icon's mark was small.

## How it was checked

flutter analyze clean; start-up tests and snapshots pass; Android debug build compiles. Not run on a physical phone; iOS not built.

## Next improvement

Look at the icon and start-up on a real Android and iPhone; swap in a high-resolution mark if one is available.
<!-- manual:end -->

## Files changed

- `calley_app/android/app/src/main/res/drawable-hdpi/launch_mark.png`
- `calley_app/android/app/src/main/res/drawable-mdpi/launch_mark.png`
- `calley_app/android/app/src/main/res/drawable-v21/launch_background.xml`
- `calley_app/android/app/src/main/res/drawable-xhdpi/launch_mark.png`
- `calley_app/android/app/src/main/res/drawable-xxhdpi/launch_mark.png`
- `calley_app/android/app/src/main/res/drawable-xxxhdpi/launch_mark.png`
- `calley_app/android/app/src/main/res/drawable/launch_background.xml`
- `calley_app/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- `calley_app/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`
- `calley_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png`
- `calley_app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png`
- `calley_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png`
- `calley_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png`
- `calley_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `calley_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png`
- `calley_app/android/app/src/main/res/values-night-v31/styles.xml`
- `calley_app/android/app/src/main/res/values-night/colors.xml`
- `calley_app/android/app/src/main/res/values-v31/styles.xml`
- `calley_app/android/app/src/main/res/values/colors.xml`
- `calley_app/android/app/src/main/res/values/ic_launcher_background.xml`
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
- `calley_app/ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `calley_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `calley_app/ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `calley_app/lib/app/bootstrap.dart`
- `calley_app/lib/main.dart`
