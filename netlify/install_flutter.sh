#!/usr/bin/env bash

set -euo pipefail

# Install Flutter SDK to $HOME/flutter (stable channel)

if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

# Ensure flutter is usable and pre-cache web artifacts
flutter --version
flutter precache --web
flutter pub get

