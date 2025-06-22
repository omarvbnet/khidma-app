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
    console.log('\n=== TESTING SIMPLE NOTIFICATION ===');

    // Get all drivers
    const allDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER'
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allDrivers.length} total drivers`);

    // Get active drivers
    const activeDrivers = allDrivers.filter(d => d.status === 'ACTIVE');
    console.log(`Active drivers: ${activeDrivers.length}`);

    // Check availability for each driver
    const driverStatus = [];
    for (const driver of activeDrivers) {
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

    const availableDrivers = driverStatus.filter(d => d.isAvailable);
    const driversWithTokens = driverStatus.filter(d => d.hasDeviceToken);

    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Drivers with tokens: ${driversWithTokens.length}`);

    // Send test notification to all drivers with tokens
    const notificationResults = [];
    for (const driver of driversWithTokens) {
      try {
        const driverUser = allDrivers.find(d => d.id === driver.id);
        if (driverUser?.deviceToken) {
          console.log(`Sending test notification to ${driver.name}...`);
          
          await sendPushNotification({
            token: driverUser.deviceToken,
            title: 'Test Notification',
            body: 'This is a test notification from the server',
            data: {
              type: 'TEST',
              message: 'Test notification sent successfully',
              timestamp: new Date().toISOString()
            },
          });

          notificationResults.push({
            driverId: driver.id,
            driverName: driver.name,
            status: 'SUCCESS',
            message: 'Notification sent successfully'
          });

          console.log(`✅ Test notification sent to ${driver.name}`);
        }
      } catch (error) {
        console.error(`❌ Failed to send test notification to ${driver.name}:`, error);
        notificationResults.push({
          driverId: driver.id,
          driverName: driver.name,
          status: 'FAILED',
          message: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    }

    return NextResponse.json({
      success: true,
      totalDrivers: allDrivers.length,
      activeDrivers: activeDrivers.length,
      availableDrivers: availableDrivers.length,
      driversWithTokens: driversWithTokens.length,
      notificationResults,
      driverDetails: driverStatus
    });

  } catch (error) {
    console.error('Error testing simple notification:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Failed to test notification',
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