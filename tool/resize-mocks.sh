#!/bin/bash

set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

cd ./packages/api_test/mocks

# `sips` is smart enough to not resize correctly sized image
# so it's safe to run this commands again and again
find attachments -type f -name '*.jpg' -exec sips -Z 100 {} \;
find data/attachment-files -type f -name '*.jpg' -exec sips -Z 100 {} \;
find tinhte2 -type f -name '*.jpg' -exec sips -Z 100 {} \;
find vi -type f -name '*.jpg' -exec sips -Z 100 {} \;
