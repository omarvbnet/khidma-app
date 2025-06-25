import { NextRequest, NextResponse } from 'next/server';
import { sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING SIMPLE BACKGROUND NOTIFICATION ===');
    
    const body = await req.json();
    const { deviceToken } = body;

    if (!deviceToken) {
      return NextResponse.json({ error: 'Device token is required' }, { status: 400 });
    }

    console.log('Testing with device token:', deviceToken.substring(0, 20) + '...');

    // Send ONLY a data-only message (no notification object)
    // This simulates what happens when the background handler receives a data-only message
    const result = await sendMulticastNotification({
      tokens: [deviceToken],
      title: '', // Empty title - no notification object
      body: '', // Empty body - no notification object
      data: {
        type: 'NEW_TRIP_AVAILABLE',
        tripId: 'test-simple-background-123',
        pickupLocation: 'Simple Test Pickup',
        dropoffLocation: 'Simple Test Dropoff',
        fare: '5000',
        distance: '5.0',
        userFullName: 'Test User',
        userPhone: '+1234567890',
        timestamp: new Date().toISOString(),
        source: 'simple_background_test',
      },
    });

    console.log('✅ Simple background notification sent');
    console.log('Result:', {
      notificationSuccessCount: result?.notificationResponse?.successCount,
      notificationFailureCount: result?.notificationResponse?.failureCount,
      dataSuccessCount: result?.dataResponse?.successCount,
      dataFailureCount: result?.dataResponse?.failureCount,
    });

    return NextResponse.json({
      success: true,
      message: 'Simple background notification test completed',
      result: {
        notificationSuccessCount: result?.notificationResponse?.successCount,
        notificationFailureCount: result?.notificationResponse?.failureCount,
        dataSuccessCount: result?.dataResponse?.successCount,
        dataFailureCount: result?.dataResponse?.failureCount,
      },
      instructions: [
        '1. Put Flutter app in background/closed state',
        '2. This sends ONLY a data-only message (no notification object)',
        '3. Check if the background handler processes it',
        '4. Look for "Background Handler Test" notification',
        '5. Check logs for trip detection and background fetch'
      ]
    });

  } catch (error) {
    console.error('❌ Error in simple background test:', error);
    return NextResponse.json(
      { error: 'Test failed', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
} 