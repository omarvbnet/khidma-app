import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { sendPushNotification } from '@/lib/firebase-admin';

// Helper function to check if a driver is available for new trips
async function isDriverAvailable(driverId: string): Promise<boolean> {
  try {
    // Check if driver has any active trips
    const activeTrips = await prisma.taxiRequest.findMany({
      where: {
        driverId: driverId,
        status: {
          in: [
            'DRIVER_ACCEPTED',
            'DRIVER_IN_WAY', 
            'DRIVER_ARRIVED',
            'USER_PICKED_UP',
            'DRIVER_IN_PROGRESS'
          ]
        }
      }
    });

    // Driver is available if they have no active trips
    return activeTrips.length === 0;
  } catch (error) {
    console.error(`Error checking driver availability for ${driverId}:`, error);
    return false;
  }
}

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING DRIVER NOTIFICATIONS ===');

    // Verify authentication
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    let decoded;
    try {
      decoded = verify(token, process.env.JWT_SECRET!);
    } catch (error) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }

    // Get all available drivers (ACTIVE status and no active trips)
    const availableDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
        deviceToken: {
          not: null
        }
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${availableDrivers.length} drivers with device tokens`);

    // Filter to only truly available drivers (no active trips)
    const trulyAvailableDrivers = [];
    for (const driver of availableDrivers) {
      const isAvailable = await isDriverAvailable(driver.id);
      if (isAvailable) {
        trulyAvailableDrivers.push(driver);
      }
    }

    console.log(`Found ${trulyAvailableDrivers.length} truly available drivers`);

    // Send test notification to all available drivers
    const notificationResults = [];
    for (const driver of trulyAvailableDrivers) {
      try {
        const result = await sendPushNotification({
          token: driver.deviceToken!,
          title: 'Test Driver Notification',
          body: 'This is a test notification for available drivers',
          data: {
            type: 'TEST_DRIVER_NOTIFICATION',
            driverId: driver.id,
            timestamp: new Date().toISOString()
          }
        });

        notificationResults.push({
          driverId: driver.id,
          driverName: driver.fullName,
          success: true,
          messageId: result?.notificationResponse || result?.dataResponse || 'unknown'
        });

        console.log(`✅ Notification sent to driver ${driver.fullName} (${driver.id})`);
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driver.fullName}:`, error);
        notificationResults.push({
          driverId: driver.id,
          driverName: driver.fullName,
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    }

    const successfulNotifications = notificationResults.filter(r => r.success).length;
    const failedNotifications = notificationResults.filter(r => !r.success).length;

    console.log(`📊 Notification Results:`);
    console.log(`- Successful: ${successfulNotifications}`);
    console.log(`- Failed: ${failedNotifications}`);

    return NextResponse.json({
      message: `Test notifications sent to ${trulyAvailableDrivers.length} available drivers`,
      totalDrivers: availableDrivers.length,
      availableDrivers: trulyAvailableDrivers.length,
      notificationsSent: successfulNotifications,
      notificationsFailed: failedNotifications,
      results: notificationResults
    });

  } catch (error) {
    console.error('Error testing driver notifications:', error);
    return NextResponse.json(
      { error: 'Failed to test driver notifications' },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== TESTING DRIVER AVAILABILITY ===');

    // Get all active drivers
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers`);

    // Check availability for each driver
    const driverStatus = [];
    for (const driver of allActiveDrivers) {
      const isAvailable = await isDriverAvailable(driver.id);
      
      // Get driver's current trips
      const currentTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
        },
        orderBy: {
          createdAt: 'desc'
        },
        take: 5
      });

      driverStatus.push({
        id: driver.id,
        name: driver.fullName,
        phone: driver.phoneNumber,
        status: driver.status,
        isAvailable,
        hasDeviceToken: !!driver.deviceToken,
        currentTrips: currentTrips.map(trip => ({
          id: trip.id,
          status: trip.status,
          createdAt: trip.createdAt
        }))
      });
    }

    const availableDrivers = driverStatus.filter(d => d.isAvailable);
    const unavailableDrivers = driverStatus.filter(d => !d.isAvailable);

    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Unavailable drivers: ${unavailableDrivers.length}`);

    return NextResponse.json({
      totalDrivers: allActiveDrivers.length,
      availableDrivers: availableDrivers.length,
      unavailableDrivers: unavailableDrivers.length,
      driverDetails: driverStatus
    });

  } catch (error) {
    console.error('Error testing driver availability:', error);
    return NextResponse.json(
      { error: 'Failed to test driver availability' },
      { status: 500 }
    );
  }
} 