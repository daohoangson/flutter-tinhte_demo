#!/bin/bash

set -eo pipefail

# Unlock git-crypt
if ! command -v git-crypt &>/dev/null; then
  brew install git-crypt
fi
# https://github.com/sliteteam/github-action-git-crypt-unlock/blob/master/entrypoint.sh
echo "${GIT_CRYPT_KEY}" | base64 -d >./git-crypt-key
file lib/config.encrypted.dart
git-crypt unlock ./git-crypt-key
file lib/config.encrypted.dart
rm ./git-crypt-key

# Extract config from pubspec.yaml
if ! command -v yq &>/dev/null; then
  brew install yq
fi

_appVersion=$(yq e '.version' pubspec.yaml)
echo "_appVersion=${_appVersion}"
_appVersionWithBuildNumber=$(printf '.version="%s+%d"' "${_appVersion}" "${GITHUB_RUN_NUMBER}${GITHUB_RUN_ATTEMPT}")
echo "_appVersionWithBuildNumber=${_appVersionWithBuildNumber}"
yq --inplace e "$_appVersionWithBuildNumber" pubspec.yaml
cat pubspec.yaml

if command -v wslpath &>/dev/null; then
  _wslGithubEnv=$(wslpath -u "$GITHUB_ENV")
  export "GITHUB_ENV=${_wslGithubEnv}"
fi

_flutterVersion=$(yq e '.environment.flutter' pubspec.yaml)
echo "FLUTTER_VERSION=${_flutterVersion}" | tee -a $GITHUB_ENV
