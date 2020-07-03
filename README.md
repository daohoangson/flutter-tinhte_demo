# tinhte_demo

Tinh tế mobile apps built with Flutter for evaluation purposes.

## Try it

Google Play Store: [Open Beta Testing](https://play.google.com/apps/testing/com.daohoangson.flutter_ttdemo)

Apple App Store: [TestFlight](https://testflight.apple.com/join/4lGGYeSU)

## Features

### Home

- Primary list: home threads
  - Image
  - Poster
  - Post date
  - Short snippet
- Special blocks:
  - Feature pages
  - Top threads
  - Trending tags
- Actions:
  - Create new thread

### Login

- Username & password
- Apple login via [apple_sign_in](https://pub.dev/packages/apple_sign_in)
- Facebook login via [flutter_facebook_login](https://pub.dev/packages/flutter_facebook_login)
- Google login via [google_sign_in](https://pub.dev/packages/google_sign_in)

### Forum list

### Forum view / Node view

- Navigation
- Primary list: threads
  - Title
  - Image
  - Poster avatar, username
  - Post date
  - Short snippet
  - Counters: replies, likes
  - Actions: comment, like, share
  - Sticky thread banner
  - Special support: background post, TinhteFact
- Search in forum

### Member view

- User profile
  - Avatar
  - Username
  - Joined date
  - Message count
  - Like count
- Actions
  - Follow
  - Ignore
- Primary list: user's threads
- Search user contents

### My feed

### Notification list

- Primary list: notifications
- Push notification via [firebase_messaging](https://pub.dev/packages/firebase_messaging)
- Note: FCM support requires deployment of [Cloud Functions for Firebase](firebase/functions)

### Tag view / Feature page

- Tag info
  - Tag text
  - Image (fp only)
  - Use count
  - News count (fp only)
- Actions
  - Follow
- Primary list: tagged threads

### Thread view

- Navigation
- Poll
- Primary list: posts
  - Poster avatar, username
  - Post body
  - Post date
  - Attachments
  - Actions: like, reply, delete, open in browser, report
  - Replies
- Actions:
  - Font control
  - Bookmark
  - Open in browser
  - Share
  - Quick reply
    - Post body
    - Attachments

### Create new thread

- Forum picker
- Thread title
- Post body
- Attachments

### Others

- Dark mode: on / off / auto
- Localization (auto)
  - English
  - Tiếng Việt

## FAQ

### How to build the app?

All credentials are encrypted so you won't be able to compile the app immediately after a git pull.
You have to replace the files mentioned in [.gitattributes](https://github.com/daohoangson/flutter-tinhte_demo/blob/master/.gitattributes) to build.

For example, `lib/config.encrypted.dart` should look like below:

```dart
import 'package:tinhte_demo/src/config.dart';

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

- `android/app/build.gradle` applicationId, signingConfigs.release
- `android/app/google-services.json`
- `android/app/src/main/AndroidManifest.xml` package, android:label
- `android/app/src/main/res/values/strings.xml` app_name, facebook_app_id, fb_login_protocol_scheme
- `android/fastlane/metadata/android/en-US/` title.txt, full_description.txt, short_description.txt
- `android/fastlane/Appfile` package_name
- `android/release.jks`
- `firebase/.firebaserc` projects.default
- `ios/Runner.xcodeproj/project.pbxproj` PRODUCT_BUNDLE_IDENTIFIER x2
- `ios/Runner/GoogleService-Info.plist`
- `ios/Runner/Info.plist` CFBundleName, CFBundleURLSchemes, FacebookAppID, FacebookDisplayName
- `ios/fastlane/Appfile` app_identifier, apple_id, etc. (basically everything)
- `ios/fastlane/Matchfile` google_cloud_bucket_name
- `ios/gc_keys.json`

You will also need to move the files within `android/app/src/main/java/com/daohoangson/flutter_ttdemo` to another directory to match the new Android package.

For Firebase Messaging, execute these commands to set the proper config variables:

```bash
firebase functions:config:set websub.hub=https://domain.com/xenforo/api/index.php\?subscriptions

firebase functions:config:set websub.url=https://region-project.cloudfunctions.net/websub
```
