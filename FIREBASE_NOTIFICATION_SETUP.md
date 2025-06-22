# Firebase Notification Setup & Testing Guide

## 🎯 **What's New**

The notification system has been updated to include **real Firebase push notifications** with device tokens. Now when you create notifications, they will:

1. ✅ **Store in database** (as before)
2. ✅ **Send Firebase push notifications** to device tokens (NEW!)
3. ✅ **Work in background/terminated state** (NEW!)
4. ✅ **Include trip data** in notifications (NEW!)

## 🔧 **Setup Requirements**

### **1. Firebase Configuration**
- ✅ Firebase project created
- ✅ `GoogleService-Info.plist` in `waddiny/ios/Runner/`
- ✅ `google-services.json` in `waddiny/android/app/`
- ✅ Firebase Admin SDK credentials in environment variables

### **2. Environment Variables**
Add these to your `.env` file:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

### **3. Database Schema**
The User model already includes:
- `deviceToken` - FCM token for push notifications
- `platform` - ios/android
- `appVersion` - app version

## 📱 **How It Works**

### **1. Device Token Registration**
When a user opens the app:
1. Firebase generates FCM token
2. Token is saved to SharedPreferences
3. Token is sent to server via `/api/users/device-token`
4. Server stores token in user's database record

### **2. Notification Flow**
When a notification is triggered:
1. **Database**: Create notification record
2. **Device Token**: Get user's stored device token
3. **Firebase**: Send push notification to device
4. **Fallback**: If Firebase fails, still create database notification

### **3. Batch Notifications**
For new trips:
1. Get all active drivers
2. Collect their device tokens
3. Send batch notification via Firebase
4. Fall back to individual notifications if batch fails

## 🧪 **Testing Steps**

### **Step 1: Build and Install App**
```bash
cd waddiny
flutter clean
flutter pub get
flutter build ios --release
flutter install --device-id YOUR_DEVICE_ID
```

### **Step 2: Check Device Token Registration**
1. Open the app
2. Navigate to Notification Test screen
3. Verify FCM token is generated and displayed
4. Check console logs for token registration

**Expected Console Output:**
```
🚀 INITIALIZING NOTIFICATION SERVICE
🔥 INITIALIZING FIREBASE MESSAGING
🔥 FCM Token: [your-fcm-token]
📤 SENDING DEVICE TOKEN TO SERVER
✅ Device token sent to server successfully
```

### **Step 3: Test Firebase Push Notifications**
1. In Notification Test screen, tap "Test Firebase Notification"
2. Check console logs for Firebase response
3. Verify notification appears on device

**Expected Console Output:**
```
🔥 Testing Firebase notification...
🔥 FIREBASE PUSH NOTIFICATION SENT TO: [token-preview]...
Firebase Message ID: [message-id]
✅ Firebase notification sent successfully
```

### **Step 4: Test Trip Status Notifications**
1. Create a trip on one device (user account)
2. Accept trip on another device (driver account)
3. Verify user gets push notification: "Driver Accepted Your Trip!"
4. Update trip status to "In Way"
5. Verify user gets push notification: "Driver is on the Way!"

### **Step 5: Test New Trip Notifications**
1. Create a new trip on user device
2. Verify all active drivers get push notification: "New Trip Available!"
3. Check that only drivers not on trips get notified

## 🔍 **Troubleshooting**

### **Issue 1: No FCM Token Generated**
**Symptoms:**
- FCM token shows "Not found"
- Firebase initialization errors

**Solutions:**
```bash
# Check Firebase configuration
ls waddiny/ios/Runner/GoogleService-Info.plist
ls waddiny/android/app/google-services.json

# Rebuild app
flutter clean
flutter pub get
flutter build ios --release
flutter install
```

### **Issue 2: Push Notifications Not Appearing**
**Symptoms:**
- Local notifications work
- Firebase notifications don't appear
- No errors in console

