# Driver Notification Debugging Guide

## 🚨 **Issue: Drivers Not Receiving Notifications**

This guide will help you systematically debug why drivers are not receiving notifications when users book trips.

## 🔍 **Step-by-Step Debugging Process**

### **Step 1: Check if the System is Deployed**
```bash
# Wait for deployment to complete (usually 2-3 minutes after git push)
# Then test the simple endpoint
curl -X GET "https://khidma-app.vercel.app/api/flutter/notifications/test-simple"
```

### **Step 2: Check Driver Status and Device Tokens**
```bash
# Test the debug endpoint
curl -X GET "https://khidma-app.vercel.app/api/flutter/notifications/debug"
```

**Expected Output:**
```json
{
  "totalDrivers": 5,
  "activeDrivers": 3,
  "driversWithTokens": 2,
  "firebaseConfig": {
    "hasProjectId": true,
    "hasClientEmail": true,
    "hasPrivateKey": true
  },
  "testNotification": "Created",
  "driverDetails": [...]
}
```

### **Step 3: Check Firebase Environment Variables**

**In Vercel Dashboard:**
1. Go to your project settings
2. Check Environment Variables
3. Verify these are set:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_CLIENT_EMAIL`
   - `FIREBASE_PRIVATE_KEY`

### **Step 4: Test Driver Registration and Login**

**In Flutter App:**
1. **Register a new driver** with the app
2. **Check console logs** for device token registration
3. **Verify the driver status** is `ACTIVE` (not `PENDING`)

**Expected Logs:**
```
📱 Device Info:
- Token: fcm_token_123...
- Platform: android/ios
- App Version: 1.0.0
✅ Device token sent to server successfully
```

### **Step 5: Test Trip Creation**

**In Flutter App:**
1. **Login as a user**
2. **Create a new trip** (book a ride)
3. **Check server logs** for notification attempts

**Expected Server Logs:**
```
=== NOTIFYING AVAILABLE DRIVERS ABOUT NEW TRIP ===
Found 3 total active drivers
Driver John Doe (abc123) - Available: true
✅ Driver John Doe has device token: fcm_token_123...
✅ Batch push notification sent to 2 available drivers
✅ All available drivers notified about new trip
```

## 🐛 **Common Issues and Solutions**

### **Issue 1: No Active Drivers**
**Problem:** `activeDrivers: 0`
**Solution:** 
- Check if drivers are registered with `ACTIVE` status
- Update existing drivers to `ACTIVE` status in database

### **Issue 2: No Device Tokens**
**Problem:** `driversWithTokens: 0`
**Solution:**
- Ensure drivers have logged in with the Flutter app
- Check if device tokens are being sent to server
- Verify Firebase is properly configured in Flutter app

### **Issue 3: Firebase Configuration Missing**
**Problem:** `firebaseConfig.hasProjectId: false`
**Solution:**
- Set Firebase environment variables in Vercel
- Follow the `FIREBASE_ENV_SETUP.md` guide

### **Issue 4: Drivers Have Active Trips**
**Problem:** Drivers are not "available"
**Solution:**
- Complete or cancel existing trips
- Check trip status in database

## 🧪 **Manual Testing Steps**

### **Test 1: Create Test Driver**
```sql
-- In your database, create a test driver
INSERT INTO "User" (
  id, phoneNumber, password, fullName, province, 
  status, role, "deviceToken", platform, "appVersion"
) VALUES (
  'test_driver_1', '+1234567890', 'hashed_password', 
  'Test Driver', 'Baghdad', 'ACTIVE', 'DRIVER',
  'test_device_token_123', 'android', '1.0.0'
);
```

### **Test 2: Send Test Notification**
```bash
curl -X POST "https://khidma-app.vercel.app/api/flutter/notifications/send-test" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocation": "Test Pickup",
    "dropoffLocation": "Test Dropoff",
    "price": 25.0,
    "distance": 5.0
  }'
```

### **Test 3: Check Database Notifications**
```sql
-- Check if notifications are being created
SELECT * FROM "Notification" 
WHERE type = 'NEW_TRIP_AVAILABLE' 
ORDER BY "createdAt" DESC 
LIMIT 10;
```

## 📱 **Flutter App Debugging**

### **Check Device Token Registration**
1. **Open Flutter app**
2. **Login as driver**
3. **Check console logs** for:
   ```
   📱 GETTING DEVICE TOKEN
   🔥 Got FCM token: [token]
   📤 SENDING DEVICE TOKEN TO SERVER
   ✅ Device token sent to server successfully
   ```

### **Check Notification Permissions**
1. **Go to app settings**
2. **Enable notifications**
3. **Check if app has notification permissions**

### **Test Local Notifications**
```dart
// In Flutter app, test local notification
await NotificationService.forceNotification(
  title: 'Test Notification',
  body: 'This is a test notification',
);
```

## 🔧 **Server-Side Debugging**

### **Check Notification Service Logs**
Look for these log patterns in Vercel logs:

**✅ Success Pattern:**
```
=== NOTIFYING AVAILABLE DRIVERS ABOUT NEW TRIP ===
Found X total active drivers
Driver [Name] ([ID]) - Available: true
✅ Driver [Name] has device token: [token]...
✅ Batch push notification sent to X available drivers
✅ All available drivers notified about new trip
```

**❌ Error Patterns:**
```
❌ Firebase Admin SDK not initialized - missing environment variables
❌ Batch Firebase notification failed: [error]
❌ Error notifying available drivers about new trip: [error]
```

### **Check Firebase Admin SDK**
```javascript
// In your server logs, look for:
⚠️ Firebase Admin SDK not available - skipping push notification
```

## 🚀 **Quick Fixes**

### **Fix 1: Update Driver Status**
```sql
-- Make all drivers ACTIVE
UPDATE "User" 
SET status = 'ACTIVE' 
WHERE role = 'DRIVER' AND status = 'PENDING';
```

### **Fix 2: Add Device Tokens**
```sql
-- Add test device tokens to drivers
UPDATE "User" 
SET "deviceToken" = 'test_token_' || id,
    platform = 'android',
    "appVersion" = '1.0.0'
WHERE role = 'DRIVER' AND "deviceToken" IS NULL;
```

### **Fix 3: Complete Active Trips**
```sql
-- Complete any active trips
UPDATE "TaxiRequest" 
SET status = 'TRIP_COMPLETED' 
WHERE status IN ('DRIVER_ACCEPTED', 'DRIVER_IN_WAY', 'DRIVER_ARRIVED', 'USER_PICKED_UP', 'DRIVER_IN_PROGRESS');
```

## 📊 **Monitoring Dashboard**

### **Key Metrics to Track:**
- Total drivers in system
- Active drivers
- Drivers with device tokens
- Notification delivery success rate
- Firebase configuration status

### **Alert Thresholds:**
- **Critical:** No active drivers
- **Warning:** Less than 50% of drivers have device tokens
- **Info:** Firebase configuration missing

## 🆘 **Emergency Contact**

If the issue persists after following this guide:

1. **Check Vercel deployment status**
2. **Verify database connectivity**
3. **Test Firebase configuration**
4. **Review server logs for errors**
5. **Contact development team with specific error details**

---

**Last Updated:** December 2024
**Status:** 🔧 Debugging Guide 