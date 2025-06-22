import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING REAL TRIP CREATION PROCESS ===');
    
    // Get a test user
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: { id: true, fullName: true, phoneNumber: true, province: true }
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    console.log('Using test user:', testUser);

    // Create a test trip with the same data structure as real trips
    const testTripData = {
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
    };

    console.log('Creating test trip with data:', testTripData);

    // Create the trip
    const testTrip = await prisma.taxiRequest.create({
      data: testTripData as any
    });

    console.log('✅ Test trip created:', testTrip);

    // Get all drivers before notification
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: { id: true, fullName: true, status: true, deviceToken: true }
    });

    console.log(`Found ${allDrivers.length} total drivers:`);
    for (const driver of allDrivers) {
      console.log(`- ${driver.fullName} (${driver.id}) - Status: ${driver.status} - Has Token: ${!!driver.deviceToken}`);
    }

    // Call the exact same notification function used in real trip creation
    console.log('\n=== CALLING NOTIFICATION FUNCTION ===');
    await notifyAvailableDriversAboutNewTrip(testTrip);

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

    // Clean up the test trip
    await prisma.taxiRequest.delete({
      where: { id: testTrip.id }
    });

    console.log('✅ Test trip cleaned up');

    return NextResponse.json({
      success: true,
      testTrip: {
        id: testTrip.id,
        pickupLocation: testTrip.pickupLocation,
        dropoffLocation: testTrip.dropoffLocation,
        price: testTrip.price
      },
      drivers: allDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        hasToken: !!d.deviceToken,
        platform: d.deviceToken ? 'ios' : 'none'
      })),
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
    console.error('❌ Error in test real trip creation:', error);
    return NextResponse.json({
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 