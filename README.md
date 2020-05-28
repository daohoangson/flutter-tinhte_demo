# tinhte_demo

Tinh tế mobile apps built with Flutter for evaluation purposes.

## Try it

Google Play Store: [Open Beta Testing](https://play.google.com/apps/testing/com.daohoangson.flutter_ttdemo)

Apple App Store: [TestFlight](https://testflight.apple.com/join/4lGGYeSU)

## Screens

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
  - Open in browser
  - Share
  - Quick reply
