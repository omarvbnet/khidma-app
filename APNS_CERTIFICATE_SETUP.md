# APNs Certificate Setup Guide

## 🔧 Fixing "No development APNs certificate" Error

This guide will help you resolve the APNs certificate error that prevents Firebase Cloud Messaging from working on iOS.

## 🚨 Problem
The error "No development APNs certificate" occurs when Firebase tries to send push notifications but doesn't have the proper Apple Push Notification service (APNs) certificate configured.

## ✅ Solutions

### **Solution 1: Upload APNs Certificate to Firebase (Recommended)**

#### Step 1: Get Your APNs Certificate

1. **Go to Apple Developer Portal**:
   - Visit [developer.apple.com](https://developer.apple.com/account/)
   - Sign in with your Apple Developer account
   - Navigate to **Certificates, Identifiers & Profiles**

2. **Create Push Notification Certificate**:
   - Click **Certificates** in the left sidebar
   - Click the **+** button to create a new certificate
   - Select **Apple Push Notification service SSL (Sandbox & Production)**
   - Click **Continue**
   - Select your App ID (e.g., `com.yourcompany.waddiny`)
   - Click **Continue**

3. **Create Certificate Signing Request (CSR)**:
   - Open **Keychain Access** on your Mac
   - Go to **Keychain Access > Certificate Assistant > Request a Certificate From a Certificate Authority**
   - Enter your email and name
   - Select **Save to disk** and choose a location
   - Click **Continue**

4. **Upload CSR and Download Certificate**:
   - Upload the CSR file to the Apple Developer portal
   - Download the generated certificate
   - Double-click the certificate to install it in Keychain Access

5. **Export the Certificate**:
   - In Keychain Access, find your push notification certificate
   - Right-click on it and select **Export**
   - Choose **Personal Information Exchange (.p12)** format
   - Set a password (remember this!)
   - Save the file as `WaddinyPushNotification.p12`

#### Step 2: Upload to Firebase Console

1. **Go to Firebase Console**:
   - Visit [console.firebase.google.com](https://console.firebase.google.com/)
   - Select your project

2. **Navigate to Project Settings**:
   - Click the gear icon → **Project settings**
   - Go to **Cloud Messaging** tab

3. **Upload APNs Certificate**:
   - In the **Apple apps (APNs)** section, click **Upload**
   - Select your `.p12` file
   - Enter the password you set when exporting
   - Click **Upload**

### **Solution 2: Use Firebase Admin SDK (Alternative)**

If you prefer to handle push notifications server-side, you can use Firebase Admin SDK which doesn't require client-side APNs certificates.

#### Step 1: Install Firebase Admin SDK

```bash
npm install firebase-admin
```

#### Step 2: Get Firebase Service Account Key

1. **Go to Firebase Console** → **Project Settings** → **Service Accounts**
2. **Click "Generate new private key"**
3. **Download the JSON file**

#### Step 3: Set Environment Variables

Add these to your `.env.local` file:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
```

#### Step 4: Use the Firebase Admin SDK

The Firebase Admin SDK is already configured in `src/lib/firebase-admin.ts` and integrated into the notification endpoints.

## 🧪 Testing

### Test Local Notifications (No APNs Required)

```bash
# Test local notifications only
flutter run
# Navigate to notification test screen
# Tap "Test Local Notification"
```

### Test Firebase Notifications (Requires APNs)

```bash
# Test Firebase push notifications
flutter run
# Navigate to notification test screen
# Tap "Test Firebase Notification"
```

## 🔍 Troubleshooting

### Common Issues

1. **Certificate Not Found**:
   - Verify the certificate is installed in Keychain Access
   - Check that the certificate matches your Bundle Identifier
   - Ensure the certificate hasn't expired

2. **Firebase Upload Fails**:
   - Check the password is correct
   - Verify the file is a valid `.p12` format
   - Ensure you have the right permissions in Firebase

3. **Notifications Still Not Working**:
   - Check iOS device settings: Settings > Notifications > App Name
   - Verify "Do Not Disturb" is disabled
   - Test on a physical device (not simulator)

### Debug Steps

1. **Check Console Logs**:
   ```
   🚀 INITIALIZING NOTIFICATION SERVICE
   🔥 INITIALIZING FIREBASE MESSAGING
   🔥 FCM Token: [token]
   ✅ Firebase Messaging initialized successfully
   ```

2. **Verify FCM Token Generation**:
   - Open the app's notification test screen
   - Check if FCM token is displayed
   - If not, there's an issue with Firebase configuration

3. **Test API Endpoints**:
   ```bash
   curl -X POST http://your-server/api/flutter/notifications/send-simple \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{
       "title": "Test",
       "body": "Test notification",
       "deviceToken": "YOUR_FCM_TOKEN"
     }'
   ```

## 📋 Checklist

### Before Testing
- [ ] APNs certificate created and uploaded to Firebase
- [ ] Firebase project configured correctly
- [ ] `GoogleService-Info.plist` in iOS project
- [ ] App built and installed on physical device
- [ ] Notification permissions granted

### After Testing
- [ ] Local notifications work
- [ ] Firebase notifications work
- [ ] Notifications work in all app states
- [ ] Trip status notifications work
- [ ] Error logs are clean

## 🚀 Next Steps

Once APNs is configured:

1. **Test all notification types**:
   - Local notifications
   - Firebase push notifications
   - Trip status notifications
   - Background notifications

2. **Monitor delivery rates**:
   - Check Firebase Console for delivery status
   - Monitor server logs for errors
   - Track user engagement

3. **Production deployment**:
   - Create production APNs certificate
   - Update Firebase configuration
   - Test on production devices

## 📞 Support

If you continue to have issues:

1. **Check Apple Developer documentation**
2. **Verify Firebase project settings**
3. **Test with a fresh device installation**
4. **Contact Apple Developer Support if needed**

## 📁 Files to Check

- `ios/Runner/GoogleService-Info.plist` - Firebase configuration
- `ios/Runner/Runner.entitlements` - Push notification entitlements
- `ios/Runner/Info.plist` - Notification permissions
- `src/lib/firebase-admin.ts` - Firebase Admin SDK configuration
- `src/app/api/flutter/notifications/send/route.ts` - Notification endpoint 