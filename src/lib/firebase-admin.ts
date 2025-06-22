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

export const messaging = getMessaging();

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
  try {
    const message = {
      token,
      notification: {
        title,
        body,
      },
      data,
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
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
  try {
    const message = {
      notification: {
        title,
        body,
      },
      data,
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      tokens,
    };

    const response = await messaging.sendMulticast(message);
    console.log('✅ Multicast notification sent:', {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
    return response;
  } catch (error) {
    console.error('❌ Error sending multicast notification:', error);
    throw error;
  }
} 