# How to release

## Android

https://flutter.dev/docs/deployment/android

```bash
flutter build apk --release
cd android && fastlane beta
```

## iOS

https://flutter.dev/docs/deployment/ios

```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=xxx

flutter build ios --release --no-codesign
cd ios && fastlane beta
```

Visit [App Store Connect](https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app) to continue.
