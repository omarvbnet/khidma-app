# iOS Notification Setup Guide

## Overview
This guide helps you set up and troubleshoot local notifications for the Waddiny taxi app on iOS devices.

## Prerequisites
- iOS 14.0 or later
- Xcode 12.0 or later
- Flutter 3.0 or later

## Setup Steps

### 1. iOS Configuration Files

#### Info.plist
The `ios/Runner/Info.plist` file has been updated with:
- Notification permissions description
- Background modes for remote notifications
- Proper notification alert style

#### Podfile
The `ios/Podfile` has been updated with:
- Notification permission definitions
- Proper iOS platform version (14.0+)

### 2. Flutter Dependencies
Ensure these dependencies are in `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^16.3.0
  permission_handler: ^11.4.0
```

### 3. Build and Install

1. Clean the project:
```bash
cd waddiny
flutter clean
flutter pub get
```

2. Install iOS pods:
```bash
cd ios
pod install
cd ..
```

3. Build for iOS:
```bash
flutter build ios
```

### 4. Testing Notifications

#### Using the Test Screen
1. Navigate to the notification test screen in the app
2. Tap "Check Permissions" to verify iOS permissions
3. Tap "Test Basic Notification" to send a test notification
4. Tap "Test Trip Notification" to test trip-specific notifications

#### Manual Testing
You can also test notifications programmatically:
```dart
// Test basic notification
await NotificationService.testNotification();

// Test trip notification
await NotificationService.showLocalNotification(
  title: 'Driver Accepted Your Trip!',
  body: 'A driver has accepted your trip request.',
  payload: '{"tripId": "test123", "type": "DRIVER_ACCEPTED"}',
  id: 1001,
);
```

## Troubleshooting

### Common Issues

#### 1. Notifications Not Appearing
**Symptoms**: No notifications show up on iOS device

**Solutions**:
- Check iOS Settings > Notifications > Waddiny
- Ensure "Allow Notifications" is enabled
- Check "Alert", "Badge", and "Sound" are enabled
- Verify "Do Not Disturb" is not enabled
- Test in both foreground and background app states

#### 2. Permission Denied
**Symptoms**: App shows permission denied errors

**Solutions**:
- Go to iOS Settings > Notifications > Waddiny
- Enable all notification permissions
- If permissions are denied, you may need to reinstall the app
- Check if the app is in "Do Not Disturb" mode

#### 3. Notifications Only Work in Foreground
**Symptoms**: Notifications only appear when app is open

**Solutions**:
- Ensure background modes are properly configured in Info.plist
- Check that the app has background app refresh enabled
- Verify notification service is properly initialized

#### 4. Build Errors
**Symptoms**: iOS build fails with notification-related errors

**Solutions**:
- Clean the project: `flutter clean`
- Delete derived data in Xcode
- Reinstall pods: `cd ios && pod install && cd ..`
- Check that all dependencies are compatible

### Debug Steps

1. **Check Console Logs**
   - Open Xcode and view device logs
   - Look for notification-related messages
   - Check for permission errors

2. **Verify Permissions**
   ```dart
   await NotificationService.checkPermissions();
   ```

3. **Test in Different States**
   - Foreground (app open and active)
   - Background (app minimized)
   - Terminated (app completely closed)

4. **Check iOS Settings**
   - Settings > Notifications > Waddiny
   - Settings > Do Not Disturb
   - Settings > Focus (iOS 15+)

### iOS-Specific Considerations

#### Background Execution
iOS has strict background execution policies. The app can:
- Receive notifications when terminated
- Process notifications when in background
- Show notifications in all app states

#### Notification Categories
The app uses the "trip_notifications" category for:
- Trip status updates
- Driver assignments
- Trip completions

#### Sound and Vibration
- Notifications include sound by default
- Vibration is enabled for Android
- iOS handles sound/vibration based on device settings

## Testing Checklist

- [ ] App builds successfully for iOS
- [ ] Notification permissions are requested on first launch
- [ ] Test notifications work in foreground
- [ ] Test notifications work in background
- [ ] Test notifications work when app is terminated
- [ ] Trip status notifications work correctly
- [ ] Notification tap handling works
- [ ] No console errors related to notifications

## Support

If you continue to experience issues:

1. Check the console logs for specific error messages
2. Verify iOS version compatibility
3. Test on different iOS devices/simulators
4. Ensure all dependencies are up to date
5. Check for any conflicting notification plugins

## Additional Resources

- [Flutter Local Notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [iOS Notification Programming Guide](https://developer.apple.com/documentation/usernotifications)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios) 