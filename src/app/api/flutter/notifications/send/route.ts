import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
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

// Send notification with Firebase support
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { userId: targetUserId, type, title, message, data, deviceToken } = await req.json();

    if (!targetUserId || !type || !title || !message) {
      return NextResponse.json(
        { error: 'Missing required fields: userId, type, title, message' },
        { status: 400 }
      );
    }

    // Verify the target user exists
    const targetUser = await prisma.user.findUnique({
      where: { id: targetUserId },
    });

    if (!targetUser) {
      return NextResponse.json(
        { error: 'Target user not found' },
        { status: 404 }
      );
    }

    // Create notification in database
    const notification = await prisma.notification.create({
      data: {
        userId: targetUserId,
        type: type as any, // Cast to NotificationType enum
        title,
        message,
        data: data || {},
      },
    });

    // If device token is provided, send Firebase push notification
    if (deviceToken) {
      try {
        // Here you would integrate with Firebase Admin SDK to send push notifications
        // For now, we'll log the notification details
        console.log('📱 FIREBASE PUSH NOTIFICATION:', {
          to: targetUserId,
          deviceToken: deviceToken.substring(0, 20) + '...',
          type,
          title,
          message,
          data,
          timestamp: new Date().toISOString(),
        });

        // TODO: Implement actual Firebase push notification sending
        // const firebaseResponse = await sendFirebaseNotification({
        //   token: deviceToken,
        //   title,
        //   body: message,
        //   data,
        // });
      } catch (firebaseError) {
        console.error('Firebase notification error:', firebaseError);
        // Continue with database notification even if Firebase fails
      }
    }

    console.log(`Notification sent to user ${targetUserId}:`, {
      type,
      title,
      message,
      notificationId: notification.id,
      hasDeviceToken: !!deviceToken,
    });

    return NextResponse.json({
      success: true,
      notification,
      firebaseSent: !!deviceToken,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
} 