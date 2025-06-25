import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

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
    console.log('\n=== TESTING REAL TRIP CREATION FLOW ===');

    const { deviceToken, userProvince = 'Riyadh' } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');
    console.log('User Province:', userProvince);

    // Find the driver with this device token
    const driver = await prisma.user.findFirst({
      where: {
        role: 'DRIVER',
        deviceToken: deviceToken
      },
      include: {
        driver: true
      }
    });

    if (!driver) {
      return NextResponse.json(
        { error: 'Driver with this device token not found' },
        { status: 404 }
      );
    }

    console.log('Found driver:', driver.fullName, 'in province:', driver.province);

    // Create a mock trip with the same structure as real trip creation
    const mockTrip = {
      id: 'test-trip-flow-' + Date.now(),
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
      pickupLat: 24.7136,
      pickupLng: 46.6753,
      dropoffLat: 24.7136,
      dropoffLng: 46.6753,
      price: 25.00,
      distance: 5.2,
      status: 'USER_WAITING',
      tripType: 'ECO',
      driverDeduction: 0,
      userPhone: '+1234567890',
      userFullName: 'Test User',
      userProvince: userProvince,
      userId: 'test-user-id',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    console.log('Mock trip created:', {
      id: mockTrip.id,
      pickupLocation: mockTrip.pickupLocation,
      dropoffLocation: mockTrip.dropoffLocation,
      price: mockTrip.price,
      userFullName: mockTrip.userFullName,
      userPhone: mockTrip.userPhone,
      userProvince: mockTrip.userProvince
    });

    // Get all active drivers in the same province as the user
    const allActiveDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE', // Only active drivers
        province: userProvince, // Only drivers in the same province
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers in province: ${userProvince}`);

    // Log driver details for debugging
    for (const driver of allActiveDrivers) {
      console.log(`- Driver: ${driver.fullName} (${driver.id}) - Province: ${driver.province} - Status: ${driver.status} - Has Token: ${!!driver.deviceToken}`);
    }

    // Filter to only available drivers (those without active trips)
    const availableDrivers = [];
    for (const driver of allActiveDrivers) {
      console.log(`\n--- Checking availability for ${driver.fullName} (${driver.id}) ---`);
      const isAvailable = await isDriverAvailable(driver.id);
      console.log(`Driver ${driver.fullName} (${driver.id}) - Available: ${isAvailable}`);
      if (isAvailable) {
        availableDrivers.push(driver);
        console.log(`✅ Added ${driver.fullName} to available drivers list`);
      } else {
        console.log(`❌ ${driver.fullName} is busy, not adding to available list`);
      }
    }

    console.log(`Found ${availableDrivers.length} available drivers in ${userProvince} to notify`);

    // If no available drivers found in the same province, log this information
    if (availableDrivers.length === 0) {
      console.log(`⚠️ No available drivers found in province: ${userProvince}`);
      console.log(`📊 Trip will not be visible to drivers outside of ${userProvince}`);
      
      return NextResponse.json({
        message: 'No available drivers found in same province',
        userProvince: userProvince,
        totalActiveDrivers: allActiveDrivers.length,
        availableDrivers: 0,
        mockTrip: {
          id: mockTrip.id,
          pickupLocation: mockTrip.pickupLocation,
          dropoffLocation: mockTrip.dropoffLocation,
          price: mockTrip.price,
          userProvince: mockTrip.userProvince
        }
      });
    }

    // Call the exact same function used in real trip creation
    console.log('Calling notifyAvailableDriversAboutNewTrip...');
    
    let notificationResult = null;
    let notificationError: any = null;
    
    try {
      await notifyAvailableDriversAboutNewTrip(mockTrip);
      console.log('✅ notifyAvailableDriversAboutNewTrip completed successfully');
      notificationResult = 'success';
    } catch (error) {
      notificationError = error;
      console.error('❌ notifyAvailableDriversAboutNewTrip failed:', error);
      console.error('Error details:', {
        message: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : 'No stack trace'
      });
      notificationResult = 'failed';
    }

    // Check if notifications were actually created in database
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 2 * 60 * 1000) // Last 2 minutes
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    console.log(`Found ${recentNotifications.length} recent NEW_TRIP_AVAILABLE notifications`);

    return NextResponse.json({
      message: `Real trip creation flow test completed`,
      userProvince: userProvince,
      totalActiveDrivers: allActiveDrivers.length,
      availableDrivers: availableDrivers.length,
      mockTrip: {
        id: mockTrip.id,
        pickupLocation: mockTrip.pickupLocation,
        dropoffLocation: mockTrip.dropoffLocation,
        price: mockTrip.price,
        userProvince: mockTrip.userProvince
      },
      driversNotified: availableDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        hasToken: !!d.deviceToken
      })),
      notificationResult,
      notificationError: notificationError?.message || null,
      notificationsCreated: recentNotifications.length,
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
    console.error('Error testing real trip creation flow:', error);
    return NextResponse.json(
      { error: 'Failed to test real trip creation flow' },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== COMPARING TEST VS REAL FLOW ===');
    
    // Check what's different between test and real flow
    const activeDrivers = await prisma.user.findMany({
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

    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    
    // Check recent trips to see if any were created
    const recentTrips = await prisma.taxiRequest.findMany({
      where: {
        createdAt: {
          gte: new Date(Date.now() - 10 * 60 * 1000) // Last 10 minutes
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 5
    });

    // Check recent notifications
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 10 * 60 * 1000) // Last 10 minutes
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    return NextResponse.json({
      success: true,
      comparison: {
        activeDrivers: activeDrivers.length,
        driversWithTokens: driversWithTokens.length,
        recentTrips: recentTrips.length,
        recentNotifications: recentNotifications.length
      },
      recentTrips: recentTrips.map(t => ({
        id: t.id,
        status: t.status,
        createdAt: t.createdAt,
        pickupLocation: t.pickupLocation
      })),
      recentNotifications: recentNotifications.map(n => ({
        id: n.id,
        userId: n.userId,
        userName: n.user?.fullName,
        createdAt: n.createdAt
      }))
    });

  } catch (error) {
    console.error('❌ Comparison check failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Comparison failed'
    }, { status: 500 });
  }
} 