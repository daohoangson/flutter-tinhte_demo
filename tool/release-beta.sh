#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."
_pwd=$( pwd )

if [ -z "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" ]; then
  echo 'Env var FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD must be set' >&2
  exit 1
fi

if [ -z "$PILOT_BETA_APP_REVIEW_INFO" ]; then
  # export PILOT_BETA_APP_REVIEW_INFO='{"contact_email":"admin@domain.com","contact_first_name":"First","contact_last_name":"Last","contact_phone":"0123456789","demo_account_name":"username","demo_account_password":"password"}'
  echo 'Env var PILOT_BETA_APP_REVIEW_INFO must be set' >&2
  exit 1
fi

cd "$_pwd"
flutter build appbundle --release
cd android && fastlane beta

cd "$_pwd"
flutter build ios --release --no-codesign
cd ios && fastlane beta

echo Done
