import { NextRequest, NextResponse } from 'next/server';
import { verify } from 'jsonwebtoken';

// Middleware to verify JWT token
async function verifyToken(req: NextRequest) {
  const authHeader = req.headers.get('authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'your-secret-key') as { userId: string };
    return decoded.userId;
  } catch (error) {
    return null;
  }
}

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

    // If device token is provided, simulate Firebase push notification
    if (deviceToken) {
      try {
        // Here you would integrate with Firebase Admin SDK to send push notifications
        // For now, we'll just log that it would be sent
        console.log('🔥 FIREBASE PUSH NOTIFICATION WOULD BE SENT TO:', deviceToken.substring(0, 20) + '...');
        
        // TODO: Implement actual Firebase push notification sending
        // const firebaseResponse = await sendFirebaseNotification({
        //   token: deviceToken,
        //   title,
        //   body,
        //   data,
        // });
      } catch (firebaseError) {
        console.error('Firebase notification error:', firebaseError);
      }
    }

    return NextResponse.json({
      success: true,
      message: 'Notification logged successfully',
      notification: {
        id: `test_${Date.now()}`,
        title,
        body,
        deviceToken: deviceToken ? 'provided' : 'not provided',
        data,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('Error sending simple notification:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
} 