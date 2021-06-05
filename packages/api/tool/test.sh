#!/bin/bash

set -eo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

exec flutter packages pub run test -r expanded
