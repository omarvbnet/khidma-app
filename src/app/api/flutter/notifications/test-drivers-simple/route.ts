import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
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
    console.log('\n=== SIMPLE DRIVER NOTIFICATION TEST ===');

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
          title: '🚕 Test Driver Notification',
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
          phone: driver.phoneNumber,
          success: true,
          messageId: result?.notificationResponse || result?.dataResponse || 'unknown'
        });

        console.log(`✅ Notification sent to driver ${driver.fullName} (${driver.id})`);
      } catch (error) {
        console.error(`❌ Failed to send notification to driver ${driver.fullName}:`, error);
        notificationResults.push({
          driverId: driver.id,
          driverName: driver.fullName,
          phone: driver.phoneNumber,
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
      success: true,
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
      { 
        success: false,
        error: 'Failed to test driver notifications',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== CHECKING DRIVER STATUS ===');

    // Get all drivers with their status
    const allDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER'
      },
      include: {
        driver: true
      }
    });

    const driverStatus = [];
    for (const driver of allDrivers) {
      const isAvailable = await isDriverAvailable(driver.id);
      
      driverStatus.push({
        id: driver.id,
        name: driver.fullName,
        phone: driver.phoneNumber,
        status: driver.status,
        isAvailable,
        hasDeviceToken: !!driver.deviceToken,
        deviceTokenPreview: driver.deviceToken ? 
          `${driver.deviceToken.substring(0, 20)}...` : 'None'
      });
    }

    const activeDrivers = driverStatus.filter(d => d.status === 'ACTIVE');
    const availableDrivers = driverStatus.filter(d => d.isAvailable);
    const driversWithTokens = driverStatus.filter(d => d.hasDeviceToken);

    return NextResponse.json({
      success: true,
      totalDrivers: allDrivers.length,
      activeDrivers: activeDrivers.length,
      availableDrivers: availableDrivers.length,
      driversWithTokens: driversWithTokens.length,
      driverDetails: driverStatus
    });

  } catch (error) {
    console.error('Error checking driver status:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Failed to check driver status',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
} 