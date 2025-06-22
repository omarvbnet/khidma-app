import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== SIMPLE NOTIFICATION TEST ===');

    // Check if we have any drivers
    const drivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER'
      },
      select: {
        id: true,
        fullName: true,
        status: true,
        deviceToken: true
      }
    });

    console.log(`Found ${drivers.length} drivers in system`);

    // Check if we have any active drivers
    const activeDrivers = drivers.filter(d => d.status === 'ACTIVE');
    console.log(`Found ${activeDrivers.length} active drivers`);

    // Check if any drivers have device tokens
    const driversWithTokens = drivers.filter(d => d.deviceToken);
    console.log(`Found ${driversWithTokens.length} drivers with device tokens`);

    // Check Firebase environment variables
    const hasFirebaseProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasFirebaseClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasFirebasePrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;

    console.log('Firebase Environment Variables:');
    console.log(`- FIREBASE_PROJECT_ID: ${hasFirebaseProjectId ? '✅ Set' : '❌ Missing'}`);
    console.log(`- FIREBASE_CLIENT_EMAIL: ${hasFirebaseClientEmail ? '✅ Set' : '❌ Missing'}`);
    console.log(`- FIREBASE_PRIVATE_KEY: ${hasFirebasePrivateKey ? '✅ Set' : '❌ Missing'}`);

    // Try to create a test notification in database
    let testNotification = null;
    if (activeDrivers.length > 0) {
      try {
        testNotification = await prisma.notification.create({
          data: {
            userId: activeDrivers[0].id,
            type: 'NEW_TRIP_AVAILABLE',
            title: 'Test Notification',
            message: 'This is a test notification to verify the system is working',
            data: {
              tripId: 'test_123',
              pickupLocation: 'Test Pickup',
              dropoffLocation: 'Test Dropoff'
            }
          }
        });
        console.log('✅ Test notification created in database');
      } catch (error) {
        console.error('❌ Failed to create test notification:', error);
      }
    }

    const result = {
      totalDrivers: drivers.length,
      activeDrivers: activeDrivers.length,
      driversWithTokens: driversWithTokens.length,
      firebaseConfig: {
        hasProjectId: hasFirebaseProjectId,
        hasClientEmail: hasFirebaseClientEmail,
        hasPrivateKey: hasFirebasePrivateKey
      },
      testNotification: testNotification ? 'Created' : 'Failed',
      driverDetails: drivers.map(d => ({
        id: d.id,
        name: d.fullName,
        status: d.status,
        hasToken: !!d.deviceToken
      }))
    };

    console.log('Test result:', result);
    return NextResponse.json(result);

  } catch (error) {
    console.error('Error in simple test:', error);
    return NextResponse.json(
      { error: 'Failed to run simple test', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 