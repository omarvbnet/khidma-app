import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING REAL TRIP CREATION FLOW EXACTLY ===');
    
    // Get a test user (same as real flow)
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: {
        id: true,
        fullName: true,
        phoneNumber: true,
        province: true,
      },
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    console.log('Using test user:', testUser);

    // Create trip data exactly like the real flow
    const createData = {
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      dropoffLat: 33.3152,
      dropoffLng: 44.3661,
      price: 5000,
      distance: 5.0,
      status: TaxiRequest_status.USER_WAITING,
      tripType: 'ECO',
      driverDeduction: 0,
      userPhone: testUser.phoneNumber,
      userFullName: testUser.fullName,
      userProvince: testUser.province,
      userId: testUser.id
    } as const;

    console.log('Creating taxi request with data:', createData);

    // Create taxi request (exactly like real flow)
    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('Successfully created taxi request:', taxiRequest);

    // Get all drivers before notification (for comparison)
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: { id: true, fullName: true, status: true, deviceToken: true }
    });

    console.log(`Found ${allDrivers.length} total drivers before notification:`);
    for (const driver of allDrivers) {
      console.log(`- ${driver.fullName} (${driver.id}) - Status: ${driver.status} - Has Token: ${!!driver.deviceToken}`);
    }

    // Notify all available drivers about the new trip (exactly like real flow)
    let notificationResult = 'success';
    let notificationError: Error | null = null;
    
    try {
      console.log('\n=== STARTING DRIVER NOTIFICATION PROCESS ===');
      console.log('Trip details for notification:', {
        id: taxiRequest.id,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation,
        price: taxiRequest.price,
        userFullName: taxiRequest.userFullName,
        userPhone: taxiRequest.userPhone
      });
      
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ All available drivers notified about new trip');
    } catch (error) {
      notificationError = error instanceof Error ? error : new Error('Unknown error');
      console.error('❌ Error notifying drivers about new trip:', notificationError);
      console.error('Notification error details:', {
        message: notificationError.message,
        stack: notificationError.stack || 'No stack trace'
      });
      notificationResult = 'failed';
    }

    // Check if notifications were actually created
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

    // Clean up the test trip
    await prisma.taxiRequest.delete({
      where: { id: taxiRequest.id }
    });

    console.log('✅ Test trip cleaned up');

    return NextResponse.json({
      success: true,
      testTrip: {
        id: taxiRequest.id,
        pickupLocation: taxiRequest.pickupLocation,
        dropoffLocation: taxiRequest.dropoffLocation,
        price: taxiRequest.price,
        status: taxiRequest.status
      },
      drivers: allDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        status: d.status,
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
    console.error('❌ Error in test real trip flow:', error);
    return NextResponse.json({
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
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