#!/bin/sh

exec flutter pub pub run intl_generator:extract_to_arb \
  --output-dir=lib/l10n \
  lib/src/intl.dart
