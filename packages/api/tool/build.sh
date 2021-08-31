#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

flutter pub get

exec flutter packages pub run build_runner build --delete-conflicting-outputs
