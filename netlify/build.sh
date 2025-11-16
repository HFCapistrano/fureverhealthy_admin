#!/usr/bin/env bash

# Don't exit on error immediately - we want to capture full error output
set -uo pipefail

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

# Analyze code for issues
echo "Analyzing code..."
flutter analyze || echo "Analysis found issues, but continuing with build..."

# Build the web app with verbose output
echo "Building Flutter web app..."
echo "=========================================="
echo "Starting Flutter web build..."
echo "=========================================="

# Build the web app (Flutter 3.38+ doesn't use --web-renderer flag)
echo "Building Flutter web app..."
if flutter build web --release 2>&1; then
    echo "=========================================="
    echo "Build completed successfully!"
    echo "=========================================="
    exit 0
fi

echo "=========================================="
echo "All build attempts failed. Check errors above."
echo "=========================================="
exit 1

