import { NextRequest, NextResponse } from 'next/server';
import { getMessaging, Message } from 'firebase-admin/messaging';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING IOS-COMPATIBLE BACKGROUND ===');
    
    const body = await req.json();
    const { deviceToken } = body;

    if (!deviceToken) {
      return NextResponse.json({ error: 'Device token is required' }, { status: 400 });
    }

    console.log('Testing with device token:', deviceToken.substring(0, 20) + '...');

    // Send a single message with both notification and data
    // This is more iOS-compatible and should work in release mode
    const message: Message = {
      token: deviceToken,
      notification: {
        title: 'New Trip Available!',
        body: 'A new trip request is available in your area. Tap to view details.',
      },
      data: {
        type: 'NEW_TRIP_AVAILABLE',
        tripId: 'test-ios-compatible-123',
        pickupLocation: 'iOS Compatible Test Pickup',
        dropoffLocation: 'iOS Compatible Test Dropoff',
        fare: '5000',
        distance: '5.0',
        userFullName: 'Test User',
        userPhone: '+1234567890',
        timestamp: new Date().toISOString(),
        source: 'ios_compatible_test',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high' as const,
        notification: {
          channelId: 'trip_notifications',
          priority: 'high',
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
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: 'New Trip Available!',
              body: 'A new trip request is available in your area. Tap to view details.',
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
            tripId: 'test-ios-compatible-123',
            pickupLocation: 'iOS Compatible Test Pickup',
            dropoffLocation: 'iOS Compatible Test Dropoff',
            fare: '5000',
            distance: '5.0',
            userFullName: 'Test User',
            userPhone: '+1234567890',
            timestamp: new Date().toISOString(),
            source: 'ios_compatible_test',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        headers: {
          'apns-priority': '10', // High priority for immediate delivery
          'apns-push-type': 'alert', // Alert type for user-visible notifications
        },
      },
    };

    const messaging = getMessaging();
    const response = await messaging.send(message);

    console.log('✅ iOS-compatible notification sent');
    console.log('Message ID:', response);

    return NextResponse.json({
      success: true,
      message: 'iOS-compatible background test completed',
      messageId: response,
      instructions: [
        '1. Put Flutter app in background/closed state',
        '2. This sends a single message with both notification and data',
        '3. Uses iOS-compatible settings (apns-priority: 10, apns-push-type: alert)',
        '4. Check if the background handler processes it',
        '5. Look for "Background Handler Test" notification',
        '6. Check logs for trip detection and background fetch'
      ]
    });

  } catch (error) {
    console.error('❌ Error in iOS-compatible test:', error);
    return NextResponse.json(
      { error: 'Test failed', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 