#!/usr/bin/env bash

set -euo pipefail

# Install location
FLUTTER_DIR="$HOME/flutter"

# Install Flutter if not already installed
if [ ! -d "$FLUTTER_DIR" ]; then
  mkdir -p "$HOME"
  echo "Installing Flutter (stable channel)..."
  # Use git clone for more reliable installation
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

# Ensure flutter is on PATH
export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"

# Verify flutter is available
which flutter || (echo "flutter not found on PATH" && exit 1)
flutter --version

# Setup Flutter
echo "Setting up Flutter..."
flutter channel stable || true
flutter upgrade --force || true
flutter config --enable-web
flutter doctor -v
flutter precache --web

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies again after clean
flutter pub get

# Build the web app with verbose output
echo "Building Flutter web app..."
flutter build web --release --verbose 2>&1 || {
    echo "Build failed. Showing detailed error:"
    flutter build web --release 2>&1
    exit 1
}

