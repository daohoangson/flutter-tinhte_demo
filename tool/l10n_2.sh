#!/bin/sh

exec flutter pub pub run intl_generator:generate_from_arb \
  --output-dir=lib/l10n \
  --no-use-deferred-loading \
  lib/src/intl.dart \
  lib/l10n/intl_*.arb
