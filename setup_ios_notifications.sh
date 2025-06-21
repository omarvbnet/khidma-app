#!/bin/bash

echo "🚀 iOS Notification Setup Script for Waddiny"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "waddiny/pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo "📱 Setting up iOS notifications..."

# Navigate to iOS directory
cd waddiny/ios

echo "🔧 Installing pods..."
pod install

if [ $? -eq 0 ]; then
    echo "✅ Pods installed successfully"
else
    echo "❌ Failed to install pods"
    exit 1
fi

# Go back to project root
cd ../..

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🔨 Building iOS project..."
flutter build ios --no-codesign

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open waddiny/ios/Runner.xcworkspace in Xcode"
echo "2. Go to Signing & Capabilities tab"
echo "3. Add 'Push Notifications' capability"
echo "4. Verify your Bundle Identifier matches your App ID"
echo "5. Test on a physical iOS device"
echo ""
echo "📖 For detailed setup instructions, see: APPLE_DEVELOPER_NOTIFICATION_SETUP.md"
echo ""
echo "🔍 To test notifications:"
echo "1. Run: flutter run"
echo "2. Navigate to notification test screen"
echo "3. Try 'Test Force Notification' button"
echo "" 