**Solutions:**
1. Check iOS notification settings: Settings > Notifications > Waddiny
2. Disable "Do Not Disturb"
3. Check Focus modes
4. Test with app in background/terminated state

### **Issue 3: Firebase Errors**
**Symptoms:**
- Firebase initialization fails
- Push notification errors

**Solutions:**
1. Check environment variables
2. Verify Firebase Admin SDK credentials
3. Check Firebase project configuration
4. Ensure APNs certificate is uploaded to Firebase

### **Issue 4: Device Token Not Saved**
**Symptoms:**
- Token generated but not saved to database
- Server errors in console

**Solutions:**
1. Check network connectivity
2. Verify authentication token
3. Check server logs for errors
4. Test device token API endpoint

## 📊 **Testing Checklist**

### **Device Token Registration:**
- [ ] FCM token generated on app launch
- [ ] Token saved to SharedPreferences
- [ ] Token sent to server successfully
- [ ] Token stored in database

### **Push Notifications:**
- [ ] Firebase notification test works
- [ ] Trip status notifications work
- [ ] New trip notifications work
- [ ] Notifications work in foreground
- [ ] Notifications work in background
- [ ] Notifications work when app terminated

### **Database Notifications:**
- [ ] Notifications stored in database
- [ ] Notification content is correct
- [ ] Notification types are correct
- [ ] Notification data includes trip info

### **Error Handling:**
- [ ] Firebase failures don't break app
- [ ] Database notifications still created
- [ ] Error logs are informative
- [ ] Fallback mechanisms work

## 🚀 **Quick Test Commands**

### **Test Device Token Registration:**
```bash
# Check if token is saved
curl -X GET http://your-server/api/users/device-token \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### **Test Firebase Notification:**
```bash
curl -X POST http://your-server/api/flutter/notifications/send-simple \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test Push",
    "body": "This is a test push notification",
    "deviceToken": "YOUR_FCM_TOKEN"
  }'
```

### **View Server Logs:**
```bash
# Check for notification logs
grep -i "firebase\|notification\|push" server.log
```

## 📱 **Expected Results**

### **Successful Implementation:**
- ✅ FCM tokens generated and stored
- ✅ Push notifications delivered to devices
- ✅ Notifications work in all app states
- ✅ Database notifications created
- ✅ Trip data included in notifications
- ✅ Batch notifications for new trips
- ✅ Error handling and fallbacks

### **Performance:**
- Push notifications delivered within 1-2 seconds
- Database notifications created immediately
- Batch notifications sent efficiently
- Error recovery works seamlessly

## 🔧 **Configuration Files**

### **Firebase Admin SDK:**
```typescript
// src/lib/firebase-admin.ts
import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

// Initialize Firebase Admin SDK
if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}
```

### **Notification Service:**
```typescript
// src/lib/notification-service.ts
import { sendPushNotification, sendMulticastNotification } from './firebase-admin';

// Send notification with Firebase fallback
async function sendNotificationWithFallback(userId, title, message, data, type) {
  // Create database notification
  const notification = await prisma.notification.create({...});
  
  // Get device token and send push notification
  const deviceToken = await getUserDeviceToken(userId);
  if (deviceToken) {
    await sendPushNotification({...});
  }
}
```

## 🎉 **Success Indicators**

When everything is working correctly, you should see:

1. **Console Logs:**
   ```
   🔥 FCM Token: [token]
   📤 SENDING DEVICE TOKEN TO SERVER
   ✅ Device token sent to server successfully
   📱 Push notification sent to user [id]: [title]
   ```

2. **Device Behavior:**
   - Notifications appear immediately
   - Sound and vibration work
   - Tap notifications open correct screen
   - Notifications work in all app states

3. **Database Records:**
   - Notifications stored with correct data
   - Device tokens saved for users
   - Trip data included in notifications

## 📞 **Support**

If you encounter issues:
1. Check console logs for error messages
2. Verify Firebase configuration
3. Test device token registration
4. Check notification permissions
5. Review server logs for delivery status 