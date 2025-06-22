# Xcode Automatic Signing Fix Guide

## Problem
The "Automatic signing failed" error occurs when Xcode cannot automatically provision your app for development or distribution. This is a common issue with Flutter iOS projects.

## Root Cause
The iOS project is missing the `CODE_SIGN_STYLE = Automatic;` setting in the main Runner target configurations, which is required for automatic signing to work properly.

## Solution

### Method 1: Fix via Xcode (Recommended)

1. **Open the iOS project in Xcode:**
   ```bash
   cd waddiny/ios
   open Runner.xcworkspace
   ```

2. **Select the Runner target:**
   - In the Project Navigator, click on the "Runner" project (top item)
   - Select the "Runner" target (not the project)

3. **Configure Signing:**
   - Go to the "Signing & Capabilities" tab
   - Make sure "Automatically manage signing" is checked
   - Select your Team from the dropdown
   - The Bundle Identifier should be: `com.usamt-iot.waddiny`

4. **Verify Settings:**
   - Development Team: Your Apple Developer Team
   - Bundle Identifier: `com.usamt-iot.waddiny`
   - Code Signing Style: Automatic

### Method 2: Fix via Project File (Advanced)

If Method 1 doesn't work, manually edit the project file:

1. **Backup the project file:**
   ```bash
   cp waddiny/ios/Runner.xcodeproj/project.pbxproj waddiny/ios/Runner.xcodeproj/project.pbxproj.backup
   ```

2. **Add missing signing settings:**
   The project file needs these settings in the Runner target configurations:
   - `CODE_SIGN_STYLE = Automatic;`
   - `DEVELOPMENT_TEAM = 28YT228VJ4;` (your team ID)

### Method 3: Clean and Rebuild

1. **Clean the project:**
   ```bash
   cd waddiny
   flutter clean
   cd ios
   rm -rf build/
   rm -rf Pods/
   rm Podfile.lock
   ```

2. **Reinstall pods:**
   ```bash
   pod install
   ```

3. **Rebuild:**
   ```bash
   cd ..
   flutter build ios
   ```

## Troubleshooting Steps

### Step 1: Check Apple Developer Account
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Verify your membership is active
3. Check that you have the correct Team ID

### Step 2: Check Xcode Preferences
1. Open Xcode
2. Go to Xcode → Preferences → Accounts
3. Make sure your Apple ID is added
4. Click "Download Manual Profiles" if needed

### Step 3: Check Bundle Identifier
1. Ensure the bundle identifier matches your Apple Developer App ID
2. Current bundle ID: `com.usamt-iot.waddiny`
3. Verify this App ID exists in your Apple Developer account

### Step 4: Check Provisioning Profiles
1. In Xcode, go to Window → Devices and Simulators
2. Check if your device is properly registered
3. Verify provisioning profiles are downloaded

## Common Issues and Solutions

### Issue 1: "No provisioning profiles found"
**Solution:**
- Make sure "Automatically manage signing" is enabled
- Check that your Apple Developer account has the correct App ID
- Try downloading profiles manually in Xcode Preferences

### Issue 2: "Bundle identifier conflicts"
**Solution:**
- Change the bundle identifier to something unique
- Update it in both Xcode and your Apple Developer account

### Issue 3: "Team not found"
**Solution:**
- Verify your Team ID in Apple Developer portal
- Make sure you're signed in with the correct Apple ID in Xcode

### Issue 4: "Certificate not found"
**Solution:**
- Go to Xcode → Preferences → Accounts
- Select your Apple ID and click "Download Manual Profiles"
- Or create a new development certificate

## Verification

After fixing the signing issue:

1. **Test on Simulator:**
   ```bash
   flutter run
   ```

2. **Test on Device:**
   ```bash
   flutter run --device-id=YOUR_DEVICE_ID
   ```

3. **Build for Archive:**
   ```bash
   flutter build ios --release
   ```

## Additional Notes

- The current Development Team ID in the project is: `28YT228VJ4`
- The current Bundle Identifier is: `com.usamt-iot.waddiny`
- Make sure these match your Apple Developer account settings
- If you need to change the bundle identifier, update it in multiple places:
  - Xcode project settings
  - Apple Developer portal
  - Firebase configuration (if using Firebase)

## Support

If the issue persists:
1. Check the Xcode Report Navigator for detailed error messages
2. Verify all certificates and provisioning profiles are valid
3. Consider creating a new App ID and provisioning profile
4. Contact Apple Developer Support if needed 