# Apple Developer Push Notification Setup Guide

## Overview
This guide will help you set up push notifications for your Waddiny taxi app in your Apple Developer account.

## Prerequisites
- Apple Developer Account ($99/year)
- Xcode installed on your Mac
- Your app's Bundle Identifier (e.g., `com.yourcompany.waddiny`)

## Step 1: Apple Developer Account Setup

### 1.1 Create App ID
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** in the left sidebar
4. Click the **+** button to create a new identifier
5. Select **App IDs** and click **Continue**
6. Choose **App** and click **Continue**
7. Fill in the details:
   - **Description**: Waddiny Taxi App
   - **Bundle ID**: `com.yourcompany.waddiny` (use your actual bundle ID)
8. Scroll down to **Capabilities** section
9. **Enable Push Notifications** by checking the box
10. Click **Continue** and then **Register**

### 1.2 Create Push Notification Certificate
1. In the same portal, go to **Certificates**
2. Click the **+** button to create a new certificate
3. Select **Apple Push Notification service SSL (Sandbox & Production)**
4. Click **Continue**
5. Select your App ID (the one you just created)
6. Click **Continue**
7. Follow the instructions to create a Certificate Signing Request (CSR):
   - Open **Keychain Access** on your Mac
   - Go to **Keychain Access > Certificate Assistant > Request a Certificate From a Certificate Authority**
   - Enter your email and name
   - Select **Save to disk** and choose a location
   - Click **Continue**
8. Upload the CSR file to the Apple Developer portal
9. Download the generated certificate
10. Double-click the certificate to install it in Keychain Access

### 1.3 Export Push Notification Certificate
1. In Keychain Access, find your push notification certificate
2. Right-click on it and select **Export**
3. Choose **Personal Information Exchange (.p12)** format
4. Set a password (remember this for later)
5. Save the file as `WaddinyPushNotification.p12`

## Step 2: Xcode Project Configuration

### 2.1 Update Bundle Identifier
1. Open your project in Xcode
2. Select the **Runner** project in the navigator
3. Select the **Runner** target
4. In the **General** tab, update the **Bundle Identifier** to match your App ID

### 2.2 Enable Push Notifications Capability
1. In Xcode, select the **Runner** target
2. Go to the **Signing & Capabilities** tab
3. Click the **+ Capability** button
4. Add **Push Notifications**
5. Verify that **Background Modes** includes:
   - Remote notifications
   - Background fetch
   - Background processing

### 2.3 Update Entitlements
The entitlements files are already configured correctly:
- `Runner.entitlements` has `aps-environment` set to `development`
- `RunnerDebug.entitlements` has additional notification capabilities

## Step 3: Firebase Configuration (Optional but Recommended)

### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Add iOS app to your Firebase project
4. Use your Bundle Identifier
5. Download `GoogleService-Info.plist`

### 3.2 Configure Firebase in Xcode
1. Add `GoogleService-Info.plist` to your Xcode project
2. Make sure it's included in the target

## Step 4: Update Flutter Configuration

### 4.1 Add Firebase Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

### 4.2 Update iOS Podfile
Make sure your `ios/Podfile` includes:
```ruby
platform :ios, '14.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Add notification capabilities
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

## Step 5: Test Push Notifications

### 5.1 Build and Install
1. Clean your project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Install pods: `cd ios && pod install && cd ..`
4. Build for iOS: `flutter build ios`

### 5.2 Test on Device
1. Connect your iOS device
2. Run the app: `flutter run`
3. Use the notification test screen in the app
4. Check if notifications appear

## Step 6: Production Setup

### 6.1 Update Entitlements for Production
When ready for production, update `Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>production</string>
</dict>
</plist>
```

### 6.2 Create Production Certificate
1. In Apple Developer Portal, create a new push notification certificate
2. Select **Production** environment
3. Follow the same CSR process
4. Download and install the production certificate

## Troubleshooting

### Common Issues

1. **Notifications not appearing**
   - Check device settings: Settings > Notifications > Waddiny
   - Verify Do Not Disturb is off
   - Check if app has notification permissions

2. **Build errors**
   - Clean project: `flutter clean`
   - Reinstall pods: `cd ios && pod install && cd ..`
   - Check Bundle Identifier matches App ID

3. **Certificate issues**
   - Verify certificate is installed in Keychain Access
   - Check certificate expiration date
   - Ensure certificate matches your Bundle Identifier

### Debug Steps

1. **Check console logs** for notification-related messages
2. **Test on physical device** (not simulator)
3. **Verify entitlements** are properly configured
4. **Check Apple Developer Portal** for correct App ID setup

## Next Steps

1. **Implement server-side push notifications** using your certificate
2. **Add Firebase Cloud Messaging** for easier push notification management
3. **Test with real trip status changes**
4. **Monitor notification delivery rates**

## Support

If you continue to have issues:
1. Check Apple Developer documentation
2. Verify all certificates are valid
3. Test with a fresh device installation
4. Contact Apple Developer Support if needed

## Files to Update

- `ios/Runner/Runner.entitlements` - Production entitlements
- `ios/Runner/Info.plist` - Notification permissions
- `ios/Podfile` - Dependencies and capabilities
- `pubspec.yaml` - Flutter dependencies 