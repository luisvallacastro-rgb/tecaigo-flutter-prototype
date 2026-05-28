#!/usr/bin/env bash
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_HOME="${HOME}/flutter"

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git \
    --branch "${FLUTTER_CHANNEL}" \
    --depth 1 \
    "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

flutter config --enable-web
flutter pub get
flutter build web --release --base-href /
