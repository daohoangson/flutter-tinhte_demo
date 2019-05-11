#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

flutter build apk --release
curl -F file=@build/app/outputs/apk/release/app-release.apk https://0x0.st
