#!/bin/sh

set -e

git submodule update --init

( cd packages/api && flutter pub get )

( \
  cd packages/flutter_widget_from_html && flutter pub get \
  && ( cd packages/core && flutter pub get ) \
  && ( cd packages/example && flutter pub get ) \
)
