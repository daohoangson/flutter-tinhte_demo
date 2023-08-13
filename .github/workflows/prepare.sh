#!/bin/bash

set -eo pipefail

# 1. Unlock git-crypt
# We could not use the existing GitHub action because it doesn't support Windows
# https://github.com/sliteteam/github-action-git-crypt-unlock/blob/master/entrypoint.sh
if ! command -v git-crypt &>/dev/null; then
  brew install git-crypt
fi
echo "${GIT_CRYPT_KEY}" | base64 -d >./git-crypt-key
file lib/config.encrypted.dart
git-crypt unlock ./git-crypt-key
file lib/config.encrypted.dart
rm ./git-crypt-key

# 2. Patch app version with monotonic build number
_appVersion=$(yq e '.version' pubspec.yaml)
echo "_appVersion=${_appVersion}"
_appVersionWithBuildNumber=$(printf '.version="%s+%d"' "${_appVersion}" "${GITHUB_RUN_NUMBER}${GITHUB_RUN_ATTEMPT}")
echo "_appVersionWithBuildNumber=${_appVersionWithBuildNumber}"
yq --inplace e "$_appVersionWithBuildNumber" pubspec.yaml
cat pubspec.yaml

# 3. Expose Flutter version
if command -v wslpath &>/dev/null; then
  _wslGithubEnv=$(wslpath -u "$GITHUB_ENV")
  export "GITHUB_ENV=${_wslGithubEnv}"
fi
_flutterVersion=$(yq e '.environment.flutter' pubspec.yaml)
echo "FLUTTER_VERSION=${_flutterVersion}" | tee -a $GITHUB_ENV
