import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { verify } from 'jsonwebtoken';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING REAL NOTIFICATION FORMAT ===');

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

    // Send notification in EXACT same format as real trip creation
    const notificationData = {
      tripId: 'test-trip-123',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Test Pickup Location',
      dropoffLocation: 'Test Dropoff Location',
      fare: '25.00',
      distance: '5.2',
      userFullName: 'Test User',
      userPhone: '+1234567890',
      userProvince: 'Test Province',
      type: 'NEW_TRIP_AVAILABLE',
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in Test Province. Tap to view details.`;

    console.log('Sending multicast notification with real format...');
    console.log('Title:', title);
    console.log('Message:', message);
    console.log('Data:', notificationData);
    console.log('Tokens count:', deviceTokens.length);

    const result = await sendMulticastNotification({
      tokens: deviceTokens,
      title,
      body: message,
      data: notificationData,
    });

    console.log('✅ Multicast notification sent:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    return NextResponse.json({
      message: `Test notification sent in real format to ${availableDrivers.length} drivers`,
      totalDrivers: availableDrivers.length,
      notificationSuccessCount: result?.notificationResponse?.successCount || 0,
      notificationFailureCount: result?.notificationResponse?.failureCount || 0,
      dataSuccessCount: result?.dataResponse?.successCount || 0,
      dataFailureCount: result?.dataResponse?.failureCount || 0,
      format: 'real_trip_creation_format',
      notificationData,
      result
    });

  } catch (error) {
    console.error('Error testing real notification format:', error);
    return NextResponse.json(
      { error: 'Failed to test real notification format' },
      { status: 500 }
    );
  }
} 