import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendPushNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== TESTING NOTIFICATION CREATION DIRECTLY ===');
    
    // Get the driver
    const driver = await prisma.user.findFirst({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        deviceToken: true
      }
    });

    if (!driver) {
      return NextResponse.json({
        success: false,
        error: 'No active driver found'
      });
    }

    console.log(`Testing notification creation for driver: ${driver.fullName} (${driver.id})`);

    // Test 1: Create database notification
    console.log('\n1. Testing database notification creation...');
    let dbNotificationResult = 'failed';
    let dbNotificationError = null;
    let dbNotificationId = null;

    try {
      const dbNotification = await prisma.notification.create({
        data: {
          userId: driver.id,
          type: 'NEW_TRIP_AVAILABLE',
          title: 'Test Notification',
          message: 'This is a test notification',
          data: {
            tripId: 'test_trip_123',
            pickupLocation: 'Test Pickup',
            dropoffLocation: 'Test Dropoff',
            fare: 1000
          }
        }
      });

      dbNotificationId = dbNotification.id;
      dbNotificationResult = 'success';
      console.log('✅ Database notification created:', dbNotification.id);
    } catch (error) {
      dbNotificationError = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Database notification creation failed:', error);
    }

    // Test 2: Test Firebase push notification
    console.log('\n2. Testing Firebase push notification...');
    let firebaseResult = 'failed';
    let firebaseError = null;

    if (driver.deviceToken) {
      try {
        await sendPushNotification({
          token: driver.deviceToken,
          title: 'Test Push Notification',
          body: 'This is a test push notification',
          data: {
            type: 'TEST',
            timestamp: Date.now().toString()
          }
        });

        firebaseResult = 'success';
        console.log('✅ Firebase push notification sent successfully');
      } catch (error) {
        firebaseError = error instanceof Error ? error.message : 'Unknown error';
        console.error('❌ Firebase push notification failed:', error);
      }
    } else {
      firebaseError = 'No device token available';
      console.log('⚠️ No device token available for Firebase test');
    }

    // Test 3: Test the full notification function
    console.log('\n3. Testing full notification function...');
    let fullFunctionResult = 'failed';
    let fullFunctionError = null;

    try {
      const { notifyAvailableDriversAboutNewTrip } = await import('@/lib/notification-service');
      
      const mockTrip = {
        id: `test_${Date.now()}`,
        pickupLocation: 'Test Pickup Location',
        dropoffLocation: 'Test Dropoff Location',
        price: 1000,
        distance: 2.0,
        userFullName: 'Test User',
        userPhone: '+1234567890'
      };

      await notifyAvailableDriversAboutNewTrip(mockTrip);
      fullFunctionResult = 'success';
      console.log('✅ Full notification function completed successfully');
    } catch (error) {
      fullFunctionError = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Full notification function failed:', error);
    }

    // Check if any notifications were created
    const recentNotifications = await prisma.notification.findMany({
      where: {
        userId: driver.id,
        createdAt: {
          gte: new Date(Date.now() - 5 * 60 * 1000) // Last 5 minutes
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Clean up test notification
    if (dbNotificationId) {
      try {
        await prisma.notification.delete({
          where: { id: dbNotificationId }
        });
        console.log('✅ Test notification cleaned up');
      } catch (error) {
        console.log('⚠️ Could not clean up test notification');
      }
    }

    return NextResponse.json({
      success: true,
      driver: {
        id: driver.id,
        name: driver.fullName,
        hasToken: !!driver.deviceToken,
        tokenPreview: driver.deviceToken ? driver.deviceToken.substring(0, 20) + '...' : 'none'
      },
      testResults: {
        databaseNotification: {
          result: dbNotificationResult,
          error: dbNotificationError,
          notificationId: dbNotificationId
        },
        firebasePush: {
          result: firebaseResult,
          error: firebaseError
        },
        fullFunction: {
          result: fullFunctionResult,
          error: fullFunctionError
        }
      },
      recentNotifications: recentNotifications.length,
      notificationDetails: recentNotifications.map(n => ({
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt
      }))
    });

  } catch (error) {
    console.error('❌ Notification creation test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Test failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 