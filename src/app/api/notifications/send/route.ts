import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { NotificationLocalizationService } from '@/lib/notification-localization';

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

// Send notification
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { userId: targetUserId, type, data } = await req.json();

    if (!targetUserId || !type) {
      return NextResponse.json(
        { error: 'Missing required fields: userId, type' },
        { status: 400 }
      );
    }

    // Verify the target user exists
    const targetUser = await prisma.user.findUnique({
      where: { id: targetUserId },
      select: { id: true, language: true, phoneNumber: true, fullName: true }
    });

    if (!targetUser) {
      return NextResponse.json(
        { error: 'Target user not found' },
        { status: 404 }
      );
    }

    // Localize notification
    const userLanguage = NotificationLocalizationService.getUserLanguage(targetUser);
    const localized = NotificationLocalizationService.getLocalizedNotification(
      type,
      userLanguage,
      data || {}
    );

    // Create notification in database
    const notification = await prisma.notification.create({
      data: {
        userId: targetUserId,
        type: type as any, // Cast to NotificationType enum
        title: localized.title,
        message: localized.message,
        data: data || {},
      },
    });

    console.log(`Notification sent to user ${targetUserId}:`, {
      type,
      title: localized.title,
      message: localized.message,
      notificationId: notification.id,
      language: userLanguage,
    });

    return NextResponse.json({
      success: true,
      notification,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
} 