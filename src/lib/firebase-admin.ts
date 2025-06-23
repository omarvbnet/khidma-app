import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

// Initialize Firebase Admin SDK only if environment variables are present
let messaging: any = null;

if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
  if (!getApps().length) {
    initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      }),
    });
  }
  messaging = getMessaging();
} else {
  console.warn('⚠️ Firebase Admin SDK not initialized - missing environment variables');
}

// Send push notification
export async function sendPushNotification({
  token,
  title,
  body,
  data = {},
}: {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  if (!messaging) {
    console.warn('⚠️ Firebase Admin SDK not available - skipping push notification');
    return null;
  }

  try {
    const message = {
      token,
      notification: {
        title,
        body,
      },
      data: {
        ...data,
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
              title,
              body,
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

    const response = await messaging.send(message);
    console.log('✅ Push notification sent successfully:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending push notification:', error);
    throw error;
  }
}

// Send notification to multiple devices
export async function sendMulticastNotification({
  tokens,
  title,
  body,
  data = {},
}: {
  tokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  if (!messaging) {
    console.warn('⚠️ Firebase Admin SDK not available - skipping multicast notification');
    return null;
  }

  try {
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        ...data,
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
              title,
              body,
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
      tokens,
    };

    const response = await messaging.sendEachForMulticast(message);
    console.log('✅ Multicast notification sent:', {
      successCount: response.successCount,
      failureCount: response.failureCount,
      responses: response.responses,
    });
    return response;
  } catch (error) {
    console.error('❌ Error sending multicast notification:', error);
    throw error;
  }
} 