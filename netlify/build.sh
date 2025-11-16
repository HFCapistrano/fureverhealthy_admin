#!/usr/bin/env bash

set -euo pipefail

# Use env var if set, otherwise default to a known stable version
FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.0}"

# Install location
FLUTTER_DIR="$HOME/flutter"

# Install Flutter if not already installed
if [ ! -d "$FLUTTER_DIR" ]; then
  mkdir -p "$HOME"
  echo "Downloading Flutter ${FLUTTER_VERSION}..."
  curl -sSLo /tmp/flutter_linux.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tar -xf /tmp/flutter_linux.tar.xz -C "$HOME"
  rm /tmp/flutter_linux.tar.xz
fi

# Ensure flutter is on PATH
export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"

# Verify flutter is available
which flutter || (echo "flutter not found on PATH" && exit 1)
flutter --version

# Setup Flutter
flutter channel stable
flutter upgrade --force
flutter config --enable-web
flutter precache --web

# Get dependencies
flutter pub get

# Build the web app
flutter build web --release

