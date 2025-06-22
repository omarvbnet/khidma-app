import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING TRIP NOTIFICATION SYSTEM ===');

    // 1. Check active drivers
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      }
    });

    console.log(`Found ${activeDrivers.length} active drivers`);

    if (activeDrivers.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'No active drivers found'
      });
    }

    // 2. Create a test trip
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' }
    });

    if (!testUser) {
      return NextResponse.json({
        success: false,
        error: 'No test user found'
      });
    }

    const testTrip = await prisma.taxiRequest.create({
      data: {
        pickupLocation: 'Test Pickup Location',
        dropoffLocation: 'Test Dropoff Location',
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.3152,
        dropoffLng: 44.3661,
        price: 5000,
        distance: 5.0,
        tripType: 'ECO',
        driverDeduction: 500,
        userProvince: 'Baghdad',
        userPhone: testUser.phoneNumber,
        userFullName: testUser.fullName,
        userId: testUser.id,
        status: 'USER_WAITING'
      }
    });

    console.log(`Created test trip: ${testTrip.id}`);

    // 3. Test notification function
    let notificationResult = 'success';
    try {
      await notifyAvailableDriversAboutNewTrip(testTrip);
      console.log('✅ Notification function completed successfully');
    } catch (error) {
      console.error('❌ Notification function failed:', error);
      notificationResult = `failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
    }

    // 4. Check recent notifications
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 5 * 60 * 1000) // Last 5 minutes
        }
      },
      include: {
        user: true
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    // 5. Clean up test trip
    await prisma.taxiRequest.delete({
      where: { id: testTrip.id }
    });

    // 6. Return results
    return NextResponse.json({
      success: true,
      testTrip: {
        id: testTrip.id,
        pickupLocation: testTrip.pickupLocation,
        dropoffLocation: testTrip.dropoffLocation,
        price: testTrip.price
      },
      drivers: activeDrivers.map(driver => ({
        id: driver.id,
        name: driver.fullName,
        hasToken: !!driver.deviceToken,
        platform: driver.platform
      })),
      notificationResult,
      recentNotifications: recentNotifications.length,
      notificationDetails: recentNotifications.map(n => ({
        id: n.id,
        title: n.title,
        type: n.type,
        userId: n.userId,
        userName: n.user.fullName,
        createdAt: n.createdAt
      }))
    });

  } catch (error) {
    console.error('Error in test trip notification:', error);
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== CHECKING NOTIFICATION SYSTEM STATUS ===');

    // Check active drivers
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      }
    });

    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    const availableDrivers: typeof activeDrivers = [];

    for (const driver of activeDrivers) {
      const activeTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
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
      
      if (activeTrips.length === 0) {
        availableDrivers.push(driver);
      }
    }

    const availableDriversWithTokens = availableDrivers.filter(d => d.deviceToken);

    // Check Firebase environment
    const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;

    return NextResponse.json({
      success: true,
      systemStatus: {
        totalDrivers: activeDrivers.length,
        driversWithTokens: driversWithTokens.length,
        availableDrivers: availableDrivers.length,
        availableDriversWithTokens: availableDriversWithTokens.length,
        firebaseConfigured: hasProjectId && hasClientEmail && hasPrivateKey
      },
      drivers: activeDrivers.map(driver => ({
        id: driver.id,
        name: driver.fullName,
        hasToken: !!driver.deviceToken,
        platform: driver.platform,
        isAvailable: availableDrivers.some(d => d.id === driver.id)
      })),
      firebaseConfig: {
        hasProjectId,
        hasClientEmail,
        hasPrivateKey
      }
    });

  } catch (error) {
    console.error('Error checking notification system status:', error);
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 