# Firebase Notification Testing Guide

## Overview
This guide will help you test and verify that Firebase Cloud Messaging (FCM) notifications are working properly in your taxi booking app.

## Prerequisites
- ✅ Apple Developer Account with Push Notifications enabled
- ✅ Firebase project configured
- ✅ GoogleService-Info.plist file in iOS project
- ✅ App built and installed on device
- ✅ Device connected to internet

## Testing Steps

### 1. Initial Setup Verification

#### Check Firebase Configuration
1. Open the app and navigate to the Notification Test screen
2. Verify that FCM token is generated and displayed
3. Check console logs for Firebase initialization messages

#### Expected Console Output:
```
🚀 INITIALIZING NOTIFICATION SERVICE
🔥 INITIALIZING FIREBASE MESSAGING
📱 iOS Notification Settings:
- Authorization Status: authorized
- Alert: true
- Badge: true
- Sound: true
🔥 FCM Token: [your-fcm-token]
✅ Firebase Messaging initialized successfully
```

### 2. Local Notification Testing

#### Test Local Notifications
1. Tap "Test Local Notification" button
2. Verify notification appears immediately
3. Check console logs for success messages

#### Expected Behavior:
- Notification appears with title "Test Notification"
- Body shows "This is a test local notification!"
- Sound plays (if enabled)
- Vibration occurs (if enabled)

### 3. Firebase Push Notification Testing

#### Test Firebase Notifications
1. Tap "Test Firebase Notification" button
2. Check console logs for API response
3. Verify notification is received

#### Expected Console Output:
```
🔥 Testing Firebase notification...
✅ Firebase notification sent successfully
```

#### Server-Side Testing
If Firebase notifications are not working, test the server endpoint directly:

```bash
curl -X POST http://your-server/api/notifications/send-simple \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Firebase Test",
    "body": "This is a Firebase push notification test!",
    "deviceToken": "YOUR_FCM_TOKEN",
    "data": {
      "type": "test",
      "message": "Firebase notification test"
    }
  }'
```

### 4. Trip Status Notification Testing

#### Test Trip Status Notifications
1. Ensure you have an active trip
2. Tap "Test Trip Status Notification" button
3. Verify notification is sent with current trip status

#### Expected Behavior:
- Notification title: "Trip Status Update"
- Body shows current trip status
- Includes trip data in payload

### 5. Permission Testing

#### Check Permissions
1. Tap "Check Permissions" button
2. Review console output for permission status

#### Request Permissions
1. Tap "Request Permissions" button
2. Follow iOS permission prompts
3. Verify permissions are granted

### 6. Device Token Management

#### Refresh Device Token
1. Tap "Refresh Token" button
2. Verify new token is generated
3. Check that token is sent to server

#### Expected Behavior:
- New FCM token is generated
- Token is saved to SharedPreferences
- Token is sent to server via API

## Troubleshooting

### Common Issues and Solutions

#### 1. FCM Token Not Generated
**Symptoms:**
- FCM token shows "Not found"
- Firebase initialization errors in console

**Solutions:**
- Verify GoogleService-Info.plist is in correct location
- Check Firebase project configuration
- Ensure app has internet connection
- Restart app and try again

#### 2. Notifications Not Appearing
**Symptoms:**
- Local notifications work but Firebase notifications don't
- No error messages in console

**Solutions:**
- Check iOS notification settings
- Verify "Do Not Disturb" is disabled
- Test with app in different states (foreground/background)
- Check server logs for delivery status

#### 3. Permission Denied
**Symptoms:**
- Permission status shows "denied"
- Notifications don't appear

**Solutions:**
- Go to iOS Settings > Notifications > Waddiny
- Enable "Allow Notifications"
- Enable "Alert", "Badge", and "Sound"
- Restart app and try again

#### 4. Server API Errors
**Symptoms:**
- Console shows HTTP error codes
- Notifications not sent to server

**Solutions:**
- Check authentication token
- Verify API endpoint is correct
- Check server logs for errors
- Test API endpoint directly

### Debug Information

#### Console Logs to Monitor
```
🚀 INITIALIZING NOTIFICATION SERVICE
🔥 INITIALIZING FIREBASE MESSAGING
📱 iOS Notification Settings
🔥 FCM Token
✅ Firebase Messaging initialized successfully
🔔 SENDING NOTIFICATION
✅ Local notification sent successfully
📨 RECEIVED FOREGROUND MESSAGE
📨 BACKGROUND MESSAGE RECEIVED
👆 NOTIFICATION TAPPED
```

#### Key Files to Check
- `waddiny/ios/Runner/GoogleService-Info.plist`
- `waddiny/ios/Runner/Info.plist`
- `waddiny/ios/Runner/Runner.entitlements`
- `waddiny/lib/services/notification_service.dart`

## Testing Checklist

### Pre-Testing
- [ ] Firebase project configured
- [ ] GoogleService-Info.plist in place
- [ ] App built and installed
- [ ] Device connected to internet
- [ ] iOS notification permissions granted

### Local Notifications
- [ ] Local notification test works
- [ ] Notification appears immediately
- [ ] Sound and vibration work
- [ ] Notification tap handling works

### Firebase Notifications
- [ ] FCM token generated
- [ ] Token sent to server
- [ ] Firebase notification test works
- [ ] Notifications received in foreground
- [ ] Notifications received in background
- [ ] Notifications received when app closed

### Trip Notifications
- [ ] Trip status notifications work
- [ ] Correct trip data in payload
- [ ] Notifications for all trip statuses

### Permissions
- [ ] Permission check works
- [ ] Permission request works
- [ ] Permissions granted by user

## Next Steps

Once testing is complete and notifications are working:

1. **Server Integration**: Ensure server can send notifications to all registered devices
2. **Production Setup**: Configure production Firebase project
3. **Monitoring**: Set up Firebase Analytics and Crashlytics
4. **User Experience**: Test notification flow in real scenarios
5. **Performance**: Monitor notification delivery rates

## Support

If you encounter issues not covered in this guide:

1. Check Firebase Console for delivery status
2. Review server logs for API errors
3. Test with different devices and iOS versions
4. Contact development team with detailed error logs

## Success Criteria

Notifications are working correctly when:
- ✅ FCM token is generated and sent to server
- ✅ Local notifications appear immediately
- ✅ Firebase notifications are received
- ✅ Notifications work in all app states
- ✅ Trip status notifications include correct data
- ✅ Notification permissions are properly managed 