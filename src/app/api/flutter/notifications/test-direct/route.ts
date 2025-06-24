import { NextRequest, NextResponse } from 'next/server';
import { sendMulticastNotification } from '@/lib/firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING DIRECT NOTIFICATION FORMATS ===');

    const { deviceToken, format = 'real' } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');
    console.log('Format:', format);

    if (format === 'real') {
      // Test real format (same as trip creation)
      console.log('Testing REAL format (same as trip creation)...');
      
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
      const message = 'A new trip request is available in Test Province. Tap to view details.';

      const result = await sendMulticastNotification({
        tokens: [deviceToken],
        title,
        body: message,
        data: notificationData,
      });

      console.log('✅ Real format notification sent:', {
        successCount: result?.successCount,
        failureCount: result?.failureCount,
      });

      return NextResponse.json({
        message: 'Real format notification sent',
        format: 'real',
        successCount: result?.successCount || 0,
        failureCount: result?.failureCount || 0,
        notificationData,
      });

    } else if (format === 'data-only') {
      // Test data-only format (like working test)
      console.log('Testing DATA-ONLY format (like working test)...');
      
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
            'apns-priority': '5',
            'apns-push-type': 'background',
          },
        },
        tokens: [deviceToken],
      };

      const result = await messaging.sendEachForMulticast(message);

      console.log('✅ Data-only format notification sent:', {
        successCount: result.successCount,
        failureCount: result.failureCount,
      });

      return NextResponse.json({
        message: 'Data-only format notification sent',
        format: 'data-only',
        successCount: result.successCount,
        failureCount: result.failureCount,
        notificationData,
      });

    } else {
      return NextResponse.json(
        { error: 'Invalid format. Use "real" or "data-only"' },
        { status: 400 }
      );
    }

  } catch (error) {
    console.error('Error testing direct notification formats:', error);
    return NextResponse.json(
      { error: 'Failed to test notification formats' },
      { status: 500 }
    );
  }
} 