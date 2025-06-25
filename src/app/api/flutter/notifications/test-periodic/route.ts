import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { startPeriodicNotificationsForTrip } from '@/lib/notification-service';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING PERIODIC NOTIFICATIONS ===');

    const { deviceToken, userProvince = 'محافظة كركوك' } = await req.json();

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

    // Create a mock trip for testing periodic notifications
    const mockTrip = {
      id: 'test-periodic-' + Date.now(),
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

    console.log('Mock trip created for periodic testing:', {
      id: mockTrip.id,
      pickupLocation: mockTrip.pickupLocation,
      dropoffLocation: mockTrip.dropoffLocation,
      price: mockTrip.price,
      userProvince: mockTrip.userProvince
    });

    // Start periodic notifications
    console.log('Starting periodic notifications...');
    await startPeriodicNotificationsForTrip(mockTrip);
    console.log('✅ Periodic notifications started');

    return NextResponse.json({
      message: 'Periodic notifications test started',
      tripId: mockTrip.id,
      userProvince: userProvince,
      driver: {
        id: driver.id,
        name: driver.fullName,
        province: driver.province,
        hasDeviceToken: !!driver.deviceToken
      },
      instructions: [
        'Periodic notifications will be sent every 30 seconds',
        'Notifications will stop after 10 minutes or when trip status changes',
        'Check your device for notifications every 30 seconds',
        'To stop notifications, change trip status to DRIVER_ACCEPTED or other non-waiting status'
      ]
    });

  } catch (error) {
    console.error('Error testing periodic notifications:', error);
    return NextResponse.json(
      { error: 'Failed to test periodic notifications' },
      { status: 500 }
    );
  }
} 