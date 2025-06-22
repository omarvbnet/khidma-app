# Notification Testing Guide for Real Devices

## 📱 **iOS Device Testing**

### **Prerequisites:**
- Physical iOS device (iPhone/iPad)
- Apple Developer account
- Xcode installed on Mac
- Device connected via USB or same WiFi network
- Developer Mode enabled on device

### **Step 1: Enable Developer Mode on iOS Device**
1. Go to **Settings > Privacy & Security > Developer Mode**
2. Toggle **Developer Mode** ON
3. Restart your device when prompted
4. Enter your device passcode to confirm

### **Step 2: Trust Your Mac (if using USB)**
1. Connect your iOS device to Mac via USB
2. On your iOS device, tap **"Trust This Computer"**
3. Enter your device passcode

### **Step 3: Build and Install App**
```bash
cd waddiny

# Clean and get dependencies
flutter clean
flutter pub get

# Build for iOS device
flutter build ios --release

# Install on connected device
flutter install --device-id 00008110-001059A93EF3801E  # Omar iphone
# OR
flutter install --device-id 00008030-00090502269B402E  # omar's iPad
```

### **Step 4: Configure iOS Notification Permissions**
1. **First Launch:** The app will request notification permissions
2. **Manual Check:** Go to **Settings > Notifications > Waddiny**
3. **Enable:**
   - Allow Notifications: ✅ ON
   - Lock Screen: ✅ ON
   - Notification Center: ✅ ON
   - Banners: ✅ ON
   - Sounds: ✅ ON
   - Badges: ✅ ON

### **Step 5: Test Notifications**

#### **A. Test Local Notifications (App Open)**
1. Open the Waddiny app
2. Navigate to any trip screen
3. Tap the notification icon in the app bar
4. Use the test screen to verify notifications work

#### **B. Test Background Notifications (App Minimized)**
1. Open the app and navigate to a trip
2. Press home button to minimize app
3. Create a trip from another device/account
4. Verify notification appears on lock screen

#### **C. Test Foreground Notifications (App Active)**
1. Keep app open and active
2. Have another user create a trip
3. Verify notification appears as banner

## 🤖 **Android Device Testing**

### **Prerequisites:**
- Physical Android device
- USB debugging enabled
- Device connected via USB

### **Step 1: Enable Developer Options**
1. Go to **Settings > About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings > Developer Options**
4. Enable **USB Debugging**

### **Step 2: Build and Install App**
```bash
cd waddiny

# Clean and get dependencies
flutter clean
flutter pub get

# Build for Android
flutter build apk --release

# Install on connected device
flutter install
```

### **Step 3: Configure Android Notification Permissions**
1. **First Launch:** Grant notification permissions when prompted
2. **Manual Check:** Go to **Settings > Apps > Waddiny > Notifications**
3. **Enable all notification types**

### **Step 4: Test Notifications**
Same testing scenarios as iOS above.

## 🧪 **Testing Scenarios**

### **Scenario 1: Driver Accepts Trip**
1. **User Device:** Create a new trip
2. **Driver Device:** Accept the trip
3. **Expected:** User gets "Driver Accepted Your Trip!" notification

### **Scenario 2: Driver Status Updates**
1. **Driver Device:** Update trip status to "In Way"
2. **Expected:** User gets "Driver is on the Way!" notification
3. **Driver Device:** Update trip status to "Arrived"
4. **Expected:** User gets "Driver Has Arrived!" notification

### **Scenario 3: New Trip Notifications**
1. **User Device:** Create a new trip
2. **Driver Device:** Should get "New Trip Available!" notification
3. **Note:** Only drivers not currently on trips should get notified

### **Scenario 4: Trip Completion**
1. **Driver Device:** Complete the trip
2. **Expected:** Both user and driver get "Trip Completed!" notifications

## 🔧 **Troubleshooting**

### **iOS Issues:**

#### **Notifications Not Appearing:**
1. Check notification permissions in Settings
2. Ensure "Do Not Disturb" is OFF
3. Check Focus modes (Work, Sleep, etc.)
4. Verify app has background refresh enabled

#### **Permission Denied:**
```bash
# Reset app permissions
flutter clean
flutter pub get
flutter install
```

#### **Build Errors:**
```bash
# Clean Xcode build
cd ios
rm -rf build/
pod install
cd ..
flutter clean
flutter pub get
```

### **Android Issues:**

#### **Notifications Not Appearing:**
1. Check notification permissions in Settings
2. Ensure battery optimization is disabled for the app
3. Check if "Do Not Disturb" is enabled

#### **Permission Issues:**
```bash
# Reset app data
flutter clean
flutter pub get
flutter install
```

## 📊 **Testing Checklist**

### **iOS Testing:**
- [ ] App installs successfully
- [ ] Notification permissions granted
- [ ] Local notifications work (app open)
- [ ] Background notifications work (app minimized)
- [ ] Foreground notifications work (app active)
- [ ] Notification sounds play
- [ ] Notification badges appear
- [ ] Tap notifications open correct screen

### **Android Testing:**
- [ ] App installs successfully
- [ ] Notification permissions granted
- [ ] Local notifications work
- [ ] Background notifications work
- [ ] Foreground notifications work
- [ ] Notification sounds play
- [ ] Notification badges appear
- [ ] Tap notifications open correct screen

## 🚀 **Quick Test Commands**

### **Build and Install:**
```bash
# iOS
flutter build ios --release
flutter install --device-id YOUR_DEVICE_ID

# Android
flutter build apk --release
flutter install
```

### **Check Device Connection:**
```bash
flutter devices
```

### **View Logs:**
```bash
# iOS
flutter logs --device-id YOUR_DEVICE_ID

# Android
flutter logs
```

## 📱 **Device-Specific Notes**

### **iPhone (00008110-001059A93EF3801E):**
- iOS 18.2
- Wireless connection
- Ensure Developer Mode is enabled

### **iPad (00008030-00090502269B402E):**
- iOS 18.3.2
- Wireless connection
- Ensure Developer Mode is enabled

## 🎯 **Expected Results**

### **Successful Testing:**
- ✅ Notifications appear immediately
- ✅ Correct notification content
- ✅ Proper notification sounds
- ✅ Tap notifications navigate correctly
- ✅ No crashes or errors

### **Common Issues:**
- ❌ Delayed notifications (check network)
- ❌ Wrong notification content (check backend)
- ❌ No notifications (check permissions)
- ❌ App crashes (check logs)

## 📞 **Support**

If you encounter issues:
1. Check the console logs for error messages
2. Verify device permissions
3. Test with different devices
4. Check network connectivity
5. Review the notification service logs 