const { getMessaging } = require('firebase-admin/messaging');
const { initializeApp, cert } = require('firebase-admin/app');

// Initialize Firebase Admin SDK
if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_CLIENT_EMAIL || !process.env.FIREBASE_PRIVATE_KEY) {
  console.error('❌ Firebase environment variables not found');
  process.exit(1);
}

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

// Your device token
const DEVICE_TOKEN = 'ffRQaXTw7Uj3pk5t6Oltzm:APA91bF-LhNp19r6Dh0CLLnS5v1N2wWOP0ZtbeqDGqMfh6Z3df7VWa23-NYG8TKYfIyk2gI76mizwsp6QH3wZQBAqf3fPqbj79RL3hd4eKUsqXAq8iZ1tew';

async function testRealFormat() {
  console.log('\n=== TESTING REAL FORMAT (Same as Trip Creation) ===');
  
  const notificationData = {
    tripId: 'test-trip-123',
    newStatus: 'NEW_TRIP_AVAILABLE',
    pickupLocation: 'Test Pickup Location',
    dropoffLocation: 'Test Dropoff Location',
    fare: '25.00',
    distance: '5.2',
    userFullName: 'Test User',
    userPhone: '+1234567890',
    userProvince: 'Test Province',
    type: 'NEW_TRIP_AVAILABLE',
  };

  const message = {
    token: DEVICE_TOKEN,
    notification: {
      title: 'New Trip Available!',
      body: 'A new trip request is available in Test Province. Tap to view details.',
    },
    data: {
      ...notificationData,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      sound: 'default',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'trip_notifications',
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
        icon: '@mipmap/ic_launcher',
        color: '#2196F3',
        sound: 'notification_sound',
        vibrateTimingsMillis: [0, 500, 200, 500],
        lightSettings: {
          color: '#2196F3',
          lightOnDurationMillis: 1000,
          lightOffDurationMillis: 500,
        },
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: 'New Trip Available!',
            body: 'A new trip request is available in Test Province. Tap to view details.',
          },
          sound: 'default',
          badge: 1,
          'content-available': 1,
          'mutable-content': 1,
          category: 'trip_notifications',
          'thread-id': 'trip_notifications',
        },
      },
      headers: {
        'apns-priority': '10',
        'apns-push-type': 'alert',
      },
    },
  };

  try {
    const response = await messaging.send(message);
    console.log('✅ Real format notification sent successfully:', response);
    return true;
  } catch (error) {
    console.error('❌ Real format notification failed:', error);
    return false;
  }
}

async function testDataOnlyFormat() {
  console.log('\n=== TESTING DATA-ONLY FORMAT (Like Working Test) ===');
  
  const notificationData = {
    tripId: 'test-trip-456',
    newStatus: 'NEW_TRIP_AVAILABLE',
    pickupLocation: 'Test Pickup Location',
    dropoffLocation: 'Test Dropoff Location',
    fare: '25.00',
    distance: '5.2',
    userFullName: 'Test User',
    userPhone: '+1234567890',
    userProvince: 'Test Province',
    type: 'NEW_TRIP_AVAILABLE',
    title: 'New Trip Available!',
    body: 'A new trip request is available in Test Province. Tap to view details.',
  };

  const message = {
    token: DEVICE_TOKEN,
    data: notificationData,
    android: {
      priority: 'high',
      data: notificationData,
    },
    apns: {
      payload: {
        aps: {
          'content-available': 1,
          'mutable-content': 1,
        },
      },
      headers: {
        'apns-priority': '5',
        'apns-push-type': 'background',
      },
    },
  };

  try {
    const response = await messaging.send(message);
    console.log('✅ Data-only format notification sent successfully:', response);
    return true;
  } catch (error) {
    console.error('❌ Data-only format notification failed:', error);
    return false;
  }
}

async function runTests() {
  console.log('🚀 Starting notification format tests...');
  console.log('Device Token:', DEVICE_TOKEN.substring(0, 20) + '...');
  
  // Test real format
  const realFormatSuccess = await testRealFormat();
  
  // Wait 5 seconds between tests
  console.log('\n⏳ Waiting 5 seconds before next test...');
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  // Test data-only format
  const dataOnlySuccess = await testDataOnlyFormat();
  
  console.log('\n📊 Test Results:');
  console.log('- Real Format (Trip Creation):', realFormatSuccess ? '✅ SUCCESS' : '❌ FAILED');
  console.log('- Data-Only Format (Working Test):', dataOnlySuccess ? '✅ SUCCESS' : '❌ FAILED');
  
  console.log('\n📱 Please check your Flutter app for:');
  console.log('1. Foreground notifications (app open)');
  console.log('2. Background notifications (app in background)');
  console.log('3. Background handler logs in console');
  console.log('4. Test notification from background handler');
}

runTests().catch(console.error); 