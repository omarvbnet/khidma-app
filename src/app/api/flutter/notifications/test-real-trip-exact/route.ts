import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING REAL TRIP EXACT NOTIFICATION STRUCTURE ===');

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
      tripId: 'test-real-trip-exact-123',
      newStatus: 'NEW_TRIP_AVAILABLE',
      pickupLocation: 'Test Real Trip Pickup',
      dropoffLocation: 'Test Real Trip Dropoff',
      fare: '5000',
      distance: '5.0',
      userFullName: 'Test User',
      userPhone: '+1234567890',
      userProvince: 'محافظة كركوك',
    };

    const title = 'New Trip Available!';
    const message = `A new trip request is available in ${notificationData.userProvince}. Tap to view details.`;
    const type = 'NEW_TRIP_AVAILABLE';

    console.log('Sending notification with EXACT real trip structure:');
    console.log('Title:', title);
    console.log('Message:', message);
    console.log('Data:', notificationData);
    console.log('Type:', type);

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

    console.log('✅ Real trip exact notification sent');
    console.log('Result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    // Also create a database notification like real trip creation does
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
      console.log('✅ Database notification created');
    }

    return NextResponse.json({
      success: true,
      message: 'Real trip exact notification test completed',
      notificationData,
      result: {
        notificationSuccessCount: result?.notificationResponse?.successCount,
        notificationFailureCount: result?.notificationResponse?.failureCount,
        dataSuccessCount: result?.dataResponse?.successCount,
        dataFailureCount: result?.dataResponse?.failureCount,
      }
    });

  } catch (error) {
    console.error('❌ Error in real trip exact notification test:', error);
    return NextResponse.json(
      { error: 'Failed to test real trip exact notification' },
      { status: 500 }
    );
  }
} 