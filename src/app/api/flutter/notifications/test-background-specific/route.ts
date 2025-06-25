import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendPushNotification } from '@/lib/firebase-admin';

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
      const result = await sendPushNotification({
        token: deviceToken,
        title: 'Background Test Trip',
        body: 'This is a background test notification',
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'background_test_123',
          title: 'Background Test Trip',
          body: 'This is a background test notification',
          pickupLocation: 'Background Test Pickup',
          dropoffLocation: 'Background Test Dropoff',
          fare: '25.00',
          timestamp: new Date().toISOString(),
        }
      });
      
      results.push({
        test: 'Pure Data-Only Notification',
        status: 'success',
        messageId: result?.notificationResponse || result?.dataResponse || 'unknown',
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
      const result = await sendPushNotification({
        token: deviceToken,
        title: 'Silent Test Trip',
        body: 'This is a silent test notification',
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'silent_test_456',
          title: 'Silent Test Trip',
          body: 'This is a silent test notification',
          pickupLocation: 'Silent Test Pickup',
          dropoffLocation: 'Silent Test Dropoff',
          fare: '30.00',
          timestamp: new Date().toISOString(),
        }
      });
      
      results.push({
        test: 'Silent Notification',
        status: 'success',
        messageId: result?.notificationResponse || result?.dataResponse || 'unknown',
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
      const result = await sendPushNotification({
        token: deviceToken,
        title: 'Hybrid Test Trip',
        body: 'This is a hybrid test notification',
        data: {
          type: 'NEW_TRIP_AVAILABLE',
          tripId: 'hybrid_test_789',
          title: 'Hybrid Test Trip',
          body: 'This is a hybrid test notification',
          pickupLocation: 'Hybrid Test Pickup',
          dropoffLocation: 'Hybrid Test Dropoff',
          fare: '35.00',
          timestamp: new Date().toISOString(),
        }
      });
      
      results.push({
        test: 'Hybrid Notification',
        status: 'success',
        messageId: result?.notificationResponse || result?.dataResponse || 'unknown',
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