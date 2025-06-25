import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING REAL TRIP EXACT MATCH ===');
    
    const body = await req.json();
    const { deviceToken } = body;

    if (!deviceToken) {
      return NextResponse.json({ error: 'Device token is required' }, { status: 400 });
    }

    console.log('Testing with device token:', deviceToken.substring(0, 20) + '...');

    // Get a test user
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: { id: true, fullName: true, phoneNumber: true, province: true }
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    // Create a test trip with the EXACT same data structure as real trips
    const testTripData = {
      pickupLocation: 'Real Trip Test Pickup',
      dropoffLocation: 'Real Trip Test Dropoff',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      dropoffLat: 33.3152,
      dropoffLng: 44.3661,
      price: 5000,
      distance: 5.0,
      status: 'USER_WAITING',
      tripType: 'ECO',
      driverDeduction: 0,
      userPhone: testUser.phoneNumber,
      userFullName: testUser.fullName,
      userProvince: testUser.province,
      userId: testUser.id
    };

    console.log('Creating test trip with data:', testTripData);

    // Create the trip using the EXACT same process as real trip creation
    const testTrip = await prisma.taxiRequest.create({
      data: testTripData as any
    });

    console.log('✅ Test trip created:', testTrip.id);

    // Get all drivers before notification
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: { id: true, fullName: true, status: true, deviceToken: true }
    });

    console.log(`Found ${allDrivers.length} total drivers:`);
    for (const driver of allDrivers) {
      console.log(`- ${driver.fullName} (${driver.id}) - Status: ${driver.status} - Has Token: ${!!driver.deviceToken}`);
    }

    // Simulate the EXACT notification process from real trip creation
    console.log('\n=== STARTING DRIVER NOTIFICATION PROCESS (REAL SIMULATION) ===');
    console.log('Trip details for notification:', {
      id: testTrip.id,
      pickupLocation: testTrip.pickupLocation,
      dropoffLocation: testTrip.dropoffLocation,
      price: testTrip.price,
      userFullName: testTrip.userFullName,
      userPhone: testTrip.userPhone
    });
    
    // Add a small delay to ensure the trip is fully committed (same as real process)
    await new Promise(resolve => setTimeout(resolve, 100));
    
    console.log('Calling notifyAvailableDriversAboutNewTrip...');
    await notifyAvailableDriversAboutNewTrip(testTrip);
    console.log('✅ All available drivers notified about new trip');
    
    // Verify notifications were created
    const recentNotifications = await prisma.notification.findMany({
      where: {
        type: 'NEW_TRIP_AVAILABLE',
        createdAt: {
          gte: new Date(Date.now() - 1 * 60 * 1000) // Last 1 minute
        }
      },
      include: {
        user: {
          select: { fullName: true, role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    
    console.log(`✅ Verification: ${recentNotifications.length} notifications created for this trip`);

    // Clean up the test trip
    await prisma.taxiRequest.delete({
      where: { id: testTrip.id }
    });

    console.log('✅ Test trip cleaned up');

    return NextResponse.json({
      success: true,
      message: 'Real trip creation simulation completed',
      testTrip: {
        id: testTrip.id,
        pickupLocation: testTrip.pickupLocation,
        dropoffLocation: testTrip.dropoffLocation,
        price: testTrip.price
      },
      notificationsCreated: recentNotifications.length,
      driversFound: allDrivers.length
    });

  } catch (error) {
    console.error('❌ Error in real trip exact match test:', error);
    return NextResponse.json(
      { error: 'Test failed', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 