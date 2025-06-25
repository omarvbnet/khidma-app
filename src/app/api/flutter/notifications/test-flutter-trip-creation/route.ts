import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaxiRequest_status } from '@prisma/client';
import { notifyAvailableDriversAboutNewTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING FLUTTER TRIP CREATION PROCESS ===');
    
    const body = await req.json();
    console.log('Received Flutter trip data:', body);

    // Get a test user
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: { id: true, fullName: true, phoneNumber: true, province: true }
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    // Use the exact same data structure as Flutter sends
    const createData = {
      pickupLocation: body.pickupLocation || 'Flutter Test Pickup',
      dropoffLocation: body.dropoffLocation || 'Flutter Test Dropoff',
      pickupLat: Number(body.pickupLat) || 33.3152,
      pickupLng: Number(body.pickupLng) || 44.3661,
      dropoffLat: Number(body.dropoffLat) || 33.3152,
      dropoffLng: Number(body.dropoffLng) || 44.3661,
      price: Number(body.price) || 5000,
      distance: Number(body.distance) || 5.0,
      status: TaxiRequest_status.USER_WAITING,
      tripType: body.tripType || 'ECO',
      driverDeduction: Number(body.driverDeduction) || 0,
      userPhone: body.userPhone || testUser.phoneNumber,
      userFullName: body.userFullName || testUser.fullName,
      userProvince: body.userProvince || testUser.province,
      userId: testUser.id
    };

    console.log('Creating trip with Flutter data:', createData);

    // Create the trip using the EXACT same process as Flutter
    const taxiRequest = await prisma.taxiRequest.create({
      data: createData as any
    });

    console.log('✅ Flutter trip created:', taxiRequest.id);

    // Get all drivers before notification
    const allDrivers = await prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: { id: true, fullName: true, status: true, deviceToken: true }
    });

    console.log(`Found ${allDrivers.length} total drivers:`);
    for (const driver of allDrivers) {
      console.log(`- ${driver.fullName} (${driver.id}) - Status: ${driver.status} - Has Token: ${!!driver.deviceToken}`);
    }

    // Call the EXACT same notification function as real trip creation
    console.log('\n=== CALLING NOTIFICATION FUNCTION ===');
    try {
      console.log('Calling notifyAvailableDriversAboutNewTrip...');
      await notifyAvailableDriversAboutNewTrip(taxiRequest);
      console.log('✅ All available drivers notified about new trip');
    } catch (notificationError) {
      console.error('❌ Error notifying drivers about new trip:', notificationError);
      console.error('Notification error details:', {
        message: notificationError instanceof Error ? notificationError.message : 'Unknown error',
        stack: notificationError instanceof Error ? notificationError.stack : 'No stack trace'
      });
    }

    // Check if notifications were created
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
      where: { id: taxiRequest.id }
    });

    return NextResponse.json({
      success: true,
      message: 'Flutter trip creation test completed',
      tripCreated: taxiRequest.id,
      notificationsCreated: recentNotifications.length,
      notificationDetails: recentNotifications.map(n => ({
        id: n.id,
        userId: n.userId,
        userFullName: n.user?.fullName,
        type: n.type,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt
      })),
      analysis: {
        tripData: createData,
        driverCount: allDrivers.length,
        driversWithTokens: allDrivers.filter(d => d.deviceToken).length
      }
    });

  } catch (error) {
    console.error('❌ Error in Flutter trip creation test:', error);
    return NextResponse.json({
      success: false,
      error: 'Flutter trip creation test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 