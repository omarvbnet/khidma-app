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

// Helper function to convert all data values to strings (FCM requirement)
function convertDataToStrings(data: Record<string, any>): Record<string, string> {
  const stringData: Record<string, string> = {};
  
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) {
      stringData[key] = '';
    } else if (typeof value === 'object') {
      stringData[key] = JSON.stringify(value);
    } else {
      stringData[key] = String(value);
    }
  }
  
  return stringData;
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
  data?: Record<string, any>;
}) {
  if (!messaging) {
    console.warn('⚠️ Firebase Admin SDK not available - skipping push notification');
    return null;
  }

  try {
    // Convert all data values to strings (FCM requirement)
    const stringData = convertDataToStrings(data);
    
    console.log('📱 Converting notification data to strings:', {
      originalData: data,
      stringData: stringData,
    });

    // Create both notification and data-only messages for better background delivery
    const notificationMessage = {
      token,
      notification: {
        title,
        body,
      },
      data: {
        ...stringData,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        title: title, // Include title in data for background handling
        body: body,   // Include body in data for background handling
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

    // Also send a data-only message for better background handling
    const dataOnlyMessage = {
      token,
      data: {
        ...stringData,
        title: title,
        body: body,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        type: stringData.type || 'NEW_TRIP_AVAILABLE',
        timestamp: new Date().toISOString(),
      },
      android: {
        priority: 'high',
        data: {
          ...stringData,
          title: title,
          body: body,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          sound: 'default',
          type: stringData.type || 'NEW_TRIP_AVAILABLE',
          timestamp: new Date().toISOString(),
        },
      },
      apns: {
        payload: {
          aps: {
            'content-available': 1,
            'mutable-content': 1,
            category: 'trip_notifications',
            'thread-id': 'trip_notifications',
          },
          data: {
            ...stringData,
            title: title,
            body: body,
            type: stringData.type || 'NEW_TRIP_AVAILABLE',
            timestamp: new Date().toISOString(),
          },
        },
        headers: {
          'apns-priority': '5', // Lower priority for data-only messages
          'apns-push-type': 'background',
        },
      },
    };

    // Send both messages
    const [notificationResponse, dataResponse] = await Promise.all([
      messaging.send(notificationMessage),
      messaging.send(dataOnlyMessage),
    ]);

    console.log('✅ Push notifications sent successfully:', {
      notificationResponse,
      dataResponse,
    });
    return { notificationResponse, dataResponse };
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
  data?: Record<string, any>;
}) {
  if (!messaging) {
    console.warn('⚠️ Firebase Admin SDK not available - skipping multicast notification');
    return null;
  }

  try {
    // Convert all data values to strings (FCM requirement)
    const stringData = convertDataToStrings(data);
    
    console.log('📱 Converting multicast notification data to strings:', {
      originalData: data,
      stringData: stringData,
    });

    // Create notification message with correct format for sendEachForMulticast
    const notificationMessage = {
      notification: {
        title,
        body,
      },
      data: {
        ...stringData,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        title: title,
        body: body,
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
          'apns-priority': '10', // must be 10 for alert
          'apns-push-type': 'alert', // must be alert for notification
        },
      },
    };

    // Also send a data-only message for background handler logic
    const dataOnlyMessage = {
      data: {
        ...stringData,
        title: title,
        body: body,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        type: stringData.type || 'NEW_TRIP_AVAILABLE',
        timestamp: new Date().toISOString(),
      },
      android: {
        priority: 'high',
        data: {
          ...stringData,
          title: title,
          body: body,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          sound: 'default',
          type: stringData.type || 'NEW_TRIP_AVAILABLE',
          timestamp: new Date().toISOString(),
        },
      },
      apns: {
        payload: {
          aps: {
            'content-available': 1,
            'mutable-content': 1,
            category: 'trip_notifications',
            'thread-id': 'trip_notifications',
          },
          data: {
            ...stringData,
            title: title,
            body: body,
            type: stringData.type || 'NEW_TRIP_AVAILABLE',
            timestamp: new Date().toISOString(),
          },
        },
        headers: {
          'apns-priority': '5', // Lower priority for data-only messages
          'apns-push-type': 'background',
        },
      },
    };

    // Send both messages using sendEachForMulticast with correct format
    const [notificationResponse, dataResponse] = await Promise.all([
      messaging.sendEachForMulticast({
        ...notificationMessage,
        tokens,
      }),
      messaging.sendEachForMulticast({
        ...dataOnlyMessage,
        tokens,
      }),
    ]);

    console.log('✅ Multicast notifications sent:', {
      notificationResponse: {
        successCount: notificationResponse.successCount,
        failureCount: notificationResponse.failureCount,
        responses: notificationResponse.responses,
      },
      dataResponse: {
        successCount: dataResponse.successCount,
        failureCount: dataResponse.failureCount,
        responses: dataResponse.responses,
      },
    });
    return { notificationResponse, dataResponse };
  } catch (error) {
    console.error('❌ Error sending multicast notification:', error);
    throw error;
  }
} 