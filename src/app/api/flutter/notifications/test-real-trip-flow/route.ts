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

    // Verify authentication
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    let decoded: any;
    try {
      decoded = verify(token, process.env.JWT_SECRET!);
    } catch (error) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }

    // Get user details to determine province
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    console.log('User province:', user.province);

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
      userPhone: user.phoneNumber,
      userFullName: user.fullName,
      userProvince: user.province,
      userId: user.id,
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
        province: user.province, // Only drivers in the same province
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${allActiveDrivers.length} total active drivers in province: ${user.province}`);

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

    console.log(`Found ${availableDrivers.length} available drivers in ${user.province} to notify`);

    // If no available drivers found in the same province, log this information
    if (availableDrivers.length === 0) {
      console.log(`⚠️ No available drivers found in province: ${user.province}`);
      console.log(`📊 Trip will not be visible to drivers outside of ${user.province}`);
      
      return NextResponse.json({
        message: 'No available drivers found in same province',
        userProvince: user.province,
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
    await notifyAvailableDriversAboutNewTrip(mockTrip);
    console.log('✅ notifyAvailableDriversAboutNewTrip completed');

    return NextResponse.json({
      message: `Real trip creation flow test completed`,
      userProvince: user.province,
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