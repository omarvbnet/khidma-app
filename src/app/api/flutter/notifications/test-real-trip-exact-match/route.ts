import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING EXACT REAL TRIP NOTIFICATION MATCH ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    // Get a test user to match real trip creation exactly
    const testUser = await prisma.user.findFirst({
      where: { role: 'USER' },
      select: { id: true, fullName: true, phoneNumber: true, province: true }
    });

    if (!testUser) {
      return NextResponse.json({ error: 'No test user found' }, { status: 404 });
    }

    // Create the EXACT same notification data as real trip creation
    const notificationData = {
      tripId: 'exact-match-test-123',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Exact Match Test Pickup',
      dropoffLocation: 'Exact Match Test Dropoff',
      fare: '5000',
      distance: '5.0',
      userFullName: testUser.fullName,
      userPhone: testUser.phoneNumber,
      userProvince: testUser.province,
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${testUser.province}. Tap to view details.`;
    const type = 'NEW_TRIP_AVAILABLE';

    console.log('Sending EXACT real trip notification:');
    console.log('Title:', title);
    console.log('Message:', message);
    console.log('Type:', type);
    console.log('Full notification data:', JSON.stringify(notificationData, null, 2));

    // Use the EXACT same function and structure as real trip creation
    const result = await sendMulticastNotification({
      tokens: [deviceToken],
      title,
      body: message,
      data: {
        ...notificationData,
        type,
      },
    });

    console.log('✅ Exact real trip notification sent');
    console.log('Result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    // Create a database notification for tracking (exactly like real trip creation)
    const testDriver = await prisma.user.findFirst({
      where: { role: 'DRIVER' }
    });

    if (testDriver) {
      await prisma.notification.create({
        data: {
          userId: testDriver.id,
          type: type,
          title: title,
          message: message,
          data: notificationData,
        }
      });
      console.log('✅ Database notification created (exactly like real trip)');
    }

    // Expected Flutter detection analysis for this exact payload
    const expectedDetection = {
      hasNotificationObject: true,
      notificationTitle: title,
      notificationBody: message,
      dataType: type,
      dataKeys: Object.keys(notificationData),
      shouldDetectByMethod1: title.toLowerCase().includes('trip') || message.toLowerCase().includes('trip') || title.toLowerCase().includes('new') || message.toLowerCase().includes('available'),
      shouldDetectByMethod2: type.toLowerCase().includes('trip') || type.toLowerCase().includes('new'),
      shouldDetectByMethod3: ['NEW_TRIP_AVAILABLE', 'NEW_TRIPS_AVAILABLE', 'trip_created', 'new_trip', 'TEST_DRIVER_NOTIFICATION'].includes(type),
      shouldDetectByMethod4: (title + ' ' + message + ' ' + Object.values(notificationData).join(' ')).toLowerCase().includes('trip'),
      shouldDetectByMethod5: true, // From backend source
      shouldDetectByMethod6: true, // Has data payload
    };

    return NextResponse.json({
      success: true,
      message: 'Exact real trip notification match test completed',
      notificationData,
      result: {
        notificationSuccessCount: result?.notificationResponse?.successCount,
        notificationFailureCount: result?.notificationResponse?.failureCount,
        dataSuccessCount: result?.dataResponse?.successCount,
        dataFailureCount: result?.dataResponse?.failureCount,
      },
      expectedFlutterDetection: expectedDetection,
      instructions: [
        '1. Put Flutter app in background/closed state',
        '2. This notification uses EXACT same structure as real trip creation',
        '3. Check if you receive it in background/closed',
        '4. If this works but real trips don\'t, there\'s a timing or race condition issue',
        '5. If this doesn\'t work, there\'s a payload structure issue'
      ]
    });

  } catch (error) {
    console.error('❌ Error in exact real trip notification match test:', error);
    return NextResponse.json(
      { error: 'Failed to test exact real trip notification match' },
      { status: 500 }
    );
  }
} 