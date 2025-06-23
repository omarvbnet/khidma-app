# Release Mode Background Notifications Guide

## Problem
Background notifications work in debug mode but fail in release mode. This is a common issue with Flutter apps using Firebase Cloud Messaging.

## Root Causes & Solutions

### 1. APS Environment Configuration

**Problem**: Debug mode uses development APS environment, but release mode needs production.

**Solution**: ✅ Fixed
- Updated `Runner.entitlements` to use `production` APS environment
- Created `RunnerRelease.entitlements` for release builds
- Debug entitlements remain with `development` environment

### 2. Background Message Handler Registration

**Problem**: Background message handler might not be properly registered in release mode.

**Solution**: ✅ Fixed
- Enhanced background message handler with better error handling
- Added comprehensive logging for debugging
- Ensured handler is registered before other Firebase operations

### 3. iOS AppDelegate Configuration

**Problem**: AppDelegate might not handle background notifications properly in release mode.

**Solution**: ✅ Fixed
- Enhanced AppDelegate with better notification handling
- Added silent notification processing
- Improved permission requests
- Added notification categories

### 4. Firebase Configuration

**Problem**: Firebase might not be properly initialized in release mode.

**Solution**: ✅ Fixed
- Enhanced Firebase initialization with error handling
- Added verification steps for Firebase messaging
- Improved token handling

## Testing Steps

### Step 1: Build Release Version

```bash
# Clean the project
cd waddiny
flutter clean

# Get dependencies
flutter pub get

# Build iOS release version
flutter build ios --release

# Or build for specific device
flutter build ios --release --target-platform ios-arm64
```

### Step 2: Install Release Version

```bash
# Install on connected device
flutter install --release

# Or use Xcode to install
open ios/Runner.xcworkspace
# Then Archive and distribute
```

### Step 3: Test Notifications

1. **Foreground Test**: Open the app and send a notification
2. **Background Test**: Put app in background and send notification
3. **Closed Test**: Close the app completely and send notification

### Step 4: Use Test Script

```bash
# Install dependencies
npm install axios

# Update the script with your backend URL and user ID
# Edit waddiny/scripts/test-release-notifications.js

# Test all notification types
node scripts/test-release-notifications.js all

# Test specific notification
node scripts/test-release-notifications.js trip
```

## Debugging Release Mode

### 1. Check Console Logs

In Xcode:
1. Window → Devices and Simulators
2. Select your device
3. View Device Logs
4. Filter by your app name

### 2. Check Notification Permissions

```dart
// Add this to your app to check permissions
Future<void> checkNotificationPermissions() async {
  if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    print('📱 Notification Settings:');
    print('- Authorization Status: ${settings.authorizationStatus}');
    print('- Alert: ${settings.alert}');
    print('- Badge: ${settings.badge}');
    print('- Sound: ${settings.sound}');
  }
}
```

### 3. Verify Device Token

```dart
// Check if device token is properly registered
Future<void> verifyDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print('🔥 FCM Token: $token');
  
  // Check if token is saved
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('fcm_token');
  print('💾 Saved Token: $savedToken');
  
  // Check if token matches
  print('✅ Token Match: ${token == savedToken}');
}
```

## Common Issues & Fixes

### Issue 1: "No notifications received"

**Check**:
- Device token is properly registered
- Backend is sending to correct token
- APS environment is correct for build type
- App has notification permissions

**Fix**:
```bash
# Re-register device token
flutter clean
flutter pub get
flutter build ios --release
flutter install --release
```

### Issue 2: "Notifications only work in foreground"

**Check**:
- Background message handler is registered
- AppDelegate handles background notifications
- Background modes are properly configured

**Fix**:
- Verify `FirebaseMessaging.onBackgroundMessage` is called in main()
- Check AppDelegate background notification methods
- Ensure Info.plist has proper background modes

### Issue 3: "Silent notifications not working"

**Check**:
- AppDelegate processes silent notifications
- Background fetch is enabled
- Data-only messages are handled

**Fix**:
- Verify silent notification handling in AppDelegate
- Check background fetch configuration
- Test with data-only messages

## Backend Configuration

### 1. Firebase Admin SDK

Ensure your backend has proper Firebase configuration:

```javascript
// Example backend notification sending
const admin = require('firebase-admin');

admin.messaging().send({
  token: deviceToken,
  notification: {
    title: 'New Trip Available!',
    body: 'A new trip request is waiting for you'
  },
  data: {
    type: 'NEW_TRIP_AVAILABLE',
    screen: 'driver_waiting',
    timestamp: new Date().toISOString()
  },
  apns: {
    payload: {
      aps: {
        'content-available': 1, // For silent notifications
        'mutable-content': 1
      }
    }
  }
});
```

### 2. Environment Variables

Ensure these are set in your backend:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`

## Verification Checklist

- [ ] App builds in release mode without errors
- [ ] Device token is generated and saved
- [ ] Backend receives and stores device token
- [ ] Foreground notifications work
- [ ] Background notifications work
- [ ] Silent notifications work
- [ ] App launches from notification tap
- [ ] Notification permissions are granted
- [ ] APS environment is correct for build type

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [iOS Push Notifications Guide](https://developer.apple.com/documentation/usernotifications)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)

## Support

If issues persist after following this guide:

1. Check Xcode device logs for detailed error messages
2. Verify Firebase project configuration
3. Test with a simple notification payload
4. Compare debug vs release build configurations
5. Check Apple Developer account push notification settings 