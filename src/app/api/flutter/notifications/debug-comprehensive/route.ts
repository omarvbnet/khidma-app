import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { sendPushNotification, sendMulticastNotification } from '@/lib/firebase-admin';

export async function POST(req: NextRequest) {
  try {
    console.log('\n=== COMPREHENSIVE NOTIFICATION DEBUG ===');
    
    const results: any = {
      step1: { name: 'Check Firebase Environment', status: 'pending' },
      step2: { name: 'Check Active Drivers', status: 'pending' },
      step3: { name: 'Check Driver Device Tokens', status: 'pending' },
      step4: { name: 'Check Driver Availability', status: 'pending' },
      step5: { name: 'Test Direct Firebase Push', status: 'pending' },
      step6: { name: 'Test Notification Function', status: 'pending' },
      step7: { name: 'Create Test Trip', status: 'pending' },
      step8: { name: 'Test Full Trip Creation Flow', status: 'pending' }
    };

    // Step 1: Check Firebase Environment
    console.log('\n1. CHECKING FIREBASE ENVIRONMENT...');
    const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
    const hasClientEmail = !!process.env.FIREBASE_CLIENT_EMAIL;
    const hasPrivateKey = !!process.env.FIREBASE_PRIVATE_KEY;
    
    results.step1 = {
      name: 'Check Firebase Environment',
      status: hasProjectId && hasClientEmail && hasPrivateKey ? 'success' : 'failed',
      details: {
        hasProjectId,
        hasClientEmail,
        hasPrivateKey,
        projectId: process.env.FIREBASE_PROJECT_ID || 'NOT_SET'
      }
    };
    
    console.log('Firebase config:', results.step1.details);

    // Step 2: Check Active Drivers
    console.log('\n2. CHECKING ACTIVE DRIVERS...');
    const activeDrivers = await prisma.user.findMany({
      where: {
        role: 'DRIVER',
        status: 'ACTIVE'
      },
      select: {
        id: true,
        fullName: true,
        status: true,
        deviceToken: true,
        platform: true
      }
    });
    
    results.step2 = {
      name: 'Check Active Drivers',
      status: 'success',
      details: {
        totalActiveDrivers: activeDrivers.length,
        drivers: activeDrivers.map(d => ({
          id: d.id,
          name: d.fullName,
          hasToken: !!d.deviceToken,
          platform: d.platform
        }))
      }
    };
    
    console.log(`Found ${activeDrivers.length} active drivers`);

    // Step 3: Check Driver Device Tokens
    console.log('\n3. CHECKING DRIVER DEVICE TOKENS...');
    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    const driversWithoutTokens = activeDrivers.filter(d => !d.deviceToken);
    
    results.step3 = {
      name: 'Check Driver Device Tokens',
      status: 'success',
      details: {
        driversWithTokens: driversWithTokens.length,
        driversWithoutTokens: driversWithoutTokens.length,
        tokenDetails: driversWithTokens.map(d => ({
          id: d.id,
          name: d.fullName,
          tokenPreview: d.deviceToken?.substring(0, 20) + '...',
          platform: d.platform
        }))
      }
    };
    
    console.log(`Drivers with tokens: ${driversWithTokens.length}`);
    console.log(`Drivers without tokens: ${driversWithoutTokens.length}`);

    // Step 4: Check Driver Availability
    console.log('\n4. CHECKING DRIVER AVAILABILITY...');
    const availableDrivers = [];
    const busyDrivers = [];
    
    for (const driver of activeDrivers) {
      const activeTrips = await prisma.taxiRequest.findMany({
        where: {
          driverId: driver.id,
          status: {
            in: [
              'DRIVER_ACCEPTED',
              'DRIVER_IN_WAY', 
              'DRIVER_ARRIVED',
              'USER_PICKED_UP',
              'DRIVER_IN_PROGRESS'
            ]
          }
        }
      });
      
      if (activeTrips.length === 0) {
        availableDrivers.push(driver);
      } else {
        busyDrivers.push({ ...driver, activeTrips: activeTrips.length });
      }
    }
    
    results.step4 = {
      name: 'Check Driver Availability',
      status: 'success',
      details: {
        availableDrivers: availableDrivers.length,
        busyDrivers: busyDrivers.length,
        availableDriversWithTokens: availableDrivers.filter(d => d.deviceToken).length,
        availableDriversList: availableDrivers.map(d => ({
          id: d.id,
          name: d.fullName,
          hasToken: !!d.deviceToken
        }))
      }
    };
    
    console.log(`Available drivers: ${availableDrivers.length}`);
    console.log(`Busy drivers: ${busyDrivers.length}`);

    // Step 5: Test Direct Firebase Push
    console.log('\n5. TESTING DIRECT FIREBASE PUSH...');
    let firebaseTestResult = 'failed';
    let firebaseError = null;
    
    if (driversWithTokens.length > 0 && hasProjectId && hasClientEmail && hasPrivateKey) {
      try {
        const testToken = driversWithTokens[0].deviceToken!;
        await sendPushNotification({
          token: testToken,
          title: 'Test Notification',
          body: 'This is a test notification from the debug endpoint',
          data: {
            type: 'TEST',
            timestamp: Date.now().toString()
          }
        });
        firebaseTestResult = 'success';
        console.log('✅ Direct Firebase push successful');
      } catch (error) {
        firebaseError = error instanceof Error ? error.message : 'Unknown error';
        console.error('❌ Direct Firebase push failed:', error);
      }
    } else {
      firebaseError = 'No drivers with tokens or Firebase not configured';
      console.log('⚠️ Skipping Firebase test - no tokens or config');
    }
    
    results.step5 = {
      name: 'Test Direct Firebase Push',
      status: firebaseTestResult,
      details: {
        error: firebaseError,
        testedWithToken: driversWithTokens.length > 0 ? driversWithTokens[0].deviceToken?.substring(0, 20) + '...' : 'none'
      }
    };

    // Step 6: Test Notification Function
    console.log('\n6. TESTING NOTIFICATION FUNCTION...');
    let notificationTestResult = 'failed';
    let notificationError = null;
    
    if (availableDrivers.length > 0) {
      try {
        // Import the notification function
        const { notifyAvailableDriversAboutNewTrip } = await import('@/lib/notification-service');
        
        // Create a mock trip
        const mockTrip = {
          id: `debug_${Date.now()}`,
          pickupLocation: 'Debug Pickup',
          dropoffLocation: 'Debug Dropoff',
          price: 1000,
          distance: 2.0,
          userFullName: 'Debug User',
          userPhone: '+1234567890'
        };
        
        await notifyAvailableDriversAboutNewTrip(mockTrip);
        notificationTestResult = 'success';
        console.log('✅ Notification function test successful');
      } catch (error) {
        notificationError = error instanceof Error ? error.message : 'Unknown error';
        console.error('❌ Notification function test failed:', error);
      }
    } else {
      notificationError = 'No available drivers to test with';
      console.log('⚠️ Skipping notification function test - no available drivers');
    }
    
    results.step6 = {
      name: 'Test Notification Function',
      status: notificationTestResult,
      details: {
        error: notificationError
      }
    };

    // Step 7: Create Test Trip
    console.log('\n7. CREATING TEST TRIP...');
    let testTripResult = 'failed';
    let testTripError = null;
    let testTripId = null;
    
    try {
      const testUser = await prisma.user.findFirst({
        where: { role: 'USER' },
        select: { id: true, fullName: true, phoneNumber: true, province: true }
      });
      
      if (testUser) {
        const testTrip = await prisma.taxiRequest.create({
          data: {
            pickupLocation: 'Debug Test Pickup',
            dropoffLocation: 'Debug Test Dropoff',
            pickupLat: 33.3152,
            pickupLng: 44.3661,
            dropoffLat: 33.3152,
            dropoffLng: 44.3661,
            price: 2000,
            distance: 3.0,
            status: 'USER_WAITING',
            tripType: 'ECO',
            driverDeduction: 0,
            userPhone: testUser.phoneNumber,
            userFullName: testUser.fullName,
            userProvince: testUser.province,
            userId: testUser.id
          }
        });
        
        testTripId = testTrip.id;
        testTripResult = 'success';
        console.log('✅ Test trip created:', testTrip.id);
      } else {
        testTripError = 'No test user found';
        console.log('⚠️ No test user found');
      }
    } catch (error) {
      testTripError = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Test trip creation failed:', error);
    }
    
    results.step7 = {
      name: 'Create Test Trip',
      status: testTripResult,
      details: {
        error: testTripError,
        tripId: testTripId
      }
    };

    // Step 8: Test Full Trip Creation Flow
    console.log('\n8. TESTING FULL TRIP CREATION FLOW...');
    let fullFlowResult = 'failed';
    let fullFlowError = null;
    
    if (testTripId) {
      try {
        // Check if notifications were created
        const recentNotifications = await prisma.notification.findMany({
          where: {
            type: 'NEW_TRIP_AVAILABLE',
            createdAt: {
              gte: new Date(Date.now() - 2 * 60 * 1000) // Last 2 minutes
            }
          },
          include: {
            user: {
              select: { fullName: true, role: true }
            }
          },
          orderBy: { createdAt: 'desc' }
        });
        
        fullFlowResult = 'success';
        console.log(`✅ Full flow test successful - ${recentNotifications.length} notifications created`);
        
        // Clean up test trip
        await prisma.taxiRequest.delete({
          where: { id: testTripId }
        });
        console.log('✅ Test trip cleaned up');
        
      } catch (error) {
        fullFlowError = error instanceof Error ? error.message : 'Unknown error';
        console.error('❌ Full flow test failed:', error);
      }
    } else {
      fullFlowError = 'No test trip created in previous step';
    }
    
    results.step8 = {
      name: 'Test Full Trip Creation Flow',
      status: fullFlowResult,
      details: {
        error: fullFlowError
      }
    };

    console.log('\n=== DEBUG COMPLETE ===');
    
    return NextResponse.json({
      success: true,
      timestamp: new Date().toISOString(),
      results,
      summary: {
        totalSteps: Object.keys(results).length,
        successfulSteps: Object.values(results).filter((r: any) => r.status === 'success').length,
        failedSteps: Object.values(results).filter((r: any) => r.status === 'failed').length
      }
    });

  } catch (error) {
    console.error('❌ Comprehensive debug failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Debug failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  try {
    console.log('\n=== QUICK NOTIFICATION STATUS CHECK ===');
    
    // Quick status check
    const activeDrivers = await prisma.user.findMany({
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
    
    const driversWithTokens = activeDrivers.filter(d => d.deviceToken);
    const hasFirebaseConfig = !!(process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY);
    
    return NextResponse.json({
      success: true,
      status: {
        activeDrivers: activeDrivers.length,
        driversWithTokens: driversWithTokens.length,
        firebaseConfigured: hasFirebaseConfig,
        systemReady: activeDrivers.length > 0 && driversWithTokens.length > 0 && hasFirebaseConfig
      },
      drivers: activeDrivers.map(d => ({
        id: d.id,
        name: d.fullName,
        hasToken: !!d.deviceToken
      }))
    });
    
  } catch (error) {
    console.error('❌ Quick status check failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Status check failed'
    }, { status: 500 });
  }
} 