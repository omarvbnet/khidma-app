import { NextRequest, NextResponse } from 'next/server';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING NOTIFICATION-ONLY BACKGROUND ===');
    
    const body = await req.json();
    const { deviceToken } = body;

    if (!deviceToken) {
      return NextResponse.json({ error: 'Device token is required' }, { status: 400 });
    }

    console.log('Testing with device token:', deviceToken.substring(0, 20) + '...');

    // Send ONLY a notification message (with notification object, minimal data)
    const result = await sendMulticastNotification({
      tokens: [deviceToken],
      title: 'New Trip Available!',
      body: 'A new trip request is available in your area. Tap to view details.',
      data: {
        type: 'NEW_TRIP_AVAILABLE',
        timestamp: new Date().toISOString(),
        source: 'notification_only_test',
      },
    });

    console.log('✅ Notification-only background message sent');
    console.log('Result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    return NextResponse.json({
      success: true,
      message: 'Notification-only background test completed',
      result: {
        notificationSuccessCount: result?.notificationResponse?.successCount,
        notificationFailureCount: result?.notificationResponse?.failureCount,
        dataSuccessCount: result?.dataResponse?.successCount,
        dataFailureCount: result?.dataResponse?.failureCount,
      },
      instructions: [
        '1. Put Flutter app in background/closed state',
        '2. This sends a notification message with minimal data',
        '3. Check if the background handler processes it',
        '4. Look for "Background Handler Test" notification',
        '5. Check logs for trip detection and background fetch'
      ]
    });

  } catch (error) {
    console.error('❌ Error in notification-only test:', error);
    return NextResponse.json(
      { error: 'Test failed', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 