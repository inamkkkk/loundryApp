#!/bin/bash

# LaundryFlow Project Repair Script

echo "🛠️  Starting Project Repair..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter command not found! Please ensure Flutter is in your PATH."
    exit 1
fi

echo "📦 Installing Dependencies..."
flutter pub get

echo "🧱 Generating Code (Freezed, Riverpod)..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Repair Complete! The errors should now be resolved."
