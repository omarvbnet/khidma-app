import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== SIMPLE NOTIFICATION TEST ===');
    
    // Get the driver
    const driver = await prisma.user.findFirst({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true
      }
    });

    if (!driver) {
      return NextResponse.json({
        success: false,
        error: 'No active driver found'
      });
    }

    console.log(`Testing with driver: ${driver.fullName} (${driver.id})`);

    // Create a simple notification directly
    const notification = await prisma.notification.create({
      data: {
        userId: driver.id,
        type: 'NEW_TRIP_AVAILABLE',
        title: 'Simple Test Notification',
        message: 'This is a simple test notification',
        data: {
          tripId: 'simple_test_123',
          pickupLocation: 'Simple Pickup',
          dropoffLocation: 'Simple Dropoff'
        }
      }
    });

    console.log('✅ Simple notification created:', notification.id);

    // Check if the notification was actually saved
    const savedNotification = await prisma.notification.findUnique({
      where: { id: notification.id },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      }
    });

    console.log('✅ Notification retrieved from database:', savedNotification?.id);

    // Clean up
    await prisma.notification.delete({
      where: { id: notification.id }
    });

    console.log('✅ Test notification cleaned up');

    return NextResponse.json({
      success: true,
      driver: {
        id: driver.id,
        name: driver.fullName,
        hasToken: !!driver.deviceToken
      },
      notification: {
        id: notification.id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        createdAt: notification.createdAt
      },
      verification: {
        saved: !!savedNotification,
        savedId: savedNotification?.id
      }
    });

  } catch (error) {
    console.error('❌ Simple notification test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 