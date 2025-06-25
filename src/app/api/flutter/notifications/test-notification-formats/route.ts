import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendPushNotification, sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING DIFFERENT NOTIFICATION FORMATS ===');

    // Get all drivers with device tokens
    const drivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        deviceToken: { not: null }
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true
      }
    });

    console.log(`Found ${drivers.length} drivers with device tokens`);

    if (drivers.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'No drivers with device tokens found'
      });
    }

    const results = [];

    // Test 1: Standard notification with title and body
    console.log('\n1. Testing standard notification...');
    try {
      const testData = {
        type: 'TEST_STANDARD',
        tripId: 'test_standard_123',
        timestamp: new Date().toISOString()
      };

      const response = await sendPushNotification({
        token: drivers[0].deviceToken!,
        title: 'Standard Test Notification',
        body: 'This is a standard notification with title and body',
        data: testData
      });

      results.push({
        test: 'Standard Notification',
        status: 'success',
        response: response
      });
      console.log('✅ Standard notification sent');
    } catch (error) {
      results.push({
        test: 'Standard Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Standard notification failed:', error);
    }

    // Test 2: Data-only notification (no title/body in notification object)
    console.log('\n2. Testing data-only notification...');
    try {
      const testData = {
        type: 'TEST_DATA_ONLY',
        tripId: 'test_data_only_456',
        title: 'Data-Only Test Notification',
        body: 'This is a data-only notification - title and body are in data payload',
        timestamp: new Date().toISOString()
      };

      // Send data-only message
      const { getMessaging } = await import('firebase-admin/messaging');
      const dataOnlyMessage = {
        token: drivers[0].deviceToken!,
        data: testData,
        android: {
          priority: 'high' as const,
          data: testData,
        },
        apns: {
          payload: {
            aps: {
              'content-available': 1,
              'mutable-content': 1,
              category: 'trip_notifications',
              'thread-id': 'trip_notifications',
            },
            data: testData,
          },
          headers: {
            'apns-priority': '5',
            'apns-push-type': 'background',
          },
        },
      };

      const response = await getMessaging().send(dataOnlyMessage);
      results.push({
        test: 'Data-Only Notification',
        status: 'success',
        response: response
      });
      console.log('✅ Data-only notification sent');
    } catch (error) {
      results.push({
        test: 'Data-Only Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Data-only notification failed:', error);
    }

    // Test 3: Silent notification (content-available: 1)
    console.log('\n3. Testing silent notification...');
    try {
      const testData = {
        type: 'TEST_SILENT',
        tripId: 'test_silent_789',
        title: 'Silent Test Notification',
        body: 'This is a silent notification that should trigger background processing',
        timestamp: new Date().toISOString()
      };

      const { getMessaging } = await import('firebase-admin/messaging');
      const silentMessage = {
        token: drivers[0].deviceToken!,
        data: testData,
        android: {
          priority: 'high' as const,
          data: testData,
        },
        apns: {
          payload: {
            aps: {
              'content-available': 1,
              category: 'trip_notifications',
              'thread-id': 'trip_notifications',
            },
            data: testData,
          },
          headers: {
            'apns-priority': '5',
            'apns-push-type': 'background',
          },
        },
      };

      const response = await getMessaging().send(silentMessage);
      results.push({
        test: 'Silent Notification',
        status: 'success',
        response: response
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

    // Test 4: Multicast notification to all drivers
    console.log('\n4. Testing multicast notification...');
    try {
      const deviceTokens = drivers.map(d => d.deviceToken!);
      const testData = {
        type: 'TEST_MULTICAST',
        tripId: 'test_multicast_101',
        timestamp: new Date().toISOString()
      };

      const response = await sendMulticastNotification({
        tokens: deviceTokens,
        title: 'Multicast Test Notification',
        body: `This is a multicast notification sent to ${deviceTokens.length} drivers`,
        data: testData
      });

      results.push({
        test: 'Multicast Notification',
        status: 'success',
        response: response
      });
      console.log('✅ Multicast notification sent');
    } catch (error) {
      results.push({
        test: 'Multicast Notification',
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      console.error('❌ Multicast notification failed:', error);
    }

    console.log('\n=== TEST RESULTS ===');
    console.log(JSON.stringify(results, null, 2));

    return NextResponse.json({
      success: true,
      message: 'Notification format tests completed',
      results: results,
      driversTested: drivers.length
    });

  } catch (error) {
    console.error('❌ Error in notification format tests:', error);
    return NextResponse.json(
      { error: 'Failed to test notification formats' },
      { status: 500 }
    );
  }
} 