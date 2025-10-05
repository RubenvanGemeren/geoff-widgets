#!/bin/bash

echo "🚀 Setting up Geoff Widgets Flutter App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Clean and get dependencies
echo "📦 Installing dependencies..."
flutter clean
flutter pub get

# Generate required files
echo "🔧 Generating required files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for connected devices
echo "📱 Checking for connected devices..."
flutter devices

echo ""
echo "🎉 Setup complete! You can now run the app with:"
echo "   flutter run"
echo ""
echo "📋 Quick commands:"
echo "   flutter run                    # Run on connected device"
echo "   flutter run --debug           # Run in debug mode"
echo "   flutter build apk --release  # Build release APK"
echo "   flutter clean                 # Clean build cache"
echo ""
echo "🔧 For Android tablet deployment:"
echo "   1. Enable Developer Options on your tablet"
echo "   2. Enable USB Debugging"
echo "   3. Connect via USB cable"
echo "   4. Run 'flutter run'"
