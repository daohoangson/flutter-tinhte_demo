#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

_path=./build/app/outputs/apk/release/app-arm64-v8a-release.apk
rm -f $_path

flutter build apk --release --target-platform android-arm64 --split-per-abi
curl -F file=@$_path https://0x0.st
