import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING NOTIFICATION CREATION ===');
    
    // Get a test driver
    const testDriver = await prisma.user.findFirst({
      where: { role: 'DRIVER' },
      select: { id: true, fullName: true, deviceToken: true }
    });

    if (!testDriver) {
      return NextResponse.json({ error: 'No test driver found' }, { status: 404 });
    }

    console.log('Using test driver:', testDriver);

    // Try to create a notification directly
    const notificationData = {
      tripId: 'test-trip-id',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Test Pickup',
      dropoffLocation: 'Test Dropoff',
      fare: 5000,
      distance: 5.0,
      userFullName: 'Test User',
      userPhone: '1234567890',
    };

    console.log('Creating notification with data:', notificationData);

    // Create notification in database
    const notification = await prisma.notification.create({
      data: {
        userId: testDriver.id,
        type: 'NEW_TRIP_AVAILABLE',
        title: 'New Trip Available!',
        message: 'A new trip request is available in your area. Tap to view details.',
        data: notificationData,
      },
    });

    console.log('✅ Notification created:', notification);

    // Get recent notifications
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 5 * 60 * 1000) // Last 5 minutes
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 10
    });

    return NextResponse.json({
      success: true,
      notificationCreated: {
        id: notification.id,
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        createdAt: notification.createdAt
      },
      testDriver: {
        id: testDriver.id,
        name: testDriver.fullName,
        hasToken: !!testDriver.deviceToken
      },
      recentNotifications: recentNotifications.length,
      notificationDetails: recentNotifications.map(n => ({
        id: n.id,
        userId: n.userId,
        userName: n.user?.fullName,
        userRole: n.user?.role,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt
      }))
    });

  } catch (error) {
    console.error('❌ Error in test notification creation:', error);
    return NextResponse.json({
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : 'No stack trace'
    }, { status: 500 });
  }
} 