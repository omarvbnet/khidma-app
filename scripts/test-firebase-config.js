import dotenv from 'dotenv';
import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

dotenv.config();

console.log('\n=== TESTING FIREBASE CONFIGURATION ===\n');

// Check environment variables
const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;

console.log('1. ENVIRONMENT VARIABLES:');
console.log(`   FIREBASE_PROJECT_ID: ${hasProjectId ? '✅ Set' : '❌ Missing'}`);
console.log(`   FIREBASE_CLIENT_EMAIL: ${hasClientEmail ? '✅ Set' : '❌ Missing'}`);
console.log(`   FIREBASE_PRIVATE_KEY: ${hasPrivateKey ? '✅ Set' : '❌ Missing'}`);

if (hasProjectId) {
  console.log(`   Project ID: ${process.env.FIREBASE_PROJECT_ID}`);
}

if (hasClientEmail) {
  console.log(`   Client Email: ${process.env.FIREBASE_CLIENT_EMAIL}`);
}

if (hasPrivateKey) {
  const keyPreview = process.env.FIREBASE_PRIVATE_KEY.substring(0, 50) + '...';
  console.log(`   Private Key: ${keyPreview}`);
}

// Test Firebase Admin SDK initialization
console.log('\n2. TESTING FIREBASE ADMIN SDK:');

try {
  if (hasProjectId && hasClientEmail && hasPrivateKey) {
    if (!getApps().length) {
      initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
    }
    
    const messaging = getMessaging();
    console.log('✅ Firebase Admin SDK initialized successfully');
    
    // Test with a mock token
    console.log('\n3. TESTING PUSH NOTIFICATION:');
    const testToken = 'test_token_123';
    
    try {
      const message = {
        token: testToken,
        notification: {
          title: 'Test Notification',
          body: 'This is a test notification',
        },
        data: {
          test: 'true',
        },
      };
      
      // This will fail with invalid token, but we can see if the SDK is working
      await messaging.send(message);
    } catch (error) {
      if (error.code === 'messaging/invalid-registration-token') {
        console.log('✅ Firebase Admin SDK is working (expected error for test token)');
        console.log('   Error: Invalid registration token (expected for test)');
      } else {
        console.log('❌ Firebase Admin SDK error:', error.message);
      }
    }
    
  } else {
    console.log('❌ Cannot initialize Firebase Admin SDK - missing environment variables');
  }
} catch (error) {
  console.log('❌ Error testing Firebase Admin SDK:', error.message);
}

console.log('\n=== SUMMARY ===');
if (hasProjectId && hasClientEmail && hasPrivateKey) {
  console.log('✅ Firebase configuration appears to be complete');
  console.log('✅ Environment variables are set');
  console.log('✅ Firebase Admin SDK should work');
} else {
  console.log('❌ Firebase configuration is incomplete');
  console.log('❌ Missing required environment variables');
  console.log('❌ Push notifications will not work');
}

console.log('\n📝 NEXT STEPS:');
if (!hasProjectId || !hasClientEmail || !hasPrivateKey) {
  console.log('1. Set up Firebase environment variables in Vercel');
  console.log('2. Follow the FIREBASE_ENV_SETUP.md guide');
  console.log('3. Redeploy the application');
} else {
  console.log('1. Test with a real device token');
  console.log('2. Check server logs for notification errors');
  console.log('3. Verify Firebase project settings');
} 