const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔍 COMPREHENSIVE NOTIFICATION DEBUG SCRIPT');
console.log('==========================================\n');

// Check if we're in the right directory
const currentDir = process.cwd();
console.log(`📁 Current directory: ${currentDir}`);

// Check if this is the khidma-app1 project
if (!fs.existsSync(path.join(currentDir, 'waddiny')) || !fs.existsSync(path.join(currentDir, 'src'))) {
  console.error('❌ Error: This script must be run from the khidma-app1 root directory');
  process.exit(1);
}

console.log('✅ Project structure verified\n');

// Function to run commands and log output
function runCommand(command, description) {
  return new Promise((resolve, reject) => {
    console.log(`🔄 ${description}...`);
    exec(command, { cwd: currentDir }, (error, stdout, stderr) => {
      if (error) {
        console.error(`❌ Error: ${error.message}`);
        reject(error);
        return;
      }
      if (stderr) {
        console.warn(`⚠️ Warning: ${stderr}`);
      }
      console.log(`✅ ${description} completed`);
      if (stdout.trim()) {
        console.log(`📄 Output:\n${stdout}`);
      }
      resolve(stdout);
    });
  });
}

// Main debugging function
async function debugNotifications() {
  try {
    console.log('🚀 Starting comprehensive notification debugging...\n');

    // 1. Check environment variables
    console.log('1️⃣ CHECKING ENVIRONMENT VARIABLES');
    console.log('================================');
    
    const envVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_CLIENT_EMAIL', 
      'FIREBASE_PRIVATE_KEY',
      'JWT_SECRET',
      'DATABASE_URL'
    ];
    
    for (const envVar of envVars) {
      const value = process.env[envVar];
      if (value) {
        console.log(`✅ ${envVar}: ${envVar.includes('KEY') || envVar.includes('SECRET') ? '***SET***' : value.substring(0, 20) + '...'}`);
      } else {
        console.log(`❌ ${envVar}: NOT SET`);
      }
    }
    console.log('');

    // 2. Check Firebase configuration files
    console.log('2️⃣ CHECKING FIREBASE CONFIGURATION FILES');
    console.log('========================================');
    
    const firebaseFiles = [
      'waddiny/android/app/google-services.json',
      'waddiny/ios/Runner/GoogleService-Info.plist'
    ];

    for (const file of firebaseFiles) {
      if (fs.existsSync(file)) {
        const stats = fs.statSync(file);
        console.log(`✅ ${file}: EXISTS (${stats.size} bytes)`);
    } else {
        console.log(`❌ ${file}: MISSING`);
      }
    }
    console.log('');

    // 3. Check Flutter dependencies
    console.log('3️⃣ CHECKING FLUTTER DEPENDENCIES');
    console.log('================================');
    
    const pubspecPath = path.join(currentDir, 'waddiny', 'pubspec.yaml');
    if (fs.existsSync(pubspecPath)) {
      const pubspecContent = fs.readFileSync(pubspecPath, 'utf8');
      
      const requiredDeps = [
        'firebase_core',
        'firebase_messaging', 
        'flutter_local_notifications'
      ];

      for (const dep of requiredDeps) {
        if (pubspecContent.includes(dep)) {
          console.log(`✅ ${dep}: INCLUDED`);
        } else {
          console.log(`❌ ${dep}: MISSING`);
        }
      }
    } else {
      console.log('❌ pubspec.yaml not found');
    }
    console.log('');

    // 4. Check iOS configuration
    console.log('4️⃣ CHECKING iOS CONFIGURATION');
    console.log('=============================');
    
    const iosFiles = [
      'waddiny/ios/Runner/Info.plist',
      'waddiny/ios/Runner/AppDelegate.swift'
    ];
    
    for (const file of iosFiles) {
      if (fs.existsSync(file)) {
        const content = fs.readFileSync(file, 'utf8');
        
        if (file.includes('Info.plist')) {
          const hasBackgroundModes = content.includes('UIBackgroundModes');
          const hasRemoteNotification = content.includes('remote-notification');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Background modes: ${hasBackgroundModes ? '✅' : '❌'}`);
          console.log(`   - Remote notification: ${hasRemoteNotification ? '✅' : '❌'}`);
        } else if (file.includes('AppDelegate.swift')) {
          const hasFirebase = content.includes('Firebase');
          const hasNotificationDelegate = content.includes('UNUserNotificationCenter');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Firebase import: ${hasFirebase ? '✅' : '❌'}`);
          console.log(`   - Notification delegate: ${hasNotificationDelegate ? '✅' : '❌'}`);
        }
      } else {
        console.log(`❌ ${file}: MISSING`);
      }
    }
    console.log('');

    // 5. Check Android configuration
    console.log('5️⃣ CHECKING ANDROID CONFIGURATION');
    console.log('=================================');
    
    const androidFiles = [
      'waddiny/android/app/src/main/AndroidManifest.xml',
      'waddiny/android/app/build.gradle'
    ];

    for (const file of androidFiles) {
      if (fs.existsSync(file)) {
        const content = fs.readFileSync(file, 'utf8');
        
        if (file.includes('AndroidManifest.xml')) {
          const hasPermissions = content.includes('POST_NOTIFICATIONS');
          const hasFirebaseService = content.includes('FlutterFirebaseMessagingService');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Notification permissions: ${hasPermissions ? '✅' : '❌'}`);
          console.log(`   - Firebase messaging service: ${hasFirebaseService ? '✅' : '❌'}`);
        } else if (file.includes('build.gradle')) {
          const hasFirebasePlugin = content.includes('firebase');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Firebase plugin: ${hasFirebasePlugin ? '✅' : '❌'}`);
        }
      } else {
        console.log(`❌ ${file}: MISSING`);
    }
    }
    console.log('');

    // 6. Check backend notification service
    console.log('6️⃣ CHECKING BACKEND NOTIFICATION SERVICE');
    console.log('========================================');
    
    const backendFiles = [
      'src/lib/firebase-admin.ts',
      'src/lib/notification-service.ts'
    ];

    for (const file of backendFiles) {
      if (fs.existsSync(file)) {
        const content = fs.readFileSync(file, 'utf8');
        
        if (file.includes('firebase-admin.ts')) {
          const hasSendPushNotification = content.includes('sendPushNotification');
          const hasSendMulticastNotification = content.includes('sendMulticastNotification');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - sendPushNotification: ${hasSendPushNotification ? '✅' : '❌'}`);
          console.log(`   - sendMulticastNotification: ${hasSendMulticastNotification ? '✅' : '❌'}`);
        } else if (file.includes('notification-service.ts')) {
          const hasNotifyDrivers = content.includes('notifyAvailableDriversAboutNewTrip');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - notifyAvailableDriversAboutNewTrip: ${hasNotifyDrivers ? '✅' : '❌'}`);
        }
      } else {
        console.log(`❌ ${file}: MISSING`);
      }
    }
    console.log('');

    // 7. Check Flutter notification service
    console.log('7️⃣ CHECKING FLUTTER NOTIFICATION SERVICE');
    console.log('========================================');
    
    const flutterFiles = [
      'waddiny/lib/services/notification_service.dart',
      'waddiny/lib/main.dart'
    ];

    for (const file of flutterFiles) {
      if (fs.existsSync(file)) {
        const content = fs.readFileSync(file, 'utf8');
        
        if (file.includes('notification_service.dart')) {
          const hasFirebaseMessaging = content.includes('FirebaseMessaging');
          const hasBackgroundHandler = content.includes('onBackgroundMessage');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Firebase messaging: ${hasFirebaseMessaging ? '✅' : '❌'}`);
          console.log(`   - Background handler: ${hasBackgroundHandler ? '✅' : '❌'}`);
        } else if (file.includes('main.dart')) {
          const hasBackgroundHandler = content.includes('_firebaseMessagingBackgroundHandler');
          console.log(`✅ ${file}: EXISTS`);
          console.log(`   - Background message handler: ${hasBackgroundHandler ? '✅' : '❌'}`);
        }
    } else {
        console.log(`❌ ${file}: MISSING`);
      }
    }
    console.log('');

    // 8. Generate recommendations
    console.log('8️⃣ RECOMMENDATIONS');
    console.log('==================');
    
    console.log('📋 To fix background notification issues:');
    console.log('');
    console.log('1. 🔧 Ensure Firebase environment variables are set:');
    console.log('   - FIREBASE_PROJECT_ID');
    console.log('   - FIREBASE_CLIENT_EMAIL');
    console.log('   - FIREBASE_PRIVATE_KEY');
    console.log('');
    console.log('2. 📱 Verify device token registration:');
    console.log('   - Check that FCM tokens are being generated');
    console.log('   - Verify tokens are being sent to the server');
    console.log('   - Ensure tokens are stored in the database');
    console.log('');
    console.log('3. 🔔 Test notification permissions:');
    console.log('   - iOS: Check Settings > Notifications > App Name');
    console.log('   - Android: Check app notification settings');
    console.log('');
    console.log('4. 🧪 Test notification flow:');
    console.log('   - Create a test trip request');
    console.log('   - Check server logs for notification sending');
    console.log('   - Verify Firebase console for delivery status');
    console.log('');
    console.log('5. 📊 Monitor notification delivery:');
    console.log('   - Check Firebase console analytics');
    console.log('   - Monitor server logs for errors');
    console.log('   - Test on both foreground and background states');
    console.log('');

    console.log('✅ Debugging completed successfully!');
    console.log('');
    console.log('🚀 Next steps:');
    console.log('1. Fix any issues identified above');
    console.log('2. Test notifications on physical devices');
    console.log('3. Check Firebase console for delivery analytics');
    console.log('4. Monitor server logs during trip creation');

  } catch (error) {
    console.error('❌ Error during debugging:', error);
    process.exit(1);
  }
}

// Run the debugging
debugNotifications(); 