#!/bin/bash

# KitchaApp Production Build Script (v2.0.0)
# Usage: ./scripts/build_release.sh [apk|appbundle]

TYPE=$1
if [ -z "$TYPE" ]; then
  TYPE="appbundle"
fi

echo "🚀 Starting KitchaApp Production Build ($TYPE)..."

# Load environment variables if available
if [ -f .env.production ]; then
  source .env.production
fi

# Get version from pubspec.yaml
VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
echo "📦 Version: $VERSION"

# Clean
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build
if [ "$TYPE" == "apk" ]; then
  echo "🛠️ Building APK..."
  flutter build apk --release \
    --dart-define=ENV=production \
    --dart-define=SENTRY_DSN=$SENTRY_DSN \
    --dart-define=MEM0_API_KEY=$MEM0_API_KEY \
    --dart-define=SPOONACULAR_API_KEY=$SPOONACULAR_API_KEY
else
  echo "🛠️ Building AppBundle..."
  flutter build appbundle --release \
    --dart-define=ENV=production \
    --dart-define=SENTRY_DSN=$SENTRY_DSN \
    --dart-define=MEM0_API_KEY=$MEM0_API_KEY \
    --dart-define=SPOONACULAR_API_KEY=$SPOONACULAR_API_KEY
fi

# Success check
if [ $? -eq 0 ]; then
  echo "✅ Build completed successfully!"
  if [ "$TYPE" == "apk" ]; then
    echo "📍 APK: build/app/outputs/flutter-apk/app-release.apk"
  else
    echo "📍 AppBundle: build/app/outputs/bundle/release/app-release.aab"
  fi
else
  echo "❌ Build failed!"
  exit 1
fi
