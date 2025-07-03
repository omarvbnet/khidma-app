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

// Get user notifications
export async function GET(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { searchParams } = new URL(req.url);
    const limit = parseInt(searchParams.get('limit') || '20');
    const offset = parseInt(searchParams.get('offset') || '0');
    const unreadOnly = searchParams.get('unread') === 'true';

    const where = {
      userId,
      ...(unreadOnly && { isRead: false }),
    };

    const notifications = await prisma.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });

    const totalCount = await prisma.notification.count({ where });

    return NextResponse.json({
      notifications,
      totalCount,
      hasMore: offset + limit < totalCount,
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    return NextResponse.json(
      { error: 'Failed to fetch notifications' },
      { status: 500 }
    );
  }
}

// Mark notifications as read
export async function PATCH(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { notificationIds, markAllAsRead } = await req.json();

    if (markAllAsRead) {
      await prisma.notification.updateMany({
        where: { userId, isRead: false },
        data: { isRead: true },
      });
    } else if (notificationIds && Array.isArray(notificationIds)) {
      await prisma.notification.updateMany({
        where: { 
          id: { in: notificationIds },
          userId 
        },
        data: { isRead: true },
      });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error updating notifications:', error);
    return NextResponse.json(
      { error: 'Failed to update notifications' },
      { status: 500 }
    );
  }
} 

// Send notification to drivers for new trip
export async function POST(req: NextRequest) {
  const userId = await verifyToken(req);
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { tripId } = await req.json();

    if (!tripId) {
      return NextResponse.json(
        { error: 'Trip ID is required' },
        { status: 400 }
      );
    }

    // Get the trip details
    const trip = await prisma.taxiRequest.findUnique({
      where: { id: tripId },
      include: { user: true },
    });

    if (!trip) {
      return NextResponse.json(
        { error: 'Trip not found' },
        { status: 404 }
      );
    }

    console.log('🚀 DEPRECATED: This endpoint is deprecated. Notifications are now handled automatically when trips are created.');
    console.log('🚀 Trip details:', {
      tripId: trip.id,
      userId: trip.userId,
      userRole: trip.user.role,
      userProvince: trip.user.province,
    });

    return NextResponse.json({
      success: false,
      message: 'This endpoint is deprecated. Notifications are now handled automatically when trips are created.',
      driversNotified: 0,
    });
  } catch (error) {
    console.error('Error in deprecated notification endpoint:', error);
    return NextResponse.json(
      { error: 'Failed to process request' },
      { status: 500 }
    );
  }
} 