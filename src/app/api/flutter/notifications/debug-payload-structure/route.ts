import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== DEBUGGING PAYLOAD STRUCTURE FOR FLUTTER DETECTION ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    // Use the EXACT same notification structure as real trip creation
    const notificationData = {
      tripId: 'debug-payload-test-123',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Debug Test Pickup',
      dropoffLocation: 'Debug Test Dropoff',
      fare: '5000',
      distance: '5.0',
      userFullName: 'Debug Test User',
      userPhone: '+1234567890',
      userProvince: 'محافظة كركوك',
      // Add debugging fields to help with detection
      type: 'NEW_TRIP_AVAILABLE',
      title: 'New Trip Available!',
      body: 'A new trip request is available in محافظة كركوك. Tap to view details.',
      timestamp: new Date().toISOString(),
      debug: 'true',
      source: 'real_trip_creation',
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${notificationData.userProvince}. Tap to view details.`;
    const type = 'NEW_TRIP_AVAILABLE';

    console.log('Sending notification with debugging payload:');
    console.log('Title:', title);
    console.log('Message:', message);
    console.log('Type:', type);
    console.log('Full notification data:', JSON.stringify(notificationData, null, 2));

    // Use the EXACT same function as real trip creation
    const result = await sendMulticastNotification({
      tokens: [deviceToken],
      title,
      body: message,
      data: {
        ...notificationData,
        type,
      },
    });

    console.log('✅ Debug payload notification sent');
    console.log('Result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    // Create a database notification for tracking
    const testUser = await prisma.user.findFirst({
      where: { role: 'DRIVER' }
    });

    if (testUser) {
      await prisma.notification.create({
        data: {
          userId: testUser.id,
          type: type,
          title: title,
          message: message,
          data: notificationData,
        }
      });
      console.log('✅ Database notification created for debugging');
    }

    // Expected Flutter detection analysis
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
      message: 'Debug payload structure test completed',
      notificationData,
      result: {
        notificationSuccessCount: result?.notificationResponse?.successCount,
        notificationFailureCount: result?.notificationResponse?.failureCount,
        dataSuccessCount: result?.dataResponse?.successCount,
        dataFailureCount: result?.dataResponse?.failureCount,
      },
      expectedFlutterDetection: expectedDetection,
      instructions: 'Check Flutter logs for background handler detection results'
    });

  } catch (error) {
    console.error('❌ Error in debug payload structure test:', error);
    return NextResponse.json(
      { error: 'Failed to test debug payload structure' },
      { status: 500 }
    );
  }
} 