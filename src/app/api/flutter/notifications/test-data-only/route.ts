import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { getMessaging } from 'firebase-admin/messaging';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING DATA-ONLY NOTIFICATION FORMAT ===');

    // Verify authentication
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    let decoded;
    try {
      decoded = verify(token, process.env.JWT_SECRET!);
    } catch (error) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }

    // Get all available drivers
    const availableDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE',
        deviceToken: {
          not: null
        }
      },
      include: {
        driver: true
      }
    });

    console.log(`Found ${availableDrivers.length} drivers with device tokens`);

    if (availableDrivers.length === 0) {
      return NextResponse.json({
        message: 'No drivers with device tokens found',
        totalDrivers: 0,
        notificationsSent: 0
      });
    }

    // Collect device tokens
    const deviceTokens = availableDrivers.map(driver => driver.deviceToken!);

    // Send DATA-ONLY notification (no notification object)
    const notificationData = {
      tripId: 'test-trip-456',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
      fare: '25.00',
      distance: '5.2',
      userFullName: 'Test User',
      userPhone: '+1234567890',
      userProvince: 'Test Province',
      type: 'NEW_TRIP_AVAILABLE',
      title: 'New Trip Available!',
      body: 'A new trip request is available in Test Province. Tap to view details.',
    };

    console.log('Sending data-only notification...');
    console.log('Data:', notificationData);
    console.log('Tokens count:', deviceTokens.length);

    const messaging = getMessaging();
    const message = {
      data: notificationData,
      android: {
        priority: 'high' as const,
        data: notificationData,
      },
      apns: {
        payload: {
          aps: {
            'content-available': 1,
            'mutable-content': 1,
          },
        },
        headers: {
          'apns-priority': '5', // Lower priority for data-only
          'apns-push-type': 'background',
        },
      },
      tokens: deviceTokens,
    };

    const result = await messaging.sendEachForMulticast(message);

    console.log('✅ Data-only notification sent:', {
      successCount: result.successCount,
      failureCount: result.failureCount,
    });

    return NextResponse.json({
      message: `Data-only test notification sent to ${availableDrivers.length} drivers`,
      totalDrivers: availableDrivers.length,
      notificationsSent: result.successCount,
      notificationsFailed: result.failureCount,
      format: 'data_only_format',
      notificationData,
      result
    });

  } catch (error) {
    console.error('Error testing data-only notification format:', error);
    return NextResponse.json(
      { error: 'Failed to test data-only notification format' },
      { status: 500 }
    );
  }
} 