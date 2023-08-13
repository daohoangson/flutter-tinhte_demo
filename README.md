# tinhte_demo

Tinh tế mobile apps built with Flutter for evaluation purposes.

## Try it

Google Play Store: [Open Beta Testing](https://play.google.com/apps/testing/com.daohoangson.flutter_ttdemo)

Apple App Store: [TestFlight](https://testflight.apple.com/join/4lGGYeSU)

Or check the PR / commit comments, this repo has GitHub Actions setup to build and
upload the apps to GCS (automatically deleted after 30 days).

## Features

- Supported platforms: Android, iOS, Linux, macOS, Windows
- State management with [provider](https://pub.dev/packages/provider)
- Apple login via [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)
- Google login via [google_sign_in](https://pub.dev/packages/google_sign_in)
- Store authentication token with [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- Render HTML with [flutter_widget_from_html](https://pub.dev/packages/flutter_widget_from_html)
- Push notification via [firebase_messaging](https://pub.dev/packages/firebase_messaging)
- Dark mode: on / off / auto
- Developer hidden menu (tap "Version" thrice)
- Android, iOS domain association with [built-in deep link support](https://docs.flutter.dev/ui/navigation/deep-linking)

## FAQ

### How to build the app?

All credentials are encrypted so you won't be able to compile the app immediately after a git pull.
You have to replace the files mentioned in [.gitattributes](https://github.com/daohoangson/flutter-tinhte_demo/blob/master/.gitattributes) to build.

For example, `lib/config.encrypted.dart` should look like below:

```dart
import 'package:the_app/src/config.dart';

class Config extends ConfigBase {
  @override
  final apiRoot = 'https://domain.com/community/api/index.php';

  @override
  final clientId = 'abc';

  @override
  final clientSecret = 'xyz';

  @override
  final siteRoot = 'https://domain.com/community';
}
```

See [How to use another package name?](#how-to-use-another-package-name) for more information to rename the app.

### How to support a new language?

1. Translate the `lib/l10n/intl_messages.arb` into your new language. Save it as `/lib/l10n/intl_(language_code).arb`.
1. Execute `./tool/l10n_2.sh` to generate l10n files
1. Update `supportedLocales` param in `lib/main.dart`
1. Update `isSupported` method in `lib/src/intl.dart`
1. Update `CFBundleLocalizations` in `ios/Runner/Info.plist` to include the new language code

### How to use another package name?

Pick a unique package name across Play Store and App Store then update these files:

- `.github/workflows/flutter.yml` GCS_BUCKET, GCS_URL
- `android/app/build.gradle` applicationId, signingConfigs.release
- `android/app/src/main/AndroidManifest.xml` package, android:label
- `android/app/src/main/res/values/strings.xml` app_name
- `android/fastlane/metadata/android/en-US/` title.txt, full_description.txt, short_description.txt
- `android/fastlane/Appfile`
- `firebase/.firebaserc` projects.default
- `ios/Runner.xcodeproj/project.pbxproj` PRODUCT_BUNDLE_IDENTIFIER x2, PROVISIONING_PROFILE_SPECIFIER x2
- `ios/Runner/Info.plist` CFBundleName, CFBundleURLSchemes
- `ios/fastlane/Appfile`
- `ios/fastlane/Fastfile` xcargs (PROVISIONING_PROFILE_SPECIFIER), manifest (appURL, displayImageURL, fullSizeImageURL)
- `ios/fastlane/Matchfile`
- `linux/CMakeLists.txt` APPLICATION_ID
- `macos/Runner/Configs/AppInfo.xcconfig`
- `macos/Runner.xcodeproj/project.pbxproj` PROVISIONING_PROFILE_SPECIFIER x3
- `macos/fastlane/Appfile`
- `macos/fastlane/Fastfile` notarize
- `macos/fastlane/Matchfile`
- `windows/runner/Runner.rc`
- `pubspec.yaml` msix_config>identity_name
- Re-run `flutterfire configure` to update Firebase apps

You will also need to move the files within `android/app/src/main/java/com/daohoangson/flutter_ttdemo` to another directory to match the new Android package.

For Firebase Messaging, execute these commands to set the proper config variables:

```bash
firebase functions:config:set websub.hub=https://domain.com/xenforo/api/index.php\?subscriptions

firebase functions:config:set websub.url=https://region-project.cloudfunctions.net/websub
```
