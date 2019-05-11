#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

flutter build apk --debug
curl -F file=@build/app/outputs/apk/debug/app-debug.apk https://0x0.st
