#!/bin/bash

set -eo pipefail

# Unlock git-crypt
if ! command -v git-crypt &>/dev/null; then
  brew install --verbose git-crypt
fi
# https://github.com/sliteteam/github-action-git-crypt-unlock/blob/master/entrypoint.sh
echo "${GIT_CRYPT_KEY}" | base64 --decode >./git-crypt-key
git-crypt unlock ./git-crypt-key
rm ./git-crypt-key

# Extract config from pubspec.yaml
if ! command -v yq &>/dev/null; then
  if ! command -v brew &>/dev/null; then
    _os=$(uname -s | tr '[:upper:]' '[:lower:]')
    _arch=amd64
    wget "https://github.com/mikefarah/yq/releases/download/v4.12.1/yq_${_os}_${_arch}" --quiet -O /usr/bin/yq && chmod +x /usr/bin/yq
  else
    brew install --verbose yq
  fi
fi
_appVersion=$(yq e '.version' pubspec.yaml)
_appVersionWithoutNumber=$(echo "${_appVersion}" | sed 's/+.*$//')

if ! command -v wslpath &>/dev/null; then
  echo "GITHUB_ENV=$GITHUB_ENV"
else
  _wslGithubEnv=$(wslpath -u "$GITHUB_ENV")
  export "GITHUB_ENV=${_wslGithubEnv}"
fi

echo "APP_VERSION=${_appVersion}" | tee -a $GITHUB_ENV
echo "BUILD_NAME=${_appVersionWithoutNumber}-${GITHUB_SHA:0:7}" | tee -a $GITHUB_ENV

_flutterVersion=$(yq e '.environment.flutter' pubspec.yaml)
echo "FLUTTER_VERSION=${_flutterVersion}" | tee -a $GITHUB_ENV
