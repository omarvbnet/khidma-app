#!/bin/bash

echo "🔥 Firebase Notification Testing Script"
echo "========================================"

# Check if we're in the right directory
if [ ! -d "waddiny" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

cd waddiny

echo ""
echo "📱 Checking Firebase Configuration Files..."

# Check for GoogleService-Info.plist
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist found in ios/Runner/"
else
    echo "❌ GoogleService-Info.plist not found in ios/Runner/"
    echo "   Please ensure the file is in the correct location"
fi

# Check for google-services.json
if [ -f "android/app/google-services.json" ]; then
    echo "✅ google-services.json found in android/app/"
else
    echo "❌ google-services.json not found in android/app/"
    echo "   Please ensure the file is in the correct location"
fi

echo ""
echo "📦 Checking Dependencies..."

# Check if Firebase dependencies are in pubspec.yaml
if grep -q "firebase_core" pubspec.yaml; then
    echo "✅ firebase_core dependency found"
else
    echo "❌ firebase_core dependency not found"
fi

if grep -q "firebase_messaging" pubspec.yaml; then
    echo "✅ firebase_messaging dependency found"
else
    echo "❌ firebase_messaging dependency not found"
fi

echo ""
echo "🔧 Building Project..."

# Clean and get dependencies
echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo ""
echo "📱 Building iOS App..."

# Build iOS app
if flutter build ios --debug; then
    echo "✅ iOS build successful"
else
    echo "❌ iOS build failed"
    exit 1
fi

echo ""
echo "🎯 Testing Steps:"
echo "1. Install the app on your iOS device"
echo "2. Open the app and navigate to Notification Test screen"
echo "3. Check that FCM token is generated"
echo "4. Test local notifications"
echo "5. Test Firebase notifications"
echo "6. Verify permissions are granted"

echo ""
echo "📋 Manual Testing Checklist:"
echo "□ FCM token is generated and displayed"
echo "□ Local notification test works"
echo "□ Firebase notification test works"
echo "□ Trip status notification test works"
echo "□ Permission check works"
echo "□ Device token refresh works"

echo ""
echo "🔍 Debug Information:"
echo "• Check console logs for Firebase initialization messages"
echo "• Verify notification permissions in iOS Settings"
echo "• Test with app in foreground and background"
echo "• Check server logs for notification delivery"

echo ""
echo "📚 Documentation:"
echo "• See FIREBASE_NOTIFICATION_TESTING.md for detailed guide"
echo "• Check APPLE_DEVELOPER_NOTIFICATION_SETUP.md for setup instructions"

echo ""
echo "✅ Testing script completed!"
echo "Please run the app and test notifications manually." 