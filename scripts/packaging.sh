#!/bin/bash

# FlacMusicApp IPA Packaging Script
# Usage: ./scripts/packaging.sh [app_name]

set -e

APP_NAME="${1:-FlacMusicApp-iOS}"
ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives"
OUTPUT_DIR="."

echo "🔍 Searching for archive..."
ARCHIVE_PATH=$(find "$ARCHIVE_DIR" -name "*.xcarchive" -type d 2>/dev/null | grep "$APP_NAME" | head -1)

if [ -z "$ARCHIVE_PATH" ]; then
    echo "❌ Archive not found for: $APP_NAME"
    echo "📂 Available archives:"
    find "$ARCHIVE_DIR" -name "*.xcarchive" -type d 2>/dev/null | head -10
    exit 1
fi

echo "✅ Found archive: $ARCHIVE_PATH"

echo "📦 Extracting app..."
PRODUCTS_PATH="$ARCHIVE_PATH/Products/Applications"
if [ ! -d "$PRODUCTS_PATH" ]; then
    echo "❌ Products folder not found"
    exit 1
fi

APP_PATH=$(find "$PRODUCTS_PATH" -name "*.app" -type d | head -1)
if [ -z "$APP_PATH" ]; then
    echo "❌ App not found in archive"
    exit 1
fi

echo "✅ App: $APP_PATH"

echo "📱 Creating IPA..."
mkdir -p Payload
cp -r "$APP_PATH" Payload/
zip -r "${APP_NAME}.ipa" Payload/
rm -rf Payload

echo "✅ IPA created: ${APP_NAME}.ipa"
ls -lh "${APP_NAME}.ipa"
