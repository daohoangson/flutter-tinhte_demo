#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."
_pwd=$( pwd )

if [ -z "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" ]; then
  echo 'Env var FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD must be set' >&2
  exit 1
fi

cd "$_pwd"
flutter build apk --release
cd android && fastlane beta

cd "$_pwd"
flutter build ios --release --no-codesign
cd ios && fastlane beta

echo Done
