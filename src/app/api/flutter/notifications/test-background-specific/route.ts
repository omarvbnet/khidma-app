import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { getMessaging } from 'firebase-admin/messaging';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING BACKGROUND-SPECIFIC NOTIFICATIONS ===');

    const { deviceToken } = await req.json();

    if (!deviceToken) {
      return NextResponse.json(
        { error: 'Device token is required' },
        { status: 400 }
      );
    }

    console.log('Device Token:', deviceToken.substring(0, 20) + '...');

    const results = [];

    // Test 1: Pure data-only notification (should trigger background handler)
    console.log('\n1. Testing pure data-only notification...');
    try {
      const dataOnlyMessage = {
        token: deviceToken,
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'background_test_123',
          title: 'Background Test Trip',
          body: 'This is a background test notification',
          pickupLocation: 'Background Test Pickup',
          dropoffLocation: 'Background Test Dropoff',
          fare: '25.00',
          timestamp: new Date().toISOString(),
        },
        android: {
          priority: 'high' as const,
          data: {
            type: 'NEW_TRIP_AVAILABLE',
            tripId: 'background_test_123',
            title: 'Background Test Trip',
            body: 'This is a background test notification',
            pickupLocation: 'Background Test Pickup',
            dropoffLocation: 'Background Test Dropoff',
            fare: '25.00',
            timestamp: new Date().toISOString(),
          },
        },
        apns: {
          payload: {
            aps: {
              'content-available': 1,
              'mutable-content': 1,
              category: 'trip_notifications',
              'thread-id': 'trip_notifications',
            },
            data: {
              type: 'NEW_TRIP_AVAILABLE',
              tripId: 'background_test_123',
              title: 'Background Test Trip',
              body: 'This is a background test notification',
              pickupLocation: 'Background Test Pickup',
              dropoffLocation: 'Background Test Dropoff',
              fare: '25.00',
              timestamp: new Date().toISOString(),
            },
          },
          headers: {
            'apns-priority': '5',
            'apns-push-type': 'background',
          },
        },
      };

      const messaging = getMessaging();
      const response = await messaging.send(dataOnlyMessage);
      
      results.push({
        test: 'Pure Data-Only Notification',
        status: 'success',
        messageId: response,
        description: 'Should trigger background handler'
      });
      console.log('✅ Pure data-only notification sent');
    } catch (error) {
      results.push({
        test: 'Pure Data-Only Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Pure data-only notification failed:', error);
    }

    // Test 2: Silent notification with minimal aps
    console.log('\n2. Testing silent notification...');
    try {
      const silentMessage = {
        token: deviceToken,
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'silent_test_456',
          title: 'Silent Test Trip',
          body: 'This is a silent test notification',
          pickupLocation: 'Silent Test Pickup',
          dropoffLocation: 'Silent Test Dropoff',
          fare: '30.00',
          timestamp: new Date().toISOString(),
        },
        android: {
          priority: 'high' as const,
          data: {
            type: 'NEW_TRIP_AVAILABLE',
            tripId: 'silent_test_456',
            title: 'Silent Test Trip',
            body: 'This is a silent test notification',
            pickupLocation: 'Silent Test Pickup',
            dropoffLocation: 'Silent Test Dropoff',
            fare: '30.00',
            timestamp: new Date().toISOString(),
          },
        },
        apns: {
          payload: {
            aps: {
              'content-available': 1,
            },
            data: {
              type: 'NEW_TRIP_AVAILABLE',
              tripId: 'silent_test_456',
              title: 'Silent Test Trip',
              body: 'This is a silent test notification',
              pickupLocation: 'Silent Test Pickup',
              dropoffLocation: 'Silent Test Dropoff',
              fare: '30.00',
              timestamp: new Date().toISOString(),
            },
          },
          headers: {
            'apns-priority': '5',
            'apns-push-type': 'background',
          },
        },
      };

      const messaging = getMessaging();
      const response = await messaging.send(silentMessage);
      
      results.push({
        test: 'Silent Notification',
        status: 'success',
        messageId: response,
        description: 'Should trigger background handler with minimal aps'
      });
      console.log('✅ Silent notification sent');
    } catch (error) {
      results.push({
        test: 'Silent Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Silent notification failed:', error);
    }

    // Test 3: Notification with both alert and data (should work in all states)
    console.log('\n3. Testing notification with both alert and data...');
    try {
      const hybridMessage = {
        token: deviceToken,
        notification: {
          title: 'Hybrid Test Trip',
          body: 'This is a hybrid test notification',
        },
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'hybrid_test_789',
          title: 'Hybrid Test Trip',
          body: 'This is a hybrid test notification',
          pickupLocation: 'Hybrid Test Pickup',
          dropoffLocation: 'Hybrid Test Dropoff',
          fare: '35.00',
          timestamp: new Date().toISOString(),
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'trip_notifications',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: '@mipmap/ic_launcher',
            color: '#2196F3',
            sound: 'notification_sound',
            vibrateTimingsMillis: [0, 500, 200, 500],
            lightSettings: {
              color: '#2196F3',
              lightOnDurationMillis: 1000,
              lightOffDurationMillis: 500,
            },
          },
          data: {
            type: 'NEW_TRIP_AVAILABLE',
            tripId: 'hybrid_test_789',
            title: 'Hybrid Test Trip',
            body: 'This is a hybrid test notification',
            pickupLocation: 'Hybrid Test Pickup',
            dropoffLocation: 'Hybrid Test Dropoff',
            fare: '35.00',
            timestamp: new Date().toISOString(),
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: 'Hybrid Test Trip',
                body: 'This is a hybrid test notification',
              },
              sound: 'default',
              badge: 1,
              'content-available': 1,
              'mutable-content': 1,
              category: 'trip_notifications',
              'thread-id': 'trip_notifications',
            },
            data: {
              type: 'NEW_TRIP_AVAILABLE',
              tripId: 'hybrid_test_789',
              title: 'Hybrid Test Trip',
              body: 'This is a hybrid test notification',
              pickupLocation: 'Hybrid Test Pickup',
              dropoffLocation: 'Hybrid Test Dropoff',
              fare: '35.00',
              timestamp: new Date().toISOString(),
            },
          },
          headers: {
            'apns-priority': '10',
            'apns-push-type': 'alert',
          },
        },
      };

      const messaging = getMessaging();
      const response = await messaging.send(hybridMessage);
      
      results.push({
        test: 'Hybrid Notification',
        status: 'success',
        messageId: response,
        description: 'Should work in foreground, background, and closed states'
      });
      console.log('✅ Hybrid notification sent');
    } catch (error) {
      results.push({
        test: 'Hybrid Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Hybrid notification failed:', error);
    }

    console.log('\n=== BACKGROUND TEST RESULTS ===');
    console.log(JSON.stringify(results, null, 2));

    return NextResponse.json({
      success: true,
      message: 'Background-specific notification tests completed',
      results: results
    });

  } catch (error) {
    console.error('❌ Error in background-specific notification tests:', error);
    return NextResponse.json(
      { error: 'Failed to test background-specific notifications' },
      { status: 500 }
    );
  }
} 