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

    console.log('🚀 Sending notification for trip:', {
      tripId: trip.id,
      userId: trip.userId,
      userRole: trip.user.role,
      userProvince: trip.user.province,
    });

    // Verify the user is actually a USER (not a driver)
    if (trip.user.role !== 'USER') {
      console.log('❌ User is not a regular user, skipping notification:', {
        userId: trip.userId,
        role: trip.user.role,
      });
      return NextResponse.json({
        success: false,
        message: 'Only regular users can create trips',
        driversNotified: 0,
      });
    }

    // Get all active drivers in the user's province
    const drivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
        province: trip.user.province,
        deviceToken: { not: null },
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true,
        province: true,
        role: true,
        status: true,
      },
    });

    console.log(`🚗 Found ${drivers.length} active drivers in ${trip.user.province}:`);
    drivers.forEach(driver => {
      console.log(`  - ${driver.fullName} (${driver.id}) - Token: ${driver.deviceToken ? `${driver.deviceToken.substring(0, 20)}...` : 'null'}`);
    });

    if (drivers.length === 0) {
      console.log('❌ No active drivers found in province:', trip.user.province);
      return NextResponse.json({
        success: false,
        message: 'No active drivers found in your area',
        driversNotified: 0,
      });
    }

    // Verify each driver's role before sending notification
    const validDrivers = drivers.filter(driver => {
      const isValid = driver.role === 'DRIVER' && driver.status === 'ACTIVE';
      if (!isValid) {
        console.log(`⚠️ Skipping driver ${driver.fullName} (${driver.id}): role=${driver.role}, status=${driver.status}`);
      }
      return isValid;
    });

    console.log(`✅ ${validDrivers.length} valid drivers to notify out of ${drivers.length} total`);

    if (validDrivers.length === 0) {
      console.log('❌ No valid drivers found after role verification');
      return NextResponse.json({
        success: false,
        message: 'No valid drivers found in your area',
        driversNotified: 0,
      });
    }

    // Send notifications to valid drivers
    let driversNotified = 0;
    for (const driver of validDrivers) {
      try {
        // Create notification in database
        await prisma.notification.create({
          data: {
            userId: driver.id,
            type: 'NEW_TRIP_AVAILABLE',
            title: 'New Trip Available',
            message: `New trip from ${trip.pickupLocation} to ${trip.dropoffLocation}`,
            data: {
              tripId: trip.id,
              pickupLocation: trip.pickupLocation,
              dropoffLocation: trip.dropoffLocation,
              price: trip.price,
              distance: trip.distance,
            },
          },
        });

        console.log(`📱 Notification sent to driver ${driver.fullName} (${driver.id})`);
        driversNotified++;
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driver.fullName}:`, error);
      }
    }

    console.log(`✅ Successfully notified ${driversNotified} drivers`);

    return NextResponse.json({
      success: true,
      message: `Notification sent to ${driversNotified} drivers`,
      driversNotified,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
} 