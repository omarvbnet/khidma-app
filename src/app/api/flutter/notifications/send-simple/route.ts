import { NextRequest, NextResponse } from 'next/server';
import { verifyToken } from '@/lib/jwt';
import { sendPushNotification } from '@/lib/firebase-admin';

// Send simple notification (for testing)
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { title, body, deviceToken, data } = await req.json();

    if (!title || !body) {
      return NextResponse.json(
        { error: 'Missing required fields: title, body' },
        { status: 400 }
      );
    }

    // Log the notification details
    console.log('📱 SIMPLE FIREBASE NOTIFICATION:', {
      from: userId,
      title,
      body,
      deviceToken: deviceToken ? deviceToken.substring(0, 20) + '...' : 'Not provided',
      data,
      timestamp: new Date().toISOString(),
    });

    // If device token is provided, send Firebase push notification
    if (deviceToken) {
      try {
        const firebaseResponse = await sendPushNotification({
          token: deviceToken,
          title,
          body,
          data: data || {},
        });
        
        console.log('🔥 FIREBASE PUSH NOTIFICATION SENT TO:', deviceToken.substring(0, 20) + '...');
        console.log('Firebase Message ID:', firebaseResponse);
        
        return NextResponse.json({
          success: true,
          message: 'Firebase push notification sent successfully',
          notification: {
            id: `firebase_${Date.now()}`,
            title,
            body,
            deviceToken: 'sent',
            data,
            firebaseMessageId: firebaseResponse,
            timestamp: new Date().toISOString(),
          },
        });
      } catch (firebaseError) {
        console.error('Firebase notification error:', firebaseError);
        return NextResponse.json({
          success: false,
          message: 'Firebase notification failed',
          error: firebaseError instanceof Error ? firebaseError.message : 'Unknown error',
          notification: {
            id: `failed_${Date.now()}`,
            title,
            body,
            deviceToken: 'failed',
            data,
            timestamp: new Date().toISOString(),
          },
        }, { status: 500 });
      }
    } else {
      return NextResponse.json({
        success: false,
        message: 'No device token provided',
        notification: {
          id: `no_token_${Date.now()}`,
          title,
          body,
          deviceToken: 'not provided',
          data,
          timestamp: new Date().toISOString(),
        },
      }, { status: 400 });
    }
  } catch (error) {
    console.error('Error sending simple notification:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
} 